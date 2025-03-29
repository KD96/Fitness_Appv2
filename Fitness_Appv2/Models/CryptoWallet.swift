import Foundation

struct CryptoWallet: Codable {
    var balance: Double = 0.0
    var transactions: [Transaction] = []
    
    enum CryptoType: String, Codable, CaseIterable {
        case bitcoin = "Bitcoin"
        case ethereum = "Ethereum"
        case solana = "Solana"
        
        var symbol: String {
            switch self {
            case .bitcoin: return "BTC"
            case .ethereum: return "ETH"
            case .solana: return "SOL"
            }
        }
        
        var icon: String {
            switch self {
            case .bitcoin: return "bitcoinsign.circle.fill"
            case .ethereum: return "e.circle.fill"
            case .solana: return "s.circle.fill"
            }
        }
        
        // Tasas de conversión (1 PureToken = X criptomoneda)
        // Estas tasas deberían actualizarse dinámicamente en una app real
        var conversionRate: Double {
            switch self {
            case .bitcoin: return 0.000001  // 1 token = 0.000001 BTC
            case .ethereum: return 0.00001  // 1 token = 0.00001 ETH
            case .solana: return 0.0001     // 1 token = 0.0001 SOL
            }
        }
    }
    
    enum TransactionType: String, Codable {
        case sent
        case received
        case converted
    }
    
    struct Transaction: Identifiable, Codable {
        var id = UUID()
        var date: Date
        var amount: Double
        var type: TransactionType
        var description: String
        var cryptoType: CryptoType?
    }
    
    // Añadir una transacción al wallet
    mutating func addTransaction(amount: Double, type: TransactionType, description: String, cryptoType: CryptoType? = nil) {
        let transaction = Transaction(
            date: Date(),
            amount: amount,
            type: type,
            description: description,
            cryptoType: cryptoType
        )
        
        transactions.append(transaction)
        
        // Actualizar balance
        switch type {
        case .received, .converted:
            balance += amount
        case .sent:
            balance -= amount
        }
    }
    
    // Convertir tokens a criptomoneda
    mutating func convertTokens(tokenAmount: Double, to cryptoType: CryptoType) -> Double {
        let cryptoAmount = tokenAmount * cryptoType.conversionRate
        
        // Añadir transacción
        addTransaction(
            amount: cryptoAmount,
            type: .converted,
            description: "Converted \(tokenAmount) tokens to \(cryptoType.symbol)",
            cryptoType: cryptoType
        )
        
        return cryptoAmount
    }
} 