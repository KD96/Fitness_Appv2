import Foundation

struct Workout: Identifiable, Codable {
    var id = UUID()
    var type: WorkoutType
    var duration: TimeInterval
    var date: Date
    var calories: Double
    var notes: String?
    var completed: Bool = false
    
    // For rewards calculation
    var tokenReward: Double {
        // Simple algorithm: 1 token per 10 minutes of workout
        return duration / 600
    }
}

enum WorkoutType: String, Codable, CaseIterable {
    case running
    case walking
    case cycling
    case swimming
    case weightTraining
    case yoga
    case hiit
    case other
    
    var icon: String {
        switch self {
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .cycling: return "figure.outdoor.cycle"
        case .swimming: return "figure.pool.swim"
        case .weightTraining: return "dumbbell"
        case .yoga: return "figure.yoga"
        case .hiit: return "figure.highintensity.intervaltraining"
        case .other: return "figure.mixed.cardio"
        }
    }
} 