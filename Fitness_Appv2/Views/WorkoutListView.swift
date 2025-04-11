import SwiftUI

struct WorkoutListView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showingNewWorkout = false
    @State private var selectedWorkout: Workout?
    @State private var searchText = ""
    @State private var selectedFilterOption: FilterOption = .all
    @State private var showingFilterOptions = false
    @Environment(\.colorScheme) var colorScheme
    
    enum FilterOption: String, CaseIterable, Identifiable {
        case all = "All Workouts"
        case running = "Running"
        case cycling = "Cycling"
        case walking = "Walking"
        case weightTraining = "Weight Training"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .all: return "figure.mixed.cardio"
            case .running: return "figure.run"
            case .cycling: return "figure.outdoor.cycle"
            case .walking: return "figure.walk"
            case .weightTraining: return "dumbbell.fill"
            }
        }
        
        // Convert FilterOption to equivalent WorkoutType
        var workoutType: WorkoutType? {
            switch self {
            case .all: return nil
            case .running: return .running
            case .cycling: return .cycling
            case .walking: return .walking
            case .weightTraining: return .strength
            }
        }
    }
    
    var filteredWorkouts: [Workout] {
        let workouts = dataStore.currentUser.completedWorkouts.sorted(by: { $0.date > $1.date })
        
        // Use workoutType mapping for more reliable filtering
        let filteredByType: [Workout]
        if selectedFilterOption == .all {
            filteredByType = workouts
        } else if let workoutType = selectedFilterOption.workoutType {
            filteredByType = workouts.filter { $0.type == workoutType }
        } else {
            filteredByType = workouts
        }
        
        if searchText.isEmpty {
            return filteredByType
        } else {
            return filteredByType.filter { workout in
                workout.type.rawValue.lowercased().contains(searchText.lowercased()) ||
                workout.notes?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
    }
    
    var body: some View {
        UIComponents.TabContentView(
            backgroundColor: PureLifeColors.adaptiveBackground(scheme: colorScheme)
        ) {
            VStack(spacing: 0) {
                // Custom header with search bar
                VStack(spacing: 16) {
                    // Logo and profile
                    PureLifeHeader(showUserAvatar: true, userInitials: String(dataStore.currentUser.firstName.prefix(1)))
                    
                    // Search and filter area
                    HStack(spacing: 12) {
                        // Search field
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16))
                                .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                            
                            TextField("Search workouts", text: $searchText)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                                .onChange(of: searchText) { _, newValue in
                                    if !newValue.isEmpty {
                                        dataStore.trackEvent(eventName: "workout_search")
                                    }
                                }
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                                }
                            }
                        }
                        .padding(12)
                        .background(PureLifeColors.adaptiveSurface(scheme: colorScheme))
                        .cornerRadius(16)
                        
                        // Filter button
                        Button(action: {
                            withAnimation {
                                showingFilterOptions.toggle()
                                if showingFilterOptions {
                                    dataStore.trackEvent(eventName: "show_workout_filters")
                                }
                            }
                        }) {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(selectedFilterOption != .all ? PureLifeColors.logoGreen : PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                                .frame(width: 40, height: 40)
                                .background(PureLifeColors.adaptiveSurface(scheme: colorScheme))
                                .cornerRadius(14)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // Filter options row (collapsible)
                if showingFilterOptions {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(FilterOption.allCases) { option in
                                Button(action: {
                                    selectedFilterOption = option
                                    dataStore.trackEvent(eventName: "filter_workouts_by_\(option.rawValue.lowercased().replacingOccurrences(of: " ", with: "_"))")
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: option.icon)
                                            .font(.system(size: 14))
                                        
                                        Text(option.rawValue)
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 14)
                                    .foregroundColor(selectedFilterOption == option ? 
                                                    .white : 
                                                    PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                                    .background(
                                        Capsule()
                                            .fill(selectedFilterOption == option ? 
                                                 PureLifeColors.logoGreen : 
                                                 PureLifeColors.adaptiveSurfaceSecondary(scheme: colorScheme))
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Workout counter and add button
                HStack {
                    Text("\(filteredWorkouts.count) \(filteredWorkouts.count == 1 ? "Workout" : "Workouts")")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    
                    Spacer()
                    
                    Button(action: {
                        showingNewWorkout = true
                        dataStore.trackEvent(eventName: "add_workout_button_tapped")
                        dataStore.trackFeatureUsed(featureName: "workout_creation")
                    }) {
                        HStack(spacing: 6) {
                            Text("Add")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                            
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16))
                        }
                        .foregroundColor(PureLifeColors.logoGreen)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 14)
                        .background(
                            Capsule()
                                .fill(PureLifeColors.logoGreen.opacity(0.12))
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // Workouts list or empty state
                if filteredWorkouts.isEmpty {
                    emptyWorkoutsView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredWorkouts) { workout in
                                WorkoutCardView(workout: workout)
                                    .onTapGesture {
                                        selectedWorkout = workout
                                        dataStore.trackEvent(eventName: "view_workout_details")
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingNewWorkout) {
            NewWorkoutView()
        }
        .sheet(item: $selectedWorkout) { workout in
            WorkoutDetailView(workout: workout)
        }
        .onAppear {
            dataStore.trackScreenView(screenName: "WorkoutListView")
        }
    }
    
    // MARK: - Supporting Views
    
    private var emptyWorkoutsView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(PureLifeColors.logoGreen.opacity(0.08))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "figure.run")
                    .font(.system(size: 48))
                    .foregroundColor(PureLifeColors.logoGreen.opacity(0.6))
            }
            
            VStack(spacing: 8) {
                Text(searchText.isEmpty ? "No workouts yet" : "No matching workouts")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                
                Text(searchText.isEmpty ? 
                    "Start your fitness journey by adding your first workout" : 
                    "Try adjusting your search or filters")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 40)
            }
            
            if searchText.isEmpty && selectedFilterOption == .all {
                Button(action: {
                    showingNewWorkout = true
                }) {
                    Text("Add Your First Workout")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
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
                .padding(.top, 12)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WorkoutCardView: View {
    let workout: Workout
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Workout top section with type and date
            HStack {
                // Workout type icon
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.type.rawValue)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                    
                    Text(formattedDate)
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
            
            // Divider with gradient
            Rectangle()
                .fill(PureLifeColors.adaptiveDivider(scheme: colorScheme))
                .frame(height: 1)
            
            // Metrics grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 16) {
                // Duration
                metricItem(
                    value: formattedDuration,
                    label: "Duration",
                    icon: "clock.fill"
                )
                
                // Calories
                metricItem(
                    value: "\(Int(workout.caloriesBurned))",
                    label: "Calories",
                    icon: "flame.fill"
                )
                
                // Distance
                metricItem(
                    value: workout.distance != nil ? String(format: "%.1f km", workout.distance!) : "N/A",
                    label: "Distance",
                    icon: "location.fill"
                )
            }
            
            // Notes section if available
            if let notes = workout.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    
                    Text(notes)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                        .lineLimit(2)
                }
                .padding(.top, 4)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(PureLifeColors.adaptiveSurface(scheme: colorScheme))
                .shadow(color: PureLifeColors.adaptiveCardShadow(scheme: colorScheme), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Helper methods
    
    private func metricItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(PureLifeColors.logoGreen)
                
                Text(label)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
            }
            
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
        }
    }
    
    private var iconName: String {
        switch workout.type.rawValue.lowercased() {
        case "running": return "figure.run"
        case "cycling": return "figure.outdoor.cycle"
        case "walking": return "figure.walk"
        case "weight training": return "dumbbell.fill"
        default: return "figure.mixed.cardio"
        }
    }
    
    private var iconBackgroundColor: Color {
        switch workout.type.rawValue.lowercased() {
        case "running": return Color.blue
        case "cycling": return Color.green
        case "walking": return Color.orange
        case "weight training": return Color.purple
        default: return PureLifeColors.logoGreen
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d, yyyy · h:mm a"
        return formatter.string(from: workout.date)
    }
    
    private var formattedDuration: String {
        let hours = Int(workout.durationMinutes) / 60
        let minutes = Int(workout.durationMinutes) % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WorkoutListView()
                .environmentObject(AppDataStore())
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            WorkoutListView()
                .environmentObject(AppDataStore())
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 