import SwiftUI

struct ModernWorkoutCard: View {
    let workout: Workout
    var onTap: (() -> Void)? = nil
    var showDetails: Bool = true
    var imageHeight: CGFloat = 150
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            UIComponents.GlassMorphicCard(cornerRadius: 24) {
                VStack(spacing: 0) {
                    // Header with athlete image
                    ZStack(alignment: .bottomLeading) {
                        // Athlete image for the workout type
                        if let image = UIImage(named: AthleteCarouselView.getWorkoutTypeImages(workout.type).first ?? "") {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: imageHeight)
                                .clipped()
                        } else {
                            // Fallback gradient
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            PureLifeColors.logoGreen.opacity(0.8),
                                            PureLifeColors.logoGreen.opacity(0.4)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: imageHeight)
                        }
                        
                        // Gradient overlay for better text visibility
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.0),
                                Color.black.opacity(0.6)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: imageHeight)
                        
                        // Workout type and duration
                        VStack(alignment: .leading, spacing: 6) {
                            // Badges for duration and calories
                            HStack(spacing: 8) {
                                metricBadge(
                                    icon: "clock.fill",
                                    text: "\(workout.durationMinutes) min"
                                )
                                
                                metricBadge(
                                    icon: "flame.fill",
                                    text: "\(Int(workout.caloriesBurned)) cal"
                                )
                                
                                if let distance = workout.distance, distance > 0 {
                                    metricBadge(
                                        icon: "map.fill",
                                        text: String(format: "%.1f km", distance)
                                    )
                                }
                            }
                            
                            Text(workout.type.rawValue.capitalized)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 1)
                                .padding(.top, 4)
                        }
                        .padding(20)
                    }
                    
                    // Workout details
                    if showDetails {
                        VStack(alignment: .leading, spacing: 16) {
                            // Date with icon
                            HStack(spacing: 10) {
                                Image(systemName: "calendar")
                                    .foregroundColor(PureLifeColors.logoGreen)
                                
                                Text(formattedDate(workout.date))
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                                
                                Spacer()
                                
                                // Tokens earned
                                HStack(spacing: 4) {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(PureLifeColors.logoGreen)
                                        .font(.system(size: 15))
                                    
                                    Text("+\(String(format: "%.1f", workout.tokensEarned))")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(PureLifeColors.logoGreen)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(PureLifeColors.logoGreen.opacity(0.1))
                                .cornerRadius(10)
                            }
                            
                            // Notes if available
                            if let notes = workout.notes, !notes.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Notes")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                                    
                                    Text(notes)
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                                        .lineLimit(2)
                                }
                            }
                            
                            // Additional metrics if available
                            let metrics = getRelevantMetrics()
                            if !metrics.isEmpty {
                                HStack(spacing: 12) {
                                    ForEach(metrics, id: \.name) { metric in
                                        metricItem(metric: metric)
                                    }
                                }
                            }
                        }
                        .padding(20)
                    }
                }
            }
        }
    }
    
    // Helper method to format date
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Helper to create metric badges
    private func metricBadge(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
            
            Text(text)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
    
    // Helper to create detailed metric items
    private func metricItem(metric: WorkoutCardMetric) -> some View {
        VStack(spacing: 4) {
            Text(metric.name)
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
            
            Text(metric.formattedValue)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(PureLifeColors.adaptiveSurfaceSecondary(scheme: colorScheme))
        .cornerRadius(12)
    }
    
    // Helper to get relevant metrics for this workout
    private func getRelevantMetrics() -> [WorkoutCardMetric] {
        var metrics: [WorkoutCardMetric] = []
        
        // Add specific metrics based on the workout type
        switch workout.type {
        case .running, .walking, .cycling:
            if let distance = workout.distance, distance > 0 {
                metrics.append(
                    WorkoutCardMetric(
                        name: "Distance",
                        value: distance,
                        format: "%.2f km"
                    )
                )
            }
            if let steps = workout.steps, steps > 0 {
                metrics.append(
                    WorkoutCardMetric(
                        name: "Steps",
                        value: Double(steps),
                        format: "%.0f"
                    )
                )
            }
        case .swimming:
            if let laps = workout.laps, laps > 0 {
                metrics.append(
                    WorkoutCardMetric(
                        name: "Laps",
                        value: Double(laps),
                        format: "%.0f"
                    )
                )
            }
        case .strength:
            if let sets = workout.sets, sets > 0 {
                metrics.append(
                    WorkoutCardMetric(
                        name: "Sets",
                        value: Double(sets),
                        format: "%.0f"
                    )
                )
            }
            if let reps = workout.reps, reps > 0 {
                metrics.append(
                    WorkoutCardMetric(
                        name: "Reps",
                        value: Double(reps),
                        format: "%.0f"
                    )
                )
            }
            if let weight = workout.weight, weight > 0 {
                metrics.append(
                    WorkoutCardMetric(
                        name: "Weight",
                        value: weight,
                        format: "%.1f kg"
                    )
                )
            }
        case .yoga, .hiit, .other:
            if let intensity = workout.intensity {
                metrics.append(
                    WorkoutCardMetric(
                        name: "Intensity",
                        value: 0, // Not used for formatted value
                        format: "",
                        formattedValue: intensity.rawValue.capitalized
                    )
                )
            }
        }
        
        // Add heart rate if available
        if let heartRateData = workout.heartRate {
            metrics.append(
                WorkoutCardMetric(
                    name: "Heart Rate",
                    value: Double(heartRateData.average),
                    format: "%.0f bpm"
                )
            )
        }
        
        return metrics
    }
}

// Helper struct for workout metrics (renombrada para evitar conflictos)
struct WorkoutCardMetric {
    let name: String
    let value: Double
    let format: String
    let formattedValue: String
    
    init(name: String, value: Double, format: String, formattedValue: String = "") {
        self.name = name
        self.value = value
        self.format = format
        if formattedValue.isEmpty {
            self.formattedValue = String(format: format, value)
        } else {
            self.formattedValue = formattedValue
        }
    }
}

// Preview provider
struct ModernWorkoutCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ModernWorkoutCard(
                workout: Workout(
                    id: UUID(),
                    name: "Morning Run",
                    type: .running,
                    durationMinutes: 35,
                    date: Date(),
                    caloriesBurned: 320,
                    tokensEarned: 12.5,
                    notes: "Felt great today, maintained good pace.",
                    distance: 4.2,
                    completed: true
                )
            )
            
            ModernWorkoutCard(
                workout: Workout(
                    id: UUID(),
                    name: "Strength Training",
                    type: .strength,
                    durationMinutes: 60,
                    date: Date().addingTimeInterval(-86400),
                    caloriesBurned: 450,
                    tokensEarned: 18.0,
                    notes: "Focused on upper body.",
                    completed: true
                )
            )
        }
        .padding()
        .background(PureLifeColors.adaptiveBackground(scheme: .light))
        .previewLayout(.sizeThatFits)
    }
} 