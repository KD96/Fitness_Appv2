import SwiftUI

struct WorkoutRecommendationView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.colorScheme) var colorScheme
    
    @State private var recommendation: String?
    @State private var isLoading = false
    @State private var error: String?
    @State private var parsedRecommendation: ParsedWorkoutRecommendation?
    
    // OpenAI service
    private let openAIService = OpenAIService()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 18))
                    .foregroundColor(PureLifeColors.logoGreen)
                
                Text("AI Workout Suggestion")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                
                Spacer()
                
                Button(action: {
                    fetchRecommendation()
                    dataStore.trackEvent(eventName: "refresh_workout_recommendation")
                }) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(PureLifeColors.logoGreen.opacity(0.8))
                }
            }
            
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                }
                .frame(height: 100)
            } else if let parsedRecommendation = parsedRecommendation {
                StyledWorkoutRecommendation(recommendation: parsedRecommendation, colorScheme: colorScheme)
            } else if let error = error {
                VStack(alignment: .center, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)
                    
                    Text("Couldn't generate recommendation.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                    
                    Text("Check your internet connection and try again.")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(PureLifeColors.adaptiveSurfaceSecondary(scheme: colorScheme))
                )
            } else {
                Button(action: {
                    fetchRecommendation()
                    dataStore.trackEvent(eventName: "get_ai_workout_recommendation")
                    dataStore.trackFeatureUsed(featureName: "ai_recommendations")
                }) {
                    HStack {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 16))
                        
                        Text("Get AI Workout Suggestion")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(PureLifeColors.logoGreen)
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(PureLifeColors.adaptiveSurface(scheme: colorScheme))
        )
        .onAppear {
            // Only auto-fetch if we don't already have a recommendation
            if recommendation == nil && !isLoading {
                fetchRecommendation()
            }
        }
    }
    
    private func fetchRecommendation() {
        isLoading = true
        error = nil
        
        openAIService.generateWorkoutRecommendation(for: dataStore.currentUser) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    self.error = error.localizedDescription
                    print("Error fetching recommendation: \(error.localizedDescription)")
                } else if let result = result {
                    self.recommendation = result
                    self.parsedRecommendation = parseWorkoutRecommendation(result)
                }
            }
        }
    }
    
    private func parseWorkoutRecommendation(_ text: String) -> ParsedWorkoutRecommendation {
        // Default values
        var name = "Custom Workout"
        var type = "Mixed"
        var duration = "30-45 minutes"
        var description = text
        var difficulty = "Moderate"
        
        // Try to extract information using simple parsing
        let lines = text.split(separator: "\n")
        
        for line in lines {
            let lowercased = line.lowercased()
            
            if lowercased.contains("workout name") || 
               lowercased.contains("workout:") ||
               lowercased.contains("name:") {
                name = String(line.split(separator: ":").last ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            } else if lowercased.contains("type") || lowercased.contains("category") {
                type = String(line.split(separator: ":").last ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            } else if lowercased.contains("duration") || lowercased.contains("time") {
                duration = String(line.split(separator: ":").last ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            } else if lowercased.contains("description") || lowercased.contains("details") {
                description = String(line.split(separator: ":").last ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            } else if lowercased.contains("difficulty") || lowercased.contains("level") || lowercased.contains("intensity") {
                difficulty = String(line.split(separator: ":").last ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        return ParsedWorkoutRecommendation(
            name: name,
            type: type,
            duration: duration,
            description: description,
            difficulty: difficulty,
            rawText: text
        )
    }
}

// MARK: - Data Structures for Parsed Recommendations

struct ParsedWorkoutRecommendation {
    var name: String
    var type: String
    var duration: String
    var description: String
    var difficulty: String
    var rawText: String
    
    var workoutTypeIcon: String {
        let lowerType = type.lowercased()
        
        if lowerType.contains("run") {
            return "figure.run"
        } else if lowerType.contains("strength") || lowerType.contains("weight") {
            return "dumbbell"
        } else if lowerType.contains("walk") {
            return "figure.walk"
        } else if lowerType.contains("cycle") || lowerType.contains("bike") {
            return "bicycle"
        } else if lowerType.contains("hiit") {
            return "bolt.heart"
        } else if lowerType.contains("yoga") {
            return "figure.mind.and.body"
        } else {
            return "figure.mixed.cardio"
        }
    }
    
    var difficultyColor: Color {
        let lowerDifficulty = difficulty.lowercased()
        
        if lowerDifficulty.contains("easy") || lowerDifficulty.contains("beginner") {
            return .green
        } else if lowerDifficulty.contains("moderate") || lowerDifficulty.contains("medium") {
            return .orange
        } else if lowerDifficulty.contains("hard") || lowerDifficulty.contains("difficult") || lowerDifficulty.contains("challenging") {
            return .red
        } else {
            return .orange
        }
    }
}

// MARK: - Styled Recommendation View

struct StyledWorkoutRecommendation: View {
    let recommendation: ParsedWorkoutRecommendation
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Workout name and type
            HStack {
                ZStack {
                    Circle()
                        .fill(PureLifeColors.logoGreen.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: recommendation.workoutTypeIcon)
                        .font(.system(size: 22))
                        .foregroundColor(PureLifeColors.logoGreen)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendation.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                    
                    Text(recommendation.type)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                }
                
                Spacer()
            }
            
            // Details section
            VStack(spacing: 12) {
                // Duration and difficulty
                HStack {
                    // Duration badge
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                        
                        Text(recommendation.duration)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        Capsule()
                            .fill(PureLifeColors.adaptiveSurfaceSecondary(scheme: colorScheme))
                    )
                    
                    Spacer()
                    
                    // Difficulty badge
                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 12))
                            .foregroundColor(recommendation.difficultyColor)
                        
                        Text(recommendation.difficulty)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(recommendation.difficultyColor)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        Capsule()
                            .fill(recommendation.difficultyColor.opacity(0.15))
                    )
                }
                
                Divider()
                    .background(PureLifeColors.adaptiveDivider(scheme: colorScheme))
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "text.bubble.fill")
                            .font(.system(size: 14))
                            .foregroundColor(PureLifeColors.logoGreen)
                        
                        Text("Description")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                    }
                    
                    Text(recommendation.description)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Try it button
                Button(action: {
                    // Action to start this workout would go here
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14))
                        
                        Text("Try This Workout")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(PureLifeColors.logoGreen)
                    )
                }
                .padding(.top, 4)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(PureLifeColors.adaptiveSurfaceSecondary(scheme: colorScheme))
            )
        }
    }
}

struct WorkoutRecommendationView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutRecommendationView()
            .environmentObject(AppDataStore())
            .previewLayout(.sizeThatFits)
            .padding()
    }
} 