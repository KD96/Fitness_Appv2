import SwiftUI
import UIKit

struct RewardView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showingCryptoWallet = false
    @State private var showingPurchaseConfirmation = false
    @State private var selectedReward: Reward?
    @State private var selectedCategory: Reward.Category?
    
    // Colores de PureLife
    private let pureLifeGreen = Color(red: 199/255, green: 227/255, blue: 214/255)
    private let pureLifeLightGreen = Color(red: 220/255, green: 237/255, blue: 230/255)
    private let pureLifeBlack = Color.black
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Logo y título de la app
                    HStack {
                        Text("pure")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(pureLifeBlack) +
                        Text("life")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(pureLifeBlack) +
                        Text(".")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(pureLifeBlack)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                    
                    // Usuario y nivel
                    UserLevelView(user: dataStore.currentUser)
                        .padding(.horizontal)
                    
                    // Token balance card
                    VStack(spacing: 4) {
                        Text("Token Balance")
                            .font(.headline)
                            .foregroundColor(pureLifeBlack.opacity(0.7))
                        
                        Text("\(String(format: "%.1f", dataStore.currentUser.tokenBalance))")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(pureLifeBlack)
                        
                        Text("PURE")
                            .font(.caption)
                            .foregroundColor(pureLifeBlack.opacity(0.7))
                        
                        Button(action: {
                            showingCryptoWallet = true
                        }) {
                            Text("Convert to Crypto")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(pureLifeBlack)
                                .cornerRadius(8)
                        }
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(pureLifeGreen)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Marketplace header
                    HStack {
                        Text("Marketplace")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(pureLifeBlack)
                        
                        Spacer()
                        
                        if selectedCategory != nil {
                            Button(action: {
                                selectedCategory = nil
                            }) {
                                Text("All Categories")
                                    .font(.subheadline)
                                    .foregroundColor(pureLifeBlack)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Categories horizontal scroll
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Reward.Category.allCases, id: \.self) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: selectedCategory == category,
                                    action: {
                                        selectedCategory = category
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 5)
                    
                    // Featured rewards or filtered rewards
                    if let category = selectedCategory {
                        // Filtered rewards for selected category
                        LazyVStack(spacing: 16) {
                            ForEach(dataStore.getRewardsForCategory(category)) { reward in
                                RewardCard(reward: reward) {
                                    selectedReward = reward
                                    showingPurchaseConfirmation = true
                                }
                                .padding(.horizontal)
                            }
                        }
                    } else {
                        // Featured rewards section
                        if !dataStore.featuredRewards.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Featured Rewards")
                                    .font(.headline)
                                    .foregroundColor(pureLifeBlack)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(dataStore.featuredRewards) { reward in
                                            FeaturedRewardCard(reward: reward) {
                                                selectedReward = reward
                                                showingPurchaseConfirmation = true
                                            }
                                            .frame(width: 250, height: 180)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // New arrivals section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("New Arrivals")
                                    .font(.headline)
                                    .foregroundColor(pureLifeBlack)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                
                                LazyVStack(spacing: 16) {
                                    ForEach(dataStore.availableRewards.filter { $0.isNew }) { reward in
                                        RewardCard(reward: reward) {
                                            selectedReward = reward
                                            showingPurchaseConfirmation = true
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        
                        // Your purchases section
                        if !dataStore.currentUser.purchasedRewards.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Your Purchases")
                                    .font(.headline)
                                    .foregroundColor(pureLifeBlack)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(dataStore.currentUser.purchasedRewards) { reward in
                                            PurchasedRewardCard(reward: reward)
                                                .frame(width: 220, height: 150)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(pureLifeLightGreen.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingCryptoWallet) {
                CryptoWalletView()
                    .environmentObject(dataStore)
            }
            .alert(isPresented: $showingPurchaseConfirmation) {
                purchaseConfirmationAlert
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
    
    // Colores de PureLife
    private let pureLifeGreen = Color(red: 199/255, green: 227/255, blue: 214/255)
    private let pureLifeBlack = Color.black
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Level \(user.currentLevel.level)")
                        .font(.headline)
                        .foregroundColor(pureLifeBlack)
                    
                    Text(user.currentLevel.title)
                        .font(.subheadline)
                        .foregroundColor(pureLifeBlack.opacity(0.7))
                }
                
                Spacer()
                
                // Progress circle
                ZStack {
                    Circle()
                        .stroke(lineWidth: 8.0)
                        .opacity(0.3)
                        .foregroundColor(pureLifeGreen)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(user.progressToNextLevel, 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: 8.0, lineCap: .round, lineJoin: .round))
                        .foregroundColor(pureLifeGreen)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear, value: user.progressToNextLevel)
                    
                    Text("\(Int(user.progressToNextLevel * 100))%")
                        .font(.caption)
                        .bold()
                }
                .frame(width: 50, height: 50)
            }
            
            // XP Progress bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("XP: \(user.experiencePoints)")
                        .font(.caption)
                        .foregroundColor(pureLifeBlack)
                    
                    Spacer()
                    
                    if user.currentLevel.level < UserLevel.levels.count {
                        let nextLevel = UserLevel.levels.first { $0.level == user.currentLevel.level + 1 }
                        if let next = nextLevel {
                            Text("\(next.requiredPoints - user.experiencePoints) XP to Level \(next.level)")
                                .font(.caption)
                                .foregroundColor(pureLifeBlack.opacity(0.7))
                        }
                    }
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: geometry.size.width, height: 6)
                            .opacity(0.3)
                            .foregroundColor(pureLifeGreen)
                        
                        Rectangle()
                            .frame(width: geometry.size.width * CGFloat(user.progressToNextLevel), height: 6)
                            .foregroundColor(pureLifeGreen)
                    }
                    .cornerRadius(3.0)
                }
                .frame(height: 6)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct CategoryButton: View {
    let category: Reward.Category
    let isSelected: Bool
    let action: () -> Void
    
    // Colores de PureLife
    private let pureLifeGreen = Color(red: 199/255, green: 227/255, blue: 214/255)
    private let pureLifeBlack = Color.black
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? pureLifeBlack : pureLifeBlack.opacity(0.6))
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? pureLifeBlack : pureLifeBlack.opacity(0.6))
            }
            .frame(width: 80, height: 70)
            .background(isSelected ? pureLifeGreen : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(pureLifeGreen, lineWidth: 1)
            )
        }
    }
}

struct RewardCard: View {
    let reward: Reward
    let action: () -> Void
    
    // Colores de PureLife
    private let pureLifeGreen = Color(red: 199/255, green: 227/255, blue: 214/255)
    private let pureLifeBlack = Color.black
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Partner logo
                Image(systemName: reward.partnerLogo)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(reward.category.color)
                    .cornerRadius(10)
                
                // Details
                VStack(alignment: .leading, spacing: 4) {
                    // Title
                    Text(reward.title)
                        .font(.headline)
                        .foregroundColor(pureLifeBlack)
                        .lineLimit(1)
                    
                    // Partner
                    Text(reward.partnerName)
                        .font(.subheadline)
                        .foregroundColor(pureLifeBlack.opacity(0.6))
                        .lineLimit(1)
                    
                    // Description
                    Text(reward.description)
                        .font(.caption)
                        .foregroundColor(pureLifeBlack.opacity(0.6))
                        .lineLimit(2)
                    
                    // Tags
                    HStack {
                        if reward.isNew {
                            Text("NEW")
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                        
                        if let percentage = reward.discountPercentage {
                            Text("\(percentage)% OFF")
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                }
                
                Spacer()
                
                // Price
                VStack(alignment: .trailing, spacing: 4) {
                    Text(reward.formattedCost)
                        .font(.headline)
                        .foregroundColor(pureLifeBlack)
                    
                    Text("BUY")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(pureLifeGreen)
                        .foregroundColor(pureLifeBlack)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
        }
    }
}

struct FeaturedRewardCard: View {
    let reward: Reward
    let action: () -> Void
    
    // Colores de PureLife
    private let pureLifeGreen = Color(red: 199/255, green: 227/255, blue: 214/255)
    private let pureLifeBlack = Color.black
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: reward.partnerLogo)
                        .font(.title3)
                        .foregroundColor(reward.category.color)
                    
                    Text(reward.partnerName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(pureLifeBlack)
                    
                    Spacer()
                    
                    if reward.isNew {
                        Text("NEW")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }
                
                // Title
                Text(reward.title)
                    .font(.headline)
                    .foregroundColor(pureLifeBlack)
                    .lineLimit(2)
                
                // Description
                Text(reward.description)
                    .font(.caption)
                    .foregroundColor(pureLifeBlack.opacity(0.7))
                    .lineLimit(2)
                
                Spacer()
                
                // Footer
                HStack {
                    // Discount if any
                    if let percentage = reward.discountPercentage {
                        Text("\(percentage)% OFF")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    } else if let amount = reward.discountAmount {
                        Text("$\(Int(amount)) OFF")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    // Price
                    Text(reward.formattedCost)
                        .font(.headline)
                        .foregroundColor(pureLifeBlack)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
        }
    }
}

struct PurchasedRewardCard: View {
    let reward: Reward
    
    // Colores de PureLife
    private let pureLifeGreen = Color(red: 199/255, green: 227/255, blue: 214/255)
    private let pureLifeBlack = Color.black
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                Image(systemName: reward.partnerLogo)
                    .font(.title3)
                    .foregroundColor(reward.category.color)
                
                Text(reward.partnerName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(pureLifeBlack)
                
                Spacer()
                
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(pureLifeGreen)
            }
            
            // Title
            Text(reward.title)
                .font(.headline)
                .foregroundColor(pureLifeBlack)
                .lineLimit(1)
            
            Spacer()
            
            // Expiry info if available
            if let expiryDate = reward.expiryDate {
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                    
                    Text("Expires: \(formattedDate(expiryDate))")
                        .font(.caption)
                        .foregroundColor(pureLifeBlack.opacity(0.6))
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
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
    }
} 