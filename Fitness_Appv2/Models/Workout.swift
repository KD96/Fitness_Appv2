import Foundation

struct Workout: Identifiable, Codable {
    var id = UUID()
    var name: String
    var type: WorkoutType
    var durationMinutes: Int
    var date: Date
    var caloriesBurned: Double
    var tokensEarned: Double
    var notes: String?
    var distance: Double?
    var completed: Bool = false
}

enum WorkoutType: String, Codable, CaseIterable {
    case running
    case walking
    case cycling
    case swimming
    case strength
    case yoga
    case hiit
    case other
    
    var icon: String {
        switch self {
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .cycling: return "figure.outdoor.cycle"
        case .swimming: return "figure.pool.swim"
        case .strength: return "dumbbell"
        case .yoga: return "figure.yoga"
        case .hiit: return "figure.highintensity.intervaltraining"
        case .other: return "figure.mixed.cardio"
        }
    }
} 