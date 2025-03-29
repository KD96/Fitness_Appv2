import Foundation
import HealthKit
import SwiftUI

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    private let workoutTypes: [HKWorkoutActivityType] = [
        .running,
        .walking,
        .cycling,
        .swimming,
        .traditionalStrengthTraining,
        .yoga,
        .highIntensityIntervalTraining
    ]
    
    @Published var isAuthorized = false
    @Published var recentWorkouts: [Workout] = []
    @Published var weeklyActivityLevels: [Double] = Array(repeating: 0.0, count: 7)
    @Published var totalSteps: Int = 0
    @Published var activeCalories: Double = 0
    
    private init() {}
    
    // Comprobar si HealthKit está disponible
    func isHealthDataAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    // Solicitar autorización para acceder a datos de salud
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        // Definir los tipos de datos a los que queremos acceder
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        // Solicitar autorización
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            DispatchQueue.main.async {
                self.isAuthorized = success
                completion(success)
                
                if success {
                    self.fetchAllHealthData()
                }
            }
        }
    }
    
    // Cargar todos los datos de salud
    func fetchAllHealthData() {
        fetchRecentWorkouts()
        fetchWeeklyActivity()
        fetchTotalStepsToday()
        fetchActiveCaloriesToday()
    }
    
    // Cargar entrenamientos recientes desde HealthKit
    func fetchRecentWorkouts() {
        // Definir un predicado para obtener workouts de los últimos 30 días
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: endDate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        // Ordenar por fecha más reciente
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        // Crear y ejecutar la consulta
        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: predicate, limit: 20, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            
            DispatchQueue.main.async {
                guard let workouts = samples as? [HKWorkout], error == nil else {
                    print("Error fetching workouts: \(String(describing: error))")
                    return
                }
                
                self.recentWorkouts = workouts.compactMap { hkWorkout in
                    // Convertir HKWorkout a nuestro modelo Workout
                    let workoutType = self.mapHKWorkoutTypeToWorkoutType(hkWorkout.workoutActivityType)
                    let duration = hkWorkout.duration
                    let date = hkWorkout.endDate
                    
                    // Get calories using the recommended approach for iOS 18+
                    var calories: Double = 0
                    if #available(iOS 18.0, *) {
                        // iOS 18 y superior: usar el método recomendado
                        if let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
                           let statistics = hkWorkout.statistics(for: activeEnergyType),
                           let caloriesQuantity = statistics.sumQuantity() {
                            calories = caloriesQuantity.doubleValue(for: .kilocalorie())
                        }
                    } else {
                        // iOS anterior: usar el método obsoleto
                        calories = hkWorkout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0
                    }
                    
                    // Validar los valores para evitar NaN
                    if duration.isNaN || duration.isInfinite || duration <= 0 {
                        return nil // Ignorar este workout
                    }
                    
                    if calories.isNaN || calories.isInfinite {
                        // Si las calorías no son válidas, usar un valor predeterminado
                        return Workout(
                            id: UUID(),
                            name: "Workout from HealthKit",
                            type: workoutType,
                            durationMinutes: Int(duration / 60),
                            date: date,
                            caloriesBurned: 0,
                            tokensEarned: 0,
                            distance: nil,
                            completed: true
                        )
                    }
                    
                    return Workout(
                        id: UUID(),
                        name: "Workout from HealthKit",
                        type: workoutType,
                        durationMinutes: Int(duration / 60),
                        date: date,
                        caloriesBurned: calories,
                        tokensEarned: calories / 50, // Una regla simple: 1 token por cada 50 calorías
                        distance: hkWorkout.totalDistance?.doubleValue(for: .meter()) ?? nil,
                        completed: true
                    )
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // Cargar datos de actividad semanal
    func fetchWeeklyActivity() {
        let calendar = Calendar.current
        let endDate = Date()
        _ = calendar.date(byAdding: .day, value: -6, to: endDate)!
        
        var weekDays: [Date] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: endDate) {
                weekDays.append(date)
            }
        }
        
        // Grupo de disparo para esperar a que se completen todas las consultas
        let dispatchGroup = DispatchGroup()
        
        var dailyStepCounts: [Date: Double] = [:]
        
        for day in weekDays {
            dispatchGroup.enter()
            
            // Obtener el comienzo y el final del día
            let startOfDay = calendar.startOfDay(for: day)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
            
            let query = HKStatisticsQuery(quantityType: HKQuantityType.quantityType(forIdentifier: .stepCount)!, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
                
                defer {
                    dispatchGroup.leave()
                }
                
                guard let result = result, let sum = result.sumQuantity() else {
                    dailyStepCounts[day] = 0
                    return
                }
                
                // Guardar el recuento de pasos para este día
                dailyStepCounts[day] = sum.doubleValue(for: HKUnit.count())
            }
            
            healthStore.execute(query)
        }
        
        // Cuando todas las consultas se completen, normalizar y actualizar weeklyActivityLevels
        dispatchGroup.notify(queue: .main) {
            // Ordenar las fechas más recientes primero
            let sortedDays = weekDays.sorted(by: { $0 > $1 })
            
            // Encontrar el valor máximo para normalizar
            _ = dailyStepCounts.values.max() ?? 10000
            
            // Normalizar los valores entre 0 y 1
            self.weeklyActivityLevels = sortedDays.map { day in
                let steps = dailyStepCounts[day] ?? 0
                let normalizedValue = min(steps / 10000, 1.0) // Normalizar con un objetivo de 10000 pasos
                
                // Protección contra valores NaN o infinitos
                if normalizedValue.isNaN || normalizedValue.isInfinite {
                    return 0.0
                }
                return normalizedValue
            }
        }
    }
    
    // Obtener el total de pasos de hoy
    func fetchTotalStepsToday() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: HKQuantityType.quantityType(forIdentifier: .stepCount)!, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async {
                    self.totalSteps = 0
                }
                return
            }
            
            DispatchQueue.main.async {
                let stepValue = sum.doubleValue(for: HKUnit.count())
                // Protección contra valores NaN o valores negativos
                if stepValue.isNaN || stepValue.isInfinite || stepValue < 0 {
                    self.totalSteps = 0
                } else {
                    self.totalSteps = Int(stepValue)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // Obtener las calorías activas de hoy
    func fetchActiveCaloriesToday() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async {
                    self.activeCalories = 0
                }
                return
            }
            
            DispatchQueue.main.async {
                let caloriesValue = sum.doubleValue(for: HKUnit.kilocalorie())
                // Protección contra valores NaN o valores negativos
                if caloriesValue.isNaN || caloriesValue.isInfinite || caloriesValue < 0 {
                    self.activeCalories = 0
                } else {
                    self.activeCalories = caloriesValue
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // Convertir tipos de entrenamiento de HealthKit a nuestros tipos
    private func mapHKWorkoutTypeToWorkoutType(_ hkType: HKWorkoutActivityType) -> WorkoutType {
        switch hkType {
        case .running:
            return .running
        case .walking:
            return .walking
        case .cycling:
            return .cycling
        case .swimming:
            return .swimming
        case .traditionalStrengthTraining:
            return .strength
        case .yoga:
            return .yoga
        case .highIntensityIntervalTraining:
            return .hiit
        default:
            return .other
        }
    }
} 