import SwiftUI
import Charts

struct UserStatsView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var selectedTimeFrame: TimeFrame = .week
    
    enum TimeFrame: String, CaseIterable, Identifiable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        
        var id: String { self.rawValue }
    }
    
    // Calcular las iniciales del nombre del usuario
    private var userInitials: String {
        let name = dataStore.currentUser.name
        let components = name.components(separatedBy: " ")
        if components.count > 1, 
           let first = components.first?.prefix(1), 
           let last = components.last?.prefix(1) {
            return "\(first)\(last)"
        } else if let first = name.first {
            return String(first)
        }
        return "U"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Tarjeta de información del usuario
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    // Información del usuario
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hello, \(dataStore.currentUser.firstName)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.textPrimary)
                        
                        Text("Your fitness journey awaits")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(PureLifeColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Avatar del usuario
                    ZStack {
                        Circle()
                            .fill(PureLifeColors.pureGreenLight.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Text(userInitials)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(PureLifeColors.pureGreenDark)
                    }
                }
                
                // Tokens e información de progreso
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(Int(dataStore.currentUser.tokenBalance))")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.textPrimary)
                        
                        Text("Total tokens")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(PureLifeColors.textSecondary)
                    }
                    
                    Divider()
                        .frame(height: 36)
                        .background(PureLifeColors.divider)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(dataStore.totalWorkoutsCompleted)")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.textPrimary)
                        
                        Text("Workouts")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(PureLifeColors.textSecondary)
                    }
                }
                .padding(.top, 4)
            }
            .padding(18)
            .background(PureLifeColors.surface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
        }
    }
    
    // MARK: - Componentes de UI
    
    private func statCard(icon: String, title: String, value: String, trend: String, trendLabel: String, iconColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icono y título
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
                    .frame(width: 36, height: 36)
                    .background(iconColor.opacity(0.1))
                    .cornerRadius(10)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(PureLifeColors.textSecondary)
            }
            
            // Valor principal
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(PureLifeColors.textPrimary)
            
            // Tendencia
            HStack(spacing: 4) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 12))
                    .foregroundColor(PureLifeColors.pureGreen)
                
                Text(trend)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(PureLifeColors.pureGreen)
                
                Text(trendLabel)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(PureLifeColors.textSecondary)
            }
        }
        .padding(16)
        .background(PureLifeColors.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(PureLifeColors.textSecondary)
        }
    }
}

struct UserStatsView_Previews: PreviewProvider {
    static var previews: some View {
        UserStatsView()
            .environmentObject(AppDataStore())
            .preferredColorScheme(.dark)
    }
} 