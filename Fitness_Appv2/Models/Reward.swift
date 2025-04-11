import Foundation
import SwiftUI

// Modelo para representar una recompensa o descuento de partner
struct Reward: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var partnerName: String
    var partnerLogo: String // Nombre del icono de sistema
    var tokenCost: Double
    var discountPercentage: Int? // Para descuentos porcentuales
    var discountAmount: Double? // Para descuentos de cantidad fija
    var expiryDate: Date?
    var category: Category
    var isFeatured: Bool = false
    var isNew: Bool = false
    
    enum Category: String, Codable, CaseIterable {
        case fitness = "Fitness Gear"
        case nutrition = "Nutrition"
        case wellness = "Wellness"
        
        var icon: String {
            switch self {
            case .fitness: return "figure.run.circle"
            case .nutrition: return "leaf.circle"
            case .wellness: return "heart.circle"
            }
        }
        
        var color: Color {
            switch self {
            case .fitness: return Color.blue
            case .nutrition: return Color.green
            case .wellness: return Color.purple
            }
        }
    }
    
    // Devuelve una representación formateada del precio en tokens
    var formattedCost: String {
        return "\(Int(tokenCost)) PURE"
    }
    
    // Devuelve una representación formateada del descuento
    var formattedDiscount: String {
        if let percentage = discountPercentage {
            return "\(percentage)% OFF"
        } else if let amount = discountAmount {
            return "$\(amount) OFF"
        }
        return "Special Offer"
    }
}

// Modelo para representar un nivel de usuario
struct UserLevel: Codable, Equatable {
    var level: Int
    var title: String
    var requiredPoints: Int
    var benefits: [String]
    var tokenMultiplier: Double
    
    static let levels: [UserLevel] = [
        UserLevel(
            level: 1,
            title: "Beginner",
            requiredPoints: 0,
            benefits: ["Basic rewards access"],
            tokenMultiplier: 1.0
        ),
        UserLevel(
            level: 2,
            title: "Intermediate",
            requiredPoints: 200,
            benefits: ["10% bonus on all tokens", "Access to premium rewards"],
            tokenMultiplier: 1.1
        ),
        UserLevel(
            level: 3,
            title: "Advanced",
            requiredPoints: 500,
            benefits: ["20% bonus on all tokens", "All exclusive benefits"],
            tokenMultiplier: 1.2
        )
    ]
    
    // Obtener el nivel actual basado en los puntos
    static func getCurrentLevel(points: Int) -> UserLevel {
        for i in (0..<levels.count).reversed() {
            if points >= levels[i].requiredPoints {
                return levels[i]
            }
        }
        return levels[0]
    }
    
    // Calcular el progreso hacia el siguiente nivel (0.0 - 1.0)
    static func getProgressToNextLevel(points: Int) -> Double {
        let currentLevel = getCurrentLevel(points: points)
        let currentLevelIndex = levels.firstIndex(of: currentLevel) ?? 0
        
        // Si es el último nivel, el progreso es completo
        if currentLevelIndex == levels.count - 1 {
            return 1.0
        }
        
        let nextLevel = levels[currentLevelIndex + 1]
        let pointsForCurrentLevel = points - currentLevel.requiredPoints
        let pointsRequiredForNextLevel = nextLevel.requiredPoints - currentLevel.requiredPoints
        
        return min(Double(pointsForCurrentLevel) / Double(pointsRequiredForNextLevel), 1.0)
    }
} 