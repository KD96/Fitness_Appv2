import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    
    // Add transition animation state
    @Namespace private var tabAnimation
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FitnessView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(0)
                .background(
                    tabBackground(imageName: "fitness_background", opacity: 0.05)
                )
            
            WorkoutListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Workouts")
                }
                .tag(1)
                .background(
                    tabBackground(imageName: "weight_lifting", opacity: 0.05)
                )
            
            CommunityView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Community")
                }
                .tag(2)
                .background(
                    tabBackground(imageName: "couple athlete", opacity: 0.05)
                )
            
            NutritionView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Nutrition")
                }
                .tag(3)
                .background(
                    tabBackground(imageName: "athlete_banner", opacity: 0.05)
                )
            
            RewardView()
                .tabItem {
                    Image(systemName: "gift")
                    Text("Rewards")
                }
                .tag(4)
                .background(
                    tabBackground(imageName: "women athlete", opacity: 0.05)
                )
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(5)
                .background(
                    tabBackground(imageName: "Boxer", opacity: 0.05)
                )
        }
        .accentColor(PureLifeColors.logoGreen)
        .onAppear {
            setupTabBar()
        }
        .onChange(of: colorScheme) { _ in
            setupTabBar()
        }
        // Add transition animation
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
    }
    
    private func setupTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        
        // Apply blur background effect
        appearance.backgroundEffect = UIBlurEffect(style: colorScheme == .dark ? .systemUltraThinMaterialDark : .systemUltraThinMaterialLight)
        
        // Add subtle border at the top
        appearance.shadowColor = UIColor(PureLifeColors.adaptiveDivider(scheme: colorScheme))
        
        // Configure tab styling
        let itemAppearance = UITabBarItemAppearance()
        
        // Enhance selected state with more prominence
        itemAppearance.selected.iconColor = UIColor(PureLifeColors.logoGreen)
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(PureLifeColors.logoGreen),
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ]
        
        // Soften unselected state for better contrast
        itemAppearance.normal.iconColor = UIColor.gray.withAlphaComponent(0.7)
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray.withAlphaComponent(0.7),
            .font: UIFont.systemFont(ofSize: 11, weight: .medium)
        ]
        
        // Apply the appearance to all layout types
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        // Apply the appearance
        UITabBar.appearance().standardAppearance = appearance
        
        // For iOS 15+, configure also scrollEdgeAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    // Helper method to create a subtle background with a real image
    private func tabBackground(imageName: String, opacity: Double = 0.05) -> some View {
        Group {
            if let image = UIImage(named: imageName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .opacity(opacity)
                    .blur(radius: 2)
            } else {
                Color.clear // Fallback si la imagen no está disponible
            }
        }
    }
}

// MARK: - Botón para reiniciar onboarding (solo para desarrollo)
extension MainTabView {
    func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AppDataStore())
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
        
        MainTabView()
            .environmentObject(AppDataStore())
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
    }
} 