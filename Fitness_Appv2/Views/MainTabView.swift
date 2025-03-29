import SwiftUI

struct MainTabView: View {
    @StateObject var dataStore = AppDataStore()
    @State private var selectedTab = 0
    @State private var isShowingOnboarding = false
    
    // Colores de PureLife
    private let pureLifeGreen = Color(red: 199/255, green: 227/255, blue: 214/255)
    private let pureLifeBlack = Color.black
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                FitnessView()
                    .tabItem {
                        Label("Fitness", systemImage: "figure.run")
                    }
                    .tag(0)
                
                RewardView()
                    .tabItem {
                        Label("Rewards", systemImage: "star.fill")
                    }
                    .tag(1)
                
                SocialView()
                    .tabItem {
                        Label("Social", systemImage: "person.2.fill")
                    }
                    .tag(2)
            }
            .accentColor(pureLifeBlack) 
            .environmentObject(dataStore)
            .onAppear {
                dataStore.loadData()
                
                // Verificar si es la primera vez que se abre la app
                if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                    isShowingOnboarding = true
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                }
                
                // Personalizar la apariencia de la TabBar
                let appearance = UITabBarAppearance()
                appearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)
                appearance.backgroundColor = UIColor(pureLifeGreen.opacity(0.95))
                
                // Color para los ítems seleccionados y no seleccionados
                let itemAppearance = UITabBarItemAppearance()
                itemAppearance.normal.iconColor = UIColor.darkGray
                itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.darkGray]
                itemAppearance.selected.iconColor = UIColor.black
                itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.black]
                
                appearance.stackedLayoutAppearance = itemAppearance
                appearance.inlineLayoutAppearance = itemAppearance
                appearance.compactInlineLayoutAppearance = itemAppearance
                
                // Establecer la apariencia para diferentes estados
                UITabBar.appearance().standardAppearance = appearance
                if #available(iOS 15.0, *) {
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
            }
            .transition(.opacity)
            .animation(.easeInOut, value: selectedTab)
            
            // Mostrar onboarding como una fullscreen cover
            if isShowingOnboarding {
                OnboardingView(isShowingOnboarding: $isShowingOnboarding)
                    .environmentObject(dataStore)
                    .transition(.opacity)
                    .zIndex(1) // Asegurar que está por encima del TabView
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
    }
} 