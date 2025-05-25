//
//  WorkoutRepository.swift
//  Fitness_Appv2
//
//  Created by Data Wiring Integration
//

import Foundation
import Supabase

/// Repository for workout data operations with offline support
class WorkoutRepository: ObservableObject {
    
    // MARK: - Properties
    private let client: SupabaseClient
    private let offlineQueue = OfflineWorkoutQueue()
    
    @Published var workouts: [Workout] = []
    @Published var isLoading = false
    @Published var error: WorkoutError?
    
    // MARK: - Initialization
    init(client: SupabaseClient = SupabaseConfig.client) {
        self.client = client
    }
    
    // MARK: - CRUD Operations
    
    /// Fetch workouts for current user
    func fetchWorkouts() async {
        await MainActor.run { isLoading = true }
        
        do {
            guard let userId = SupabaseConfig.currentUserId else {
                throw WorkoutError.notAuthenticated
            }
            
            let response: [SupabaseWorkout] = try await client.database
                .from("workouts")
                .select()
                .eq("user_id", value: userId)
                .order("workout_date", ascending: false)
                .execute()
                .value
            
            let localWorkouts = response.map { convertToLocalWorkout($0) }
            
            await MainActor.run {
                self.workouts = localWorkouts
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.error = WorkoutError.fetchFailed(error.localizedDescription)
                self.isLoading = false
            }
        }
    }
    
    /// Create new workout
    func createWorkout(_ workout: Workout) async {
        do {
            guard let userId = SupabaseConfig.currentUserId else {
                // Add to offline queue if not authenticated
                offlineQueue.addWorkout(workout)
                return
            }
            
            let supabaseWorkout = convertToSupabaseWorkout(workout, userId: userId)
            
            try await client.database
                .from("workouts")
                .insert(supabaseWorkout)
                .execute()
            
            // Refresh workouts
            await fetchWorkouts()
            
        } catch {
            // Add to offline queue on failure
            offlineQueue.addWorkout(workout)
            await MainActor.run {
                self.error = WorkoutError.createFailed(error.localizedDescription)
            }
        }
    }
    
    /// Update existing workout
    func updateWorkout(_ workout: Workout) async {
        do {
            guard let userId = SupabaseConfig.currentUserId else {
                throw WorkoutError.notAuthenticated
            }
            
            let supabaseWorkout = convertToSupabaseWorkout(workout, userId: userId)
            
            try await client.database
                .from("workouts")
                .update(supabaseWorkout)
                .eq("id", value: workout.id)
                .execute()
            
            // Update local array
            await MainActor.run {
                if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
                    workouts[index] = workout
                }
            }
            
        } catch {
            await MainActor.run {
                self.error = WorkoutError.updateFailed(error.localizedDescription)
            }
        }
    }
    
    /// Delete workout
    func deleteWorkout(_ workout: Workout) async {
        do {
            try await client.database
                .from("workouts")
                .delete()
                .eq("id", value: workout.id)
                .execute()
            
            // Remove from local array
            await MainActor.run {
                workouts.removeAll { $0.id == workout.id }
            }
            
        } catch {
            await MainActor.run {
                self.error = WorkoutError.deleteFailed(error.localizedDescription)
            }
        }
    }
    
    /// Sync offline workouts
    func syncOfflineWorkouts() async {
        let offlineWorkouts = offlineQueue.getWorkouts()
        
        for workout in offlineWorkouts {
            await createWorkout(workout)
        }
        
        offlineQueue.clearWorkouts()
    }
}

// MARK: - Data Conversion
extension WorkoutRepository {
    
    private func convertToLocalWorkout(_ supabaseWorkout: SupabaseWorkout) -> Workout {
        return Workout(
            id: supabaseWorkout.id,
            name: supabaseWorkout.name,
            type: WorkoutType(rawValue: supabaseWorkout.type) ?? .running,
            durationMinutes: supabaseWorkout.durationMinutes,
            date: supabaseWorkout.workoutDate,
            caloriesBurned: supabaseWorkout.caloriesBurned,
            tokensEarned: supabaseWorkout.tokensEarned,
            notes: supabaseWorkout.notes,
            distance: supabaseWorkout.distanceMeters,
            completed: supabaseWorkout.completed
        )
    }
    
    private func convertToSupabaseWorkout(_ workout: Workout, userId: UUID) -> [String: AnyJSON] {
        return [
            "id": AnyJSON(workout.id.uuidString),
            "user_id": AnyJSON(userId.uuidString),
            "name": AnyJSON(workout.name),
            "type": AnyJSON(workout.type.rawValue),
            "duration_minutes": AnyJSON(workout.durationMinutes),
            "calories_burned": AnyJSON(workout.caloriesBurned),
            "tokens_earned": AnyJSON(workout.tokensEarned),
            "notes": AnyJSON(workout.notes),
            "distance_meters": AnyJSON(workout.distance),
            "completed": AnyJSON(workout.completed),
            "workout_date": AnyJSON(workout.date.ISO8601Format())
        ]
    }
}

// MARK: - Error Handling
enum WorkoutError: LocalizedError {
    case notAuthenticated
    case fetchFailed(String)
    case createFailed(String)
    case updateFailed(String)
    case deleteFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User not authenticated"
        case .fetchFailed(let message):
            return "Failed to fetch workouts: \(message)"
        case .createFailed(let message):
            return "Failed to create workout: \(message)"
        case .updateFailed(let message):
            return "Failed to update workout: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete workout: \(message)"
        }
    }
} 