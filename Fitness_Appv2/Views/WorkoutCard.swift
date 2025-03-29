import SwiftUI

struct WorkoutCard: View {
    let workout: Workout
    
    // Formatter para mostrar la fecha
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Encabezado con tipo e ícono
            HStack {
                // Icono del tipo de ejercicio
                Image(systemName: workout.type.icon)
                    .font(.system(size: 14))
                    .foregroundColor(PureLifeColors.pureGreen)
                
                // Tipo de ejercicio
                Text(workout.type.rawValue)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(PureLifeColors.textSecondary)
                
                Spacer()
                
                // Fecha
                Text(dateFormatter.string(from: workout.date))
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(PureLifeColors.textSecondary)
            }
            
            // Nombre del entrenamiento
            Text(workout.name)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(PureLifeColors.textPrimary)
                .padding(.top, 2)
            
            // Estadísticas de entrenamiento
            HStack(spacing: 24) {
                // Duración
                WorkoutStat(
                    icon: "clock",
                    value: formatDuration(minutes: workout.durationMinutes),
                    label: "Duration"
                )
                
                // Calorías
                WorkoutStat(
                    icon: "flame",
                    value: String(format: "%.0f", workout.caloriesBurned),
                    label: "Calories"
                )
                
                // Tokens
                WorkoutStat(
                    icon: "star",
                    value: String(format: "%.0f", workout.tokensEarned),
                    label: "Tokens"
                )
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(PureLifeColors.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    // Dar formato a la duración en minutos
    private func formatDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        
        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }
}

// Sub-componente para mostrar cada estadística
struct WorkoutStat: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(PureLifeColors.pureGreen)
                
                Text(value)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(PureLifeColors.textPrimary)
            }
            
            Text(label)
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(PureLifeColors.textSecondary)
        }
    }
}

// Vista previa
struct WorkoutCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            PureLifeColors.background.ignoresSafeArea()
            
            WorkoutCard(workout: sampleWorkout)
                .padding(20)
        }
        .preferredColorScheme(.light)
    }
    
    // Datos de ejemplo para la vista previa
    static var sampleWorkout: Workout {
        Workout(
            id: UUID(),
            name: "Morning Run",
            type: .running,
            durationMinutes: 45,
            date: Date(),
            caloriesBurned: 320.0,
            tokensEarned: 16.0,
            notes: nil
        )
    }
} 