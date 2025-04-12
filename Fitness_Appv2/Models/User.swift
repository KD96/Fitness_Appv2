import Foundation
import SwiftUI

// User level structure to represent user's experience level
enum FitnessUserLevel: Int, Codable {
    case beginner = 1
    case intermediate = 2
    case advanced = 3
    case expert = 4
    case master = 5
    
    var name: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .expert: return "Expert"
        case .master: return "Master"
        }
    }
    
    // Add level property that returns the raw value
    var level: Int {
        return self.rawValue
    }
    
    // Add title property for display in UI
    var title: String {
        return "Level \(self.rawValue): \(self.name)"
    }
    
    // Calculate current level based on XP points
    static func getCurrentLevel(points: Int) -> FitnessUserLevel {
        switch points {
        case 0..<1000:
            return .beginner
        case 1000..<3000:
            return .intermediate
        case 3000..<6000:
            return .advanced
        case 6000..<10000:
            return .expert
        default:
            return .master
        }
    }
    
    // Calculate progress percentage to next level
    static func getProgressToNextLevel(points: Int) -> Double {
        let level = getCurrentLevel(points: points)
        
        // If already at max level, return 100%
        if level == .master {
            return 1.0
        }
        
        let nextLevelPoints: Int
        let currentLevelMinPoints: Int
        
        switch level {
        case .beginner:
            currentLevelMinPoints = 0
            nextLevelPoints = 1000
        case .intermediate:
            currentLevelMinPoints = 1000
            nextLevelPoints = 3000
        case .advanced:
            currentLevelMinPoints = 3000
            nextLevelPoints = 6000
        case .expert:
            currentLevelMinPoints = 6000
            nextLevelPoints = 10000
        case .master:
            return 1.0 // Should not reach here
        }
        
        let pointsInCurrentLevel = points - currentLevelMinPoints
        let pointsRequiredForNextLevel = nextLevelPoints - currentLevelMinPoints
        
        return Double(pointsInCurrentLevel) / Double(pointsRequiredForNextLevel)
    }
}

struct User: Identifiable, Codable {
    var id = UUID()
    var name: String
    var profileImage: String? // URL or system image name
    var tokenBalance: Double = 0.0
    var friends: [UUID] = []
    var workoutStreak: Int = 0
    var completedWorkouts: [Workout] = []
    
    // Simplified fields for MVP
    var experiencePoints: Int = 0
    var purchasedRewards: [Reward] = []
    var userPreferences = UserPreferences()
    var joinDate = Date()
    
    // New social connection properties
    var pendingFriendRequests: [UUID] = []
    var sentFriendRequests: [UUID] = []
    var connectedEvents: [UUID] = [] // IDs of events the user has joined
    var bio: String = ""
    var socialPrivacySettings = SocialPrivacySettings()
    
    // Propiedad computada para obtener el primer nombre
    var firstName: String {
        return name.components(separatedBy: " ").first ?? name
    }
    
    // Add token reward to user balance
    mutating func addTokens(_ amount: Double) {
        tokenBalance += amount
    }
    
    // Add a completed workout and update tokens
    mutating func completeWorkout(_ workout: Workout) {
        // Añadir el entrenamiento a la lista de completados
        completedWorkouts.append(workout)
        
        // Actualizar racha de entrenamientos (lógica simplificada)
        workoutStreak += 1
        
        // Calculate token reward based on duration
        let baseTokens = workout.tokensEarned
        
        // Añadir tokens a balance
        tokenBalance += baseTokens
        
        // Añadir puntos de experiencia (XP)
        // 10 XP por minuto de ejercicio
        let xpEarned = workout.durationMinutes * 10
        experiencePoints += xpEarned
    }
    
    // Obtener el nivel actual
    var currentLevel: FitnessUserLevel {
        return FitnessUserLevel.getCurrentLevel(points: experiencePoints)
    }
    
    // Calcular progreso hacia el siguiente nivel
    var progressToNextLevel: Double {
        return FitnessUserLevel.getProgressToNextLevel(points: experiencePoints)
    }
    
    // Comprar una recompensa
    mutating func purchaseReward(_ reward: Reward) -> Bool {
        // Verificar si hay suficientes tokens
        if tokenBalance >= reward.tokenCost {
            tokenBalance -= reward.tokenCost
            purchasedRewards.append(reward)
            return true
        }
        return false
    }
    
    // New methods for social features
    
    // Send a friend request to another user
    mutating func sendFriendRequest(to userId: UUID) {
        if !sentFriendRequests.contains(userId) && !friends.contains(userId) {
            sentFriendRequests.append(userId)
        }
    }
    
    // Accept a friend request from another user
    mutating func acceptFriendRequest(from userId: UUID) {
        if pendingFriendRequests.contains(userId) {
            // Remove from pending requests
            pendingFriendRequests.removeAll { $0 == userId }
            
            // Add to friends
            if !friends.contains(userId) {
                friends.append(userId)
            }
        }
    }
    
    // Decline a friend request
    mutating func declineFriendRequest(from userId: UUID) {
        pendingFriendRequests.removeAll { $0 == userId }
    }
    
    // Remove a friend
    mutating func removeFriend(_ userId: UUID) {
        friends.removeAll { $0 == userId }
    }
    
    // Join an event
    mutating func joinEvent(_ eventId: UUID) {
        if !connectedEvents.contains(eventId) {
            connectedEvents.append(eventId)
        }
    }
    
    // Leave an event
    mutating func leaveEvent(_ eventId: UUID) {
        connectedEvents.removeAll { $0 == eventId }
    }
}

// Estructura para preferencias de usuario
struct UserPreferences: Codable {
    var fitnessGoal: FitnessGoal = .general
    var favoriteActivities: [WorkoutType] = []
    var receiveNotifications: Bool = true
    var userAppearance: AppearanceMode = .system
    
    enum FitnessGoal: String, Codable, CaseIterable {
        case loseWeight = "Lose Weight"
        case gainMuscle = "Gain Muscle"
        case improveEndurance = "Improve Endurance"
        case general = "General Fitness"
        
        var icon: String {
            switch self {
            case .loseWeight: return "arrow.down.circle"
            case .gainMuscle: return "figure.arms.open"
            case .improveEndurance: return "figure.run"
            case .general: return "heart"
            }
        }
    }
    
    enum AppearanceMode: String, Codable, CaseIterable {
        case light = "Light"
        case dark = "Dark" 
        case system = "System"
        
        var icon: String {
            switch self {
            case .light: return "sun.max.fill"
            case .dark: return "moon.fill"
            case .system: return "gear"
            }
        }
    }
}

// New structure for social privacy settings
struct SocialPrivacySettings: Codable {
    var showWorkoutsToFriends: Bool = true
    var showWorkoutsToPublic: Bool = false
    var allowFriendRequests: Bool = true
    var showRewardsActivity: Bool = true
    var showRealName: Bool = true
    
    // Default initializer
    init(
        showWorkoutsToFriends: Bool = true,
        showWorkoutsToPublic: Bool = false,
        allowFriendRequests: Bool = true,
        showRewardsActivity: Bool = true,
        showRealName: Bool = true
    ) {
        self.showWorkoutsToFriends = showWorkoutsToFriends
        self.showWorkoutsToPublic = showWorkoutsToPublic
        self.allowFriendRequests = allowFriendRequests
        self.showRewardsActivity = showRewardsActivity
        self.showRealName = showRealName
    }
} 