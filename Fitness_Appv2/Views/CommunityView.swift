import SwiftUI

struct CommunityView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Fondo principal
            PureLifeColors.adaptiveBackground(scheme: colorScheme).ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 20) {
                // Logo
                PureLifeHeader()
                
                Spacer()
                
                // Mensaje de características por venir
                VStack(spacing: 16) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 70))
                        .foregroundColor(PureLifeColors.logoGreen)
                    
                    Text("Community Features Coming Soon")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                        .multilineTextAlignment(.center)
                    
                    Text("Connect with friends, join challenges, and compete on leaderboards.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                Spacer()
            }
        }
    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CommunityView()
                .environmentObject(AppDataStore())
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            CommunityView()
                .environmentObject(AppDataStore())
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
} 