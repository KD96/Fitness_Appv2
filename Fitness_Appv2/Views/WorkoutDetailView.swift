import SwiftUI
import UIKit

struct WorkoutDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showingDeleteConfirmation = false
    
    let workout: Workout
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Header section with workout image and basic info
                headerSection
                
                // Workout details and stats
                UIComponents.Card(title: "Workout Details", icon: "chart.bar.fill") {
                    detailsSection
                }
                .padding(.horizontal, Spacing.screenHorizontalPadding)
                
                // Notes section if available
                if let notes = workout.notes, !notes.isEmpty {
                    UIComponents.Card(title: "Notes", icon: "note.text") {
                        Text(notes)
                            .font(.system(size: PureLifeTypography.body1, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                    }
                    .padding(.horizontal, Spacing.screenHorizontalPadding)
                }
                
                // Action buttons
                actionsSection
                    .padding(.horizontal, Spacing.screenHorizontalPadding)
                    .padding(.bottom, Spacing.xl)
            }
            .padding(.top, Spacing.lg)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }
            
            ToolbarItem(placement: .principal) {
                Text(workout.name)
                    .font(.system(size: PureLifeTypography.heading4, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.textPrimary)
            }
        }
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("Delete Workout"),
                message: Text("Are you sure you want to delete this workout? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    deleteWorkout()
                },
                secondaryButton: .cancel()
            )
        }
        .background(PureLifeColors.background.ignoresSafeArea())
    }
    
    // MARK: - UI Components
    
    private var backgroundImage: String {
        switch workout.type {
        case .running:
            return "running"
        case .cycling:
            return "cycling"
        case .walking:
            return "Bike"
        case .strength:
            return "weight_lifting"
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 0) {
            // Real image for workout type
            ZStack(alignment: .center) {
                // Background image
                if let image = UIImage(named: backgroundImage) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 180)
                } else {
                    // Fallback gradient background
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [typeColor.opacity(0.3), typeColor.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 180)
                }
                
                // Overlay gradient for better text visibility
                LinearGradient(
                    gradient: Gradient(colors: [.black.opacity(0.6), .clear, .black.opacity(0.6)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 180)
                
                // Workout type icon with improved visibility
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: AthleteImages.getIconForWorkoutType(workout.type))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 60)
                        .foregroundColor(.white)
                }
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .cornerRadius(16, corners: [.topLeft, .topRight])
            
            UIComponents.Card(title: "", cornerRadius: 0) {
                HStack(spacing: 15) {
                    // Workout type icon
                    ZStack {
                        Circle()
                            .fill(typeColor.opacity(0.15))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: workout.type.icon)
                            .font(.system(size: 24))
                            .foregroundColor(typeColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(workout.name)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.textPrimary)
                        
                        Text(workout.type.rawValue)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(PureLifeColors.textSecondary)
                        
                        Text(formattedDate)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(PureLifeColors.textSecondary)
                            .padding(.top, 5)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, Spacing.screenHorizontalPadding)
        .shadow(radius: 5)
    }
    
    private var detailsSection: some View {
        VStack(spacing: 20) {
            // Grid de estadísticas
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                // Duración
                statItem(
                    iconName: "clock.fill",
                    iconColor: .blue,
                    value: formattedDuration,
                    label: "Duration"
                )
                
                // Calorías
                statItem(
                    iconName: "flame.fill",
                    iconColor: .orange,
                    value: "\(Int(workout.caloriesBurned))",
                    label: "Calories"
                )
                
                // Distancia (si aplica)
                if let distance = workout.distance, distance > 0 {
                    statItem(
                        iconName: "arrow.left.and.right",
                        iconColor: .green,
                        value: String(format: "%.1f km", distance),
                        label: "Distance"
                    )
                }
                
                // Tokens ganados
                statItem(
                    iconName: "bitcoinsign.circle.fill",
                    iconColor: .yellow,
                    value: "\(Int(workout.tokensEarned))",
                    label: "Tokens Earned"
                )
            }
        }
    }
    
    private func statItem(iconName: String, iconColor: Color, value: String, label: String) -> some View {
        HStack(spacing: 15) {
            // Icono
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: iconName)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.textPrimary)
                
                Text(label)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(PureLifeColors.textSecondary)
            }
            
            Spacer()
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: Spacing.md) {
            UIComponents.PrimaryButton(
                title: "Complete Workout",
                icon: "checkmark.circle.fill",
                action: {
                    withAnimation(.spring()) {
                        // Mark workout as completed logic would go here
                        // dataStore.markWorkoutAsCompleted(workout)
                    }
                }
            )
            
            HStack(spacing: Spacing.md) {
                UIComponents.SecondaryButton(
                    title: "Edit",
                    icon: "pencil",
                    action: {
                        // Edit workout logic would go here
                    }
                )
                
                UIComponents.SecondaryButton(
                    title: "Delete",
                    icon: "trash",
                    action: {
                        withAnimation {
                            showingDeleteConfirmation = true
                        }
                    }
                )
            }
        }
    }
    
    private var backButton: some View {
        Button(action: {
            withAnimation {
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            ZStack {
                Circle()
                    .fill(PureLifeColors.logoGreen.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(PureLifeColors.logoGreen)
            }
        }
    }
    
    // MARK: - Helpers
    
    var typeColor: Color {
        switch workout.type {
        case .running:
            return Color.blue
        case .cycling:
            return Color.orange
        case .strength:
            return Color.green
        case .walking:
            return Color.teal
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy 'at' h:mm a"
        return formatter.string(from: workout.date)
    }
    
    var formattedDuration: String {
        let minutes = workout.durationMinutes
        if minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func deleteWorkout() {
        // Implementation of deleteWorkout function
        withAnimation(.spring()) {
            // dataStore.deleteWorkout(workout)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleWorkout = Workout(
            id: UUID(),
            name: "Morning Run",
            type: .running,
            durationMinutes: 30,
            date: Date(),
            caloriesBurned: 250,
            tokensEarned: 3,
            notes: nil,
            distance: 3.5,
            completed: true
        )
        
        return WorkoutDetailView(workout: sampleWorkout)
            .environmentObject(AppDataStore())
            .preferredColorScheme(.dark)
    }
} 