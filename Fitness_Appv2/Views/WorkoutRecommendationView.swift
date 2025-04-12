import SwiftUI

struct WorkoutRecommendationView: View {
    // MARK: - Properties
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.colorScheme) var colorScheme
    
    @State private var recommendation: String?
    @State private var isLoading = false
    @State private var error: String?
    @State private var parsedRecommendation: ParsedWorkoutRecommendation?
    @State private var showingSavedMessage = false
    
    // Services
    private let openAIService = OpenAIService()
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 12) {
            headerView
            
            // Main content container - adapts height to content
            contentView
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(PureLifeColors.adaptiveSurface(scheme: colorScheme))
                )
            
            if showingSavedMessage {
                savedConfirmationView
            }
        }
        .onAppear {
            if recommendation == nil && !isLoading {
                fetchRecommendation()
            }
        }
    }
    
    // MARK: - UI Components
    
    private var headerView: some View {
        HStack {
            Text("AI Workout Suggestion")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
            
            Spacer()
            
            Button(action: {
                fetchRecommendation()
                dataStore.trackEvent(eventName: "refresh_workout_recommendation")
            }) {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(PureLifeColors.logoGreen)
            }
        }
    }
    
    private var savedConfirmationView: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Text("Workout saved")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            Capsule()
                .fill(Color.green)
        )
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    // MARK: - Content Views
    
    @ViewBuilder
    private var contentView: some View {
        if isLoading {
            loadingView
        } else if let error = error {
            errorView(error)
        } else if let recommendation = parsedRecommendation {
            recommendationView(recommendation)
        } else {
            emptyStateView
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: PureLifeColors.logoGreen))
            Text("Crafting your personalized workout...")
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                .multilineTextAlignment(.center)
        }
        .frame(minHeight: 150)
        .padding(16)
    }
    
    private func errorView(_ errorMessage: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 28))
                .foregroundColor(PureLifeColors.error)
            
            Text(errorMessage)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Button(action: {
                fetchRecommendation()
            }) {
                Text("Try Again")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Capsule().fill(PureLifeColors.logoGreen))
            }
        }
        .frame(minHeight: 150)
        .padding(16)
    }
    
    private func recommendationView(_ recommendation: ParsedWorkoutRecommendation) -> some View {
        ZStack(alignment: .bottom) {
            // Background image - with validated dimensions and proper fallback
            let imageName = getBackgroundImageForWorkoutType(recommendation.type.lowercased())
            if let _ = UIImage(named: imageName) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipped()
            } else {
                // Fallback gradient if image isn't available
                LinearGradient(
                    gradient: Gradient(colors: [PureLifeColors.logoGreen, PureLifeColors.logoGreenDark]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(maxWidth: .infinity)
                .frame(height: 180)
            }
            
            // Text content overlay
            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text(recommendation.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(3)
                
                Text(recommendation.duration)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 4)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.black.opacity(0.7), .black.opacity(0)]),
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 5)
        .frame(maxWidth: .infinity)
        .frame(height: 180)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 10) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 28))
                .foregroundColor(PureLifeColors.logoGreen)
            
            Text("Tap refresh to get a workout suggestion")
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                .multilineTextAlignment(.center)
        }
        .frame(minHeight: 150)
        .padding(16)
    }
    
    // MARK: - Helper methods
    
    private func fetchRecommendation() {
        isLoading = true
        error = nil
        
        // Dismiss keyboard if present
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        // Track analytics
        dataStore.trackEvent(eventName: "request_workout_recommendation")
        
        // Small delay to ensure UI updates completely before network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            self.openAIService.generateWorkoutRecommendation(for: self.dataStore.currentUser) { [self] result, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.error = error.localizedDescription
                        print("Error fetching recommendation: \(error.localizedDescription)")
                        
                        // Track error for analytics
                        self.dataStore.trackEvent(
                            eventName: "workout_recommendation_error",
                            parameters: ["error": error.localizedDescription]
                        )
                    } else if let result = result {
                        self.recommendation = result
                        self.parsedRecommendation = self.parseWorkoutRecommendation(result)
                        
                        // Track success for analytics
                        self.dataStore.trackFeatureUsed(featureName: "ai_workout_recommendation")
                    }
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
    
    private func getBackgroundImageForWorkoutType(_ type: String) -> String {
        switch type.lowercased() {
        case "running":
            return "running"
        case "cycling":
            return "cycling"
        case "walking", "hiking":
            return "Bike"
        case "weight training", "strength", "weights":
            return "weight_lifting"
        case "yoga", "stretching":
            return "yoga"
        case "swimming", "water sports":
            return "couple athlete"
        case "tennis", "badminton", "racket sports":
            return "Tennis"
        case "hiit", "high intensity interval training":
            return "weight_lifting"
        case "boxing", "martial arts":
            return "Boxer"
        case "snowboarding", "skiing", "winter sports":
            return "snowboarding"
        default:
            return "fitness_background"
        }
    }
    
    private func extractMinutesFromDuration(_ duration: String) -> Int {
        let components = duration.split(separator: "-")
        guard components.count == 2 else { return 30 } // Default to 30 minutes if format is incorrect
        
        let start = components[0].split(separator: " ")
        let end = components[1].split(separator: " ")
        
        guard start.count == 2, end.count == 2 else { return 30 } // Default to 30 minutes if format is incorrect
        
        let startMinutes = Int(start[0]) ?? 0
        let endMinutes = Int(end[0]) ?? 0
        
        return (startMinutes + endMinutes) / 2 // Average the two durations
    }
    
    private func saveWorkout(_ recommendation: ParsedWorkoutRecommendation) {
        // All properties are non-optional at this point
        let name = recommendation.name 
        let type = recommendation.type
        let durationString = recommendation.duration
        let description = recommendation.description
        
        // Convert duration string to minutes
        let durationMinutes = extractMinutesFromDuration(durationString)
        
        // Create and save the workout
        let newWorkout = Workout(
            name: name,
            type: WorkoutType(rawValue: type) ?? .running,
            durationMinutes: durationMinutes,
            date: Date(),
            caloriesBurned: calculateEstimatedCalories(for: durationMinutes, type: type),
            tokensEarned: 10, // Default token reward
            notes: description,
            completed: false)
        
        dataStore.saveWorkout(newWorkout)
        dataStore.trackEvent(eventName: "save_ai_recommended_workout")
        dataStore.trackFeatureUsed(featureName: "ai_workout_recommendation")
        
        // Show confirmation
        withAnimation {
            showingSavedMessage = true
            
            // Hide message after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                withAnimation {
                    self.showingSavedMessage = false
                }
            }
        }
    }
    
    // Calculate estimated calories based on workout duration and type
    private func calculateEstimatedCalories(for minutes: Int, type: String) -> Double {
        let baseCaloriesPerMinute: Double
        
        switch type.lowercased() {
        case _ where type.contains("run"):
            baseCaloriesPerMinute = 10.0
        case _ where type.contains("walk"):
            baseCaloriesPerMinute = 5.0
        case _ where type.contains("cycl") || type.contains("bike"):
            baseCaloriesPerMinute = 8.0
        case _ where type.contains("strength") || type.contains("weight"):
            baseCaloriesPerMinute = 7.0
        case _ where type.contains("hiit"):
            baseCaloriesPerMinute = 12.0
        case _ where type.contains("yoga"):
            baseCaloriesPerMinute = 4.0
        default:
            baseCaloriesPerMinute = 6.0
        }
        
        return Double(minutes) * baseCaloriesPerMinute
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