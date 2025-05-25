//
//  SupabaseService.swift
//  Fitness_Appv2
//
//  Created by Data Wiring Integration
//

import Foundation
import Supabase

/// Singleton service for Supabase operations
@MainActor
class SupabaseService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = SupabaseService()
    
    // MARK: - Properties
    private let client: SupabaseClient
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    // MARK: - Initialization
    private init() {
        self.client = SupabaseConfig.client
        
        // Check initial auth state
        Task {
            await checkAuthState()
        }
    }
    
    // MARK: - Authentication
    func checkAuthState() async {
        do {
            let session = try await client.auth.session
            isAuthenticated = session.user != nil
            if let user = session.user {
                await loadUserProfile(userId: user.id)
            }
        } catch {
            isAuthenticated = false
            currentUser = nil
        }
    }
    
    func signUp(email: String, password: String, name: String) async throws {
        let response = try await client.auth.signUp(
            email: email,
            password: password
        )
        
        // Create user profile
        if let user = response.user {
            try await createUserProfile(userId: user.id, email: email, name: name)
        }
    }
    
    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
        await checkAuthState()
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
        isAuthenticated = false
        currentUser = nil
    }
    
    // MARK: - User Profile
    private func createUserProfile(userId: UUID, email: String, name: String) async throws {
        let userProfile: [String: AnyJSON] = [
            "id": AnyJSON(userId.uuidString),
            "email": AnyJSON(email),
            "name": AnyJSON(name)
        ]
        
        try await client.database
            .from("users")
            .insert(userProfile)
            .execute()
    }
    
    private func loadUserProfile(userId: UUID) async {
        do {
            let response: [UserProfile] = try await client.database
                .from("users")
                .select()
                .eq("id", value: userId)
                .execute()
                .value
            
            if let profile = response.first {
                // Convert to local User model
                currentUser = convertToLocalUser(profile)
            }
        } catch {
            print("Error loading user profile: \(error)")
        }
    }
    
    private func convertToLocalUser(_ profile: UserProfile) -> User {
        var user = User(name: profile.name)
        user.id = profile.id
        user.tokenBalance = profile.tokenBalance
        user.experiencePoints = profile.experiencePoints
        user.workoutStreak = profile.workoutStreak
        return user
    }
} 