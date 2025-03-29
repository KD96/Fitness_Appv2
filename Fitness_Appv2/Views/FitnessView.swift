import SwiftUI
import UIKit

struct FitnessView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showingNewWorkout = false
    @State private var selectedWorkout: Workout?
    @State private var showingHealthKitAuth = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 22) {
                    // Header con logo y botón de perfil
                    HStack {
                        PureLifeHeader(showUserAvatar: true, userInitials: String(dataStore.currentUser.firstName.prefix(1)))
                    }
                    .padding(.bottom, 4)
                    
                    // User stats summary
                    UserStatsView()
                        .padding(.horizontal, 24)
                    
                    // Weekly activity summary
                    WeeklyActivityView()
                        .padding(.horizontal, 24)
                    
                    // Banner para conectar con Apple Health si no está habilitado
                    if !dataStore.isHealthKitEnabled {
                        Button(action: {
                            showingHealthKitAuth = true
                        }) {
                            HStack {
                                Image(systemName: "heart.text.square.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(PureLifeColors.logoGreen.opacity(0.8))
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Use your real health data")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                                    
                                    Text("Connect to Apple Health")
                                        .font(.system(size: 13, design: .rounded))
                                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(PureLifeColors.adaptiveSurface(scheme: colorScheme))
                                    .shadow(color: PureLifeColors.adaptiveCardShadow(scheme: colorScheme), radius: 6, x: 0, y: 2)
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    // Recent workouts header
                    HStack {
                        Text("Recent Workouts")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                        
                        Spacer()
                        
                        Button(action: {
                            showingNewWorkout = true
                        }) {
                            Label("Add Workout", systemImage: "plus.circle.fill")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(PureLifeColors.logoGreen)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Recent workouts list
                    VStack(spacing: 16) {
                        if dataStore.currentUser.completedWorkouts.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "figure.run")
                                    .font(.system(size: 60))
                                    .foregroundColor(PureLifeColors.logoGreen.opacity(0.3))
                                    .padding()
                                
                                Text("No workouts yet")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                                
                                Text("Start your fitness journey by adding your first workout")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                                
                                Button(action: {
                                    showingNewWorkout = true
                                }) {
                                    Text("Add Your First Workout")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 24)
                                        .background(PureLifeColors.logoGreen.opacity(0.3))
                                        .cornerRadius(16)
                                }
                                .padding(.top, 12)
                            }
                            .padding(.vertical, 30)
                        } else {
                            ForEach(dataStore.currentUser.completedWorkouts.sorted(by: { $0.date > $1.date })) { workout in
                                WorkoutRowView(workout: workout)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedWorkout = workout
                                    }
                                    .padding(.horizontal, 24)
                            }
                        }
                    }
                }
                .padding(.vertical, 20)
            }
            .background(PureLifeColors.adaptiveBackground(scheme: colorScheme).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewWorkout = true
                    }) {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundColor(PureLifeColors.logoGreen)
                    }
                }
            }
            .sheet(isPresented: $showingNewWorkout) {
                NewWorkoutView()
            }
            .sheet(item: $selectedWorkout) { workout in
                WorkoutDetailView(workout: workout)
            }
            .sheet(isPresented: $showingHealthKitAuth) {
                HealthKitAuthView()
            }
        }
    }
}

struct WeeklyActivityView: View {
    @EnvironmentObject var dataStore: AppDataStore
    let days = ["M", "T", "W", "T", "F", "S", "S"]
    @Environment(\.colorScheme) var colorScheme
    
    // Referencia al HealthKitManager para obtener datos
    private let healthKitManager = HealthKitManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Weekly Activity")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                
                Spacer()
                
                if dataStore.isHealthKitEnabled {
                    Text("Apple Health")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding(.bottom, 4)
            
            HStack(spacing: 8) {
                ForEach(0..<7) { index in
                    VStack(spacing: 6) {
                        ZStack(alignment: .bottom) {
                            Rectangle()
                                .foregroundColor(PureLifeColors.adaptiveElevatedSurface(scheme: colorScheme))
                                .frame(width: 30, height: 100)
                                .cornerRadius(8)
                            
                            let activityLevel = getActivityLevel(for: index)
                            if activityLevel > 0 {
                                Rectangle()
                                    .foregroundColor(activityColor(activityLevel))
                                    .frame(width: 30, height: max(0, min(activityLevel * 100, 100)))
                                    .cornerRadius(8)
                            }
                        }
                        
                        Text(days[index])
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(PureLifeColors.adaptiveSurface(scheme: colorScheme))
                .shadow(color: PureLifeColors.adaptiveCardShadow(scheme: colorScheme), radius: 5, x: 0, y: 2)
        )
    }
    
    // Obtener el nivel de actividad del HealthKitManager si está disponible
    private func getActivityLevel(for index: Int) -> Double {
        if dataStore.isHealthKitEnabled {
            let value = healthKitManager.weeklyActivityLevels[index]
            // Proteger contra NaN y valores negativos
            if value.isNaN || value < 0 {
                return 0
            }
            return value
        } else {
            // Valores simulados si HealthKit no está disponible
            let simulatedLevels: [Double] = [0.3, 0.7, 0.5, 0.8, 0.2, 0.9, 0.6]
            return simulatedLevels[index]
        }
    }
    
    func activityColor(_ level: Double) -> Color {
        // Validación adicional para evitar problemas con valores extremos
        let safeLevel = max(0, min(level, 1))
        
        if safeLevel < 0.3 {
            return PureLifeColors.logoGreen.opacity(0.3)
        } else if safeLevel < 0.7 {
            return PureLifeColors.logoGreen.opacity(0.8)
        } else {
            return PureLifeColors.logoGreen
        }
    }
}

struct WorkoutRowView: View {
    let workout: Workout
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Icono del tipo de ejercicio
            Image(systemName: workout.type.icon)
                .font(.system(size: 18))
                .foregroundColor(PureLifeColors.logoGreen)
                .frame(width: 46, height: 46)
                .background(PureLifeColors.logoGreen.opacity(0.3))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.type.rawValue.capitalized)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                
                HStack(spacing: 12) {
                    Label("\(workout.durationMinutes) min", systemImage: "clock")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    
                    Label("\(Int(workout.caloriesBurned)) cal", systemImage: "flame.fill")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formattedDate(workout.date))
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                
                Text("+\(String(format: "%.1f", workout.tokensEarned))")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.logoGreen)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(PureLifeColors.adaptiveSurface(scheme: colorScheme))
                .shadow(color: PureLifeColors.adaptiveCardShadow(scheme: colorScheme), radius: 6, x: 0, y: 2)
        )
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct FitnessView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FitnessView()
                .environmentObject(AppDataStore())
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            FitnessView()
                .environmentObject(AppDataStore())
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
} 