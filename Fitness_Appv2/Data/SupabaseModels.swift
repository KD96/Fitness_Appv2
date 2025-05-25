//
//  SupabaseModels.swift
//  Fitness_Appv2
//
//  Created by Data Wiring Integration
//

import Foundation

/// Supabase workout model matching database schema
struct SupabaseWorkout: Codable {
    let id: UUID
    let userId: UUID
    let name: String
    let type: String
    let durationMinutes: Int
    let caloriesBurned: Double
    let tokensEarned: Double
    let notes: String?
    let completed: Bool
    let distanceMeters: Double?
    let steps: Int?
    let averageHeartRate: Int?
    let maxHeartRate: Int?
    let minHeartRate: Int?
    let reps: Int?
    let sets: Int?
    let weightKg: Double?
    let intensity: String?
    let workoutDate: Date
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, notes, completed, steps, reps, sets, intensity
        case userId = "user_id"
        case durationMinutes = "duration_minutes"
        case caloriesBurned = "calories_burned"
        case tokensEarned = "tokens_earned"
        case distanceMeters = "distance_meters"
        case averageHeartRate = "average_heart_rate"
        case maxHeartRate = "max_heart_rate"
        case minHeartRate = "min_heart_rate"
        case weightKg = "weight_kg"
        case workoutDate = "workout_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Supabase user model matching database schema
struct SupabaseUser: Codable {
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

/// Supabase reward model
struct SupabaseReward: Codable {
    let id: UUID
    let name: String
    let description: String
    let category: String
    let tokenCost: Double
    let imageUrl: String?
    let partnerName: String?
    let partnerLogoUrl: String?
    let isFeatured: Bool
    let isAvailable: Bool
    let stockQuantity: Int?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, category
        case tokenCost = "token_cost"
        case imageUrl = "image_url"
        case partnerName = "partner_name"
        case partnerLogoUrl = "partner_logo_url"
        case isFeatured = "is_featured"
        case isAvailable = "is_available"
        case stockQuantity = "stock_quantity"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Supabase social activity model
struct SupabaseSocialActivity: Codable {
    let id: UUID
    let userId: UUID
    let activityType: String
    let title: String
    let description: String?
    let metadata: [String: AnyCodable]
    let workoutId: UUID?
    let rewardId: UUID?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, metadata
        case userId = "user_id"
        case activityType = "activity_type"
        case workoutId = "workout_id"
        case rewardId = "reward_id"
        case createdAt = "created_at"
    }
}

/// Helper for encoding/decoding any JSON value
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }
} 