import Foundation

/// A simple analytics manager to track user events and app usage
class AnalyticsManager {
    // Singleton instance
    static let shared = AnalyticsManager()
    
    // Private init for singleton pattern
    private init() {
        loadSessionData()
    }
    
    // Analytics data storage
    private var eventCounts: [String: Int] = [:]
    private var screenViewCounts: [String: Int] = [:]
    private var sessionStartTime: Date?
    private var workoutTypeUsage: [String: Int] = [:]
    private var featureUsage: [String: Int] = [:]
    
    // Session constants
    private let sessionDataKey = "AnalyticsSessionData"
    
    // MARK: - Public Event Tracking Methods
    
    /// Track when a screen is viewed
    func trackScreenView(screenName: String) {
        let count = screenViewCounts[screenName] ?? 0
        screenViewCounts[screenName] = count + 1
        saveSessionData()
    }
    
    /// Track when a user action/event occurs
    func trackEvent(eventName: String) {
        let count = eventCounts[eventName] ?? 0
        eventCounts[eventName] = count + 1
        saveSessionData()
    }
    
    /// Track when a workout is completed
    func trackWorkoutCompleted(type: String, durationMinutes: Int) {
        // Track workout type usage
        let count = workoutTypeUsage[type] ?? 0
        workoutTypeUsage[type] = count + 1
        
        // Track the completed workout event
        trackEvent(eventName: "workout_completed")
        
        saveSessionData()
    }
    
    /// Track feature usage
    func trackFeatureUsed(featureName: String) {
        let count = featureUsage[featureName] ?? 0
        featureUsage[featureName] = count + 1
        saveSessionData()
    }
    
    /// Start a new user session
    func startSession() {
        sessionStartTime = Date()
        saveSessionData()
    }
    
    /// End the current user session
    func endSession() {
        guard let startTime = sessionStartTime else { return }
        
        let sessionDuration = Date().timeIntervalSince(startTime)
        trackEvent(eventName: "session_completed")
        
        // Log session duration (in minutes)
        print("Session duration: \(Int(sessionDuration / 60)) minutes")
        
        sessionStartTime = nil
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