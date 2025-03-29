import SwiftUI

struct CryptoWalletView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedCryptoType: CryptoWallet.CryptoType = .bitcoin
    @State private var conversionAmount: String = ""
    @State private var showingConfirmation = false
    @State private var selectedTab = 0
    
    // Colores de PureLife
    private let pureLifeGreen = Color(red: 199/255, green: 227/255, blue: 214/255)
    private let pureLifeLightGreen = Color(red: 220/255, green: 237/255, blue: 230/255)
    private let pureLifeBlack = Color.black
    
    var body: some View {
        NavigationView {
            ZStack {
                pureLifeLightGreen.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        HStack {
                            Text("Crypto")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(pureLifeBlack)
                            
                            Text("Wallet")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(pureLifeBlack.opacity(0.6))
                            
                            Spacer()
                            
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(pureLifeBlack.opacity(0.7))
                            }
                        }
                        .padding(.horizontal)
                        
                        Text("Convert your fitness rewards to cryptocurrency")
                            .font(.subheadline)
                            .foregroundColor(pureLifeBlack.opacity(0.7))
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    // Balance cards
                    HStack(spacing: 12) {
                        // PURE token balance
                        VStack(alignment: .leading, spacing: 6) {
                            Text("PURE TOKEN")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(pureLifeBlack.opacity(0.7))
                            
                            Text("\(Int(dataStore.currentUser.tokenBalance))")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(pureLifeBlack)
                            
                            Spacer()
                            
                            Image(systemName: "p.circle.fill")
                                .font(.title)
                                .foregroundColor(pureLifeGreen)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(16)
                        
                        // Crypto balance
                        VStack(alignment: .leading, spacing: 6) {
                            Text("CRYPTO")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(pureLifeBlack.opacity(0.7))
                            
                            let formattedBalance = String(format: "%.6f", dataStore.currentUser.cryptoWallet.balance)
                            Text(formattedBalance)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(pureLifeBlack)
                            
                            Spacer()
                            
                            Image(systemName: "bitcoinsign.circle.fill")
                                .font(.title)
                                .foregroundColor(.orange)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    // Tabs
                    HStack {
                        TabButton(
                            title: "Convert",
                            isSelected: selectedTab == 0,
                            action: { selectedTab = 0 }
                        )
                        
                        TabButton(
                            title: "Transactions",
                            isSelected: selectedTab == 1,
                            action: { selectedTab = 1 }
                        )
                    }
                    .padding(.top, 20)
                    .padding(.horizontal)
                    
                    // Tab content
                    if selectedTab == 0 {
                        convertView
                    } else {
                        transactionsView
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .alert(isPresented: $showingConfirmation) {
            let amount = Double(conversionAmount) ?? 0
            let cryptoAmount = amount * selectedCryptoType.conversionRate
            let formattedAmount = String(format: "%.8f", cryptoAmount)
            
            return Alert(
                title: Text("Confirm Conversion"),
                message: Text("Convert \(Int(amount)) PURE tokens to \(formattedAmount) \(selectedCryptoType.symbol)?"),
                primaryButton: .default(Text("Convert")) {
                    convertTokens()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // MARK: - Convert View
    
    private var convertView: some View {
        VStack(spacing: 20) {
            // Crypto type selector
            VStack(alignment: .leading, spacing: 8) {
                Text("Select Cryptocurrency")
                    .font(.headline)
                    .foregroundColor(pureLifeBlack)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(CryptoWallet.CryptoType.allCases, id: \.self) { cryptoType in
                            CryptoTypeButton(
                                cryptoType: cryptoType,
                                isSelected: selectedCryptoType == cryptoType,
                                action: {
                                    selectedCryptoType = cryptoType
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // Conversion amount
            VStack(alignment: .leading, spacing: 8) {
                Text("Amount to Convert")
                    .font(.headline)
                    .foregroundColor(pureLifeBlack)
                
                VStack {
                    TextField("Enter amount", text: $conversionAmount)
                        .keyboardType(.decimalPad)
                        .font(.title3)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    
                    HStack {
                        Text("Available: \(Int(dataStore.currentUser.tokenBalance)) PURE")
                            .font(.caption)
                            .foregroundColor(pureLifeBlack.opacity(0.7))
                        
                        Spacer()
                        
                        Button(action: {
                            conversionAmount = "\(Int(dataStore.currentUser.tokenBalance))"
                        }) {
                            Text("MAX")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(pureLifeGreen)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            .padding(.horizontal)
            
            // Conversion rate
            VStack(alignment: .leading, spacing: 4) {
                Text("Conversion Rate")
                    .font(.headline)
                    .foregroundColor(pureLifeBlack)
                
                HStack {
                    Text("1 PURE =")
                        .font(.body)
                        .foregroundColor(pureLifeBlack.opacity(0.7))
                    
                    let formattedRate = String(format: "%.8f", selectedCryptoType.conversionRate)
                    Text("\(formattedRate) \(selectedCryptoType.symbol)")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(pureLifeBlack)
                    
                    Spacer()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            // Conversion preview
            if let amount = Double(conversionAmount), amount > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    Text("You will receive:")
                        .font(.headline)
                        .foregroundColor(pureLifeBlack)
                    
                    HStack {
                        let cryptoAmount = amount * selectedCryptoType.conversionRate
                        let formattedCryptoAmount = String(format: "%.8f", cryptoAmount)
                        
                        Text("\(formattedCryptoAmount) \(selectedCryptoType.symbol)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(pureLifeBlack)
                        
                        Spacer()
                        
                        Image(systemName: selectedCryptoType.icon)
                            .font(.title2)
                            .foregroundColor(Color.orange)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Convert button
            Button(action: {
                if let amount = Double(conversionAmount),
                   amount > 0,
                   amount <= dataStore.currentUser.tokenBalance {
                    showingConfirmation = true
                }
            }) {
                Text("Convert Tokens")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        getConvertButtonBackground()
                    )
                    .cornerRadius(16)
                    .padding(.horizontal)
            }
            .disabled(!isConversionValid())
            .padding(.bottom, 24)
        }
    }
    
    // MARK: - Transactions View
    
    private var transactionsView: some View {
        VStack {
            if dataStore.currentUser.cryptoWallet.transactions.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 64))
                        .foregroundColor(pureLifeGreen.opacity(0.8))
                    
                    Text("No transactions yet")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text("Complete more workouts or convert tokens to see your transaction history")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(pureLifeBlack.opacity(0.7))
                        .padding(.horizontal, 40)
                }
                .padding(.top, 40)
            } else {
                List {
                    ForEach(dataStore.currentUser.cryptoWallet.transactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                }
                .listStyle(PlainListStyle())
                .background(pureLifeLightGreen)
            }
        }
    }
    
    // MARK: - Helper Views
    
    private struct TabButton: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(isSelected ? Color.black : Color.gray)
                    
                    // Indicator
                    Rectangle()
                        .fill(isSelected ? Color.black : Color.clear)
                        .frame(height: 2)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private struct CryptoTypeButton: View {
        let cryptoType: CryptoWallet.CryptoType
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 12) {
                    Image(systemName: cryptoType.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(cryptoType.symbol)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? .white : .primary)
                }
                .frame(width: 80, height: 80)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.orange : Color.white)
                )
            }
        }
    }
    
    private struct TransactionRow: View {
        let transaction: CryptoWallet.Transaction
        
        var body: some View {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: getTransactionIcon())
                    .font(.title2)
                    .foregroundColor(getTransactionColor())
                    .frame(width: 40, height: 40)
                    .background(getTransactionColor().opacity(0.1))
                    .clipShape(Circle())
                
                // Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.description)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(transaction.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Amount
                Text(getFormattedAmount())
                    .font(.headline)
                    .foregroundColor(getTransactionColor())
            }
            .padding(.vertical, 8)
        }
        
        private func getTransactionIcon() -> String {
            switch transaction.type {
            case .received:
                return "arrow.down.circle.fill"
            case .sent:
                return "arrow.up.circle.fill"
            case .converted:
                return "arrow.left.arrow.right.circle.fill"
            }
        }
        
        private func getTransactionColor() -> Color {
            switch transaction.type {
            case .received:
                return .green
            case .sent:
                return .red
            case .converted:
                return .orange
            }
        }
        
        private func getFormattedAmount() -> String {
            let prefix = transaction.type == .received ? "+" : "-"
            if let cryptoType = transaction.cryptoType {
                let formattedAmount = String(format: "%.8f", transaction.amount)
                return "\(prefix)\(formattedAmount) \(cryptoType.symbol)"
            } else {
                let formattedAmount = String(format: "%.2f", transaction.amount)
                return "\(prefix)\(formattedAmount) PURE"
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func isConversionValid() -> Bool {
        guard let amount = Double(conversionAmount), amount > 0 else {
            return false
        }
        
        return amount <= dataStore.currentUser.tokenBalance
    }
    
    private func getConvertButtonBackground() -> Color {
        if isConversionValid() {
            return pureLifeBlack
        } else {
            return Color.gray.opacity(0.5)
        }
    }
    
    private func convertTokens() {
        guard let amount = Double(conversionAmount), amount > 0 else {
            return
        }
        
        // Intentar convertir tokens a crypto
        if dataStore.currentUser.convertTokensToCrypto(amount: amount, to: selectedCryptoType) {
            // Éxito, guardar cambios
            dataStore.saveData()
            
            // Limpiar campo
            conversionAmount = ""
        }
    }
} 