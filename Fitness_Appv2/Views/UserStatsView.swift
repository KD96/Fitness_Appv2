import SwiftUI
import Charts

struct UserStatsView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var selectedTimeFrame: TimeFrame = .week
    @State private var selectedStatTab = 0
    
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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Tarjeta de información del usuario
                userInfoCard
                
                // Selector de periodo
                timeFrameSelector
                
                // Gráfico principal
                activityChartCard
                
                // Selector de pestañas
                tabSelector
                    .padding(.top, 5)
                
                // Grid de estadísticas
                statsGrid
                    .padding(.top, 5)
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, 16)
        }
        .background(PureLifeColors.background)
    }
    
    // MARK: - Componentes de UI
    
    // Tarjeta de información del usuario
    private var userInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Información del usuario
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hello, \(dataStore.currentUser.firstName)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(PureLifeColors.textPrimary)
                    
                    Text("Your fitness journey")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(PureLifeColors.textSecondary)
                }
                
                Spacer()
                
                // Avatar del usuario
                ZStack {
                    Circle()
                        .fill(PureLifeColors.logoGreen.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Text(userInitials)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(PureLifeColors.logoGreen)
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
    
    // Selector de periodo
    private var timeFrameSelector: some View {
        HStack {
            ForEach(TimeFrame.allCases) { timeFrame in
                Button(action: {
                    withAnimation(.spring()) {
                        selectedTimeFrame = timeFrame
                    }
                }) {
                    Text(timeFrame.rawValue)
                        .font(.system(size: 14, weight: selectedTimeFrame == timeFrame ? .bold : .medium, design: .rounded))
                        .foregroundColor(selectedTimeFrame == timeFrame ? PureLifeColors.textPrimary : PureLifeColors.textSecondary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            ZStack {
                                if selectedTimeFrame == timeFrame {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(PureLifeColors.logoGreen.opacity(0.3))
                                }
                            }
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                if timeFrame != TimeFrame.allCases.last {
                    Spacer()
                }
            }
        }
    }
    
    // Tarjeta del gráfico de actividad
    private var activityChartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Progress")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(PureLifeColors.textPrimary)
            
            // Gráfico
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(dataStore.getWorkoutDataForChart(timeFrame: selectedTimeFrame)) { item in
                        BarMark(
                            x: .value("Day", item.label),
                            y: .value("Value", item.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [PureLifeColors.logoGreen, PureLifeColors.logoGreen.opacity(0.7)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(6)
                    }
                }
                .chartYScale(domain: 0...dataStore.getMaxChartValue(timeFrame: selectedTimeFrame))
                .frame(height: 180)
            } else {
                // Fallback para versiones anteriores de iOS
                Text("Charts available on iOS 16 and newer")
                    .foregroundColor(PureLifeColors.textSecondary)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .frame(height: 180)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            // Leyenda para el gráfico
            HStack(spacing: 16) {
                legendItem(color: PureLifeColors.logoGreen, label: "Workouts")
                legendItem(color: PureLifeColors.logoGreen.opacity(0.7), label: "Target")
            }
        }
        .padding(18)
        .background(PureLifeColors.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    // Selector de pestañas de estadísticas
    private var tabSelector: some View {
        HStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring()) {
                    selectedStatTab = 0
                }
            }) {
                Text("Workouts")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(selectedStatTab == 0 ? PureLifeColors.logoGreen : PureLifeColors.textSecondary)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
            }
            .background(
                Rectangle()
                    .fill(Color.clear)
                    .overlay(
                        Rectangle()
                            .fill(selectedStatTab == 0 ? PureLifeColors.logoGreen : Color.clear)
                            .frame(height: 2),
                        alignment: .bottom
                    )
            )
            
            Button(action: {
                withAnimation(.spring()) {
                    selectedStatTab = 1
                }
            }) {
                Text("Activity")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(selectedStatTab == 1 ? PureLifeColors.logoGreen : PureLifeColors.textSecondary)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
            }
            .background(
                Rectangle()
                    .fill(Color.clear)
                    .overlay(
                        Rectangle()
                            .fill(selectedStatTab == 1 ? PureLifeColors.logoGreen : Color.clear)
                            .frame(height: 2),
                        alignment: .bottom
                    )
            )
        }
        .background(PureLifeColors.surface)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
    }
    
    // Grid de estadísticas
    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            if selectedStatTab == 0 {
                // Workouts stats
                statCard(
                    icon: "figure.run",
                    title: "Workouts",
                    value: "\(dataStore.totalWorkoutsCompleted)",
                    trend: "+\(dataStore.weeklyWorkoutCount)",
                    trendLabel: "this week",
                    iconColor: PureLifeColors.logoGreen
                )
                
                statCard(
                    icon: "clock",
                    title: "Minutes",
                    value: "\(dataStore.totalMinutesExercised)",
                    trend: "+\(dataStore.weeklyMinutesExercised)",
                    trendLabel: "this week",
                    iconColor: Color.blue
                )
                
                statCard(
                    icon: "flame.fill",
                    title: "Calories",
                    value: "\(Int(dataStore.totalCaloriesBurned))",
                    trend: "+\(Int(dataStore.weeklyCaloriesBurned))",
                    trendLabel: "this week",
                    iconColor: Color.orange
                )
                
                statCard(
                    icon: "star.fill",
                    title: "Tokens",
                    value: "\(Int(dataStore.currentUser.tokenBalance))",
                    trend: "+\(Int(dataStore.weeklyTokensEarned))",
                    trendLabel: "this week",
                    iconColor: Color.yellow
                )
            } else {
                // Activity stats
                healthMetricCard(
                    icon: "figure.walk",
                    title: "Steps",
                    value: "\(dataStore.healthKitData.stepsCount)",
                    target: "10,000 steps",
                    progress: CGFloat(dataStore.healthKitData.stepsCount) / 10000.0,
                    iconColor: PureLifeColors.logoGreen
                )
                
                healthMetricCard(
                    icon: "map",
                    title: "Distance",
                    value: String(format: "%.1f km", dataStore.healthKitData.distance),
                    target: "5.0 km goal",
                    progress: CGFloat(dataStore.healthKitData.distance) / 5.0,
                    iconColor: Color.blue
                )
                
                healthMetricCard(
                    icon: "bolt.fill",
                    title: "Active Energy",
                    value: "\(Int(dataStore.healthKitData.activeEnergy)) kcal",
                    target: "600 kcal goal",
                    progress: CGFloat(dataStore.healthKitData.activeEnergy) / 600.0,
                    iconColor: Color.orange
                )
                
                healthMetricCard(
                    icon: "heart.fill",
                    title: "Heart Rate",
                    value: "\(Int(dataStore.healthKitData.heartRate)) bpm",
                    target: "Rest: \(Int(dataStore.healthKitData.restingHeartRate)) bpm",
                    progress: 1.0,
                    iconColor: Color.red
                )
            }
        }
    }
    
    // Tarjeta de estadística
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
                    .foregroundColor(PureLifeColors.logoGreen)
                
                Text(trend)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(PureLifeColors.logoGreen)
                
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
    
    // Tarjeta de métrica de salud
    private func healthMetricCard(icon: String, title: String, value: String, target: String, progress: CGFloat, iconColor: Color) -> some View {
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
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(PureLifeColors.textPrimary)
            
            // Objetivo
            Text(target)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(PureLifeColors.textSecondary)
            
            // Barra de progreso
            ZStack(alignment: .leading) {
                // Fondo
                Capsule()
                    .fill(PureLifeColors.elevatedSurface)
                    .frame(height: 6)
                
                // Progreso
                GeometryReader { geometry in
                    Capsule()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [iconColor, iconColor.opacity(0.7)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, min(progress, 1.0)) * geometry.size.width, height: 6)
                }
                .frame(height: 6)
            }
        }
        .padding(16)
        .background(PureLifeColors.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    // Elemento de leyenda
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
            .preferredColorScheme(.light)
    }
} 