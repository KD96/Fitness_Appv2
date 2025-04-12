import SwiftUI

struct ModernWorkoutCard: View {
    let workout: Workout
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    // Propiedades derivadas
    private var colorForWorkoutType: Color {
        switch workout.type {
        case .running:
            return .blue
        case .cycling:
            return .orange
        case .strength:
            return .green
        case .walking:
            return .teal
        }
    }
    
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
    
    var body: some View {
        Button(action: onTap) {
            cardContent
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var cardContent: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // Background image for the workout type
                if let image = UIImage(named: backgroundImage) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: 200)
                        .clipped()
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            colorForWorkoutType.opacity(0.7),
                                            colorForWorkoutType.opacity(0.1)
                                        ]),
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                        )
                }
                
                // Workout details
                VStack(alignment: .leading, spacing: 0) {
                    // Bottom section with metrics
                    VStack(alignment: .leading, spacing: 16) {
                        // Top info section
                        HStack(spacing: 16) {
                            // Workout type icon
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.9))
                                    .frame(width: 45, height: 45)
                                
                                Image(systemName: workout.type.icon)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(colorForWorkoutType)
                            }
                            
                            // Workout details
                            VStack(alignment: .leading, spacing: 3) {
                                Text(workout.name)
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text(formatDate(workout.date))
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            Spacer()
                            
                            // Completion indicator or duration
                            VStack(alignment: .trailing, spacing: 2) {
                                HStack(spacing: 4) {
                                    if workout.completed {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(PureLifeColors.success)
                                            .font(.system(size: 12))
                                    }
                                    
                                    Text("\(workout.durationMinutes) min")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(workout.completed ? 
                                                       PureLifeColors.success : 
                                                       Color.white)
                                }
                                
                                // Tokens earned
                                if workout.completed {
                                    HStack(spacing: 2) {
                                        Image(systemName: "leaf.fill")
                                            .font(.system(size: 10))
                                            .foregroundColor(PureLifeColors.logoGreen)
                                        
                                        Text("+\(Int(workout.tokensEarned))")
                                            .font(.system(size: 11, weight: .medium, design: .rounded))
                                            .foregroundColor(PureLifeColors.logoGreen)
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        
                        // Metrics - compact version
                        HStack(spacing: geo.size.width * 0.05) {
                            ForEach(relevantMetrics.prefix(3), id: \.self) { metric in
                                metricView(for: metric)
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.black.opacity(0.7),
                                        Color.black.opacity(0.4)
                                    ]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                    )
                }
            }
            .frame(height: 200)
            .cornerRadius(16)
            .shadow(
                color: PureLifeColors.adaptiveCardShadow(scheme: colorScheme),
                radius: 8,
                x: 0,
                y: 3
            )
        }
        .frame(height: 200)
    }
    
    private func metricView(for metric: WorkoutMetric) -> some View {
        VStack(spacing: 3) {
            // Icon
            Image(systemName: metric.icon)
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            // Value
            Text(valueForMetric(metric))
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.white)
            
            // Label
            Text(metric.rawValue)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Helper Methods
    
    private var relevantMetrics: [WorkoutMetric] {
        // Just show 3 key metrics
        var metrics = workout.type.relevantMetrics
        return Array(metrics.prefix(3))
    }
    
    private func valueForMetric(_ metric: WorkoutMetric) -> String {
        switch metric {
        case .duration:
            return "\(workout.durationMinutes) min"
        case .distance:
            guard let distance = workout.distance else { return "0 km" }
            return String(format: "%.1f km", distance)
        case .calories:
            return "\(Int(workout.caloriesBurned))"
        case .steps:
            guard let steps = workout.steps else { return "0" }
            return "\(steps)"
        case .heartRate:
            guard let heartRate = workout.heartRate?.average else { return "0 bpm" }
            return "\(heartRate) bpm"
        case .laps:
            guard let laps = workout.laps else { return "0" }
            return "\(laps)"
        case .reps:
            guard let reps = workout.reps else { return "0" }
            return "\(reps)"
        case .sets:
            guard let sets = workout.sets else { return "0" }
            return "\(sets)"
        case .weight:
            guard let weight = workout.weight else { return "0 kg" }
            return "\(Int(weight)) kg"
        case .intensity:
            return workout.intensity?.rawValue ?? "Medium"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        // If it's today, show the time
        if Calendar.current.isDateInToday(date) {
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return "Today, \(formatter.string(from: date))"
        }
        
        // If it's yesterday
        if Calendar.current.isDateInYesterday(date) {
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return "Yesterday, \(formatter.string(from: date))"
        }
        
        // Otherwise show the full date
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }
}

struct ModernWorkoutCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ModernWorkoutCard(
                workout: Workout(
                    name: "Morning Run",
                    type: .running,
                    durationMinutes: 30,
                    date: Date(),
                    caloriesBurned: 280,
                    tokensEarned: 8.0,
                    distance: 4.2,
                    completed: true
                )
            ) {
                // Implementation of onTap
            }
            
            ModernWorkoutCard(
                workout: Workout(
                    name: "Strength Training",
                    type: .strength,
                    durationMinutes: 45,
                    date: Date().addingTimeInterval(-86400),
                    caloriesBurned: 350,
                    tokensEarned: 12.0,
                    completed: false
                )
            ) {
                // Implementation of onTap
            }
        }
        .padding()
    }
} 