import Foundation
import SwiftUI
import HealthKit

class AppDataStore: ObservableObject {
    @Published var currentUser: User
    @Published var socialFeed: [SocialActivity] = []
    @Published var friends: [User] = []
    @Published var isHealthKitEnabled = false
    
    // HealthKit manager
    private let healthKitManager = HealthKitManager.shared
    
    // Mock data for MVP
    init() {
        // Create a default user
        currentUser = User(name: "User")
        
        // Add some sample friends
        friends = [
            User(name: "Alex", profileImage: "person.circle.fill"),
            User(name: "Jamie", profileImage: "person.circle.fill"),
            User(name: "Taylor", profileImage: "person.circle.fill")
        ]
        
        // Add some sample social activities
        let sampleWorkout = Workout(
            type: .running,
            duration: 1800, // 30 minutes
            date: Date().addingTimeInterval(-86400), // Yesterday
            calories: 250
        )
        
        let sampleActivity = SocialActivity.createWorkoutActivity(
            user: friends[0], 
            workout: sampleWorkout
        )
        
        socialFeed = [sampleActivity]
        
        // Setup HealthKit
        setupHealthKit()
    }
    
    // Setup HealthKit
    func setupHealthKit() {
        // Solo comprobamos si está disponible, sin solicitar permisos automáticamente
        if healthKitManager.isHealthDataAvailable() {
            // Comprobar si ya tenemos autorización
            if UserDefaults.standard.bool(forKey: "healthKitPreviouslyAuthorized") {
                healthKitManager.requestAuthorization { success in
                    DispatchQueue.main.async {
                        self.isHealthKitEnabled = success
                        
                        if success {
                            // Si se autoriza, sincronizar los datos de salud con nuestra app
                            self.syncHealthKitData()
                        }
                    }
                }
            }
        }
    }
    
    // Iniciar el proceso de autorización (llamado desde la vista de autenticación)
    func requestHealthKitAuthorization(completion: @escaping (Bool) -> Void) {
        if healthKitManager.isHealthDataAvailable() {
            healthKitManager.requestAuthorization { success in
                DispatchQueue.main.async {
                    self.isHealthKitEnabled = success
                    
                    if success {
                        // Guardar que ya hemos autorizado para futuras sesiones
                        UserDefaults.standard.set(true, forKey: "healthKitPreviouslyAuthorized")
                        
                        // Sincronizar datos
                        self.syncHealthKitData()
                    }
                    
                    completion(success)
                }
            }
        } else {
            completion(false)
        }
    }
    
    // Sincronizar datos de HealthKit
    func syncHealthKitData() {
        // Actualizar gráfico de actividad semanal
        self.importWeeklyActivity()
        
        // Importar entrenamientos recientes
        self.importWorkouts()
    }
    
    // Importar datos de actividad semanal desde HealthKit
    func importWeeklyActivity() {
        // Los niveles de actividad ya se han cargado en el HealthKitManager
    }
    
    // Importar entrenamientos desde HealthKit
    func importWorkouts() {
        // Si hay entrenamientos de HealthKit, los agregamos a los del usuario
        if !healthKitManager.recentWorkouts.isEmpty {
            // Crear un conjunto de IDs de entrenamientos existentes para evitar duplicados
            let existingIds = Set(currentUser.completedWorkouts.map { $0.id })
            
            // Agregar solo los entrenamientos que no existen ya
            for workout in healthKitManager.recentWorkouts {
                if !existingIds.contains(workout.id) {
                    currentUser.completeWorkout(workout)
                    
                    // Crear actividad social
                    let activity = SocialActivity.createWorkoutActivity(
                        user: currentUser,
                        workout: workout
                    )
                    
                    // Agregar a feed
                    socialFeed.insert(activity, at: 0)
                }
            }
            
            // Guardar los datos
            saveData()
        }
    }
    
    // Complete a workout and update everything
    func completeWorkout(_ workout: Workout) {
        // Update user data
        currentUser.completeWorkout(workout)
        
        // Create social activity
        let activity = SocialActivity.createWorkoutActivity(
            user: currentUser,
            workout: workout
        )
        
        // Add to feed
        socialFeed.insert(activity, at: 0)
        
        // Save data (would use persistence in a full implementation)
        saveData()
    }
    
    // Simple save to UserDefaults for MVP
    private func saveData() {
        if let encodedUser = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(encodedUser, forKey: "currentUser")
        }
        
        if let encodedFeed = try? JSONEncoder().encode(socialFeed) {
            UserDefaults.standard.set(encodedFeed, forKey: "socialFeed")
        }
    }
    
    // Load data from UserDefaults
    func loadData() {
        if let savedUser = UserDefaults.standard.data(forKey: "currentUser"),
           let decodedUser = try? JSONDecoder().decode(User.self, from: savedUser) {
            currentUser = decodedUser
        }
        
        if let savedFeed = UserDefaults.standard.data(forKey: "socialFeed"),
           let decodedFeed = try? JSONDecoder().decode([SocialActivity].self, from: savedFeed) {
            socialFeed = decodedFeed
        }
        
        // Sincronizar con HealthKit después de cargar datos locales
        if isHealthKitEnabled {
            syncHealthKitData()
        }
    }
    
    // Refrescar los datos de salud
    func refreshHealthData() {
        if isHealthKitEnabled {
            healthKitManager.fetchAllHealthData()
            syncHealthKitData()
        }
    }
} 