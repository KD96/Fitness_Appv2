import SwiftUI
import UIKit

struct RewardView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showingCryptoWallet = false
    @State private var showingPurchaseConfirmation = false
    @State private var selectedReward: Reward?
    @State private var selectedCategory: Reward.Category?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo principal
                PureLifeColors.background.ignoresSafeArea()
                
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
                            // Card background
                            Components.Card(title: "", cornerRadius: 25) {
                                VStack(spacing: 10) {
                                    Text("Token Balance")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(PureLifeColors.textSecondary)
                                        .padding(.top, 25)
                                    
                                    Text("\(String(format: "%.1f", dataStore.currentUser.tokenBalance))")
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundColor(PureLifeColors.textPrimary)
                                        .shadow(color: PureLifeColors.logoGreen.opacity(0.2), radius: 5, x: 0, y: 0)
                                    
                                    Text("TOKENS")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(PureLifeColors.logoGreen)
                                        .tracking(2)
                                    
                                    Spacer()
                                    
                                    // Convert button
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
                                        .foregroundColor(PureLifeColors.surface)
                                        .padding(.vertical, 12)
                                        .frame(maxWidth: .infinity)
                                        .background(PureLifeColors.logoGreen)
                                        .cornerRadius(15)
                                    }
                                    .shadow(color: PureLifeColors.logoGreen.opacity(0.2), radius: 5, x: 0, y: 2)
                                }
                                .padding(20)
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
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.textPrimary)
                
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
            
            // Categories horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
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
                    .font(.system(size: 16))
                
                Text("Featured Rewards")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.textPrimary)
            }
            .padding(.leading, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(dataStore.featuredRewards) { reward in
                        FeaturedRewardCard(reward: reward) {
                            selectedReward = reward
                            showingPurchaseConfirmation = true
                        }
                        .frame(width: 280, height: 200)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
            }
        }
    }
    
    private var newArrivalsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(PureLifeColors.logoGreen)
                    .font(.system(size: 16))
                
                Text("New Arrivals")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.textPrimary)
            }
            .padding(.leading, 16)
            
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
                            .font(.system(size: 16))
                        
                        Text("Your Purchases")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.textPrimary)
                    }
                    .padding(.leading, 16)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(dataStore.currentUser.purchasedRewards) { reward in
                                PurchasedRewardCard(reward: reward)
                                    .frame(width: 220, height: 150)
                            }
                        }
                        .padding(.horizontal, 16)
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
        Components.Card(title: "", cornerRadius: 16) {
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
                    
                    // Progress circle
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 8.0)
                            .opacity(0.2)
                            .foregroundColor(PureLifeColors.logoGreen)
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(min(user.progressToNextLevel, 1.0)))
                            .stroke(style: StrokeStyle(lineWidth: 8.0, lineCap: .round, lineJoin: .round))
                            .foregroundColor(PureLifeColors.logoGreen)
                            .rotationEffect(Angle(degrees: 270.0))
                            .animation(.easeInOut, value: user.progressToNextLevel)
                        
                        Text("\(Int(user.progressToNextLevel * 100))%")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.textPrimary)
                    }
                    .frame(width: 50, height: 50)
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
                            .frame(height: 8)
                        
                        // Fill
                        GeometryReader { geometry in
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [PureLifeColors.logoGreen, PureLifeColors.logoGreen.opacity(0.7)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: CGFloat(user.progressToNextLevel) * geometry.size.width, height: 8)
                                .animation(.easeInOut, value: user.progressToNextLevel)
                        }
                        .frame(height: 8)
                    }
                }
            }
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
                // Icon in a circle
                ZStack {
                    Circle()
                        .fill(isSelected ? PureLifeColors.logoGreen : PureLifeColors.background)
                        .frame(width: 50, height: 50)
                        .shadow(color: isSelected ? PureLifeColors.logoGreen.opacity(0.3) : Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? PureLifeColors.background : PureLifeColors.textSecondary)
                }
                
                Text(category.rawValue)
                    .font(.system(size: 12, weight: isSelected ? .bold : .medium, design: .rounded))
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
    
    var body: some View {
        Button(action: action) {
            Components.Card(title: "", cornerRadius: 16) {
                HStack(spacing: 20) {
                    // Partner logo
                    ZStack {
                        Circle()
                            .fill(reward.category.color.opacity(0.1))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: reward.partnerLogo)
                            .font(.system(size: 28))
                            .foregroundColor(reward.category.color)
                    }
                    
                    // Details
                    VStack(alignment: .leading, spacing: 6) {
                        // Title
                        Text(reward.title)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.textPrimary)
                            .lineLimit(1)
                        
                        // Partner
                        Text(reward.partnerName)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(PureLifeColors.textSecondary)
                            .lineLimit(1)
                        
                        // Description
                        Text(reward.description)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(PureLifeColors.textSecondary)
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
                    
                    // Price
                    VStack(alignment: .trailing, spacing: 8) {
                        Text(reward.formattedCost)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.textPrimary)
                        
                        Text("BUY")
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundColor(PureLifeColors.background)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(PureLifeColors.logoGreen)
                            .cornerRadius(8)
                    }
                }
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
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color)
            .cornerRadius(4)
    }
}

struct FeaturedRewardCard: View {
    let reward: Reward
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Components.Card(title: "", cornerRadius: 20) {
                ZStack {
                    // Background gradient
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    reward.category.color.opacity(0.1),
                                    PureLifeColors.surface
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [reward.category.color.opacity(0.4), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                    
                    // Content
                    VStack(alignment: .leading, spacing: 16) {
                        // Header
                        HStack {
                            Image(systemName: reward.partnerLogo)
                                .font(.system(size: 22))
                                .foregroundColor(reward.category.color)
                            
                            Text(reward.partnerName)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(PureLifeColors.textPrimary)
                            
                            Spacer()
                            
                            if reward.isNew {
                                TagView(text: "NEW", color: PureLifeColors.success)
                            }
                        }
                        
                        // Title
                        Text(reward.title)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.textPrimary)
                            .lineLimit(2)
                        
                        // Description
                        Text(reward.description)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(PureLifeColors.textSecondary)
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
                            
                            // Price
                            Text(reward.formattedCost)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(PureLifeColors.textPrimary)
                        }
                    }
                    .padding(20)
                }
            }
        }
    }
}

struct PurchasedRewardCard: View {
    let reward: Reward
    
    var body: some View {
        Components.Card(title: "", cornerRadius: 16) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 16)
                    .fill(PureLifeColors.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [PureLifeColors.logoGreen.opacity(0.3), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                
                VStack(alignment: .leading, spacing: 12) {
                    // Header
                    HStack {
                        Image(systemName: reward.partnerLogo)
                            .font(.system(size: 18))
                            .foregroundColor(reward.category.color)
                        
                        Text(reward.partnerName)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(PureLifeColors.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(PureLifeColors.success)
                    }
                    
                    // Title
                    Text(reward.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(PureLifeColors.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Expiry info if available
                    if let expiryDate = reward.expiryDate {
                        HStack {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                                .foregroundColor(PureLifeColors.textSecondary)
                            
                            Text("Expires: \(formattedDate(expiryDate))")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(PureLifeColors.textSecondary)
                        }
                    }
                }
                .padding(15)
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