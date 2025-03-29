import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Binding var isShowingOnboarding: Bool
    @State private var currentPage = 0
    @State private var userName = ""
    @State private var selectedGoal: UserPreferences.FitnessGoal = .loseWeight
    @State private var selectedActivities: [WorkoutType] = []
    
    // Colores de PureLife
    private let pureLifeGreen = Color(red: 199/255, green: 227/255, blue: 214/255)
    private let pureLifeLightGreen = Color(red: 220/255, green: 237/255, blue: 230/255)
    private let pureLifeBlack = Color.black
    
    var body: some View {
        ZStack {
            pureLifeLightGreen.ignoresSafeArea()
            
            VStack {
                // Logo header
                VStack(spacing: 4) {
                    HStack {
                        Text("pure")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(pureLifeBlack) +
                        Text("life")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(pureLifeBlack) +
                        Text(".")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(pureLifeBlack)
                    }
                    
                    logoView
                }
                .padding(.top, 50)
                
                // Page content
                TabView(selection: $currentPage) {
                    // Welcome page
                    welcomeView
                        .tag(0)
                    
                    // Name page
                    namePage
                        .tag(1)
                    
                    // Goals page
                    goalsPage
                        .tag(2)
                    
                    // Activities page
                    activitiesPage
                        .tag(3)
                    
                    // Rewards page
                    rewardsPage
                        .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Page indicators
                pageControl
                
                // Navigation buttons
                HStack {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            Text("Back")
                                .font(.headline)
                                .foregroundColor(pureLifeBlack)
                                .padding()
                                .frame(width: 100)
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                    } else {
                        Spacer()
                            .frame(width: 100)
                    }
                    
                    Spacer()
                    
                    // Next/Finish button
                    Button(action: {
                        if currentPage == 4 {
                            // Finish onboarding
                            completeOnboarding()
                        } else {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                    }) {
                        Text(currentPage == 4 ? "Get Started" : "Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 150)
                            .background(pureLifeBlack)
                            .cornerRadius(10)
                    }
                    .disabled(currentPage == 1 && userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
    
    // MARK: - Content Pages
    
    private var welcomeView: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 30) {
                // Logo
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80)
                
                Text("Track your fitness journey, earn rewards, and connect with friends.")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(PureLifeColors.textSecondary)
                    .padding(.horizontal, 30)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    private var namePage: some View {
        VStack(spacing: 30) {
            Text("What's your name?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(pureLifeBlack)
            
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(pureLifeGreen)
            
            TextField("Enter your name", text: $userName)
                .font(.title3)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal, 40)
            
            Text("We'll use this to personalize your experience")
                .font(.caption)
                .foregroundColor(pureLifeBlack.opacity(0.7))
        }
        .padding()
    }
    
    private var goalsPage: some View {
        VStack(spacing: 20) {
            Text("What's your primary fitness goal?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(pureLifeBlack)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(UserPreferences.FitnessGoal.allCases, id: \.self) { goal in
                        GoalOptionButton(
                            goal: goal,
                            isSelected: selectedGoal == goal,
                            action: {
                                selectedGoal = goal
                            }
                        )
                    }
                }
                .padding(.horizontal, 30)
            }
            .frame(height: 300)
        }
        .padding()
    }
    
    private var activitiesPage: some View {
        VStack(spacing: 20) {
            Text("What activities do you enjoy?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(pureLifeBlack)
                .multilineTextAlignment(.center)
            
            Text("Select all that apply")
                .font(.subheadline)
                .foregroundColor(pureLifeBlack.opacity(0.7))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(WorkoutType.allCases, id: \.self) { activity in
                            ActivityButton(
                                activity: activity,
                                isSelected: selectedActivities.contains(activity),
                                action: {
                                    if selectedActivities.contains(activity) {
                                        selectedActivities.removeAll { $0 == activity }
                                    } else {
                                        selectedActivities.append(activity)
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(height: 300)
        }
        .padding()
    }
    
    private var rewardsPage: some View {
        VStack(spacing: 25) {
            Text("Earn Rewards for Your Activity")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(pureLifeBlack)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Token icon
            ZStack {
                Circle()
                    .fill(pureLifeGreen)
                    .frame(width: 120, height: 120)
                
                Text("PURE")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(pureLifeBlack)
            }
            
            // Reward items
            VStack(alignment: .leading, spacing: 15) {
                FeatureItem(
                    icon: "bitcoinsign.circle",
                    title: "Earn Crypto",
                    description: "Convert your tokens to cryptocurrency"
                )
                
                FeatureItem(
                    icon: "tag.fill",
                    title: "Exclusive Discounts",
                    description: "Unlock partner offers and deals"
                )
                
                FeatureItem(
                    icon: "star.fill",
                    title: "Premium Experiences",
                    description: "Access unique events and content"
                )
            }
            .padding(.horizontal, 30)
        }
        .padding()
    }
    
    private var logoView: some View {
        VStack(spacing: 10) {
            Text("Track your fitness journey, earn rewards, and connect with friends.")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(PureLifeColors.textSecondary)
                .padding(.horizontal, 30)
        }
    }
    
    // MARK: - Helper Views
    
    private var pageControl: some View {
        HStack(spacing: 8) {
            ForEach(0..<5) { i in
                Circle()
                    .fill(currentPage == i ? pureLifeBlack : pureLifeBlack.opacity(0.2))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.bottom, 20)
    }
    
    private struct GoalOptionButton: View {
        let goal: UserPreferences.FitnessGoal
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Image(systemName: goal.icon)
                        .font(.title3)
                        .foregroundColor(isSelected ? .white : .primary)
                        .frame(width: 30)
                    
                    Text(goal.rawValue)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color(red: 199/255, green: 227/255, blue: 214/255) : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color(red: 199/255, green: 227/255, blue: 214/255) : Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
    
    private struct ActivityButton: View {
        let activity: WorkoutType
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 12) {
                    Image(systemName: activity.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(activity.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white : .primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color(red: 199/255, green: 227/255, blue: 214/255) : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color(red: 199/255, green: 227/255, blue: 214/255) : Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
    
    private struct FeatureItem: View {
        let icon: String
        let title: String
        let description: String
        
        var body: some View {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(Color.black)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Actions
    
    private func completeOnboarding() {
        // Update user data
        if !userName.isEmpty {
            dataStore.currentUser.name = userName
        }
        
        // Update user preferences
        dataStore.currentUser.userPreferences.fitnessGoal = selectedGoal
        if !selectedActivities.isEmpty {
            dataStore.currentUser.userPreferences.favoriteActivities = selectedActivities
        }
        
        // Add initial bonus tokens
        dataStore.currentUser.tokenBalance += 10
        dataStore.currentUser.cryptoWallet.addTransaction(
            amount: 10,
            type: .received,
            description: "Welcome bonus"
        )
        
        // Save data
        dataStore.saveData()
        
        // Close onboarding
        isShowingOnboarding = false
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isShowingOnboarding: .constant(true))
            .environmentObject(AppDataStore())
    }
} 