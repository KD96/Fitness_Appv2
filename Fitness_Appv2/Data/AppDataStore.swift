import Foundation
import SwiftUI
import HealthKit

// MARK: - HealthKit Data Model

// Modelo para datos de HealthKit
struct HealthKitData: Codable {
    var stepsCount: Int = 5324
    var distance: Double = 3.7
    var activeEnergy: Double = 420
    var heartRate: Double = 72
    var restingHeartRate: Double = 62
}

// MARK: - App Data Store

class AppDataStore: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentUser: User
    @Published var socialFeed: [SocialActivity] = []
    @Published var friends: [User] = []
    @Published var suggestedUsers: [User] = []
    @Published var upcomingEvents: [FitnessEvent] = []
    @Published var pendingFriendRequests: [User] = []
    @Published var isHealthKitEnabled = false
    @Published var availableRewards: [Reward] = []
    @Published var featuredRewards: [Reward] = []
    @Published var dailyMissions: [Mission] = []
    @Published var selectedRewardCategory: Reward.Category?
    @Published var healthKitData: HealthKitData = HealthKitData()
    
    // MARK: - Private Properties
    
    // Managers
    private let healthKitManager = HealthKitManager.shared
    private let analyticsManager = AnalyticsManager.shared
    
    // Offline storage
    private let userDefaultsKey = "AppDataStore_UserData"
    private let workoutsOfflineKey = "AppDataStore_OfflineWorkouts"
    private var offlineWorkoutsQueue: [Workout] = []
    
    // Batch updates helper
    private var updateBatch = 0
    private var isPerformingBatchUpdates = false
    
    // MARK: - Initialization
    
    // Mock data for MVP
    init() {
        // Create a default user
        currentUser = User(name: "User")
        
        // Setup initial data
        setupInitialData()
        
        // Setup HealthKit
        setupHealthKit()
        
        // Load any cached data
        loadCachedData()
        
        // Start analytics session
        analyticsManager.startSession()
    }
    
    deinit {
        // End analytics session when app is closed
        analyticsManager.endSession()
    }
    
    // MARK: - Setup Methods
    
    private func setupInitialData() {
        beginBatchUpdates()
        
        // Add some sample friends
        friends = [
            User(name: "Alex", profileImage: "person.circle.fill"),
            User(name: "Jamie", profileImage: "person.circle.fill")
        ]
        
        // Add some sample social activities
        let sampleWorkout = Workout(
            id: UUID(),
            name: "Evening Run",
            type: .running,
            durationMinutes: 30,
            date: Date().addingTimeInterval(-86400), // Yesterday
            caloriesBurned: 250,
            tokensEarned: 5.0,
            notes: "Felt great!",
            distance: 3.5,
            completed: true
        )
        
        let sampleActivity = SocialActivity.createWorkoutActivity(
            user: friends.first!, 
            workout: sampleWorkout
        )
        
        socialFeed = [sampleActivity]
        
        // Create sample suggested users with similar interests
        suggestedUsers = [
            User(name: "Emma Wilson", profileImage: "person.circle.fill"),
            User(name: "Michael Brown", profileImage: "person.circle.fill"),
            User(name: "Sophie Chen", profileImage: "person.circle.fill")
        ]
        
        // Create sample upcoming events
        upcomingEvents = [
            FitnessEvent(
                name: "5K Group Run",
                description: "Join us for a friendly 5K run in the park. All levels welcome!",
                eventType: .running,
                date: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
                duration: 60,
                location: "Central Park",
                isVirtual: false,
                maxParticipants: 20,
                creatorId: friends.first!.id,
                imageIcon: "figure.run"
            ),
            FitnessEvent(
                name: "Strength Training Workshop",
                description: "Learn proper form and techniques for effective strength training.",
                eventType: .strength,
                date: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
                duration: 90,
                location: "Virtual Zoom Session",
                isVirtual: true,
                maxParticipants: 15,
                creatorId: currentUser.id,
                imageIcon: "dumbbell.fill"
            )
        ]
        
        // Inicializar recompensas y misiones
        setupRewardsAndMissions()
        
        endBatchUpdates()
    }
    
    // MARK: - Batch Updates Management
    
    private func beginBatchUpdates() {
        updateBatch += 1
        isPerformingBatchUpdates = true
    }
    
    private func endBatchUpdates() {
        updateBatch -= 1
        if updateBatch == 0 {
            isPerformingBatchUpdates = false
            // Trigger a single update when batch completes
            objectWillChange.send()
        }
    }
    
    // MARK: - Offline Support
    
    private func loadCachedData() {
        // Batch data loading to minimize UI updates
        beginBatchUpdates()
        
        // Load user data from UserDefaults
        if let userData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
        }
        
        // Load offline workouts queue
        if let workoutsData = UserDefaults.standard.data(forKey: workoutsOfflineKey),
           let workouts = try? JSONDecoder().decode([Workout].self, from: workoutsData) {
            self.offlineWorkoutsQueue = workouts
            
            // Process any offline workouts
            processOfflineWorkouts()
        }
        
        endBatchUpdates()
    }
    
    private func saveUserToCache() {
        if let userData = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(userData, forKey: userDefaultsKey)
        }
    }
    
    private func saveOfflineWorkout(_ workout: Workout) {
        // Add to offline queue
        offlineWorkoutsQueue.append(workout)
        
        // Save to UserDefaults
        if let workoutsData = try? JSONEncoder().encode(offlineWorkoutsQueue) {
            UserDefaults.standard.set(workoutsData, forKey: workoutsOfflineKey)
        }
    }
    
    private func processOfflineWorkouts() {
        // In a real app, this would sync with a server when online
        for workout in offlineWorkoutsQueue {
            // Add workout to user's completed workouts if not already there
            if !currentUser.completedWorkouts.contains(where: { $0.id == workout.id }) {
                addWorkoutToUser(workout)
            }
        }
        
        // Clear the queue after processing
        offlineWorkoutsQueue.removeAll()
        UserDefaults.standard.removeObject(forKey: workoutsOfflineKey)
    }
    
    // MARK: - User & Workout Management
    
    func updateUser(_ user: User) {
        self.currentUser = user
        saveUserToCache()
    }
    
    func addWorkout(_ workout: Workout) {
        var workoutToAdd = workout
        workoutToAdd.completed = true
        
        // Add workout to user
        addWorkoutToUser(workoutToAdd)
        
        // Save to offline queue for syncing later
        saveOfflineWorkout(workoutToAdd)
        
        // Track analytics
        analyticsManager.trackWorkoutCompleted(type: workout.type.rawValue, durationMinutes: workout.durationMinutes)
    }
    
    private func addWorkoutToUser(_ workout: Workout) {
        // Update user with workout
        currentUser.completeWorkout(workout)
        
        // Save changes
        saveUserToCache()
    }
    
    // Reset user data (for testing and logout)
    func resetUserData() {
        currentUser = User(name: "User")
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        analyticsManager.trackEvent(eventName: "user_reset")
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
            discountPercentage: 10,
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
            isFeatured: true
        ))
        
        // Recompensas de Bienestar
        availableRewards.append(Reward(
            title: "Meditation App",
            description: "2 weeks free premium meditation content",
            partnerName: "ZenMind",
            partnerLogo: "brain.head.profile",
            tokenCost: 18,
            category: .wellness,
            isFeatured: true
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
                workoutTypes: [.running, .cycling]
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
    
    // MARK: - Métodos para Misiones
    
    func completeMission(_ mission: Mission) {
        if let index = dailyMissions.firstIndex(where: { $0.id == mission.id }) {
            dailyMissions[index].isCompleted = true
            
            // Actualizar tokens y XP del usuario
            currentUser.tokenBalance += mission.rewardTokens
            currentUser.experiencePoints += mission.experiencePoints
            
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
                    shouldComplete = Double(workout.durationMinutes) >= mission.targetValue
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
    
    // Métodos para filtrar datos
    private func workoutsInLastDays(_ days: Int) -> [Workout] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        return currentUser.completedWorkouts.filter { $0.date >= startDate }
    }
    
    // MARK: - Analytics Support
    
    func trackScreenView(screenName: String) {
        analyticsManager.trackScreenView(screenName: screenName)
    }
    
    func trackEvent(eventName: String, parameters: [String: Any] = [:]) {
        // Call the simpler method that doesn't take parameters
        analyticsManager.trackEvent(eventName: eventName)
        
        // Log parameters for debugging (since the existing AnalyticsManager doesn't support parameters)
        if !parameters.isEmpty {
            print("Event parameters (not tracked by AnalyticsManager): \(parameters)")
        }
    }
    
    func trackFeatureUsed(featureName: String) {
        analyticsManager.trackFeatureUsed(featureName: featureName)
    }
    
    func getAnalyticsReport() -> [String: Any] {
        return analyticsManager.getAnalyticsReport()
    }
    
    // Get most popular workout type
    var mostPopularWorkoutType: String? {
        return analyticsManager.getMostPopularWorkoutType()
    }
    
    // MARK: - Chart Data
    
    // Estructura para datos de gráficos
    struct ChartData: Identifiable {
        var id = UUID()
        var label: String
        var value: Double
    }
    
    // Obtener datos para el gráfico según el periodo seleccionado
    func getWorkoutDataForChart(timeFrame: UserStatsView.TimeFrame) -> [ChartData] {
        // Datos de ejemplo para diferentes periodos
        switch timeFrame {
        case .week:
            return [
                ChartData(label: "Mon", value: 2),
                ChartData(label: "Tue", value: 1),
                ChartData(label: "Wed", value: 3),
                ChartData(label: "Thu", value: 0),
                ChartData(label: "Fri", value: 2),
                ChartData(label: "Sat", value: 1),
                ChartData(label: "Sun", value: 0)
            ]
        case .month:
            return [
                ChartData(label: "W1", value: 5),
                ChartData(label: "W2", value: 8),
                ChartData(label: "W3", value: 6),
                ChartData(label: "W4", value: 7)
            ]
        case .year:
            return [
                ChartData(label: "Jan", value: 20),
                ChartData(label: "Feb", value: 18),
                ChartData(label: "Mar", value: 25),
                ChartData(label: "Apr", value: 22),
                ChartData(label: "May", value: 28),
                ChartData(label: "Jun", value: 30),
                ChartData(label: "Jul", value: 32),
                ChartData(label: "Aug", value: 35),
                ChartData(label: "Sep", value: 28),
                ChartData(label: "Oct", value: 25),
                ChartData(label: "Nov", value: 22),
                ChartData(label: "Dec", value: 20)
            ]
        }
    }
    
    // Obtener el valor máximo para la escala del gráfico
    func getMaxChartValue(timeFrame: UserStatsView.TimeFrame) -> Double {
        let data = getWorkoutDataForChart(timeFrame: timeFrame)
        if let maxValue = data.map({ $0.value }).max() {
            // Añadir un 20% extra para espacio en la parte superior
            return maxValue * 1.2
        }
        return 10.0 // Valor predeterminado si no hay datos
    }
    
    // MARK: - Social Connection Methods
    
    // Get suggested users based on similar interests
    func getSuggestedUsersWithSimilarInterests() -> [User] {
        // In a real app, this would query a database of users with similar interests
        // For the MVP, we'll return our sample data
        return suggestedUsers
    }
    
    // Send a friend request to another user
    func sendFriendRequest(to user: User) {
        // Update current user
        currentUser.sendFriendRequest(to: user.id)
        
        // In a real app, this would also create a notification for the recipient
        
        // Create a pending request for the recipient (would be handled server-side in a real app)
        // This is just for demo purposes in the MVP
        var recipientUser = user
        recipientUser.pendingFriendRequests.append(currentUser.id)
        
        // Update the suggested users list if the user is in it
        if let index = suggestedUsers.firstIndex(where: { $0.id == user.id }) {
            suggestedUsers[index] = recipientUser
        }
        
        // Save changes
        saveData()
    }
    
    // Accept a friend request
    func acceptFriendRequest(from user: User) {
        // Update current user
        currentUser.acceptFriendRequest(from: user.id)
        
        // Add to friends list
        if !friends.contains(where: { $0.id == user.id }) {
            friends.append(user)
        }
        
        // Remove from pending requests
        pendingFriendRequests.removeAll(where: { $0.id == user.id })
        
        // Create social activity
        let friendActivity = SocialActivity.createFriendsActivity(user: currentUser, friend: user)
        socialFeed.insert(friendActivity, at: 0)
        
        // Save changes
        saveData()
    }
    
    // Decline a friend request
    func declineFriendRequest(from user: User) {
        // Update current user
        currentUser.declineFriendRequest(from: user.id)
        
        // Remove from pending requests
        pendingFriendRequests.removeAll(where: { $0.id == user.id })
        
        // Save changes
        saveData()
    }
    
    // Create a new event
    func createEvent(_ event: FitnessEvent) {
        // Add to upcoming events
        upcomingEvents.append(event)
        
        // Save changes
        saveData()
    }
    
    // Join an event
    func joinEvent(_ event: FitnessEvent) {
        // Find the event
        if let index = upcomingEvents.firstIndex(where: { $0.id == event.id }) {
            // Update the event with the new participant
            var updatedEvent = event
            updatedEvent.participants.append(currentUser.id)
            upcomingEvents[index] = updatedEvent
            
            // Update user
            currentUser.joinEvent(event.id)
            
            // Create social activity
            let eventActivity = SocialActivity.createJoinedEventActivity(
                user: currentUser,
                eventId: event.id,
                eventName: event.name
            )
            socialFeed.insert(eventActivity, at: 0)
            
            // Save changes
            saveData()
        }
    }
    
    // Leave an event
    func leaveEvent(_ event: FitnessEvent) {
        // Find the event
        if let index = upcomingEvents.firstIndex(where: { $0.id == event.id }) {
            // Update the event by removing the participant
            var updatedEvent = event
            updatedEvent.participants.removeAll(where: { $0 == currentUser.id })
            upcomingEvents[index] = updatedEvent
            
            // Update user
            currentUser.leaveEvent(event.id)
            
            // Save changes
            saveData()
        }
    }
    
    // Get upcoming events the user has joined
    func getUserEvents() -> [FitnessEvent] {
        return upcomingEvents.filter { event in
            return currentUser.connectedEvents.contains(event.id)
        }
    }
    
    // Get user's pending friend requests
    func getPendingFriendRequests() -> [User] {
        // In a real app, this would query users whose IDs are in currentUser.pendingFriendRequests
        // For the MVP, we'll just use our sample users and filter based on IDs
        return pendingFriendRequests
    }
    
    // Track analytics for social activities
    func trackSocialActivity(type: String) {
        // Using our own trackEvent method instead of calling analyticsManager directly
        // This method properly handles the parameters
        trackEvent(eventName: "social_activity", parameters: ["type": type])
    }
}

// MARK: - Estadísticas del Usuario

extension AppDataStore {
    // Propiedades computadas para estadísticas
    var totalWorkoutsCompleted: Int {
        return currentUser.completedWorkouts.count
    }
    
    var weeklyWorkoutCount: Int {
        return workoutsInLastDays(7).count
    }
    
    var totalMinutesExercised: Int {
        return currentUser.completedWorkouts.reduce(0) { $0 + $1.durationMinutes }
    }
    
    var weeklyMinutesExercised: Int {
        return workoutsInLastDays(7).reduce(0) { $0 + $1.durationMinutes }
    }
    
    var totalCaloriesBurned: Double {
        return currentUser.completedWorkouts.reduce(0) { $0 + $1.caloriesBurned }
    }
    
    var weeklyCaloriesBurned: Double {
        return workoutsInLastDays(7).reduce(0) { $0 + $1.caloriesBurned }
    }
    
    var weeklyTokensEarned: Double {
        return workoutsInLastDays(7).reduce(0) { $0 + $1.tokensEarned }
    }
    
    // Para gráficos y HealthKit
    var isHealthKitAuthorized: Bool {
        return isHealthKitEnabled
    }
} 