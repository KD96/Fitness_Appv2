import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    
    // Determinar si se debe usar modo oscuro basado en preferencias
    private var shouldUseDarkMode: Bool {
        switch dataStore.currentUser.userPreferences.userAppearance {
        case .dark:
            return true
        case .light:
            return false
        case .system:
            return colorScheme == .dark
        }
    }
    
    var body: some View {
        ZStack {
            // Fondo adaptable según el modo
            (shouldUseDarkMode ? PureLifeColors.darkBackground : Color.white)
                .edgesIgnoringSafeArea(.all)
            
            TabView(selection: $selectedTab) {
                FitnessView()
                    .tabItem {
                        Image(systemName: "figure.walk")
                        Text("Dashboard")
                    }
                    .tag(0)
                
                WorkoutListView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Workouts")
                    }
                    .tag(1)
                
                NutritionView()
                    .tabItem {
                        Image(systemName: "fork.knife")
                        Text("Nutrition")
                    }
                    .tag(2)
                
                RewardView()
                    .tabItem {
                        Image(systemName: "gift")
                        Text("Rewards")
                    }
                    .tag(3)
                
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .tag(4)
            }
            .accentColor(PureLifeColors.logoGreen)
            .onAppear {
                configureTabBar()
            }
            .onChange(of: shouldUseDarkMode) { _ in
                configureTabBar()
            }
            
            // Overlay para el tabBar que se adapta al color del tema
            VStack {
                Spacer()
                Rectangle()
                    .fill(shouldUseDarkMode ? PureLifeColors.darkBackground : Color.white)
                    .frame(height: 49) // Altura estándar del tab bar
                    .edgesIgnoringSafeArea(.bottom)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    private func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        if shouldUseDarkMode {
            appearance.backgroundColor = UIColor(PureLifeColors.darkBackground)
        } else {
            appearance.backgroundColor = UIColor.white
        }
        
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = shouldUseDarkMode ? UIColor.lightGray : UIColor.gray
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: shouldUseDarkMode ? UIColor.lightGray : UIColor.gray]
        itemAppearance.selected.iconColor = UIColor(PureLifeColors.logoGreen)
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(PureLifeColors.logoGreen)]
        
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        UITabBar.appearance().isTranslucent = false
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