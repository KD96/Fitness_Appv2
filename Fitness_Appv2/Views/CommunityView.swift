import SwiftUI

struct CommunityView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var selectedTab: Tab = .leaderboard
    @State private var showingFriendSearch = false
    @Environment(\.colorScheme) var colorScheme
    
    // Sample user data for leaderboard since dataStore doesn't have leaderboardUsers
    @State private var leaderboardUsers: [User] = [
        User(
            name: "John Doe", 
            tokenBalance: 580
        ),
        User(
            name: "Alice Smith", 
            tokenBalance: 420
        ),
        User(
            name: "Bob Johnson", 
            tokenBalance: 310
        ),
        User(
            name: "Emma Williams", 
            tokenBalance: 250
        )
    ]
    
    enum Tab {
        case leaderboard, friends
    }
    
    var body: some View {
        UIComponents.TabContentView(
            backgroundColor: PureLifeColors.adaptiveBackground(scheme: colorScheme)
        ) {
            VStack(spacing: 0) {
                // Header with logo and user
                PureLifeHeader(showUserAvatar: true, userInitials: String(dataStore.currentUser.firstName.prefix(1)))
                    .padding(.bottom, 10)
                
                // Custom tab switcher
                tabSwitcher
                
                // Content based on selected tab
                if selectedTab == .leaderboard {
                    leaderboardContent
                } else {
                    friendsContent
                }
            }
        }
        .sheet(isPresented: $showingFriendSearch) {
            // Placeholder for FriendSearchView
            EmptyView()
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Tab Switcher
    
    private var tabSwitcher: some View {
        HStack(spacing: 0) {
            tabButton(title: "Leaderboard", tab: .leaderboard)
            tabButton(title: "Friends", tab: .friends)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(PureLifeColors.adaptiveSurfaceSecondary(scheme: colorScheme))
        )
        .frame(height: 48)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private func tabButton(title: String, tab: Tab) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedTab = tab
            }
        }) {
            Text(title)
                .font(.system(size: 16, weight: selectedTab == tab ? .bold : .medium, design: .rounded))
                .foregroundColor(selectedTab == tab ? .white : PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    Group {
                        if selectedTab == tab {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(PureLifeColors.logoGreen)
                                .shadow(color: PureLifeColors.logoGreen.opacity(0.3), radius: 5, x: 0, y: 2)
                        } else {
                            Color.clear
                        }
                    }
                )
                .padding(.horizontal, 4)
        }
    }
    
    // MARK: - Leaderboard Content
    
    private var leaderboardContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Top performers cards with medals
                topPerformersSection
                
                // Full leaderboard
                leaderboardListSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
    
    private var topPerformersSection: some View {
        VStack(spacing: 16) {
            Text("Top Performers")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Top 3 users with medals
            HStack(alignment: .bottom, spacing: 12) {
                // Silver (2nd place)
                if leaderboardUsers.count > 1 {
                    topPerformerCard(
                        user: leaderboardUsers[1],
                        position: 2,
                        scale: 0.85
                    )
                } else {
                    Spacer()
                }
                
                // Gold (1st place)
                if !leaderboardUsers.isEmpty {
                    topPerformerCard(
                        user: leaderboardUsers[0],
                        position: 1,
                        scale: 1.0
                    )
                }
                
                // Bronze (3rd place)
                if leaderboardUsers.count > 2 {
                    topPerformerCard(
                        user: leaderboardUsers[2],
                        position: 3,
                        scale: 0.85
                    )
                } else {
                    Spacer()
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
    }
    
    private func topPerformerCard(user: User, position: Int, scale: CGFloat) -> some View {
        VStack(spacing: 12) {
            // Medal
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: medalGradient(for: position),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80 * scale, height: 80 * scale)
                    .shadow(color: medalShadowColor(for: position).opacity(0.5), radius: 8, x: 0, y: 4)
                
                Text("\(position)")
                    .font(.system(size: 32 * scale, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // User avatar with initials
            ZStack {
                Circle()
                    .fill(PureLifeColors.logoGreen.opacity(0.15))
                    .frame(width: 60 * scale, height: 60 * scale)
                
                Text(String(user.firstName.prefix(1)))
                    .font(.system(size: 24 * scale, weight: .semibold, design: .rounded))
                    .foregroundColor(PureLifeColors.logoGreen)
            }
            
            // User name and points
            VStack(spacing: 4) {
                Text(user.firstName)
                    .font(.system(size: 14 * scale, weight: .semibold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                    .lineLimit(1)
                
                Text("\(Int(user.tokenBalance)) pts")
                    .font(.system(size: 12 * scale, weight: .medium, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func medalGradient(for position: Int) -> Gradient {
        switch position {
        case 1: 
            return Gradient(colors: [Color(hex: "#FFD700"), Color(hex: "#FFA500")])  // Gold
        case 2: 
            return Gradient(colors: [Color(hex: "#C0C0C0"), Color(hex: "#A0A0A0")])  // Silver
        case 3: 
            return Gradient(colors: [Color(hex: "#CD7F32"), Color(hex: "#A05A2C")])  // Bronze
        default:
            return Gradient(colors: [PureLifeColors.logoGreen, PureLifeColors.logoGreenDark])
        }
    }
    
    private func medalShadowColor(for position: Int) -> Color {
        switch position {
        case 1: return Color(hex: "#FFA500")  // Gold
        case 2: return Color(hex: "#A0A0A0")  // Silver
        case 3: return Color(hex: "#A05A2C")  // Bronze
        default: return PureLifeColors.logoGreen
        }
    }
    
    private var leaderboardListSection: some View {
        VStack(spacing: 16) {
            Text("Leaderboard")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ForEach(Array(leaderboardUsers.enumerated()), id: \.element.id) { index, user in
                    leaderboardRow(user: user, position: index + 1)
                }
            }
        }
    }
    
    private func leaderboardRow(user: User, position: Int) -> some View {
        HStack(spacing: 16) {
            // Position
            Text("\(position)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                .frame(width: 40, alignment: .center)
            
            // User avatar
            ZStack {
                Circle()
                    .fill(PureLifeColors.logoGreen.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Text(String(user.firstName.prefix(1)))
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(PureLifeColors.logoGreen)
            }
            
            // User name
            Text(user.firstName)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
            
            Spacer()
            
            // Points with token icon
            HStack(spacing: 6) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 14))
                    .foregroundColor(PureLifeColors.logoGreen)
                
                Text("\(Int(user.tokenBalance))")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(PureLifeColors.logoGreen.opacity(0.1))
            )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(PureLifeColors.adaptiveSurface(scheme: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    position <= 3 ? 
                    LinearGradient(
                        gradient: medalGradient(for: position),
                        startPoint: .leading,
                        endPoint: .trailing
                    ) : 
                    LinearGradient(
                        gradient: Gradient(colors: [PureLifeColors.adaptiveDivider(scheme: colorScheme)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: position <= 3 ? 2 : 1
                )
        )
    }
    
    // MARK: - Friends Content
    
    private var friendsContent: some View {
        VStack(spacing: 20) {
            // Add friend button
            Button(action: {
                showingFriendSearch = true
            }) {
                HStack {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 18))
                    
                    Text("Add Friends")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(PureLifeColors.logoGreen)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(PureLifeColors.logoGreen.opacity(0.12))
                )
            }
            .padding(.bottom, 10)
            
            if dataStore.currentUser.friends.isEmpty {
                // Empty state for friends
                emptyFriendsView
            } else {
                // Friends list
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        Text("Your Friends")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                        
                        // Since friends are stored as UUIDs, we'll use sample friends for display
                        ForEach(getSampleFriends()) { friend in
                            friendRow(user: friend)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // Function to create sample friends from UUIDs
    private func getSampleFriends() -> [User] {
        // In a real app, you would lookup these users from a database
        // For now, we'll create sample users with random token balances
        return [
            User(name: "David Miller", tokenBalance: 340),
            User(name: "Sarah Connor", tokenBalance: 280),
            User(name: "Michael Scott", tokenBalance: 420)
        ]
    }
    
    private var emptyFriendsView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(PureLifeColors.logoGreen.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "person.2.fill")
                    .font(.system(size: 50))
                    .foregroundColor(PureLifeColors.logoGreen.opacity(0.7))
            }
            
            VStack(spacing: 12) {
                Text("No Friends Yet")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                
                Text("Connect with friends to compare workouts and compete on the leaderboard")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
    
    private func friendRow(user: User) -> some View {
        HStack(spacing: 16) {
            // User avatar
            ZStack {
                Circle()
                    .fill(PureLifeColors.logoGreen.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Text(String(user.firstName.prefix(1)))
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(PureLifeColors.logoGreen)
            }
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.firstName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                
                HStack(spacing: 6) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 12))
                        .foregroundColor(PureLifeColors.logoGreen)
                    
                    Text("\(Int(user.tokenBalance)) tokens")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                }
            }
            
            Spacer()
            
            // Message button
            Button(action: {
                // Action for messaging
            }) {
                Image(systemName: "message.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(PureLifeColors.logoGreen)
                    )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(PureLifeColors.adaptiveSurface(scheme: colorScheme))
                .shadow(color: PureLifeColors.adaptiveCardShadow(scheme: colorScheme), radius: 6, x: 0, y: 3)
        )
        .padding(.horizontal, 20)
    }
}

// Placeholder view for friend search
struct FriendSearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Find Friends")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                
                Text("This is a placeholder for the friend search functionality")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(PureLifeColors.adaptiveBackground(scheme: colorScheme).ignoresSafeArea())
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
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