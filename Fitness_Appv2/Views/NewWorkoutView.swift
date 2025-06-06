import SwiftUI

struct NewWorkoutView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataStore: AppDataStore
    
    @State private var workoutName: String = "My Workout"
    @State private var workoutType: WorkoutType = .running
    @State private var duration: Double = 30 // minutes
    @State private var calories: Double = 300
    @State private var notes: String = ""
    @State private var date = Date()
    
    // New states for additional metrics
    @State private var distance: Double = 2.0 // km
    @State private var steps: Double = 4000
    @State private var heartRateAvg: Double = 140
    @State private var heartRateMax: Double = 170
    @State private var heartRateMin: Double = 110
    @State private var laps: Double = 10
    @State private var reps: Double = 10
    @State private var sets: Double = 3
    @State private var weight: Double = 15 // kg
    @State private var intensity: WorkoutIntensity = .medium
    
    var body: some View {
        NavigationView {
            Form {
                // Header image section
                Section {
                    VStack(alignment: .center, spacing: 0) {
                        // Icono del tipo de entrenamiento en lugar de imagen
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [
                                        AthleteImages.getColorForWorkoutType(workoutType).opacity(0.3),
                                        AthleteImages.getColorForWorkoutType(workoutType).opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(height: 200)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            
                            Image(systemName: AthleteImages.getIconForWorkoutType(workoutType))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 100)
                                .foregroundColor(AthleteImages.getColorForWorkoutType(workoutType))
                                .opacity(0.8)
                        }
                        .shadow(radius: 3)
                        .padding(.vertical, 8)
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                Section(header: Text("Workout Information")) {
                    TextField("Name", text: $workoutName)
                        .padding(.vertical, 8)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Type")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(WorkoutType.allCases, id: \.self) { type in
                                    workoutTypeButton(type)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .padding(.vertical, 8)
                }
                
                // Common metrics section
                Section(header: Text("Basic Metrics")) {
                    ForEach(commonMetrics, id: \.self) { metric in
                        metricView(for: metric)
                    }
                }
                
                // Display activity-specific metrics
                if !specificMetrics.isEmpty {
                    Section(header: Text("\(workoutType.rawValue.capitalized) Metrics")) {
                        ForEach(specificMetrics, id: \.self) { metric in
                            metricView(for: metric)
                        }
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button("Log Workout") {
                        saveWorkout()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("New Workout")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    // Workout type selection button with athletic icons
    @ViewBuilder
    private func workoutTypeButton(_ type: WorkoutType) -> some View {
        Button(action: {
            withAnimation {
                workoutType = type
                updateMetricsDefaults()
            }
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(workoutType == type ? 
                              Color.blue.opacity(0.2) : 
                              Color.gray.opacity(0.1))
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: AthleteImages.getIconForWorkoutType(type))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(workoutType == type ? .blue : .gray)
                }
                .overlay(
                    Circle()
                        .stroke(workoutType == type ? Color.blue : Color.clear, lineWidth: 2)
                )
                
                Text(type.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(workoutType == type ? .blue : .primary)
            }
        }
    }
    
    // Common metrics that appear for all workout types
    var commonMetrics: [WorkoutMetric] {
        return [.duration, .calories]
    }
    
    // Activity-specific metrics
    var specificMetrics: [WorkoutMetric] {
        return workoutType.relevantMetrics.filter { !commonMetrics.contains($0) }
    }
    
    // Function to create the appropriate view for each metric
    @ViewBuilder
    func metricView(for metric: WorkoutMetric) -> some View {
        switch metric {
        case .duration:
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Label(metric.rawValue, systemImage: metric.icon)
                    Spacer()
                    Text("\(Int(duration)) \(metric.unit ?? "")")
                        .foregroundColor(.secondary)
                }
                Slider(value: $duration, in: 5...180, step: 5)
            }
            .padding(.vertical, 4)
            
        case .distance:
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Label(metric.rawValue, systemImage: metric.icon)
                    Spacer()
                    Text(String(format: "%.1f \(metric.unit ?? "")", distance))
                        .foregroundColor(.secondary)
                }
                Slider(value: $distance, in: 0.1...42, step: 0.1)
            }
            .padding(.vertical, 4)
            
        case .calories:
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Label(metric.rawValue, systemImage: metric.icon)
                    Spacer()
                    Text("\(Int(calories)) \(metric.unit ?? "")")
                        .foregroundColor(.secondary)
                }
                Slider(value: $calories, in: 50...1000, step: 25)
            }
            .padding(.vertical, 4)
            
        case .steps:
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Label(metric.rawValue, systemImage: metric.icon)
                    Spacer()
                    Text("\(Int(steps)) \(metric.unit ?? "")")
                        .foregroundColor(.secondary)
                }
                Slider(value: $steps, in: 500...30000, step: 500)
            }
            .padding(.vertical, 4)
            
        case .heartRate:
            VStack(alignment: .leading) {
                Label(metric.rawValue, systemImage: metric.icon)
                    .padding(.bottom, 4)
                
                HStack {
                    Text("Avg")
                        .foregroundColor(.secondary)
                    Slider(value: $heartRateAvg, in: 60...200, step: 1)
                    Text("\(Int(heartRateAvg)) bpm")
                        .foregroundColor(.secondary)
                        .frame(width: 65, alignment: .trailing)
                }
                
                HStack {
                    Text("Max")
                        .foregroundColor(.secondary)
                    Slider(value: $heartRateMax, in: heartRateAvg...220, step: 1)
                    Text("\(Int(heartRateMax)) bpm")
                        .foregroundColor(.secondary)
                        .frame(width: 65, alignment: .trailing)
                }
                
                HStack {
                    Text("Min")
                        .foregroundColor(.secondary)
                    Slider(value: $heartRateMin, in: 50...heartRateAvg, step: 1)
                    Text("\(Int(heartRateMin)) bpm")
                        .foregroundColor(.secondary)
                        .frame(width: 65, alignment: .trailing)
                }
            }
            .padding(.vertical, 4)
            
        case .laps:
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Label(metric.rawValue, systemImage: metric.icon)
                    Spacer()
                    Text("\(Int(laps)) \(metric.unit ?? "")")
                        .foregroundColor(.secondary)
                }
                Slider(value: $laps, in: 1...100, step: 1)
            }
            .padding(.vertical, 4)
            
        case .reps:
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Label(metric.rawValue, systemImage: metric.icon)
                    Spacer()
                    Text("\(Int(reps)) \(metric.unit ?? "")")
                        .foregroundColor(.secondary)
                }
                Slider(value: $reps, in: 1...50, step: 1)
            }
            .padding(.vertical, 4)
            
        case .sets:
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Label(metric.rawValue, systemImage: metric.icon)
                    Spacer()
                    Text("\(Int(sets)) \(metric.unit ?? "")")
                        .foregroundColor(.secondary)
                }
                Slider(value: $sets, in: 1...10, step: 1)
            }
            .padding(.vertical, 4)
            
        case .weight:
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Label(metric.rawValue, systemImage: metric.icon)
                    Spacer()
                    Text("\(Int(weight)) \(metric.unit ?? "")")
                        .foregroundColor(.secondary)
                }
                Slider(value: $weight, in: 1...200, step: 1)
            }
            .padding(.vertical, 4)
            
        case .intensity:
            VStack(alignment: .leading, spacing: 8) {
                Label(metric.rawValue, systemImage: metric.icon)
                
                Picker("Intensity", selection: $intensity) {
                    ForEach(WorkoutIntensity.allCases, id: \.self) { level in
                        Label(level.rawValue, systemImage: level.icon)
                            .tag(level)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(.vertical, 4)
        }
    }
    
    // Update default values based on workout type
    private func updateMetricsDefaults() {
        // Reset to defaults based on workout type
        switch workoutType {
        case .running:
            distance = 5.0
            steps = 6000
            calories = 300
        case .walking:
            distance = 3.0
            steps = 4000
            calories = 200
        case .cycling:
            distance = 15.0
            calories = 350
        case .strength:
            sets = 3
            reps = 12
            weight = 15
            calories = 250
        }
    }
    
    private func saveWorkout() {
        // Create heart rate data if needed
        let heartRate: HeartRateData? = workoutType.relevantMetrics.contains(.heartRate) ?
            HeartRateData(average: Int(heartRateAvg), max: Int(heartRateMax), min: Int(heartRateMin)) : nil
        
        // Convert distance from km to meters
        let distanceInMeters: Double? = workoutType.relevantMetrics.contains(.distance) ?
            distance * 1000 : nil
        
        // Create new workout with appropriate fields based on type
        var newWorkout = Workout(
            id: UUID(),
            name: workoutName,
            type: workoutType,
            durationMinutes: Int(duration),
            date: date,
            caloriesBurned: calories,
            tokensEarned: calories / 20, // Convertir calorías a tokens
            notes: notes.isEmpty ? nil : notes,
            distance: distanceInMeters,
            completed: true
        )
        
        // Add specific metrics based on workout type
        if workoutType.relevantMetrics.contains(.steps) {
            newWorkout.steps = Int(steps)
        }
        
        if workoutType.relevantMetrics.contains(.heartRate) {
            newWorkout.heartRate = heartRate
        }
        
        if workoutType.relevantMetrics.contains(.laps) {
            newWorkout.laps = Int(laps)
        }
        
        if workoutType.relevantMetrics.contains(.reps) {
            newWorkout.reps = Int(reps)
        }
        
        if workoutType.relevantMetrics.contains(.sets) {
            newWorkout.sets = Int(sets)
        }
        
        if workoutType.relevantMetrics.contains(.weight) {
            newWorkout.weight = weight
        }
        
        if workoutType.relevantMetrics.contains(.intensity) {
            newWorkout.intensity = intensity
        }
        
        dataStore.saveWorkout(newWorkout)
    }
}

struct NewWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        NewWorkoutView()
            .environmentObject(AppDataStore())
    }
} 