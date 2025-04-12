import SwiftUI

// Enum FilterOption movido fuera de WorkoutListView para estar disponible globalmente
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

struct WorkoutListView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showingNewWorkout = false
    @State private var selectedWorkout: Workout?
    @State private var searchText = ""
    @State private var selectedFilterOption: FilterOption = .all
    @State private var showingFilterOptions = false
    @Environment(\.colorScheme) var colorScheme
    
    // New state for showing the AI recommendation
    @State private var showingAIRecommendation = true
    
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
        NavigationView {
            ZStack {
                // Background image with proper handling
                let bgImageName = getBackgroundImageForWorkouts()
                if let uiImage = UIImage(named: bgImageName) {
                    Image(bgImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .clipped()
                        .opacity(0.15)
                } else {
                    // Fallback color if image isn't available
                    Color(PureLifeColors.adaptiveSurfaceSecondary(scheme: colorScheme))
                        .opacity(0.15)
                }
                
                // Main content scroll
                mainScrollView
            }
            .navigationBarTitle("Workout List", displayMode: .large)
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
    }
    
    // MARK: - Main Content Components
    
    private var mainScrollView: some View {
        VStack(spacing: 0) {
            // Fixed Header - Stays at the top
            headerView
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)
            
            // Scrollable content with workouts and recommendation
            ScrollView {
                VStack(spacing: 16) {
                    // AI recommendation section
                    AIRecommendationSection
                    
                    // Workout counter and add button
                    workoutCounterView
                        .padding(.horizontal, 20)
                    
                    // Filter options if visible
                    if showingFilterOptions {
                        FilterOptionsView(selectedFilter: $selectedFilterOption)
                            .padding(.top, 8)
                            .padding(.bottom, 8)
                            .transition(.opacity) // Simpler transition to avoid layout shifts
                    }
                    
                    // Main workout content - list or empty state
                    if filteredWorkouts.isEmpty {
                        emptyStateView
                            .padding(.top, 20)
                    } else {
                        // Workout list with improved layout
                        workoutListView
                            .padding(.vertical, 8)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Header Components
    
    private var headerView: some View {
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
                    withAnimation(.easeInOut(duration: 0.2)) {
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
    }
    
    // MARK: - Recommendation Section
    
    private var AIRecommendationSection: some View {
        VStack {
            if showingAIRecommendation {
                // Recommendation card
                WorkoutRecommendationView()
                    .fixedSize(horizontal: false, vertical: true) // Natural sizing
                    .padding(.horizontal, 20)
                    .transition(.opacity)
            } else {
                // Button to show recommendation if hidden
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showingAIRecommendation = true
                        dataStore.trackEvent(eventName: "show_ai_recommendation")
                    }
                }) {
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                        Text("Show AI Recommendation")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(PureLifeColors.logoGreen)
                    .padding(.vertical, 8)
                }
                .padding(.horizontal, 20)
                .transition(.opacity)
            }
        }
    }
    
    // MARK: - Workout Counter and List
    
    private var workoutCounterView: some View {
        HStack {
            Text("\(filteredWorkouts.count) \(filteredWorkouts.count == 1 ? "Workout" : "Workouts")")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
            
            Spacer()
            
            Button(action: {
                showingNewWorkout = true
                dataStore.trackEvent(eventName: "add_workout_button_tapped")
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
    }
    
    private var workoutListView: some View {
        LazyVStack(spacing: 16, pinnedViews: []) {
            ForEach(filteredWorkouts) { workout in
                NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                    WorkoutCardView(workout: workout)
                }
                .buttonStyle(ScaledButtonStyle())
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Supporting Views
    
    private var emptyStateView: some View {
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
    
    // MARK: - Helper methods
    
    private func getBackgroundImageForWorkouts() -> String {
        // Choose background image based on filtered workouts or selected filter
        if selectedFilterOption != .all {
            switch selectedFilterOption {
            case .running:
                return "running"
            case .cycling:
                return "cycling"
            case .walking:
                return "Bike"
            case .weightTraining:
                return "weight_lifting"
            default:
                return "couple athlete"
            }
        } else if !filteredWorkouts.isEmpty {
            // Use the most recent workout type for background
            let recentWorkout = filteredWorkouts.first!
            switch recentWorkout.type.rawValue.lowercased() {
            case "running":
                return "running"
            case "cycling":
                return "cycling"
            case "walking":
                return "Bike"
            case "weight training", "strength":
                return "weight_lifting"
            default:
                return "couple athlete"
            }
        } else {
            return "couple athlete"
        }
    }
}

struct WorkoutCardView: View {
    let workout: Workout
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Workout top section with type and date
            HStack {
                // Workout type icon
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor)
                        .frame(width: 42, height: 42)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(workout.type.rawValue)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                    
                    Text(formattedDate)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                }
                
                Spacer()
                
                // Chevron with circle background
                ZStack {
                    Circle()
                        .strokeBorder(PureLifeColors.adaptiveDivider(scheme: colorScheme), lineWidth: 1)
                        .frame(width: 26, height: 26)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                }
            }
            
            // Divider with gradient
            Rectangle()
                .fill(PureLifeColors.adaptiveDivider(scheme: colorScheme))
                .frame(height: 1)
            
            // Fixed grid with equal spacing - more reliable layout
            HStack {
                // Duration
                metricItem(
                    value: formattedDuration,
                    label: "Duration",
                    icon: "clock.fill"
                )
                
                Spacer()
                
                // Calories
                metricItem(
                    value: "\(Int(workout.caloriesBurned))",
                    label: "Calories",
                    icon: "flame.fill"
                )
                
                Spacer()
                
                // Distance
                metricItem(
                    value: workout.distance != nil ? String(format: "%.1f km", workout.distance!) : "N/A",
                    label: "Distance",
                    icon: "location.fill"
                )
            }
            
            // Optional notes section with fixed constraints
            if let notes = workout.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    
                    Text(notes)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 2)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(PureLifeColors.adaptiveSurface(scheme: colorScheme))
                .shadow(color: PureLifeColors.adaptiveCardShadow(scheme: colorScheme), radius: 5, x: 0, y: 2)
        )
        .contentShape(Rectangle()) // Ensure the entire card is tappable
    }
    
    // MARK: - Helper methods
    
    private func metricItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(PureLifeColors.logoGreen)
                
                Text(label)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
            }
            
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
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

// ButtonStyle para crear un efecto de escala al presionar
struct ScaledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Vista para las opciones de filtro
struct FilterOptionsView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Binding var selectedFilter: FilterOption
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Filter by")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(FilterOption.allCases, id: \.self) { option in
                        filterButton(for: option)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
        }
    }
    
    private func filterButton(for option: FilterOption) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedFilter = option
                // Track filter usage
                dataStore.trackEvent(eventName: "filter_workouts_by_\(option.rawValue.lowercased().replacingOccurrences(of: " ", with: "_"))")
            }
        }) {
            HStack(spacing: 4) {
                Image(systemName: option.icon)
                    .font(.system(size: 12))
                
                Text(option.rawValue)
                    .font(.system(size: 13, weight: selectedFilter == option ? .bold : .medium, design: .rounded))
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundColor(selectedFilter == option ? 
                          .white : 
                          PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
            .background(
                Capsule()
                    .fill(selectedFilter == option ? 
                        PureLifeColors.logoGreen : 
                        PureLifeColors.adaptiveSurfaceSecondary(scheme: colorScheme))
            )
        }
    }
    
    init(selectedFilter: Binding<FilterOption>) {
        self._selectedFilter = selectedFilter
    }
} 