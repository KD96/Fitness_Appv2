import SwiftUI

struct CommunityView: View {
    @EnvironmentObject var dataStore: AppDataStore
    
    var body: some View {
        ZStack {
            // Fondo principal
            PureLifeColors.darkBackground.ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 20) {
                // Logo
                HStack {
                    HStack(spacing: 0) {
                        Text("pure")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.pureGreen)
                        
                        Text("life")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.textPrimary)
                        
                        Text(".")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.pureGreen)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Mensaje de características por venir
                VStack(spacing: 20) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 70))
                        .foregroundColor(PureLifeColors.pureGreen)
                    
                    Text("Community Features Coming Soon")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(PureLifeColors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("Connect with friends, join challenges, and compete on leaderboards.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(PureLifeColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
            }
        }
    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
            .environmentObject(AppDataStore())
            .preferredColorScheme(.dark)
    }
} 