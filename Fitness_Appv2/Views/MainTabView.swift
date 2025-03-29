import SwiftUI

struct MainTabView: View {
    @StateObject var dataStore = AppDataStore()
    @State private var selectedTab = 0
    
    // Colores de PureLife
    private let pureLifeGreen = Color(red: 199/255, green: 227/255, blue: 214/255)
    private let pureLifeBlack = Color.black
    
    var body: some View {
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
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
} 