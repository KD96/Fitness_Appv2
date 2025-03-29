import Foundation
import SwiftUI

struct User: Identifiable, Codable {
    var id = UUID()
    var name: String
    var profileImage: String? // URL or system image name
    var tokenBalance: Double = 0.0
    var friends: [UUID] = []
    var workoutStreak: Int = 0
    var completedWorkouts: [Workout] = []
    
    // Nuevos campos para funcionalidad mejorada
    var experiencePoints: Int = 0
    var cryptoWallet = CryptoWallet()
    var purchasedRewards: [Reward] = []
    var userPreferences = UserPreferences()
    var joinDate = Date()
    
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
        
        // Calcular recompensa de tokens con multiplicador de nivel
        let currentLevel = UserLevel.getCurrentLevel(points: experiencePoints)
        let baseTokens = workout.tokensEarned
        let bonusTokens = baseTokens * (currentLevel.tokenMultiplier - 1.0)
        let totalTokens = baseTokens + bonusTokens
        
        // Añadir tokens a balance
        tokenBalance += totalTokens
        
        // Añadir tokens a la wallet
        cryptoWallet.addTransaction(
            amount: totalTokens,
            type: .received,
            description: "Completed \(workout.type.rawValue) workout"
        )
        
        // Añadir puntos de experiencia (XP)
        // 10 XP por minuto de ejercicio
        let xpEarned = workout.durationMinutes * 10
        experiencePoints += xpEarned
    }
    
    // Obtener el nivel actual
    var currentLevel: UserLevel {
        return UserLevel.getCurrentLevel(points: experiencePoints)
    }
    
    // Calcular progreso hacia el siguiente nivel
    var progressToNextLevel: Double {
        return UserLevel.getProgressToNextLevel(points: experiencePoints)
    }
    
    // Comprar una recompensa
    mutating func purchaseReward(_ reward: Reward) -> Bool {
        // Verificar si hay suficientes tokens
        if tokenBalance >= reward.tokenCost {
            tokenBalance -= reward.tokenCost
            purchasedRewards.append(reward)
            
            // Registrar la transacción
            cryptoWallet.addTransaction(
                amount: reward.tokenCost,
                type: .sent,
                description: "Purchased \(reward.title) from \(reward.partnerName)"
            )
            
            return true
        }
        return false
    }
    
    // Convertir tokens a crypto
    mutating func convertTokensToCrypto(amount: Double, to cryptoType: CryptoWallet.CryptoType) -> Bool {
        if tokenBalance >= amount {
            tokenBalance -= amount
            
            // Realizar conversión a crypto
            let cryptoAmount = cryptoWallet.convertTokens(tokenAmount: amount, to: cryptoType)
            
            return true
        }
        return false
    }
}

// Estructura para preferencias de usuario
struct UserPreferences: Codable {
    var fitnessGoal: FitnessGoal = .general
    var favoriteActivities: [WorkoutType] = []
    var receiveNotifications: Bool = true
    var preferredRewardCategories: [Reward.Category] = []
    var userAppearance: AppearanceMode = .system
    
    enum FitnessGoal: String, Codable, CaseIterable {
        case loseWeight = "Lose Weight"
        case gainMuscle = "Gain Muscle"
        case improveEndurance = "Improve Endurance"
        case general = "General Fitness"
        case stressReduction = "Stress Reduction"
        
        var icon: String {
            switch self {
            case .loseWeight: return "arrow.down.circle"
            case .gainMuscle: return "figure.arms.open"
            case .improveEndurance: return "figure.run"
            case .general: return "heart"
            case .stressReduction: return "brain.head.profile"
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