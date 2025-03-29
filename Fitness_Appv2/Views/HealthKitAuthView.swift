import SwiftUI
import HealthKit

struct HealthKitAuthView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.presentationMode) var presentationMode
    @State private var isRequesting = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Colores de PureLife
    private let pureLifeGreen = Color(red: 199/255, green: 227/255, blue: 214/255)
    private let pureLifeLightGreen = Color(red: 220/255, green: 237/255, blue: 230/255)
    private let pureLifeBlack = Color.black
    
    var body: some View {
        NavigationView {
            ZStack {
                pureLifeLightGreen.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Logo
                    VStack(spacing: 10) {
                        Text("pure")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(pureLifeBlack) +
                        Text("life")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(pureLifeBlack) +
                        Text(".")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(pureLifeBlack)
                        
                        Text("Connect to your health data")
                            .font(.body)
                            .foregroundColor(pureLifeBlack.opacity(0.7))
                    }
                    .padding(.top, 50)
                    
                    Spacer()
                    
                    // Health icon
                    Image(systemName: "heart.text.square.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(pureLifeBlack)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(pureLifeGreen)
                        )
                        .padding(.bottom, 20)
                    
                    // Texto explicativo
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(pureLifeGreen)
                            Text("Access your workout history")
                                .foregroundColor(pureLifeBlack)
                        }
                        
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(pureLifeGreen)
                            Text("Track your step count")
                                .foregroundColor(pureLifeBlack)
                        }
                        
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(pureLifeGreen)
                            Text("Monitor your active calories")
                                .foregroundColor(pureLifeBlack)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Botón de conexión
                    Button(action: {
                        requestHealthKitAccess()
                    }) {
                        HStack {
                            if isRequesting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 10)
                            }
                            
                            Text(isRequesting ? "Connecting..." : "Connect to Apple Health")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .background(pureLifeBlack)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                    }
                    .disabled(isRequesting)
                    .padding(.bottom, 20)
                    
                    // Botón "Maybe Later"
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Maybe Later")
                            .font(.subheadline)
                            .foregroundColor(pureLifeBlack.opacity(0.7))
                    }
                    .padding(.bottom, 50)
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Health Data Access"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if dataStore.isHealthKitEnabled {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
        }
    }
    
    private func requestHealthKitAccess() {
        isRequesting = true
        
        if HKHealthStore.isHealthDataAvailable() {
            dataStore.requestHealthKitAuthorization { success in
                DispatchQueue.main.async {
                    isRequesting = false
                    
                    if success {
                        alertMessage = "Successfully connected to Apple Health! Your personal health data will now appear in the app."
                    } else {
                        alertMessage = "Could not access health data. Please make sure that you've granted PureLife permission to access your health data in Settings."
                    }
                    
                    showAlert = true
                }
            }
        } else {
            isRequesting = false
            alertMessage = "HealthKit is not available on this device."
            showAlert = true
        }
    }
}

struct HealthKitAuthView_Previews: PreviewProvider {
    static var previews: some View {
        HealthKitAuthView()
            .environmentObject(AppDataStore())
    }
} 