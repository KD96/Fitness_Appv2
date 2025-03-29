import SwiftUI

struct WorkoutListView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showingDetail = false
    @State private var selectedWorkout: Workout?
    @State private var searchText = ""
    @State private var showingFilter = false
    @State private var selectedWorkoutType: WorkoutType?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo principal
                PureLifeColors.background.ignoresSafeArea()
                
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
        .accentColor(PureLifeColors.pureGreen)
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
            // Logo y título
            HStack {
                HStack(spacing: 0) {
                    Text("pure")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(PureLifeColors.logoGreen)
                    
                    Text("life")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(PureLifeColors.textPrimary)
                    
                    Text(".")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(PureLifeColors.logoGreen)
                }
                
                Spacer()
                
                // Icono de usuario
                ZStack {
                    Circle()
                        .fill(PureLifeColors.pureGreenLight.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Text(userInitials)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(PureLifeColors.pureGreenDark)
                }
            }
            .padding(.horizontal, 24)
            
            // Título de página
            HStack {
                Text("Workout History")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.textPrimary)
                
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
                    .foregroundColor(PureLifeColors.textSecondary)
                
                TextField("Search workouts", text: $searchText)
                    .foregroundColor(PureLifeColors.textPrimary)
                    .accentColor(PureLifeColors.pureGreen)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(PureLifeColors.textSecondary)
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(PureLifeColors.surface)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
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
                            .foregroundColor(selectedWorkoutType == nil ? PureLifeColors.textPrimary : PureLifeColors.textSecondary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                selectedWorkoutType == nil ?
                                PureLifeColors.pureGreenLight :
                                PureLifeColors.elevatedSurface
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
                            .foregroundColor(selectedWorkoutType == type ? PureLifeColors.textPrimary : PureLifeColors.textSecondary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                selectedWorkoutType == type ?
                                PureLifeColors.pureGreenLight :
                                PureLifeColors.elevatedSurface
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
                            .foregroundColor(PureLifeColors.textSecondary)
                        
                        Spacer()
                        
                        Button(action: {
                            searchText = ""
                            selectedWorkoutType = nil
                        }) {
                            Text("Clear filters")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(PureLifeColors.pureGreen)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
                
                ForEach(filteredWorkouts) { workout in
                    WorkoutCard(workout: workout)
                        .onTapGesture {
                            selectedWorkout = workout
                            showingDetail = true
                        }
                        .padding(.horizontal, 24)
                }
                // Espaciado extra al final para mostrar todo el contenido
                Color.clear.frame(height: 20)
            }
            .padding(.top, 8)
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
            Spacer()
            
            Image(systemName: "figure.run")
                .font(.system(size: 60))
                .foregroundColor(PureLifeColors.pureGreenLight)
            
            Text("No workouts found")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(PureLifeColors.textPrimary)
            
            if !searchText.isEmpty || selectedWorkoutType != nil {
                Text("Try changing your filters")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(PureLifeColors.textSecondary)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    searchText = ""
                    selectedWorkoutType = nil
                }) {
                    Text("Clear filters")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(PureLifeColors.textPrimary)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 30)
                        .background(PureLifeColors.pureGreenLight)
                        .cornerRadius(16)
                }
                .padding(.top, 10)
            } else {
                Text("Track your first workout to get started")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(PureLifeColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                NavigationLink(destination: NewWorkoutView()) {
                    Text("Add Workout")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(PureLifeColors.textPrimary)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 30)
                        .background(PureLifeColors.pureGreenLight)
                        .cornerRadius(16)
                }
                .padding(.top, 10)
            }
            
            Spacer()
        }
    }
}

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutListView()
            .environmentObject(AppDataStore())
            .preferredColorScheme(.light)
    }
} 