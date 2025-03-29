import SwiftUI

struct WorkoutListView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showingDetail = false
    @State private var selectedWorkout: Workout?
    @State private var searchText = ""
    @State private var showingFilter = false
    @State private var selectedWorkoutType: WorkoutType?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo principal
                PureLifeColors.adaptiveBackground(scheme: colorScheme).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header personalizado
                    headerView
                    
                    // Barra de búsqueda y filtros
                    searchAndFilterBar
                    
                    // Lista de entrenamientos
                    if filteredWorkouts.isEmpty {
                        emptyStateView
                    } else {
                        workoutListView
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingDetail) {
                if let workout = selectedWorkout {
                    WorkoutDetailView(workout: workout)
                        .environmentObject(dataStore)
                }
            }
        }
        .accentColor(PureLifeColors.logoGreen)
    }
    
    // MARK: - Computed Properties
    
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
    
    var filteredWorkouts: [Workout] {
        var workouts = dataStore.currentUser.completedWorkouts
        
        // Aplicar filtro por tipo si está seleccionado
        if let type = selectedWorkoutType {
            workouts = workouts.filter { $0.type == type }
        }
        
        // Aplicar filtro de búsqueda si hay texto
        if !searchText.isEmpty {
            workouts = workouts.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.type.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Ordenar por fecha, más reciente primero
        return workouts.sorted(by: { $0.date > $1.date })
    }
    
    // MARK: - UI Components
    
    private var headerView: some View {
        VStack(spacing: 12) {
            // Logo
            PureLifeHeader(showUserAvatar: true, userInitials: userInitials)
            .padding(.bottom, 10)
            
            // Título de página
            HStack {
                Text("Workout History")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .padding(.top, 20)
        .padding(.bottom, 12)
    }
    
    private var searchAndFilterBar: some View {
        VStack(spacing: 16) {
            // Barra de búsqueda
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                
                TextField("Search workouts", text: $searchText)
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                    .accentColor(PureLifeColors.logoGreen)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(PureLifeColors.adaptiveSurface(scheme: colorScheme))
            .cornerRadius(12)
            .shadow(color: PureLifeColors.adaptiveCardShadow(scheme: colorScheme), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 24)
            
            // Filtros por tipo de entrenamiento
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // Filtro "All"
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedWorkoutType = nil
                        }
                    }) {
                        Text("All")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(selectedWorkoutType == nil ? PureLifeColors.logoGreen : PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                selectedWorkoutType == nil ?
                                PureLifeColors.logoGreen.opacity(0.3) :
                                PureLifeColors.adaptiveElevatedSurface(scheme: colorScheme)
                            )
                            .cornerRadius(20)
                    }
                    
                    // Filtros para cada tipo de entrenamiento
                    ForEach(WorkoutType.allCases, id: \.self) { type in
                        Button(action: {
                            withAnimation(.spring()) {
                                if selectedWorkoutType == type {
                                    selectedWorkoutType = nil
                                } else {
                                    selectedWorkoutType = type
                                }
                            }
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: type.icon)
                                    .font(.system(size: 12))
                                
                                Text(type.rawValue)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                            }
                            .foregroundColor(selectedWorkoutType == type ? PureLifeColors.logoGreen : PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                selectedWorkoutType == type ?
                                PureLifeColors.logoGreen.opacity(0.3) :
                                PureLifeColors.adaptiveElevatedSurface(scheme: colorScheme)
                            )
                            .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var workoutListView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                // Si hay filtros activos, mostrar texto informativo
                if !searchText.isEmpty || selectedWorkoutType != nil {
                    HStack {
                        Text(filterInfoText)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                        
                        Spacer()
                        
                        Button(action: {
                            searchText = ""
                            selectedWorkoutType = nil
                        }) {
                            Text("Clear All")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(PureLifeColors.logoGreen)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
                
                // Listar entrenamientos
                ForEach(filteredWorkouts) { workout in
                    WorkoutCard(workout: workout, onSelect: {
                        selectedWorkout = workout
                        showingDetail = true
                    })
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 20)
            }
            .padding(.top, 12)
        }
    }
    
    private var filterInfoText: String {
        var text = "Showing "
        
        if let type = selectedWorkoutType {
            text += "\(type.rawValue) workouts"
        } else {
            text += "all workouts"
        }
        
        if !searchText.isEmpty {
            text += " matching '\(searchText)'"
        }
        
        return text
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.run.circle")
                .font(.system(size: 70))
                .foregroundColor(PureLifeColors.logoGreen.opacity(0.5))
                .padding(.bottom, 10)
            
            Text("No workouts found")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
            
            if !searchText.isEmpty || selectedWorkoutType != nil {
                Text("Try changing your filters")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    searchText = ""
                    selectedWorkoutType = nil
                }) {
                    Text("Clear Filters")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(PureLifeColors.logoGreen)
                        .cornerRadius(12)
                }
                .padding(.top, 8)
            } else {
                Text("Track your first workout to get started")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                NavigationLink(destination: NewWorkoutView()) {
                    Text("Add Workout")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(PureLifeColors.logoGreen)
                        .cornerRadius(12)
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
    }
}

// MARK: - WorkoutCard Component

struct WorkoutCard: View {
    let workout: Workout
    var onSelect: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Icono del tipo de ejercicio
                Image(systemName: workout.type.icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 42, height: 42)
                    .background(PureLifeColors.logoGreen)
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.name)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                        .lineLimit(1)
                    
                    Text(workout.type.rawValue.capitalized)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formattedDate(workout.date))
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    
                    // Stats mini-row
                    HStack(spacing: 16) {
                        Label("\(workout.durationMinutes) min", systemImage: "clock")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                        
                        Label("\(Int(workout.caloriesBurned)) cal", systemImage: "flame.fill")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(PureLifeColors.adaptiveSurface(scheme: colorScheme))
                    .shadow(color: PureLifeColors.adaptiveCardShadow(scheme: colorScheme), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
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