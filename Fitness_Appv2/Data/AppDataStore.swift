import Foundation
import SwiftUI
import HealthKit

class AppDataStore: ObservableObject {
    @Published var currentUser: User
    @Published var socialFeed: [SocialActivity] = []
    @Published var friends: [User] = []
    @Published var isHealthKitEnabled = false
    
    // Nuevas propiedades para recompensas y gamificación
    @Published var availableRewards: [Reward] = []
    @Published var featuredRewards: [Reward] = []
    @Published var dailyMissions: [Mission] = []
    @Published var selectedRewardCategory: Reward.Category?
    
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
        
        // Inicializar recompensas y misiones
        setupRewardsAndMissions()
        
        // Setup HealthKit
        setupHealthKit()
    }
    
    // MARK: - Configuración de Recompensas y Misiones
    
    private func setupRewardsAndMissions() {
        // Generar recompensas de muestra
        generateSampleRewards()
        
        // Establecer recompensas destacadas
        featuredRewards = availableRewards.filter { $0.isFeatured }
        
        // Generar misiones diarias
        generateDailyMissions()
    }
    
    private func generateSampleRewards() {
        // Recompensas de Crypto
        availableRewards.append(Reward(
            title: "10 PURE to Crypto",
            description: "Convert your PURE tokens to cryptocurrency",
            partnerName: "PureLife Crypto",
            partnerLogo: "bitcoinsign.circle.fill",
            tokenCost: 10,
            category: .crypto,
            isFeatured: true,
            isNew: true
        ))
        
        availableRewards.append(Reward(
            title: "50 PURE to Crypto",
            description: "Convert your PURE tokens to cryptocurrency with bonus",
            partnerName: "PureLife Crypto",
            partnerLogo: "bitcoinsign.circle.fill",
            tokenCost: 50,
            category: .crypto
        ))
        
        // Recompensas de Fitness
        availableRewards.append(Reward(
            title: "Running Shoes Discount",
            description: "Get 15% off on premium running shoes",
            partnerName: "SportGear",
            partnerLogo: "shoe.circle",
            tokenCost: 25,
            discountPercentage: 15,
            category: .fitness,
            isFeatured: true
        ))
        
        availableRewards.append(Reward(
            title: "Gym Membership",
            description: "$10 off your next monthly membership",
            partnerName: "FitGym",
            partnerLogo: "dumbbell.fill",
            tokenCost: 20,
            discountAmount: 10,
            category: .fitness
        ))
        
        // Recompensas de Nutrición
        availableRewards.append(Reward(
            title: "Protein Shake Discount",
            description: "20% off premium protein shakes",
            partnerName: "NutriLife",
            partnerLogo: "leaf.circle.fill",
            tokenCost: 15,
            discountPercentage: 20,
            category: .nutrition
        ))
        
        availableRewards.append(Reward(
            title: "Meal Planning App",
            description: "1 month free premium subscription",
            partnerName: "MealPro",
            partnerLogo: "fork.knife.circle.fill",
            tokenCost: 30,
            category: .nutrition,
            isNew: true
        ))
        
        // Recompensas de Bienestar
        availableRewards.append(Reward(
            title: "Meditation App",
            description: "2 weeks free premium meditation content",
            partnerName: "ZenMind",
            partnerLogo: "brain.head.profile",
            tokenCost: 18,
            category: .wellness
        ))
        
        // Recompensas de Experiencias
        availableRewards.append(Reward(
            title: "Adventure Park Pass",
            description: "25% off day pass to Adventure World",
            partnerName: "Adventure World",
            partnerLogo: "map.circle.fill",
            tokenCost: 40,
            discountPercentage: 25,
            category: .experiences,
            isFeatured: true
        ))
        
        // Recompensas de Tecnología
        availableRewards.append(Reward(
            title: "Fitness Tracker",
            description: "$25 off latest model fitness tracker",
            partnerName: "TechFit",
            partnerLogo: "applewatch.circle.fill",
            tokenCost: 35,
            discountAmount: 25,
            category: .technology
        ))
    }
    
    private func generateDailyMissions() {
        dailyMissions = [
            Mission(
                title: "Morning Workout",
                description: "Complete a workout before 10 AM",
                rewardTokens: 5,
                experiencePoints: 50,
                type: .daily,
                requirementType: .timeOfDay,
                targetValue: 10
            ),
            Mission(
                title: "Cardio Master",
                description: "Complete 20 minutes of cardio",
                rewardTokens: 3,
                experiencePoints: 30,
                type: .daily,
                requirementType: .duration,
                targetValue: 20,
                workoutTypes: [.running, .cycling, .swimming]
            ),
            Mission(
                title: "Step Goal",
                description: "Reach 8,000 steps today",
                rewardTokens: 4,
                experiencePoints: 40,
                type: .daily,
                requirementType: .steps,
                targetValue: 8000
            )
        ]
    }
    
    // MARK: - Métodos para Recompensas
    
    func getRewardsForCategory(_ category: Reward.Category) -> [Reward] {
        return availableRewards.filter { $0.category == category }
    }
    
    func purchaseReward(_ reward: Reward) -> Bool {
        if currentUser.purchaseReward(reward) {
            saveData()
            return true
        }
        return false
    }
    
    func convertTokensToCrypto(amount: Double, to cryptoType: CryptoWallet.CryptoType = .bitcoin) -> Bool {
        if currentUser.convertTokensToCrypto(amount: amount, to: cryptoType) {
            saveData()
            return true
        }
        return false
    }
    
    // MARK: - Métodos para Misiones
    
    func completeMission(_ mission: Mission) {
        if let index = dailyMissions.firstIndex(where: { $0.id == mission.id }) {
            dailyMissions[index].isCompleted = true
            
            // Actualizar tokens y XP del usuario
            currentUser.tokenBalance += mission.rewardTokens
            currentUser.experiencePoints += mission.experiencePoints
            
            // Registrar la transacción
            currentUser.cryptoWallet.addTransaction(
                amount: mission.rewardTokens,
                type: .received,
                description: "Completed mission: \(mission.title)"
            )
            
            saveData()
        }
    }
    
    // MARK: - Métodos de HealthKit
    
    // Setup HealthKit
    func setupHealthKit() {
        // Solo comprobamos si está disponible, sin solicitar permisos automáticamente
        if healthKitManager.isHealthDataAvailable() {
            // Comprobar si ya tenemos autorización
            if UserDefaults.standard.bool(forKey: "healthKitPreviouslyAuthorized") {
                healthKitManager.requestAuthorization { success in
                    self.isHealthKitEnabled = success
                }
            }
        }
    }
    
    // Request HealthKit authorization
    func requestHealthKitAuthorization(completion: @escaping (Bool) -> Void = {_ in }) {
        healthKitManager.requestAuthorization { success in
            DispatchQueue.main.async {
                self.isHealthKitEnabled = success
                if success {
                    UserDefaults.standard.set(true, forKey: "healthKitPreviouslyAuthorized")
                }
                completion(success)
            }
        }
    }
    
    // MARK: - User Workout Methods
    
    // Save new workout and update user stats
    func saveWorkout(_ workout: Workout) {
        var updatedWorkout = workout
        updatedWorkout.completed = true
        
        // Update user with the workout
        currentUser.completeWorkout(updatedWorkout)
        
        // Add to social feed
        let activity = SocialActivity.createWorkoutActivity(user: currentUser, workout: updatedWorkout)
        socialFeed.insert(activity, at: 0)
        
        // Check for mission completion
        checkMissionCompletion(with: updatedWorkout)
        
        // Save data
        saveData()
    }
    
    private func checkMissionCompletion(with workout: Workout) {
        for (index, mission) in dailyMissions.enumerated() {
            if mission.isCompleted {
                continue
            }
            
            var shouldComplete = false
            
            switch mission.requirementType {
            case .duration:
                if mission.workoutTypes.isEmpty || mission.workoutTypes.contains(workout.type) {
                    shouldComplete = workout.duration / 60 >= mission.targetValue
                }
                
            case .timeOfDay:
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: workout.date)
                shouldComplete = hour < Int(mission.targetValue)
                
            case .steps:
                // Steps require HealthKit data, handled separately
                continue
                
            case .workoutType:
                shouldComplete = mission.workoutTypes.contains(workout.type)
            }
            
            if shouldComplete {
                dailyMissions[index].isCompleted = true
                
                // Award tokens and XP
                currentUser.tokenBalance += mission.rewardTokens
                currentUser.experiencePoints += mission.experiencePoints
                
                // Register transaction
                currentUser.cryptoWallet.addTransaction(
                    amount: mission.rewardTokens,
                    type: .received,
                    description: "Completed mission: \(mission.title)"
                )
            }
        }
    }
    
    // MARK: - Data Persistence
    
    func saveData() {
        // Simple UserDefaults persistence for MVP
        if let encoded = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
        
        if let encoded = try? JSONEncoder().encode(socialFeed) {
            UserDefaults.standard.set(encoded, forKey: "socialFeed")
        }
        
        if let encoded = try? JSONEncoder().encode(dailyMissions) {
            UserDefaults.standard.set(encoded, forKey: "dailyMissions")
        }
    }
    
    func loadData() {
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let decodedUser = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = decodedUser
        }
        
        if let feedData = UserDefaults.standard.data(forKey: "socialFeed"),
           let decodedFeed = try? JSONDecoder().decode([SocialActivity].self, from: feedData) {
            socialFeed = decodedFeed
        }
        
        if let missionsData = UserDefaults.standard.data(forKey: "dailyMissions"),
           let decodedMissions = try? JSONDecoder().decode([Mission].self, from: missionsData) {
            // Solo cargar misiones si son de hoy, de lo contrario regenerarlas
            if isToday(decodedMissions.first?.expiryDate ?? Date(timeIntervalSince1970: 0)) {
                dailyMissions = decodedMissions
            } else {
                generateDailyMissions()
            }
        }
    }
    
    private func isToday(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(date)
    }
} 