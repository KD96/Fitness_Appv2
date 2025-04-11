import SwiftUI

struct NutritionView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.colorScheme) var colorScheme
    
    // State for showing/hiding the AI recommendation
    @State private var showingAIRecommendation = true
    
    var body: some View {
        NavigationView {
            ZStack {
                PureLifeColors.adaptiveBackground(scheme: colorScheme).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Nutrition Plans")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                                .padding(.top, 20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Simple meal plans for your fitness goals")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 20)
                        
                        // AI Nutrition Recommendation (collapsible)
                        if showingAIRecommendation {
                            VStack(spacing: 12) {
                                // Recommendation content
                                NutritionRecommendationView()
                                    .padding(.horizontal, 20)
                                
                                // Toggle button to hide
                                Button(action: {
                                    withAnimation {
                                        showingAIRecommendation = false
                                        dataStore.trackEvent(eventName: "hide_ai_nutrition_plan")
                                    }
                                }) {
                                    HStack {
                                        Text("Hide AI Recommendation")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                        Image(systemName: "chevron.up")
                                            .font(.system(size: 12))
                                    }
                                    .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                                    .padding(.vertical, 8)
                                }
                            }
                            .padding(.bottom, 8)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        } else {
                            // Button to show recommendation if hidden
                            Button(action: {
                                withAnimation {
                                    showingAIRecommendation = true
                                    dataStore.trackEvent(eventName: "show_ai_nutrition_plan")
                                }
                            }) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 12))
                                    Text("Show AI Nutrition Plan")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12))
                                }
                                .foregroundColor(PureLifeColors.logoGreen)
                                .padding(.vertical, 8)
                            }
                            .padding(.bottom, 8)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // Standard Meal Plan Cards
                        Text("Standard Plans")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        
                        mealPlanCard(title: "Weight Loss Plan", 
                                     description: "Low calorie, high protein diet to support weight loss while maintaining muscle mass.",
                                     calories: "1,800",
                                     protein: "30%",
                                     carbs: "40%",
                                     fat: "30%",
                                     icon: "arrow.down.circle.fill",
                                     color: .blue)
                        
                        mealPlanCard(title: "Muscle Gain Plan", 
                                     description: "High protein diet with adequate carbs to fuel workouts and support muscle growth.",
                                     calories: "2,600",
                                     protein: "40%",
                                     carbs: "40%",
                                     fat: "20%",
                                     icon: "figure.arms.open",
                                     color: .orange)
                        
                        mealPlanCard(title: "Balanced Diet", 
                                     description: "Well-balanced macronutrients for overall health and sustained energy levels.",
                                     calories: "2,200",
                                     protein: "25%",
                                     carbs: "50%",
                                     fat: "25%",
                                     icon: "heart.circle.fill",
                                     color: .green)
                        
                        // Nutrition Tips
                        Text("Nutrition Tips")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            
                        tipCard(title: "Stay Hydrated", 
                                description: "Drink at least 8 glasses of water daily to maintain energy levels and support metabolism.",
                                icon: "drop.fill")
                        
                        tipCard(title: "Protein Timing",
                                description: "Consume protein within 30 minutes after workout to maximize muscle recovery.",
                                icon: "clock.fill")
                        
                        tipCard(title: "Balanced Meals",
                                description: "Include a protein source, complex carbs, and healthy fats in each meal for optimal nutrition.",
                                icon: "square.grid.3x3.fill")
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                dataStore.trackScreenView(screenName: "NutritionView")
            }
        }
    }
    
    // MARK: - UI Components
    
    private func mealPlanCard(title: String, description: String, calories: String, protein: String, carbs: String, fat: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Plan header
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                    
                    Text(description)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                        .lineLimit(2)
                }
                
                Spacer()
            }
            
            // Plan details
            VStack(spacing: 12) {
                HStack {
                    Text("Daily Calories:")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    
                    Spacer()
                    
                    Text(calories)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                }
                
                Rectangle()
                    .fill(PureLifeColors.adaptiveDivider(scheme: colorScheme))
                    .frame(height: 1)
                
                HStack(spacing: 0) {
                    // Macros
                    macroItem(name: "Protein", value: protein)
                        .frame(maxWidth: .infinity)
                    
                    macroItem(name: "Carbs", value: carbs)
                        .frame(maxWidth: .infinity)
                    
                    macroItem(name: "Fat", value: fat)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(20)
        .background(PureLifeColors.adaptiveSurface(scheme: colorScheme))
        .cornerRadius(16)
        .shadow(color: PureLifeColors.adaptiveCardShadow(scheme: colorScheme), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    private func macroItem(name: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
            
            Text(name)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
        }
    }
    
    private func tipCard(title: String, description: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(PureLifeColors.logoGreen.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(PureLifeColors.logoGreen)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                
                Text(description)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(16)
        .background(PureLifeColors.adaptiveSurface(scheme: colorScheme))
        .cornerRadius(16)
        .shadow(color: PureLifeColors.adaptiveCardShadow(scheme: colorScheme), radius: 3, x: 0, y: 2)
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

struct NutritionView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionView()
            .environmentObject(AppDataStore())
    }
} 