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
    
    // Additional metrics
    var distance: Double?             // For: running, walking, cycling, swimming (in meters)
    var steps: Int?                   // For: running, walking
    var heartRate: HeartRateData?     // For: all types
    var laps: Int?                    // For: swimming
    var reps: Int?                    // For: strength
    var sets: Int?                    // For: strength
    var weight: Double?               // For: strength (in kg)
    var intensity: WorkoutIntensity?  // For: yoga, hiit, other
    
    var completed: Bool = false
    
    // Default initializer with basic properties
    init(id: UUID = UUID(), 
         name: String, 
         type: WorkoutType, 
         durationMinutes: Int, 
         date: Date, 
         caloriesBurned: Double, 
         tokensEarned: Double, 
         notes: String? = nil, 
         distance: Double? = nil,
         completed: Bool = false) {
        self.id = id
        self.name = name
        self.type = type
        self.durationMinutes = durationMinutes
        self.date = date
        self.caloriesBurned = caloriesBurned
        self.tokensEarned = tokensEarned
        self.notes = notes
        self.distance = distance
        self.completed = completed
    }
}

// Heart rate data
struct HeartRateData: Codable {
    var average: Int
    var max: Int
    var min: Int
}

// Workout intensity level
enum WorkoutIntensity: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var icon: String {
        switch self {
        case .low: return "heart"
        case .medium: return "heart.fill"
        case .high: return "bolt.heart.fill"
        }
    }
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
    
    // Helper method to get relevant metrics for this workout type
    var relevantMetrics: [WorkoutMetric] {
        switch self {
        case .running:
            return [.duration, .distance, .calories, .steps, .heartRate]
        case .walking:
            return [.duration, .distance, .calories, .steps, .heartRate]
        case .cycling:
            return [.duration, .distance, .calories, .heartRate]
        case .swimming:
            return [.duration, .distance, .calories, .laps, .heartRate]
        case .strength:
            return [.duration, .calories, .sets, .reps, .weight, .heartRate]
        case .yoga:
            return [.duration, .calories, .intensity, .heartRate]
        case .hiit:
            return [.duration, .calories, .intensity, .heartRate]
        case .other:
            return [.duration, .calories, .intensity, .heartRate]
        }
    }
}

// Enum representing different workout metrics
enum WorkoutMetric: String, CaseIterable {
    case duration = "Duration"
    case distance = "Distance"
    case calories = "Calories"
    case steps = "Steps"
    case heartRate = "Heart Rate"
    case laps = "Laps"
    case reps = "Repetitions"
    case sets = "Sets"
    case weight = "Weight"
    case intensity = "Intensity"
    
    var icon: String {
        switch self {
        case .duration: return "clock"
        case .distance: return "figure.walk"
        case .calories: return "flame"
        case .steps: return "shoeprints.fill"
        case .heartRate: return "heart.fill"
        case .laps: return "arrow.triangle.capsulepath"
        case .reps: return "repeat"
        case .sets: return "number.square"
        case .weight: return "dumbbell.fill"
        case .intensity: return "bolt"
        }
    }
    
    var unit: String? {
        switch self {
        case .duration: return "min"
        case .distance: return "km"
        case .calories: return "cal"
        case .steps: return "steps"
        case .heartRate: return "bpm"
        case .laps: return "laps"
        case .reps: return "reps"
        case .sets: return "sets"
        case .weight: return "kg"
        case .intensity: return nil
        }
    }
} 