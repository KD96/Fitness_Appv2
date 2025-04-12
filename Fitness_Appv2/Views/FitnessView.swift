import SwiftUI
import UIKit

struct FitnessView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showingNewWorkout = false
    @State private var selectedWorkout: Workout?
    @State private var showingHealthKitAuth = false
    @Environment(\.colorScheme) var colorScheme
    
    // Reference to HealthKitManager for activity data
    private let healthKitManager = HealthKitManager.shared
    
    var body: some View {
        NavigationView {
            UIComponents.TabContentView(
                backgroundImage: "fitness_background",
                backgroundOpacity: 0.07,
                backgroundColor: PureLifeColors.adaptiveBackground(scheme: colorScheme)
            ) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Header with logo and avatar
                        HStack {
                            PureLifeHeader(showUserAvatar: true, userInitials: String(dataStore.currentUser.firstName.prefix(1)))
                        }
                        .padding(.bottom, 10)
                        
                        // Hero section with welcome and athlete images
                        heroSection
                        
                        // User stats card with modern design
                        userStatsCard
                            .padding(.horizontal, 20)
                        
                        // Featured workout types with athlete images
                        featuredWorkoutTypesSection
                        
                        // Weekly activity card
                        weeklyActivityCard
                            .padding(.horizontal, 20)
                        
                        // Health banner only shown if not connected
                        if !dataStore.isHealthKitEnabled {
                            healthConnectBanner
                        }
                        
                        // Recently completed workouts with modern cards
                        recentWorkoutsSection
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingNewWorkout) {
                NewWorkoutView()
            }
            .sheet(item: $selectedWorkout) { workout in
                WorkoutDetailView(workout: workout)
            }
            .sheet(isPresented: $showingHealthKitAuth) {
                HealthKitAuthView()
            }
            .onAppear {
                // Track screen view
                dataStore.trackScreenView(screenName: "FitnessView")
            }
        }
    }
    
    // MARK: - UI Components
    
    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Hello, \(dataStore.currentUser.firstName)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                
                Text("Ready for your daily workout?")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
            }
            .padding(.horizontal, 20)
            
            // Hero card with real image background
            GeometryReader { geo in
                ZStack(alignment: .bottomLeading) {
                    // Real image background
                    if let image = UIImage(named: "couple athlete") {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: 200)
                            .clipped()
                            .cornerRadius(16)
                    } else {
                        // Fallback gradient background
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        PureLifeColors.accentBlue.opacity(0.7),
                                        PureLifeColors.accentPurple.opacity(0.6)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: geo.size.width, height: 200)
                    }
                    
                    // Overlay gradient for text contrast
                    LinearGradient(
                        gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                        startPoint: .bottom,
                        endPoint: .center
                    )
                    .frame(width: geo.size.width, height: 200)
                    .cornerRadius(16)
                    
                    // Card content
                    VStack(alignment: .leading, spacing: 10) {
                        Spacer()
                        Text("Start your fitness journey")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                        
                        Button(action: {
                            showingNewWorkout = true
                            dataStore.trackEvent(eventName: "hero_add_workout_button_tapped")
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .bold))
                                
                                Text("Add Workout")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 18)
                            .background(PureLifeColors.logoGreen)
                            .cornerRadius(30)
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(20)
                }
                .frame(width: geo.size.width, height: 200)
            }
            .frame(height: 200)
            .padding(.horizontal, 20)
        }
    }
    
    private var userStatsCard: some View {
        UIComponents.GlassMorphicCard(cornerRadius: 24) {
            VStack(spacing: 15) {
                // Stats counters
                HStack(spacing: 0) {
                    // Token balance
                    statItem(
                        title: "Tokens",
                        value: "\(Int(dataStore.currentUser.tokenBalance))",
                        icon: "crown.fill",
                        color: PureLifeColors.logoGreen
                    )
                    
                    // Vertical divider
                    Rectangle()
                        .fill(PureLifeColors.adaptiveDivider(scheme: colorScheme))
                        .frame(width: 1, height: 36)
                    
                    // Workout count
                    statItem(
                        title: "Workouts",
                        value: "\(dataStore.totalWorkoutsCompleted)",
                        icon: "figure.run",
                        color: PureLifeColors.logoGreen
                    )
                    
                    // Vertical divider
                    Rectangle()
                        .fill(PureLifeColors.adaptiveDivider(scheme: colorScheme))
                        .frame(width: 1, height: 36)
                    
                    // Calories
                    statItem(
                        title: "Calories",
                        value: "\(dataStore.totalCaloriesBurned)",
                        icon: "flame.fill",
                        color: Color.orange
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
            }
        }
    }
    
    private func statItem(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
            }
            
            Text(title)
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
        }
        .frame(maxWidth: .infinity)
    }
    
    private var featuredWorkoutTypesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Workout Categories")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                .padding(.horizontal, 20)
            
            GeometryReader { geo in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        workoutTypeCard(.running, geometry: geo)
                        workoutTypeCard(.walking, geometry: geo)
                        workoutTypeCard(.cycling, geometry: geo)
                        workoutTypeCard(.strength, geometry: geo)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                }
            }
            .frame(height: 140)
        }
    }
    
    private func workoutTypeCard(_ type: WorkoutType, geometry: GeometryProxy) -> some View {
        let cardWidth = min(geometry.size.width * 0.25, 100)
        
        return Button(action: {
            // Show workout creation with pre-selected type
            showingNewWorkout = true
        }) {
            VStack(alignment: .center, spacing: 8) {
                // Icon with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AthleteImages.getColorForWorkoutType(type).opacity(0.3),
                                    AthleteImages.getColorForWorkoutType(type).opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: cardWidth * 0.8, height: cardWidth * 0.8)
                    
                    Image(systemName: AthleteImages.getIconForWorkoutType(type))
                        .font(.system(size: cardWidth * 0.3))
                        .foregroundColor(AthleteImages.getColorForWorkoutType(type))
                }
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AthleteImages.getColorForWorkoutType(type).opacity(0.8),
                                    AthleteImages.getColorForWorkoutType(type).opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: AthleteImages.getColorForWorkoutType(type).opacity(0.2), radius: 6, x: 0, y: 3)
                
                Text(type.rawValue.capitalized)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
            }
            .frame(width: cardWidth)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var weeklyActivityCard: some View {
        UIComponents.ModernCard(cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 14) {
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
                .padding(.bottom, 2)
                
                // Weekly activity graph
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(0..<7) { index in
                        VStack(spacing: 8) {
                            // Activity bar
                            let activityLevel = getActivityLevel(for: index)
                            ZStack(alignment: .bottom) {
                                // Placeholder background
                                Rectangle()
                                    .foregroundColor(PureLifeColors.adaptiveSurfaceSecondary(scheme: colorScheme))
                                    .frame(width: 28, height: 100)
                                    .cornerRadius(8)
                                
                                // Activity level indicator
                                if activityLevel > 0 {
                                    Rectangle()
                                        .foregroundColor(activityColor(activityLevel))
                                        .frame(width: 28, height: max(0, min(activityLevel * 100, 100)))
                                        .cornerRadius(8)
                                }
                            }
                            
                            // Day label
                            Text(dayOfWeek(for: index))
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 4)
            }
            .padding(16)
        }
    }
    
    // Obtener el nivel de actividad del HealthKitManager si está disponible
    private func getActivityLevel(for index: Int) -> Double {
        if dataStore.isHealthKitEnabled {
            let value = healthKitManager.weeklyActivityLevels[index]
            // Proteger contra NaN y valores negativos
            if value.isNaN || value < 0 || !value.isFinite {
                return 0
            }
            return min(max(value, 0), 1) // Ensure value is between 0 and 1
        } else {
            // Valores simulados si HealthKit no está disponible
            let simulatedLevels: [Double] = [0.3, 0.7, 0.5, 0.8, 0.2, 0.9, 0.6]
            return simulatedLevels[index]
        }
    }
    
    // Color según el nivel de actividad
    private func activityColor(_ level: Double) -> Color {
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
    
    // Devuelve la etiqueta del día de la semana para un índice dado
    private func dayOfWeek(for index: Int) -> String {
        let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let today = Calendar.current.component(.weekday, from: Date()) - 1 // 0-based index
        let dayIndex = (today + index) % 7
        return days[dayIndex]
    }
    
    private var healthConnectBanner: some View {
        Button(action: {
            showingHealthKitAuth = true
        }) {
            UIComponents.ModernCard(cornerRadius: 24) {
                HStack(spacing: 16) {
                    // Icon with gradient background
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.red.opacity(0.7), Color.red.opacity(0.5)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Use your real health data")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                        
                        Text("Connect to Apple Health")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    }
                    
                    Spacer()
                    
                    // Chevron with circle background
                    ZStack {
                        Circle()
                            .strokeBorder(PureLifeColors.adaptiveDivider(scheme: colorScheme), lineWidth: 1)
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    }
                }
                .padding(20)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title with add button
            HStack {
                Text("Recent Workouts")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                
                Spacer()
                
                Button(action: {
                    showingNewWorkout = true
                    dataStore.trackEvent(eventName: "add_workout_from_recent_section")
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                        
                        Text("Add")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(PureLifeColors.logoGreen)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(PureLifeColors.logoGreen.opacity(0.12))
                    .cornerRadius(20)
                }
            }
            .padding(.horizontal, 20)
            
            if dataStore.currentUser.completedWorkouts.isEmpty {
                emptyWorkoutsView
            } else {
                recentWorkoutsList
            }
        }
    }
    
    private var emptyWorkoutsView: some View {
        VStack(spacing: 18) {
            // Add athlete image for empty state
            if let image = UIImage(named: "athlete2") {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        PureLifeColors.logoGreen,
                                        PureLifeColors.logoGreen.opacity(0.5)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
                    .shadow(color: PureLifeColors.logoGreen.opacity(0.3), radius: 10, x: 0, y: 0)
                    .padding(.top, 20)
            } else {
                ZStack {
                    Circle()
                        .fill(PureLifeColors.logoGreen.opacity(0.08))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "figure.run")
                        .font(.system(size: 48))
                        .foregroundColor(PureLifeColors.logoGreen.opacity(0.6))
                }
                .padding(.top, 20)
            }
            
            VStack(spacing: 8) {
                Text("No workouts yet")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                
                Text("Start your fitness journey by adding your first workout")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                showingNewWorkout = true
            }) {
                HStack {
                    Text("Add Your First Workout")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 32)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [PureLifeColors.logoGreen, PureLifeColors.logoGreenDark]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(28)
                .shadow(color: PureLifeColors.logoGreen.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.top, 10)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity)
        .modifier(PureLifeColors.modernCard(cornerRadius: 24, padding: 0, scheme: colorScheme))
        .padding(.horizontal, 20)
    }
    
    private var recentWorkoutsList: some View {
        VStack(spacing: 12) {
            ForEach(dataStore.currentUser.completedWorkouts.prefix(3)) { workout in
                ModernWorkoutCard(workout: workout) {
                    selectedWorkout = workout
                    dataStore.trackEvent(eventName: "view_workout_from_dashboard")
                }
                .padding(.horizontal, 20)
            }
            
            // See all button
            Button(action: {
                // Change tab to workouts list
                dataStore.trackEvent(eventName: "view_all_workouts_from_dashboard")
            }) {
                HStack {
                    Text("View All Workouts")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                }
                .foregroundColor(PureLifeColors.logoGreen)
                .padding(.vertical, 16)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func startNewWorkout() {
        // Track button tap
        dataStore.trackEvent(eventName: "add_workout_tapped")
        dataStore.trackFeatureUsed(featureName: "workout_creation")
        
        showingNewWorkout = true
    }
    
    private func connectHealthApp() {
        // Track health connection
        dataStore.trackEvent(eventName: "connect_health_tapped")
        dataStore.trackFeatureUsed(featureName: "health_integration")
        
        showingHealthKitAuth = true
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
            if value.isNaN || value < 0 || !value.isFinite {
                return 0
            }
            return min(max(value, 0), 1) // Ensure value is between 0 and 1
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