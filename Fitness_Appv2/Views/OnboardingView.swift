import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Binding var isShowingOnboarding: Bool
    @State private var currentPage = 0
    @State private var userName = ""
    @State private var selectedGoal: UserPreferences.FitnessGoal = .general
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
                    
                    // Name and goals page (combined)
                    nameAndGoalsPage
                        .tag(1)
                    
                    // Activities page
                    activitiesPage
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Page indicators
                HStack {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(currentPage == index ? pureLifeBlack : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding()
                
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
                        if currentPage == 2 {
                            // Finish onboarding
                            completeOnboarding()
                        } else {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                    }) {
                        Text(currentPage == 2 ? "Get Started" : "Next")
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
                Image(systemName: "figure.run")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80)
                    .foregroundColor(pureLifeBlack)
                
                // Icono atlético en lugar de imagen
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.green.opacity(0.2)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 200)
                    
                    Image(systemName: "figure.mixed.cardio")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 30)
                .shadow(radius: 5)
                
                Text("Track your fitness journey and earn rewards")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(PureLifeColors.textSecondary)
                    .padding(.horizontal, 30)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    private var nameAndGoalsPage: some View {
        VStack(spacing: 20) {
            Text("Let's get to know you")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(pureLifeBlack)
            
            // Name field
            VStack(alignment: .leading) {
                Text("Your name")
                    .font(.headline)
                    .foregroundColor(pureLifeBlack.opacity(0.8))
                
                TextField("Enter your name", text: $userName)
                    .font(.title3)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            // Goals selection
            VStack(alignment: .leading) {
                Text("Your fitness goal")
                    .font(.headline)
                    .foregroundColor(pureLifeBlack.opacity(0.8))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(UserPreferences.FitnessGoal.allCases, id: \.self) { goal in
                            goalButton(goal)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 20)
        }
        .padding()
    }
    
    private var activitiesPage: some View {
        VStack(spacing: 20) {
            Text("What activities do you enjoy?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(pureLifeBlack)
            
            Text("Select all that apply")
                .font(.subheadline)
                .foregroundColor(pureLifeBlack.opacity(0.7))
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(WorkoutType.allCases, id: \.self) { activity in
                    activityButton(activity)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding()
    }
    
    // MARK: - Helper Views
    
    private var logoView: some View {
        ZStack {
            Rectangle()
                .fill(pureLifeGreen)
                .frame(width: 60, height: 3)
                .offset(y: -15)
            
            Text("FITNESS")
                .font(.system(size: 11, weight: .heavy))
                .foregroundColor(pureLifeBlack)
                .kerning(2)
        }
        .padding(.bottom, 10)
    }
    
    private func goalButton(_ goal: UserPreferences.FitnessGoal) -> some View {
        Button(action: {
            selectedGoal = goal
        }) {
            VStack {
                Image(systemName: goal.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(selectedGoal == goal ? .white : pureLifeBlack)
                    .padding(10)
                    .background(selectedGoal == goal ? pureLifeBlack : Color.white)
                    .clipShape(Circle())
                
                Text(goal.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(selectedGoal == goal ? pureLifeBlack : pureLifeBlack.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: 80)
            }
            .padding(8)
            .background(selectedGoal == goal ? pureLifeGreen.opacity(0.3) : Color.clear)
            .cornerRadius(10)
        }
    }
    
    private func activityButton(_ activity: WorkoutType) -> some View {
        Button(action: {
            if selectedActivities.contains(activity) {
                selectedActivities.removeAll { $0 == activity }
            } else {
                selectedActivities.append(activity)
            }
        }) {
            HStack {
                Image(systemName: activity.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(selectedActivities.contains(activity) ? .white : pureLifeBlack)
                
                Text(activity.rawValue.capitalized)
                    .font(.callout)
                    .foregroundColor(selectedActivities.contains(activity) ? .white : pureLifeBlack)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(selectedActivities.contains(activity) ? pureLifeBlack : Color.white)
            .cornerRadius(10)
        }
    }
    
    // MARK: - Actions
    
    private func completeOnboarding() {
        // Create user with onboarding data
        var user = dataStore.currentUser
        user.name = userName
        user.userPreferences.fitnessGoal = selectedGoal
        user.userPreferences.favoriteActivities = selectedActivities
        
        // Update user in data store
        dataStore.updateUser(user)
        
        // Mark onboarding as completed
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        isShowingOnboarding = false
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isShowingOnboarding: .constant(true))
            .environmentObject(AppDataStore())
    }
} 