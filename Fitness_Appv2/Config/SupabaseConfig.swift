//
//  SupabaseConfig.swift
//  Fitness_Appv2
//
//  Created by Supabase Integration
//

import Foundation
import Supabase

/// Configuration for Supabase integration
struct SupabaseConfig {
    
    // MARK: - Supabase Configuration
    
    /// Supabase project URL
    static let supabaseURL = URL(string: Environment.current.supabaseURL)!
    
    /// Supabase anon key (public key)
    static let supabaseAnonKey = Environment.current.anonKey
    
    // MARK: - Supabase Client
    
    /// Shared Supabase client instance
    static let client = SupabaseClient(
        supabaseURL: supabaseURL,
        supabaseKey: supabaseAnonKey
    )
    
    // MARK: - Database Tables
    
    /// Table names for type-safe database operations
    enum Tables {
        static let users = "users"
        static let workouts = "workouts"
        static let rewards = "rewards"
        static let userRewards = "user_rewards"
        static let missions = "missions"
        static let userMissionProgress = "user_mission_progress"
        static let friendships = "friendships"
        static let socialActivities = "social_activities"
        static let fitnessEvents = "fitness_events"
        static let eventParticipants = "event_participants"
        static let analyticsEvents = "analytics_events"
    }
    
    // MARK: - Storage Buckets
    
    /// Storage bucket names
    enum StorageBuckets {
        static let avatars = "avatars"
        static let workoutImages = "workout-images"
        static let rewardImages = "reward-images"
    }
    
    // MARK: - Realtime Channels
    
    /// Realtime channel names for live updates
    enum RealtimeChannels {
        static let socialFeed = "social-feed"
        static let friendships = "friendships"
        static let events = "fitness-events"
        static let missions = "daily-missions"
    }
    
    // MARK: - Configuration Methods
    
    /// Configure Supabase client with custom options
    static func configureClient() {
        // Add any additional client configuration here
        // For example: custom headers, timeout settings, etc.
    }
    
    /// Get authenticated user ID
    static var currentUserId: UUID? {
        return client.auth.currentUser?.id
    }
    
    /// Check if user is authenticated
    static var isAuthenticated: Bool {
        return client.auth.currentUser != nil
    }
}

// MARK: - Environment Configuration

extension SupabaseConfig {
    
    /// Environment-specific configuration
    enum Environment {
        case development
        case staging
        case production
        
        static var current: Environment {
            #if DEBUG
            return .development
            #else
            return .production
            #endif
        }
        
        var supabaseURL: String {
            switch self {
            case .development:
                return "http://127.0.0.1:54321" // Local Supabase
            case .staging:
                return "https://your-staging-project-id.supabase.co"
            case .production:
                return "https://pbnzchrhqibmdtyiibhx.supabase.co"
            }
        }
        
        var anonKey: String {
            switch self {
            case .development:
                return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
            case .staging:
                return "your-staging-anon-key"
            case .production:
                return "your-prod-anon-key"
            }
        }
    }
}

// MARK: - Error Handling

extension SupabaseConfig {
    
    /// Custom error types for Supabase operations
    enum SupabaseError: LocalizedError {
        case notAuthenticated
        case invalidConfiguration
        case networkError(String)
        case databaseError(String)
        case authError(String)
        
        var errorDescription: String? {
            switch self {
            case .notAuthenticated:
                return "User is not authenticated"
            case .invalidConfiguration:
                return "Invalid Supabase configuration"
            case .networkError(let message):
                return "Network error: \(message)"
            case .databaseError(let message):
                return "Database error: \(message)"
            case .authError(let message):
                return "Authentication error: \(message)"
            }
        }
    }
}

// MARK: - Helper Extensions

extension SupabaseClient {
    
    /// Convenience method to get current user profile
    func getCurrentUserProfile() async throws -> UserProfile? {
        guard let userId = auth.currentUser?.id else {
            throw SupabaseConfig.SupabaseError.notAuthenticated
        }
        
        let response: UserProfile = try await database
            .from(SupabaseConfig.Tables.users)
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value
        
        return response
    }
    
    /// Convenience method to update user's last active timestamp
    func updateLastActive() async throws {
        guard let userId = auth.currentUser?.id else {
            throw SupabaseConfig.SupabaseError.notAuthenticated
        }
        
        try await database
            .from(SupabaseConfig.Tables.users)
            .update(["last_active": Date().ISO8601Format()])
            .eq("id", value: userId)
            .execute()
    }
}

// MARK: - Data Models for Supabase

/// User profile model matching the database schema
struct UserProfile: Codable {
    let id: UUID
    let email: String
    let name: String
    let firstName: String
    let profileImageUrl: String?
    let bio: String
    let tokenBalance: Double
    let experiencePoints: Int
    let currentLevel: String
    let workoutStreak: Int
    let appearanceMode: String
    let notificationsEnabled: Bool
    let socialPrivacyEnabled: Bool
    let joinDate: Date
    let lastActive: Date
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, email, name, bio
        case firstName = "first_name"
        case profileImageUrl = "profile_image_url"
        case tokenBalance = "token_balance"
        case experiencePoints = "experience_points"
        case currentLevel = "current_level"
        case workoutStreak = "workout_streak"
        case appearanceMode = "appearance_mode"
        case notificationsEnabled = "notifications_enabled"
        case socialPrivacyEnabled = "social_privacy_enabled"
        case joinDate = "join_date"
        case lastActive = "last_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
} 