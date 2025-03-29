import Foundation

struct SocialActivity: Identifiable, Codable {
    var id = UUID()
    var userId: UUID
    var userName: String
    var activityType: ActivityType
    var workoutType: WorkoutType?
    var timestamp: Date
    var message: String?
    var tokenEarned: Double?
    
    enum ActivityType: String, Codable {
        case completedWorkout
        case earnedReward
        case achievedMilestone
        case joinedApp
    }
    
    static func createWorkoutActivity(user: User, workout: Workout) -> SocialActivity {
        return SocialActivity(
            userId: user.id,
            userName: user.name,
            activityType: .completedWorkout,
            workoutType: workout.type,
            timestamp: Date(),
            message: "Completed a \(workout.type.rawValue) workout",
            tokenEarned: workout.tokenReward
        )
    }
} 