import Foundation

struct User: Identifiable, Codable {
    var id = UUID()
    var name: String
    var profileImage: String? // URL or system image name
    var tokenBalance: Double = 0.0
    var friends: [UUID] = []
    var workoutStreak: Int = 0
    var completedWorkouts: [Workout] = []
    
    // Add token reward to user balance
    mutating func addTokens(_ amount: Double) {
        tokenBalance += amount
    }
    
    // Add a completed workout and update tokens
    mutating func completeWorkout(_ workout: Workout) {
        var completedWorkout = workout
        completedWorkout.completed = true
        completedWorkouts.append(completedWorkout)
        addTokens(workout.tokenReward)
        
        // Update streak logic
        updateStreak()
    }
    
    private mutating func updateStreak() {
        // Simple streak logic - if worked out today, increment streak
        // More sophisticated logic would be added for a production app
        if let lastWorkout = completedWorkouts.last {
            if Calendar.current.isDateInToday(lastWorkout.date) {
                workoutStreak += 1
            } else if !Calendar.current.isDateInYesterday(lastWorkout.date) {
                // Reset streak if missed a day
                workoutStreak = 1
            }
        }
    }
} 