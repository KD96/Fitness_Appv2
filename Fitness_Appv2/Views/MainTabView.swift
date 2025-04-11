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
                        Text("Dashboard")
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
                
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .tag(3)
            }
            .accentColor(PureLifeColors.logoGreen)
            .edgesIgnoringSafeArea(.all)
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
        .edgesIgnoringSafeArea(.bottom)
        .background(PureLifeColors.adaptiveBackground(scheme: colorScheme).edgesIgnoringSafeArea(.all))
    }
    
    private func configureTabBar() {
        // Solución para el modo oscuro/claro
        if #available(iOS 15.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            
            // Configuración basada en modo oscuro/claro
            if colorScheme == .dark {
                // Modo oscuro - colores específicos
                tabBarAppearance.configureWithDefaultBackground()
                tabBarAppearance.backgroundColor = UIColor(PureLifeColors.adaptiveSurface(scheme: .dark))
                
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
                tabBarAppearance.backgroundColor = UIColor(PureLifeColors.adaptiveSurface(scheme: .light))
                
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
            
            // Aplicar apariencia y hacer que sea translúcido
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            UITabBar.appearance().isTranslucent = true
        } else {
            // Configuración para iOS 14 y anteriores
            UITabBar.appearance().isTranslucent = true
            
            if colorScheme == .dark {
                UITabBar.appearance().barTintColor = UIColor(PureLifeColors.adaptiveSurface(scheme: .dark))
            } else {
                UITabBar.appearance().barTintColor = UIColor(PureLifeColors.adaptiveSurface(scheme: .light))
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