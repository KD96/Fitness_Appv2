import SwiftUI
import UIKit

struct WorkoutDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataStore: AppDataStore
    
    let workout: Workout
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo principal
                PureLifeColors.darkBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        workoutHeader
                        
                        // Estadísticas
                        statsSection
                        
                        // Notas (si existen)
                        if let notes = workout.notes, !notes.isEmpty {
                            notesSection(notes)
                        }
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                            .foregroundColor(PureLifeColors.pureGreen)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Workout Details")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(PureLifeColors.textPrimary)
                }
            }
        }
    }
    
    // MARK: - UI Components
    
    private var workoutHeader: some View {
        PureLifeUI.card {
            HStack(spacing: 15) {
                // Icono del tipo de workout
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
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(PureLifeColors.textTertiary)
                }
                
                Spacer()
            }
            .padding(20)
        }
    }
    
    private var statsSection: some View {
        PureLifeUI.card {
            VStack(spacing: 20) {
                Text("Workout Stats")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
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
            .padding(20)
        }
    }
    
    private func notesSection(_ notes: String) -> some View {
        PureLifeUI.card {
            VStack(alignment: .leading, spacing: 15) {
                Text("Notes")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.textPrimary)
                
                Text(notes)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(PureLifeColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
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
    
    // MARK: - Helpers
    
    var typeColor: Color {
        switch workout.type {
        case .running:
            return Color.blue
        case .cycling:
            return Color.orange
        case .swimming:
            return Color.cyan
        case .yoga:
            return Color.purple
        case .hiit:
            return Color.red
        case .strength:
            return Color.green
        case .walking:
            return Color.teal
        case .other:
            return Color.gray
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