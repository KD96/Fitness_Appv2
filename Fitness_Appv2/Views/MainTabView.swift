import SwiftUI

struct MainTabView: View {
    @StateObject var dataStore = AppDataStore()
    
    var body: some View {
        TabView {
            FitnessView()
                .tabItem {
                    Label("Fitness", systemImage: "figure.run")
                }
            
            RewardView()
                .tabItem {
                    Label("Rewards", systemImage: "star.fill")
                }
            
            SocialView()
                .tabItem {
                    Label("Social", systemImage: "person.2")
                }
        }
        .accentColor(.blue)
        .environmentObject(dataStore)
        .onAppear {
            dataStore.loadData()
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
} 