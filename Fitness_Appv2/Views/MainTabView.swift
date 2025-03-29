import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var selectedTab = 0
    
    init() {
        // Configuración del aspecto de UITabBar para modo claro
        UITabBar.appearance().backgroundColor = UIColor(PureLifeColors.surface)
        UITabBar.appearance().unselectedItemTintColor = UIColor(PureLifeColors.textSecondary)
        
        // Elimina la línea superior del TabBar
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        
        // Configuración adicional si es iOS 15+
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(PureLifeColors.surface)
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard principal
            UserStatsView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "chart.bar.fill" : "chart.bar")
                    Text("Stats")
                }
                .tag(0)
            
            // Vista de entrenamientos
            WorkoutListView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "figure.run.circle.fill" : "figure.run.circle")
                    Text("Workouts")
                }
                .tag(1)
            
            // Vista para iniciar un nuevo entrenamiento
            NewWorkoutView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "plus.circle.fill" : "plus.circle")
                    Text("Add")
                }
                .tag(2)
            
            // Comunidad
            CommunityView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.3.fill" : "person.3")
                    Text("Community")
                }
                .tag(3)
            
            // Recompensas
            RewardView()
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "gift.fill" : "gift")
                    Text("Rewards")
                }
                .tag(4)
        }
        .accentColor(PureLifeColors.pureGreen)
        .onAppear {
            // Aplicar el tema claro
            if #available(iOS 15.0, *) {
                // En iOS 15 y posteriores
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.windows.first?.overrideUserInterfaceStyle = .light
            } else {
                // Para iOS 14 y anteriores
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
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
    }
} 