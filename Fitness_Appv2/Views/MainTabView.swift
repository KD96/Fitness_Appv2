import SwiftUI

struct MainTabView: View {
    @StateObject var dataStore = AppDataStore()
    @State private var selectedTab = 0
    
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
        .accentColor(Color(red: 0.0, green: 0.7, blue: 0.9)) // Más vibrante que el azul estándar
        .environmentObject(dataStore)
        .onAppear {
            dataStore.loadData()
            
            // Personalizar la apariencia de la TabBar
            let appearance = UITabBarAppearance()
            appearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)
            appearance.backgroundColor = UIColor(Color(UIColor.systemBackground).opacity(0.95))
            
            // Establecer la apariencia para diferentes estados
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
        .transition(.slide)
        .animation(.easeInOut, value: selectedTab)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
} 