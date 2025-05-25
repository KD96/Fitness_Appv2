//
//  OfflineWorkoutQueue.swift
//  Fitness_Appv2
//
//  Created by Data Wiring Integration
//

import Foundation

/// Manages offline workout queue for when network is unavailable
class OfflineWorkoutQueue {
    
    // MARK: - Properties
    private let userDefaults = UserDefaults.standard
    private let queueKey = "OfflineWorkoutQueue"
    
    // MARK: - Queue Operations
    
    /// Add workout to offline queue
    func addWorkout(_ workout: Workout) {
        var queue = getWorkouts()
        queue.append(workout)
        saveWorkouts(queue)
    }
    
    /// Get all workouts in queue
    func getWorkouts() -> [Workout] {
        guard let data = userDefaults.data(forKey: queueKey),
              let workouts = try? JSONDecoder().decode([Workout].self, from: data) else {
            return []
        }
        return workouts
    }
    
    /// Clear all workouts from queue
    func clearWorkouts() {
        userDefaults.removeObject(forKey: queueKey)
    }
    
    /// Remove specific workout from queue
    func removeWorkout(_ workout: Workout) {
        var queue = getWorkouts()
        queue.removeAll { $0.id == workout.id }
        saveWorkouts(queue)
    }
    
    /// Check if queue has workouts
    var hasWorkouts: Bool {
        return !getWorkouts().isEmpty
    }
    
    /// Get count of queued workouts
    var count: Int {
        return getWorkouts().count
    }
    
    // MARK: - Private Methods
    
    private func saveWorkouts(_ workouts: [Workout]) {
        do {
            let data = try JSONEncoder().encode(workouts)
            userDefaults.set(data, forKey: queueKey)
        } catch {
            print("Failed to save offline workouts: \(error)")
        }
    }
} 