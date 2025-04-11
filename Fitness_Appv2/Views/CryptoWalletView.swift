import SwiftUI

struct CryptoWalletView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.presentationMode) var presentationMode
    
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
                    }
                    .padding(.top)
                    
                    // Token balance card
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
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    // Coming Soon Message
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.orange)
                        
                        Text("Crypto Features Coming Soon")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(pureLifeBlack)
                        
                        Text("In future updates, you'll be able to convert your fitness tokens to cryptocurrency and track your transactions.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(pureLifeBlack.opacity(0.7))
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                    
                    // Back button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Back to Rewards")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(pureLifeGreen)
                            .cornerRadius(16)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct CryptoWalletView_Previews: PreviewProvider {
    static var previews: some View {
        CryptoWalletView()
            .environmentObject(AppDataStore())
    }
} 