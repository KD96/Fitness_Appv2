import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FitnessView()
                .tabItem {
                    Image(systemName: "figure.walk")
                    Text("Fitness")
                }
                .tag(0)
            
            WorkoutListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Workouts")
                }
                .tag(1)
            
            RewardView()
                .tabItem {
                    Image(systemName: "gift")
                    Text("Rewards")
                }
                .tag(2)
            
            CommunityView()
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Community")
                }
                .tag(3)
        }
        .accentColor(PureLifeColors.logoGreen)
        .onAppear {
            configureTabBar()
        }
    }
    
    private func configureTabBar() {
        // Configuración del aspecto de UITabBar para modo adaptativo
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor(PureLifeColors.adaptiveSurface(scheme: colorScheme))
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        } else {
            // Fallback para iOS 14 y anteriores
            UITabBar.appearance().backgroundColor = UIColor(PureLifeColors.adaptiveSurface(scheme: colorScheme))
            
            // Para iOS 14 y anteriores, configurar manualmente el modo
            switch dataStore.currentUser.userPreferences.userAppearance {
            case .light:
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
            case .dark:
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
            case .system:
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
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
        
        MainTabView()
            .environmentObject(AppDataStore())
            .preferredColorScheme(.dark)
    }
} 