import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .bottom) {
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
            .onChange(of: colorScheme) { _, _ in
                configureTabBar()
            }
            .onChange(of: dataStore.currentUser.userPreferences.userAppearance) { _, _ in
                configureTabBar()
            }
        }
    }
    
    private func configureTabBar() {
        // Solución más directa para el modo oscuro
        if #available(iOS 15.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            
            // Configuración explícita basada en modo oscuro/claro
            if colorScheme == .dark {
                // Modo oscuro - colores específicos
                tabBarAppearance.configureWithOpaqueBackground()
                tabBarAppearance.backgroundColor = UIColor.black
                
                // Colores personalizados para elementos
                let itemAppearance = UITabBarItemAppearance()
                itemAppearance.normal.iconColor = UIColor.gray
                itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
                itemAppearance.selected.iconColor = UIColor(PureLifeColors.logoGreen)
                itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(PureLifeColors.logoGreen)]
                
                tabBarAppearance.stackedLayoutAppearance = itemAppearance
                tabBarAppearance.inlineLayoutAppearance = itemAppearance
                tabBarAppearance.compactInlineLayoutAppearance = itemAppearance
            } else {
                // Modo claro
                tabBarAppearance.configureWithDefaultBackground()
                tabBarAppearance.backgroundColor = UIColor.white
                
                // Colores personalizados para elementos
                let itemAppearance = UITabBarItemAppearance()
                itemAppearance.normal.iconColor = UIColor.gray
                itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
                itemAppearance.selected.iconColor = UIColor(PureLifeColors.logoGreen)
                itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(PureLifeColors.logoGreen)]
                
                tabBarAppearance.stackedLayoutAppearance = itemAppearance
                tabBarAppearance.inlineLayoutAppearance = itemAppearance
                tabBarAppearance.compactInlineLayoutAppearance = itemAppearance
            }
            
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            UITabBar.appearance().isTranslucent = false
        } else {
            // Configuración para iOS 14 y anteriores
            UITabBar.appearance().isTranslucent = false
            
            if colorScheme == .dark {
                UITabBar.appearance().barTintColor = UIColor.black
            } else {
                UITabBar.appearance().barTintColor = UIColor.white
            }
            
            // Actualizar el estilo de interfaz para iOS 14
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
            .previewDisplayName("Light Mode")
        
        MainTabView()
            .environmentObject(AppDataStore())
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
    }
} 