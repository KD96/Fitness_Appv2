import SwiftUI

struct PureLifeHeader: View {
    var showUserAvatar: Bool = false
    var userInitials: String = ""
    
    var body: some View {
        HStack {
            // Logo
            HStack(spacing: 8) {
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 26)
                
                Text("PureLife")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.textPrimary)
            }
            
            Spacer()
            
            // Avatar del usuario (opcional)
            if showUserAvatar {
                ZStack {
                    Circle()
                        .fill(PureLifeColors.logoGreen.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Text(userInitials)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(PureLifeColors.logoGreen)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}

struct PureLifeHeader_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PureLifeHeader()
            PureLifeHeader(showUserAvatar: true, userInitials: "JD")
        }
        .padding()
        .background(PureLifeColors.background)
        .previewLayout(.sizeThatFits)
    }
} 