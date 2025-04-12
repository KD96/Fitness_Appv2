import Foundation
import SwiftUI

struct SocialActivity: Identifiable, Codable {
    var id = UUID()
    var userId: UUID
    var userName: String
    var activityType: ActivityType
    var workoutType: WorkoutType?
    var timestamp: Date
    var message: String?
    var tokenEarned: Double?
    
    // New fields for social features
    var relatedUserId: UUID?
    var relatedUserName: String?
    var eventId: UUID?
    var eventName: String?
    
    enum ActivityType: String, Codable {
        case completedWorkout
        case earnedReward
        case achievedMilestone
        case joinedApp
        // New social activity types
        case becameFriends
        case joinedEvent
        case invitedToEvent
        case achievedGoalTogether
    }
    
    static func createWorkoutActivity(user: User, workout: Workout) -> SocialActivity {
        return SocialActivity(
            userId: user.id,
            userName: user.name,
            activityType: .completedWorkout,
            workoutType: workout.type,
            timestamp: Date(),
            message: "Completed a \(workout.type.rawValue) workout",
            tokenEarned: workout.tokensEarned
        )
    }
    
    // Helper method to create a "became friends" activity
    static func createFriendsActivity(user: User, friend: User) -> SocialActivity {
        return SocialActivity(
            userId: user.id,
            userName: user.name,
            activityType: .becameFriends,
            timestamp: Date(),
            message: "Connected with a new friend",
            relatedUserId: friend.id,
            relatedUserName: friend.name
        )
    }
    
    // Helper method to create a "joined event" activity
    static func createJoinedEventActivity(user: User, eventId: UUID, eventName: String) -> SocialActivity {
        return SocialActivity(
            userId: user.id,
            userName: user.name,
            activityType: .joinedEvent,
            timestamp: Date(),
            message: "Joined a fitness event",
            eventId: eventId,
            eventName: eventName
        )
    }
}

// New model for fitness events
struct FitnessEvent: Identifiable, Codable {
    var id = UUID()
    var name: String
    var description: String
    var eventType: WorkoutType
    var date: Date
    var duration: Int // in minutes
    var location: String?
    var isVirtual: Bool
    var maxParticipants: Int?
    var creatorId: UUID
    var participants: [UUID] = []
    var imageIcon: String // SF Symbol name
    
    // Helper computed properties
    var isUpcoming: Bool {
        return date > Date()
    }
    
    var participantsCount: Int {
        return participants.count
    }
    
    var isFull: Bool {
        if let max = maxParticipants {
            return participants.count >= max
        }
        return false
    }
    
    // Format the date and time for display
    func formattedDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Check if a user is already a participant
    func isUserParticipating(_ userId: UUID) -> Bool {
        return participants.contains(userId)
    }
    
    // Helper method to get a color for the event based on workout type
    func getEventColor() -> Color {
        return AthleteImages.getColorForWorkoutType(eventType)
    }
} 