import Foundation

/// A simple analytics manager to track user events and app usage
class AnalyticsManager {
    // MARK: - Singleton & Properties
    
    // Singleton instance
    static let shared = AnalyticsManager()
    
    // Analytics data storage
    private var eventCounts: [String: Int] = [:]
    private var screenViewCounts: [String: Int] = [:]
    private var sessionStartTime: Date?
    private var workoutTypeUsage: [String: Int] = [:]
    private var featureUsage: [String: Int] = [:]
    
    // Session constants
    private let sessionDataKey = "AnalyticsSessionData"
    
    // Batching properties
    private var pendingEvents: [(eventType: EventType, name: String, metadata: [String: Any]?)] = []
    private var saveTimer: Timer?
    private let saveInterval: TimeInterval = 30 // Save every 30 seconds
    
    // MARK: - Initialization
    
    // Private init for singleton pattern
    private init() {
        loadSessionData()
        setupSaveTimer()
    }
    
    deinit {
        saveTimer?.invalidate()
        saveSessionData() // Save any pending events
    }
    
    // MARK: - Event Types
    
    enum EventType {
        case screenView
        case userAction
        case workout
        case feature
        case session
    }
    
    // MARK: - Public Event Tracking Methods
    
    /// Track when a screen is viewed
    func trackScreenView(screenName: String) {
        let count = screenViewCounts[screenName] ?? 0
        screenViewCounts[screenName] = count + 1
        
        // Add to batch
        pendingEvents.append((eventType: .screenView, name: screenName, metadata: nil))
    }
    
    /// Track when a user action/event occurs
    func trackEvent(eventName: String, metadata: [String: Any]? = nil) {
        let count = eventCounts[eventName] ?? 0
        eventCounts[eventName] = count + 1
        
        // Add to batch
        pendingEvents.append((eventType: .userAction, name: eventName, metadata: metadata))
    }
    
    /// Track when a workout is completed
    func trackWorkoutCompleted(type: String, durationMinutes: Int) {
        // Track workout type usage
        let count = workoutTypeUsage[type] ?? 0
        workoutTypeUsage[type] = count + 1
        
        // Track the completed workout event with metadata
        let metadata: [String: Any] = [
            "type": type,
            "duration": durationMinutes
        ]
        
        // Add to batch
        pendingEvents.append((eventType: .workout, name: "workout_completed", metadata: metadata))
    }
    
    /// Track feature usage
    func trackFeatureUsed(featureName: String) {
        let count = featureUsage[featureName] ?? 0
        featureUsage[featureName] = count + 1
        
        // Add to batch
        pendingEvents.append((eventType: .feature, name: featureName, metadata: nil))
    }
    
    /// Start a new user session
    func startSession() {
        sessionStartTime = Date()
        
        pendingEvents.append((eventType: .session, name: "session_started", metadata: nil))
        saveSessionData() // Save immediately when session starts
    }
    
    /// End the current user session
    func endSession() {
        guard let startTime = sessionStartTime else { return }
        
        let sessionDuration = Date().timeIntervalSince(startTime)
        
        // Add session metadata
        let metadata: [String: Any] = [
            "duration_seconds": sessionDuration,
            "duration_minutes": Int(sessionDuration / 60)
        ]
        
        pendingEvents.append((eventType: .session, name: "session_completed", metadata: metadata))
        
        sessionStartTime = nil
        
        // Save immediately when session ends
        saveSessionData()
    }
    
    // MARK: - Analytics Data Access
    
    /// Get the most popular workout type
    func getMostPopularWorkoutType() -> String? {
        return workoutTypeUsage.max(by: { $0.value < $1.value })?.key
    }
    
    /// Get the most viewed screen
    func getMostViewedScreen() -> String? {
        return screenViewCounts.max(by: { $0.value < $1.value })?.key
    }
    
    /// Get the most used feature
    func getMostUsedFeature() -> String? {
        return featureUsage.max(by: { $0.value < $1.value })?.key
    }
    
    /// Get analytics report as a dictionary
    func getAnalyticsReport() -> [String: Any] {
        // Save pending events before generating report
        savePendingEvents()
        
        return [
            "eventCounts": eventCounts,
            "screenViewCounts": screenViewCounts,
            "workoutTypeUsage": workoutTypeUsage,
            "featureUsage": featureUsage,
            "totalWorkouts": workoutTypeUsage.values.reduce(0, +),
            "totalScreenViews": screenViewCounts.values.reduce(0, +),
            "totalEvents": eventCounts.values.reduce(0, +)
        ]
    }
    
    // MARK: - Private Helper Methods
    
    /// Setup timer for batch saving
    private func setupSaveTimer() {
        saveTimer = Timer.scheduledTimer(withTimeInterval: saveInterval, repeats: true) { [weak self] _ in
            self?.savePendingEvents()
        }
    }
    
    /// Save pending events and update UserDefaults
    private func savePendingEvents() {
        guard !pendingEvents.isEmpty else { return }
        
        pendingEvents.removeAll()
        saveSessionData()
    }
    
    /// Save session data to UserDefaults
    private func saveSessionData() {
        let sessionData: [String: Any] = [
            "eventCounts": eventCounts,
            "screenViewCounts": screenViewCounts,
            "workoutTypeUsage": workoutTypeUsage,
            "featureUsage": featureUsage,
            "sessionStartTime": sessionStartTime?.timeIntervalSince1970 ?? 0
        ]
        
        UserDefaults.standard.set(sessionData, forKey: sessionDataKey)
    }
    
    /// Load session data from UserDefaults
    private func loadSessionData() {
        guard let sessionData = UserDefaults.standard.dictionary(forKey: sessionDataKey) else {
            return
        }
        
        if let counts = sessionData["eventCounts"] as? [String: Int] {
            eventCounts = counts
        }
        
        if let counts = sessionData["screenViewCounts"] as? [String: Int] {
            screenViewCounts = counts
        }
        
        if let usage = sessionData["workoutTypeUsage"] as? [String: Int] {
            workoutTypeUsage = usage
        }
        
        if let usage = sessionData["featureUsage"] as? [String: Int] {
            featureUsage = usage
        }
        
        if let startTimeInterval = sessionData["sessionStartTime"] as? TimeInterval, startTimeInterval > 0 {
            sessionStartTime = Date(timeIntervalSince1970: startTimeInterval)
        }
    }
} 