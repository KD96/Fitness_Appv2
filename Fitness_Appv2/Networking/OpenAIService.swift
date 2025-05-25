import Foundation

class OpenAIService {
    private let baseURL = "https://api.openai.com/v1"
    
    // Use secure API configuration
    private var apiKey: String? {
        return APIConfig.openAIAPIKey
    }
    
    private var isConfigured: Bool {
        return apiKey != nil && !apiKey!.isEmpty
    }
    
    func generateWorkoutRecommendation(for user: User, completion: @escaping (String?, Error?) -> Void) {
        guard isConfigured else {
            completion(nil, OpenAIError.notConfigured)
            return
        }
        
        let prompt = createWorkoutPrompt(for: user)
        generateCompletion(prompt: prompt, completion: completion)
    }
    
    func generateNutritionRecommendation(for user: User, completion: @escaping (String?, Error?) -> Void) {
        guard isConfigured else {
            completion(nil, OpenAIError.notConfigured)
            return
        }
        
        let prompt = createNutritionPrompt(for: user)
        generateCompletion(prompt: prompt, completion: completion)
    }
    
    private func generateCompletion(prompt: String, completion: @escaping (String?, Error?) -> Void) {
        guard let apiKey = apiKey else {
            completion(nil, OpenAIError.notConfigured)
            return
        }
        
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            completion(nil, OpenAIError.invalidURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a professional fitness and nutrition expert. Provide personalized, safe, and practical recommendations based on the user's profile and activity history."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 300,
            "temperature": 0.7
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(nil, error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, OpenAIError.noData)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(content.trimmingCharacters(in: .whitespacesAndNewlines), nil)
                } else {
                    completion(nil, OpenAIError.invalidResponse)
                }
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    // Create a workout prompt based on user data
    private func createWorkoutPrompt(for user: User) -> String {
        let recentWorkouts = user.completedWorkouts.prefix(3).map { workout in
            "- \(workout.name) (\(workout.type.rawValue), \(workout.durationMinutes) minutes, \(workout.date.formatted()))"
        }.joined(separator: "\n")
        
        let favoriteActivities = user.userPreferences.favoriteActivities.map { $0.rawValue }.joined(separator: ", ")
        
        return """
        User Profile:
        - Fitness Goal: \(user.userPreferences.fitnessGoal.rawValue)
        - Favorite Activities: \(favoriteActivities.isEmpty ? "Not specified" : favoriteActivities)
        - Workout Streak: \(user.workoutStreak) days
        - Experience Level: \(user.currentLevel.name)
        
        Recent Workouts:
        \(recentWorkouts.isEmpty ? "No recent workouts" : recentWorkouts)
        
        Based on this information, suggest ONE specific workout that would be appropriate for today, including:
        1. Workout name
        2. Type of workout
        3. Duration
        4. Brief description (1-2 sentences)
        5. Expected difficulty level
        
        Keep it concise and actionable.
        """
    }
    
    // Create a nutrition prompt based on user data
    private func createNutritionPrompt(for user: User) -> String {
        let recentWorkouts = user.completedWorkouts.prefix(3).map { workout in
            "- \(workout.name) (\(workout.type.rawValue), \(workout.durationMinutes) minutes, \(workout.date.formatted()))"
        }.joined(separator: "\n")
        
        let caloriesBurned = user.completedWorkouts.prefix(5).reduce(0) { $0 + $1.caloriesBurned }
        let averageCaloriesBurned = user.completedWorkouts.isEmpty ? 0 : caloriesBurned / Double(min(user.completedWorkouts.count, 5))
        
        return """
        User Profile:
        - Fitness Goal: \(user.userPreferences.fitnessGoal.rawValue)
        - Workout Streak: \(user.workoutStreak) days
        - Experience Level: \(user.currentLevel.name)
        - Average Calories Burned per Workout: \(Int(averageCaloriesBurned)) calories
        
        Recent Workouts:
        \(recentWorkouts.isEmpty ? "No recent workouts" : recentWorkouts)
        
        Based on this information, provide ONE personalized nutrition recommendation for today, including:
        1. Meal plan name tailored to their goal
        2. Suggested macronutrient distribution (protein, carbs, fat percentages)
        3. A sample food suggestion for one meal
        4. One nutritional tip related to their workout pattern
        5. Approximate calorie target based on their activity level
        
        Keep it practical, specific to their recent activity, and easy to follow.
        """
    }
}

// MARK: - Error Types

enum OpenAIError: LocalizedError {
    case notConfigured
    case invalidURL
    case noData
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "OpenAI API is not properly configured. Please check your API key setup."
        case .invalidURL:
            return "Invalid API URL"
        case .noData:
            return "No data received from API"
        case .invalidResponse:
            return "Invalid response format from API"
        }
    }
} 