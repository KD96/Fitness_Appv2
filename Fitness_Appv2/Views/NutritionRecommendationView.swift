import SwiftUI

struct NutritionRecommendationView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.colorScheme) var colorScheme
    
    @State private var recommendation: String?
    @State private var isLoading = false
    @State private var error: String?
    @State private var parsedRecommendation: ParsedNutritionRecommendation?
    
    // OpenAI service
    private let openAIService = OpenAIService()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(PureLifeColors.logoGreen)
                
                Text("AI Nutrition Plan")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                
                Spacer()
                
                Button(action: {
                    fetchRecommendation()
                    dataStore.trackEvent(eventName: "refresh_nutrition_recommendation")
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
                StyledNutritionRecommendation(recommendation: parsedRecommendation, colorScheme: colorScheme)
            } else if let error = error {
                VStack(alignment: .center, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)
                    
                    Text("Couldn't generate nutrition plan.")
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
                    dataStore.trackEvent(eventName: "get_ai_nutrition_recommendation") 
                    dataStore.trackFeatureUsed(featureName: "ai_nutrition")
                }) {
                    HStack {
                        Image(systemName: "sparkles.rectangle.stack.fill")
                            .font(.system(size: 16))
                        
                        Text("Get Personalized Nutrition Plan")
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
        .shadow(color: PureLifeColors.adaptiveCardShadow(scheme: colorScheme), radius: 4, x: 0, y: 2)
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
        
        openAIService.generateNutritionRecommendation(for: dataStore.currentUser) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    self.error = error.localizedDescription
                    print("Error fetching nutrition recommendation: \(error.localizedDescription)")
                } else if let result = result {
                    self.recommendation = result
                    self.parsedRecommendation = parseNutritionRecommendation(result)
                }
            }
        }
    }
    
    private func parseNutritionRecommendation(_ text: String) -> ParsedNutritionRecommendation {
        // Default values
        var planName = "Personalized Nutrition Plan"
        var macros = "Protein: 30%, Carbs: 40%, Fat: 30%"
        var sampleMeal = "Grilled chicken with quinoa and vegetables"
        var tip = "Stay hydrated throughout the day"
        var calories = "2000 calories"
        
        // Try to extract information using simple parsing
        let lines = text.split(separator: "\n")
        
        // Try to extract sections
        for (index, line) in lines.enumerated() {
            let lowercased = line.lowercased()
            
            if lowercased.contains("meal plan") || lowercased.contains("plan name") || lowercased.contains("nutrition plan") {
                planName = String(line.split(separator: ":").last ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            } else if lowercased.contains("macronutrient") || lowercased.contains("macros") {
                macros = String(line.split(separator: ":").last ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            } else if lowercased.contains("sample meal") || lowercased.contains("food suggestion") {
                sampleMeal = String(line.split(separator: ":").last ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Look for multi-line meal description
                if index + 1 < lines.count && !lines[index + 1].lowercased().contains(":") {
                    sampleMeal += "\n" + lines[index + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                }
            } else if lowercased.contains("tip") || lowercased.contains("advice") {
                tip = String(line.split(separator: ":").last ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            } else if lowercased.contains("calorie") || lowercased.contains("calories") {
                calories = String(line.split(separator: ":").last ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        // Extract protein, carbs, fat percentages
        var protein = "30%"
        var carbs = "40%" 
        var fat = "30%"
        
        if macros.lowercased().contains("protein") {
            let components = macros.split(separator: ",")
            for component in components {
                let lowercased = component.lowercased()
                if lowercased.contains("protein") {
                    protein = extractPercentage(from: String(component)) ?? protein
                } else if lowercased.contains("carb") {
                    carbs = extractPercentage(from: String(component)) ?? carbs
                } else if lowercased.contains("fat") {
                    fat = extractPercentage(from: String(component)) ?? fat
                }
            }
        }
        
        return ParsedNutritionRecommendation(
            planName: planName,
            protein: protein,
            carbs: carbs,
            fat: fat,
            sampleMeal: sampleMeal,
            tip: tip,
            calories: calories,
            rawText: text
        )
    }
    
    private func extractPercentage(from text: String) -> String? {
        let pattern = "\\d+%"
        if let range = text.range(of: pattern, options: .regularExpression) {
            return String(text[range])
        }
        return nil
    }
}

// MARK: - Data Structures for Parsed Recommendations

struct ParsedNutritionRecommendation {
    var planName: String
    var protein: String
    var carbs: String
    var fat: String
    var sampleMeal: String
    var tip: String
    var calories: String
    var rawText: String
    
    var planColor: Color {
        if planName.lowercased().contains("weight loss") {
            return .blue
        } else if planName.lowercased().contains("muscle") || planName.lowercased().contains("strength") || planName.lowercased().contains("gain") {
            return .orange
        } else if planName.lowercased().contains("endurance") {
            return .green
        } else {
            return PureLifeColors.logoGreen
        }
    }
    
    var planIcon: String {
        let lowercased = planName.lowercased()
        
        if lowercased.contains("weight loss") {
            return "arrow.down.circle.fill"
        } else if lowercased.contains("muscle") || lowercased.contains("strength") || lowercased.contains("gain") {
            return "figure.arms.open"
        } else if lowercased.contains("endurance") {
            return "figure.run"
        } else if lowercased.contains("balanced") {
            return "equal.circle.fill"
        } else if lowercased.contains("keto") || lowercased.contains("low carb") {
            return "chart.pie.fill"
        } else {
            return "heart.circle.fill"
        }
    }
}

// MARK: - Styled Recommendation View

struct StyledNutritionRecommendation: View {
    let recommendation: ParsedNutritionRecommendation
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Plan name and icon
            HStack {
                ZStack {
                    Circle()
                        .fill(recommendation.planColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: recommendation.planIcon)
                        .font(.system(size: 22))
                        .foregroundColor(recommendation.planColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendation.planName)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                    
                    Text(recommendation.calories)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                }
                
                Spacer()
            }
            
            // Details section
            VStack(spacing: 16) {
                // Macros
                VStack(alignment: .leading, spacing: 10) {
                    Text("Macronutrients")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                    
                    HStack(spacing: 8) {
                        // Protein
                        MacroProgressBar(
                            title: "Protein",
                            value: recommendation.protein,
                            color: .blue,
                            icon: "figure.arms.open",
                            scheme: colorScheme
                        )
                        
                        // Carbs
                        MacroProgressBar(
                            title: "Carbs",
                            value: recommendation.carbs,
                            color: .green,
                            icon: "leaf.fill",
                            scheme: colorScheme
                        )
                        
                        // Fat
                        MacroProgressBar(
                            title: "Fat",
                            value: recommendation.fat,
                            color: .orange,
                            icon: "drop.fill",
                            scheme: colorScheme
                        )
                    }
                }
                
                Divider()
                    .background(PureLifeColors.adaptiveDivider(scheme: colorScheme))
                
                // Sample meal
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 14))
                            .foregroundColor(recommendation.planColor)
                        
                        Text("Sample Meal")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                    }
                    
                    Text(recommendation.sampleMeal)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Divider()
                    .background(PureLifeColors.adaptiveDivider(scheme: colorScheme))
                
                // Nutrition tip
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow)
                        
                        Text("Nutrition Tip")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                    }
                    
                    Text(recommendation.tip)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(PureLifeColors.adaptiveSurfaceSecondary(scheme: colorScheme))
            )
        }
    }
}

struct MacroProgressBar: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    let scheme: ColorScheme
    
    // Extract percentage value (numeric)
    private var percentageValue: Double {
        let numeric = value.filter { "0123456789".contains($0) }
        return Double(numeric) ?? 0
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Icon and percentage
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: scheme))
            }
            
            // Progress bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(PureLifeColors.adaptiveDivider(scheme: scheme))
                    .frame(height: 5)
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(color)
                    .frame(width: max(5, min(percentageValue, 100) / 100 * 70), height: 5)
            }
            
            // Title
            Text(title)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: scheme))
        }
        .frame(width: 70)
    }
}

struct NutritionRecommendationView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionRecommendationView()
            .environmentObject(AppDataStore())
            .previewLayout(.sizeThatFits)
            .padding()
    }
} 