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
                    Text("Dashboard")
                }
                .tag(0)
            
            WorkoutListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Workouts")
                }
                .tag(1)
            
            CommunityView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Community")
                }
                .tag(2)
            
            NutritionView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Nutrition")
                }
                .tag(3)
            
            RewardView()
                .tabItem {
                    Image(systemName: "gift")
                    Text("Rewards")
                }
                .tag(4)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(5)
        }
        .accentColor(PureLifeColors.logoGreen)
        .onAppear {
            setupTabBar()
        }
        .onChange(of: colorScheme) { _ in
            setupTabBar()
        }
    }
    
    private func setupTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        if colorScheme == .dark {
            // Configurar apariencia para modo oscuro
            appearance.backgroundColor = UIColor(PureLifeColors.darkBackground)
        } else {
            // Configurar apariencia para modo claro
            appearance.backgroundColor = UIColor.black
        }
        
        // Configurar colores de los items
        let itemAppearance = UITabBarItemAppearance()
        
        // Texto y iconos normales
        itemAppearance.normal.iconColor = UIColor.gray
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        
        // Texto y iconos seleccionados
        itemAppearance.selected.iconColor = UIColor(PureLifeColors.logoGreen)
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(PureLifeColors.logoGreen)]
        
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        // Aplicar la apariencia
        UITabBar.appearance().standardAppearance = appearance
        
        // Para iOS 15+, configurar también scrollEdgeAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
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