import SwiftUI
import UIKit

struct RewardView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showingCryptoWallet = false
    @State private var showingPurchaseConfirmation = false
    @State private var selectedReward: Reward?
    @State private var selectedCategory: Reward.Category?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            UIComponents.TabContentView(
                backgroundImage: "athlete1",
                backgroundOpacity: 0.07,
                backgroundColor: PureLifeColors.adaptiveBackground(scheme: colorScheme)
            ) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        // Logo
                        PureLifeHeader()
                        .padding(.bottom, 8)
                        
                        // User level
                        UserLevelView(user: dataStore.currentUser)
                            .padding(.horizontal, 16)
                        
                        // Balance card
                        ZStack(alignment: .bottom) {
                            // Card background with modern design
                            UIComponents.ModernCard(
                                cornerRadius: 28,
                                showAthlete: true,
                                athleteImage: "athlete2",
                                athleteOpacity: 0.08
                            ) {
                                VStack(spacing: 10) {
                                    Text("Token Balance")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                                        .padding(.top, 25)
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "crown.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(PureLifeColors.logoGreen)
                                            .shadow(color: PureLifeColors.logoGreen.opacity(0.5), radius: 5, x: 0, y: 0)
                                            
                                        Text("\(String(format: "%.1f", dataStore.currentUser.tokenBalance))")
                                            .font(.system(size: 32, weight: .bold, design: .rounded))
                                            .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                                            .shadow(color: PureLifeColors.logoGreen.opacity(0.2), radius: 5, x: 0, y: 0)
                                    }
                                    
                                    Text("TOKENS")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(PureLifeColors.logoGreen)
                                        .tracking(2)
                                    
                                    Spacer()
                                    
                                    // Convert button with more modern styling
                                    Button(action: {
                                        showingCryptoWallet = true
                                    }) {
                                        HStack {
                                            Image(systemName: "arrow.right.arrow.left")
                                                .font(.system(size: 14, weight: .bold))
                                            
                                            Text("CONVERT TO CRYPTO")
                                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                                .tracking(1)
                                        }
                                        .foregroundColor(PureLifeColors.adaptiveSurface(scheme: colorScheme))
                                        .padding(.vertical, 14)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    PureLifeColors.logoGreen,
                                                    PureLifeColors.logoGreen.opacity(0.8)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(18)
                                    }
                                    .shadow(color: PureLifeColors.logoGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                .padding(25)
                            }
                        }
                        .frame(height: 280)
                        .padding(.horizontal, 16)
                        
                        // Sección de categorías
                        categoriesSection
                        
                        // Featured, filtered o purchased rewards
                        rewardsContentSection
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingCryptoWallet) {
                CryptoWalletView()
                    .environmentObject(dataStore)
            }
            .alert(isPresented: $showingPurchaseConfirmation) {
                purchaseConfirmationAlert
            }
        }
        .accentColor(PureLifeColors.logoGreen)
    }
    
    // MARK: - UI Components
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Marketplace")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                
                Spacer()
                
                if selectedCategory != nil {
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedCategory = nil
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text("All Categories")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(PureLifeColors.logoGreen)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(PureLifeColors.logoGreen)
                        }
                    }
                    .padding(.trailing, 16)
                }
            }
            .padding(.horizontal, 20)
            
            // Categories horizontal scroll with more visual appeal
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(Reward.Category.allCases, id: \.self) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategory == category,
                            action: {
                                withAnimation(.spring()) {
                                    selectedCategory = category
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
        }
    }
    
    private var rewardsContentSection: some View {
        VStack(spacing: 25) {
            if let category = selectedCategory {
                // Filtered rewards for selected category
                VStack(spacing: 16) {
                    ForEach(dataStore.getRewardsForCategory(category)) { reward in
                        RewardCard(reward: reward) {
                            selectedReward = reward
                            showingPurchaseConfirmation = true
                        }
                        .padding(.horizontal, 20)
                    }
                }
            } else {
                // Featured rewards section
                if !dataStore.featuredRewards.isEmpty {
                    featuredRewardsSection
                    
                    Divider()
                        .background(PureLifeColors.divider.opacity(0.3))
                        .padding(.vertical, 15)
                        .padding(.horizontal, 40)
                    
                    newArrivalsSection
                    
                    Divider()
                        .background(PureLifeColors.divider.opacity(0.3))
                        .padding(.vertical, 15)
                        .padding(.horizontal, 40)
                    
                    purchasedRewardsSection
                }
            }
        }
    }
    
    private var featuredRewardsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(PureLifeColors.logoGreen)
                    .font(.system(size: 18))
                
                Text("Featured Rewards")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
            }
            .padding(.leading, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(dataStore.featuredRewards) { reward in
                        // Enhanced featured reward card
                        FeaturedRewardCard(reward: reward) {
                            selectedReward = reward
                            showingPurchaseConfirmation = true
                        }
                        .frame(width: 300, height: 220)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
        }
    }
    
    private var newArrivalsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(PureLifeColors.logoGreen)
                    .font(.system(size: 18))
                
                Text("New Arrivals")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
            }
            .padding(.leading, 20)
            
            VStack(spacing: 15) {
                ForEach(dataStore.availableRewards.filter { $0.isNew }) { reward in
                    RewardCard(reward: reward) {
                        selectedReward = reward
                        showingPurchaseConfirmation = true
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    private var purchasedRewardsSection: some View {
        Group {
            if !dataStore.currentUser.purchasedRewards.isEmpty {
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Image(systemName: "bag.fill")
                            .foregroundColor(PureLifeColors.logoGreen)
                            .font(.system(size: 18))
                        
                        Text("Your Purchases")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                    }
                    .padding(.leading, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(dataStore.currentUser.purchasedRewards) { reward in
                                PurchasedRewardCard(reward: reward)
                                    .frame(width: 220, height: 150)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                }
            }
        }
    }
    
    private var purchaseConfirmationAlert: Alert {
        guard let reward = selectedReward else {
            return Alert(title: Text("Error"), message: Text("No reward selected"))
        }
        
        return Alert(
            title: Text("Purchase Reward"),
            message: Text("Would you like to spend \(reward.formattedCost) to get this reward?"),
            primaryButton: .default(Text("Purchase")) {
                if dataStore.purchaseReward(reward) {
                    // Éxito
                } else {
                    // Fallido - podría mostrar otro alerta
                }
            },
            secondaryButton: .cancel()
        )
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Vistas complementarias

struct UserLevelView: View {
    let user: User
    
    var body: some View {
        UIComponents.ModernCard(cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 15) {
                            HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text("LEVEL \(user.currentLevel.level)")
                                .font(.system(size: 14, weight: .heavy, design: .rounded))
                                .foregroundColor(PureLifeColors.logoGreen)
                                .tracking(1)
                            
                            Text(user.currentLevel.title)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(PureLifeColors.textPrimary)
                        }
                                }
                                
                                Spacer()
                                
                    // Progress circle with better visual style
                    ZStack {
                        Circle()
                            .stroke(PureLifeColors.logoGreen.opacity(0.15), lineWidth: 8.0)
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(min(user.progressToNextLevel, 1.0)))
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        PureLifeColors.logoGreen.opacity(0.8),
                                        PureLifeColors.logoGreen
                                    ]),
                                    startPoint: .trailing,
                                    endPoint: .leading
                                ),
                                style: StrokeStyle(lineWidth: 8.0, lineCap: .round, lineJoin: .round)
                            )
                            .rotationEffect(Angle(degrees: 270.0))
                            .animation(.easeInOut, value: user.progressToNextLevel)
                        
                        Text("\(Int(user.progressToNextLevel * 100))%")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.textPrimary)
                    }
                    .frame(width: 55, height: 55)
                }
                
                // XP Progress bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("XP: \(user.experiencePoints)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(PureLifeColors.textSecondary)
                        
                        Spacer()
                        
                        if user.currentLevel.level < UserLevel.levels.count {
                            let nextLevel = UserLevel.levels.first { $0.level == user.currentLevel.level + 1 }
                            if let next = nextLevel {
                                Text("\(next.requiredPoints - user.experiencePoints) XP to Level \(next.level)")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(PureLifeColors.textSecondary)
                            }
                        }
                    }
                    
                    ZStack(alignment: .leading) {
                        // Background
                        Capsule()
                            .fill(PureLifeColors.background)
                            .frame(height: 10)
                        
                        // Fill with gradient
                        GeometryReader { geometry in
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            PureLifeColors.logoGreen, 
                                            PureLifeColors.logoGreen.opacity(0.7)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: CGFloat(user.progressToNextLevel) * geometry.size.width, height: 10)
                                .animation(.easeInOut, value: user.progressToNextLevel)
                        }
                        .frame(height: 10)
                    }
                }
            }
            .padding(20)
        }
    }
}

struct CategoryButton: View {
    let category: Reward.Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon in a circle with improved visual style
                ZStack {
                    // Background circle with gradient if selected
                    if isSelected {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        PureLifeColors.logoGreen,
                                        PureLifeColors.logoGreen.opacity(0.7)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .shadow(
                                color: PureLifeColors.logoGreen.opacity(0.5),
                                radius: 10,
                                x: 0,
                                y: 5
                            )
                    } else {
                        // Non-selected state with subtle gradient
                        Circle()
                            .fill(PureLifeColors.background)
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.5),
                                                Color.gray.opacity(0.2)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .frame(width: 60, height: 60)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 22, weight: isSelected ? .bold : .regular))
                        .foregroundColor(isSelected ? .white : PureLifeColors.textSecondary)
                }
                
                Text(category.rawValue)
                    .font(.system(size: 14, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? PureLifeColors.logoGreen : PureLifeColors.textSecondary)
                    .lineLimit(1)
            }
            .frame(width: 85)
            .padding(.vertical, 5)
        }
    }
}

struct RewardCard: View {
    let reward: Reward
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            UIComponents.ModernCard(cornerRadius: 20) {
                HStack(spacing: 20) {
                    // Partner logo with improved visual style
                    ZStack {
                        Circle()
                            .fill(reward.category.color.opacity(0.15))
                            .frame(width: 65, height: 65)
                        
                        Image(systemName: reward.partnerLogo)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(reward.category.color)
                    }
                    
                    // Details
                    VStack(alignment: .leading, spacing: 8) {
                        // Title
                        Text(reward.title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                            .lineLimit(1)
                        
                        // Partner
                        Text(reward.partnerName)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                            .lineLimit(1)
                        
                        // Description
                        Text(reward.description)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                            .lineLimit(2)
                        
                        // Tags
                        HStack {
                            if reward.isNew {
                                TagView(text: "NEW", color: PureLifeColors.success)
                            }
                            
                            if let percentage = reward.discountPercentage {
                                TagView(text: "\(percentage)% OFF", color: PureLifeColors.warning)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Price with improved button style
                    VStack(alignment: .trailing, spacing: 10) {
                        Text(reward.formattedCost)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                        
                        Text("GET NOW")
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        PureLifeColors.logoGreen,
                                        PureLifeColors.logoGreen.opacity(0.8)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: PureLifeColors.logoGreen.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                }
                .padding(20)
            }
        }
    }
}

struct TagView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(6)
    }
}

struct FeaturedRewardCard: View {
    let reward: Reward
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            UIComponents.GlassMorphicCard(cornerRadius: 24) {
                ZStack {
                    // Content with improved layout
                    VStack(alignment: .leading, spacing: 16) {
                        // Header
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(reward.category.color.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: reward.partnerLogo)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(reward.category.color)
                            }
                            
                            Text(reward.partnerName)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                            
                            Spacer()
                            
                            if reward.isNew {
                                TagView(text: "NEW", color: PureLifeColors.success)
                            }
                        }
                        
                        // Title
                        Text(reward.title)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                            .lineLimit(2)
                        
                        // Description
                        Text(reward.description)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                            .lineLimit(2)
                        
                        Spacer()
                        
                        // Footer
                                HStack {
                            // Discount if any
                            if let percentage = reward.discountPercentage {
                                TagView(text: "\(percentage)% OFF", color: PureLifeColors.warning)
                            } else if let amount = reward.discountAmount {
                                TagView(text: "$\(Int(amount)) OFF", color: PureLifeColors.warning)
                                    }
                                    
                                    Spacer()
                                    
                            // Price with improved style
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(PureLifeColors.logoGreen)
                                
                                Text(reward.formattedCost)
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(PureLifeColors.adaptiveSurfaceSecondary(scheme: colorScheme))
                            .cornerRadius(14)
                        }
                    }
                    .padding(24)
                }
            }
        }
    }
}

struct PurchasedRewardCard: View {
    let reward: Reward
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        UIComponents.ModernCard(cornerRadius: 18) {
            ZStack {
                VStack(alignment: .leading, spacing: 12) {
                    // Header
                    HStack {
                        ZStack {
                            Circle()
                                .fill(reward.category.color.opacity(0.15))
                                .frame(width: 35, height: 35)
                            
                            Image(systemName: reward.partnerLogo)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(reward.category.color)
                        }
                        
                        Text(reward.partnerName)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(PureLifeColors.success)
                    }
                    
                    // Title
                    Text(reward.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Expiry info if available with improved style
                    if let expiryDate = reward.expiryDate {
                        HStack {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                                .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                            
                            Text("Expires: \(formattedDate(expiryDate))")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                        }
                        .padding(6)
                        .background(PureLifeColors.adaptiveSurfaceSecondary(scheme: colorScheme))
                        .cornerRadius(8)
                    }
                }
                .padding(16)
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct RewardView_Previews: PreviewProvider {
    static var previews: some View {
        RewardView()
            .environmentObject(AppDataStore())
            .preferredColorScheme(.light)
    }
} 