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
        case leaderboard, friends, connect
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
                } else if selectedTab == .friends {
                    friendsContent
                } else {
                    connectContent
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
            tabButton(title: "Connect", tab: .connect)
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
                // Banner de motivación con imagen atlética
                communityBanner
                
                // Top performers cards with medals
                topPerformersSection
                
                // Full leaderboard
                leaderboardListSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
    
    // Banner de motivación comunitaria
    private var communityBanner: some View {
        ZStack(alignment: .bottomLeading) {
            // Rectángulo con gradiente en lugar de imagen
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.3), Color.blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 160)
            
            // Overlay gradient
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                    startPoint: .bottom,
                    endPoint: .center
                ))
                .frame(height: 160)
            
            // Icono grande de grupo
            Image(systemName: "person.3.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 60)
                .foregroundColor(.white.opacity(0.3))
                .padding(.trailing, 20)
                .padding(.top, 20)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Community Challenge")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Join others in reaching fitness goals")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(20)
        }
        .shadow(radius: 5)
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
            
            // User avatar with icon instead of image
            ZStack {
                Circle()
                    .fill(PureLifeColors.logoGreen.opacity(0.15))
                    .frame(width: 60 * scale, height: 60 * scale)
                
                // Si es top 3, muestra un icono atlético en lugar de iniciales
                if position <= 3 {
                    Image(systemName: getIconForPosition(position))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30 * scale, height: 30 * scale)
                        .foregroundColor(getColorForPosition(position))
                } else {
                    Text(String(user.firstName.prefix(1)))
                        .font(.system(size: 24 * scale, weight: .semibold, design: .rounded))
                        .foregroundColor(PureLifeColors.logoGreen)
                }
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
    
    // Función para obtener iconos según la posición
    private func getIconForPosition(_ position: Int) -> String {
        switch position {
        case 1:
            return "figure.run"
        case 2:
            return "dumbbell"
        case 3:
            return "figure.walk"
        default:
            return "figure.mixed.cardio"
        }
    }
    
    // Función para obtener colores según la posición
    private func getColorForPosition(_ position: Int) -> Color {
        switch position {
        case 1:
            return .blue
        case 2:
            return .orange
        case 3:
            return .purple
        default:
            return PureLifeColors.logoGreen
        }
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
    
    // MARK: - Connect Content
    
    private var connectContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Banner explaining the feature
                connectBanner
                
                // Interest selection
                interestSelectionSection
                
                // People with similar interests
                similarInterestUsersSection
                
                // Upcoming events
                upcomingEventsSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
    
    private var connectBanner: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 160)
            
            // Overlay gradient
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                    startPoint: .bottom,
                    endPoint: .center
                ))
                .frame(height: 160)
            
            // Large icon
            Image(systemName: "person.2.wave.2.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 60)
                .foregroundColor(.white.opacity(0.3))
                .padding(.trailing, 20)
                .padding(.top, 20)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Find Your Fitness Tribe")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Connect with people who share your interests")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(20)
        }
        .shadow(radius: 5)
    }
    
    private var interestSelectionSection: some View {
        VStack(spacing: 16) {
            Text("Your Fitness Interests")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Interest tags
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 12) {
                ForEach(WorkoutType.allCases, id: \.self) { workoutType in
                    interestTag(workoutType: workoutType, isSelected: dataStore.currentUser.userPreferences.favoriteActivities.contains(workoutType))
                }
                
                // Goal tag
                interestTag(
                    title: dataStore.currentUser.userPreferences.fitnessGoal.rawValue,
                    icon: dataStore.currentUser.userPreferences.fitnessGoal.icon,
                    isSelected: true,
                    color: .blue
                )
            }
        }
    }
    
    private func interestTag(workoutType: WorkoutType, isSelected: Bool) -> some View {
        interestTag(
            title: workoutType.rawValue.capitalized,
            icon: workoutType.icon,
            isSelected: isSelected,
            color: AthleteImages.getColorForWorkoutType(workoutType)
        )
    }
    
    private func interestTag(title: String, icon: String, isSelected: Bool, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(isSelected ? .white : color)
            
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? .white : PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
        }
        .padding(10)
        .frame(height: 40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? color : color.opacity(0.1))
        )
        .shadow(color: isSelected ? color.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
    }
    
    private var similarInterestUsersSection: some View {
        VStack(spacing: 16) {
            Text("People You Might Like")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Sample users with similar interests
            ForEach(getSuggestedUsers()) { user in
                suggestedUserCard(user: user)
            }
        }
    }
    
    private func getSuggestedUsers() -> [User] {
        // In a real app, this would fetch users with similar interests
        // Here we're creating sample data
        return [
            User(
                name: "Chris Evans",
                profileImage: "person.crop.circle.fill",
                tokenBalance: 320,
                workoutStreak: 12,
                experiencePoints: 2500
            ),
            User(
                name: "Jessica Rogers",
                profileImage: "person.crop.circle.fill",
                tokenBalance: 280,
                workoutStreak: 8,
                experiencePoints: 1800
            ),
            User(
                name: "Mark Banner",
                profileImage: "person.crop.circle.fill",
                tokenBalance: 340,
                workoutStreak: 15,
                experiencePoints: 3200
            )
        ]
    }
    
    private func suggestedUserCard(user: User) -> some View {
        HStack(spacing: 16) {
            // User avatar
            ZStack {
                Circle()
                    .fill(PureLifeColors.logoGreen.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: AthleteImages.getRandomAthleteIcon())
                    .font(.system(size: 22))
                    .foregroundColor(PureLifeColors.logoGreen)
            }
            
            // User info
            VStack(alignment: .leading, spacing: 8) {
                Text(user.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                
                // Common interests
                HStack(spacing: 8) {
                    ForEach(getRandomInterests(), id: \.self) { interest in
                        Text(interest)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(PureLifeColors.adaptiveSurfaceSecondary(scheme: colorScheme))
                            )
                    }
                }
            }
            
            Spacer()
            
            // Connect button
            Button(action: {
                // Action to connect with this user
            }) {
                Text("Connect")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(PureLifeColors.logoGreen)
                    )
                    .shadow(color: PureLifeColors.logoGreen.opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(PureLifeColors.adaptiveSurface(scheme: colorScheme))
                .shadow(color: PureLifeColors.adaptiveCardShadow(scheme: colorScheme), radius: 6, x: 0, y: 3)
        )
    }
    
    private func getRandomInterests() -> [String] {
        // Generate random workout types and goals as shared interests
        let allInterests = WorkoutType.allCases.map { $0.rawValue.capitalized } + 
                           UserPreferences.FitnessGoal.allCases.map { $0.rawValue }
        
        return Array(allInterests.shuffled().prefix(2))
    }
    
    private var upcomingEventsSection: some View {
        VStack(spacing: 16) {
            Text("Upcoming Events")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Sample events
            VStack(spacing: 12) {
                eventCard(
                    title: "5K Group Run",
                    date: "Next Saturday, 8:00 AM",
                    icon: "figure.run",
                    color: .blue,
                    participants: 12
                )
                
                eventCard(
                    title: "Strength Training Workshop",
                    date: "Sunday, 10:00 AM",
                    icon: "dumbbell.fill",
                    color: .orange,
                    participants: 8
                )
                
                Button(action: {
                    // Action to view all events
                }) {
                    Text("View All Events")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(PureLifeColors.logoGreen)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(PureLifeColors.logoGreen.opacity(0.1))
                        )
                }
            }
        }
    }
    
    private func eventCard(title: String, date: String, icon: String, color: Color, participants: Int) -> some View {
        HStack(spacing: 16) {
            // Event icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
            
            // Event info
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                
                Text(date)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 12))
                    
                    Text("\(participants) participants")
                        .font(.system(size: 12, design: .rounded))
                }
                .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
            }
            
            Spacer()
            
            // Join button
            Button(action: {
                // Action to join this event
            }) {
                Text("Join")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(color)
                    )
                    .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(PureLifeColors.adaptiveSurface(scheme: colorScheme))
                .shadow(color: PureLifeColors.adaptiveCardShadow(scheme: colorScheme), radius: 6, x: 0, y: 3)
        )
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