import Foundation
import SwiftUI

class AppDataStore: ObservableObject {
    @Published var currentUser: User
    @Published var socialFeed: [SocialActivity] = []
    @Published var friends: [User] = []
    
    // Mock data for MVP
    init() {
        // Create a default user
        currentUser = User(name: "User")
        
        // Add some sample friends
        friends = [
            User(name: "Alex", profileImage: "person.circle.fill"),
            User(name: "Jamie", profileImage: "person.circle.fill"),
            User(name: "Taylor", profileImage: "person.circle.fill")
        ]
        
        // Add some sample social activities
        let sampleWorkout = Workout(
            type: .running,
            duration: 1800, // 30 minutes
            date: Date().addingTimeInterval(-86400), // Yesterday
            calories: 250
        )
        
        let sampleActivity = SocialActivity.createWorkoutActivity(
            user: friends[0], 
            workout: sampleWorkout
        )
        
        socialFeed = [sampleActivity]
    }
    
    // Complete a workout and update everything
    func completeWorkout(_ workout: Workout) {
        // Update user data
        currentUser.completeWorkout(workout)
        
        // Create social activity
        let activity = SocialActivity.createWorkoutActivity(
            user: currentUser,
            workout: workout
        )
        
        // Add to feed
        socialFeed.insert(activity, at: 0)
        
        // Save data (would use persistence in a full implementation)
        saveData()
    }
    
    // Simple save to UserDefaults for MVP
    private func saveData() {
        if let encodedUser = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(encodedUser, forKey: "currentUser")
        }
        
        if let encodedFeed = try? JSONEncoder().encode(socialFeed) {
            UserDefaults.standard.set(encodedFeed, forKey: "socialFeed")
        }
    }
    
    // Load data from UserDefaults
    func loadData() {
        if let savedUser = UserDefaults.standard.data(forKey: "currentUser"),
           let decodedUser = try? JSONDecoder().decode(User.self, from: savedUser) {
            currentUser = decodedUser
        }
        
        if let savedFeed = UserDefaults.standard.data(forKey: "socialFeed"),
           let decodedFeed = try? JSONDecoder().decode([SocialActivity].self, from: savedFeed) {
            socialFeed = decodedFeed
        }
    }
} 