import Foundation

struct Mission: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var description: String
    var rewardTokens: Double
    var experiencePoints: Int
    var type: MissionType
    var requirementType: RequirementType
    var targetValue: Double  // Valor objetivo (minutos, pasos, etc.)
    var workoutTypes: [WorkoutType] = []
    var isCompleted: Bool = false
    var expiryDate: Date? = nil
    
    // Fecha de expiración por defecto para misiones diarias (+24h)
    init(title: String, description: String, rewardTokens: Double, experiencePoints: Int, 
         type: MissionType, requirementType: RequirementType, targetValue: Double, 
         workoutTypes: [WorkoutType] = [], isCompleted: Bool = false, expiryDate: Date? = nil) {
        
        self.title = title
        self.description = description
        self.rewardTokens = rewardTokens
        self.experiencePoints = experiencePoints
        self.type = type
        self.requirementType = requirementType
        self.targetValue = targetValue
        self.workoutTypes = workoutTypes
        self.isCompleted = isCompleted
        
        if let expiry = expiryDate {
            self.expiryDate = expiry
        } else if type == .daily {
            // Por defecto, las misiones diarias expiran en 24h
            self.expiryDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        }
    }
    
    enum MissionType: String, Codable {
        case daily
        case weekly
        case achievement
        case challenge
    }
    
    enum RequirementType: String, Codable {
        case duration
        case steps
        case timeOfDay
        case workoutType
    }
} 