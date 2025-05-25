//
//  WorkoutRepositoryTests.swift
//  Fitness_Appv2Tests
//
//  Created by Data Wiring Integration
//

import XCTest
import Supabase
@testable import Fitness_Appv2

final class WorkoutRepositoryTests: XCTestCase {
    
    var repository: WorkoutRepository!
    var mockClient: MockSupabaseClient!
    
    override func setUpWithError() throws {
        mockClient = MockSupabaseClient()
        repository = WorkoutRepository(client: mockClient)
    }
    
    override func tearDownWithError() throws {
        repository = nil
        mockClient = nil
    }
    
    // MARK: - Fetch Workouts Tests
    
    func testFetchWorkouts_Success() async throws {
        // Given
        let expectedWorkouts = [createMockSupabaseWorkout()]
        mockClient.mockWorkouts = expectedWorkouts
        
        // When
        await repository.fetchWorkouts()
        
        // Then
        XCTAssertEqual(repository.workouts.count, 1)
        XCTAssertEqual(repository.workouts.first?.name, "Test Workout")
        XCTAssertFalse(repository.isLoading)
        XCTAssertNil(repository.error)
    }
    
    func testFetchWorkouts_NotAuthenticated() async throws {
        // Given
        mockClient.shouldReturnUser = false
        
        // When
        await repository.fetchWorkouts()
        
        // Then
        XCTAssertTrue(repository.workouts.isEmpty)
        XCTAssertFalse(repository.isLoading)
        XCTAssertNotNil(repository.error)
        
        if case .notAuthenticated = repository.error {
            // Expected error type
        } else {
            XCTFail("Expected notAuthenticated error")
        }
    }
    
    func testFetchWorkouts_NetworkError() async throws {
        // Given
        mockClient.shouldThrowError = true
        
        // When
        await repository.fetchWorkouts()
        
        // Then
        XCTAssertTrue(repository.workouts.isEmpty)
        XCTAssertFalse(repository.isLoading)
        XCTAssertNotNil(repository.error)
    }
    
    // MARK: - Create Workout Tests
    
    func testCreateWorkout_Success() async throws {
        // Given
        let workout = createMockWorkout()
        mockClient.mockWorkouts = [createMockSupabaseWorkout()]
        
        // When
        await repository.createWorkout(workout)
        
        // Then
        XCTAssertTrue(mockClient.insertCalled)
        XCTAssertEqual(repository.workouts.count, 1)
    }
    
    func testCreateWorkout_OfflineQueue() async throws {
        // Given
        let workout = createMockWorkout()
        mockClient.shouldReturnUser = false
        
        // When
        await repository.createWorkout(workout)
        
        // Then
        XCTAssertFalse(mockClient.insertCalled)
        // Workout should be added to offline queue
    }
    
    // MARK: - Update Workout Tests
    
    func testUpdateWorkout_Success() async throws {
        // Given
        let workout = createMockWorkout()
        repository.workouts = [workout]
        
        // When
        await repository.updateWorkout(workout)
        
        // Then
        XCTAssertTrue(mockClient.updateCalled)
        XCTAssertNil(repository.error)
    }
    
    // MARK: - Delete Workout Tests
    
    func testDeleteWorkout_Success() async throws {
        // Given
        let workout = createMockWorkout()
        repository.workouts = [workout]
        
        // When
        await repository.deleteWorkout(workout)
        
        // Then
        XCTAssertTrue(mockClient.deleteCalled)
        XCTAssertTrue(repository.workouts.isEmpty)
    }
    
    // MARK: - Helper Methods
    
    private func createMockWorkout() -> Workout {
        return Workout(
            name: "Test Workout",
            type: .running,
            durationMinutes: 30,
            date: Date(),
            caloriesBurned: 250,
            tokensEarned: 25,
            completed: true
        )
    }
    
    private func createMockSupabaseWorkout() -> SupabaseWorkout {
        return SupabaseWorkout(
            id: UUID(),
            userId: UUID(),
            name: "Test Workout",
            type: "running",
            durationMinutes: 30,
            caloriesBurned: 250,
            tokensEarned: 25,
            notes: nil,
            completed: true,
            distanceMeters: nil,
            steps: nil,
            averageHeartRate: nil,
            maxHeartRate: nil,
            minHeartRate: nil,
            reps: nil,
            sets: nil,
            weightKg: nil,
            intensity: nil,
            workoutDate: Date(),
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

// MARK: - Mock Supabase Client

class MockSupabaseClient: SupabaseClient {
    
    var mockWorkouts: [SupabaseWorkout] = []
    var shouldThrowError = false
    var shouldReturnUser = true
    
    var insertCalled = false
    var updateCalled = false
    var deleteCalled = false
    
    override init(supabaseURL: URL, supabaseKey: String) {
        super.init(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }
    
    // Mock database operations would go here
    // Note: This is a simplified mock - in real implementation,
    // you'd need to mock the database property and its methods
}

// MARK: - Offline Queue Tests

final class OfflineWorkoutQueueTests: XCTestCase {
    
    var queue: OfflineWorkoutQueue!
    
    override func setUpWithError() throws {
        queue = OfflineWorkoutQueue()
        queue.clearWorkouts() // Start with clean slate
    }
    
    override func tearDownWithError() throws {
        queue.clearWorkouts()
        queue = nil
    }
    
    func testAddWorkout() {
        // Given
        let workout = createTestWorkout()
        
        // When
        queue.addWorkout(workout)
        
        // Then
        XCTAssertEqual(queue.count, 1)
        XCTAssertTrue(queue.hasWorkouts)
        XCTAssertEqual(queue.getWorkouts().first?.id, workout.id)
    }
    
    func testClearWorkouts() {
        // Given
        queue.addWorkout(createTestWorkout())
        XCTAssertTrue(queue.hasWorkouts)
        
        // When
        queue.clearWorkouts()
        
        // Then
        XCTAssertFalse(queue.hasWorkouts)
        XCTAssertEqual(queue.count, 0)
    }
    
    func testRemoveSpecificWorkout() {
        // Given
        let workout1 = createTestWorkout()
        let workout2 = createTestWorkout()
        queue.addWorkout(workout1)
        queue.addWorkout(workout2)
        
        // When
        queue.removeWorkout(workout1)
        
        // Then
        XCTAssertEqual(queue.count, 1)
        XCTAssertEqual(queue.getWorkouts().first?.id, workout2.id)
    }
    
    private func createTestWorkout() -> Workout {
        return Workout(
            name: "Test Workout",
            type: .running,
            durationMinutes: 30,
            date: Date(),
            caloriesBurned: 250,
            tokensEarned: 25
        )
    }
} 