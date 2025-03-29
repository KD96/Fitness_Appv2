import SwiftUI

struct NewWorkoutView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataStore: AppDataStore
    
    @State private var workoutType: WorkoutType = .running
    @State private var duration: Double = 30 // minutes
    @State private var calories: Double = 300
    @State private var notes: String = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Workout Type")) {
                    Picker("Type", selection: $workoutType) {
                        ForEach(WorkoutType.allCases, id: \.self) { type in
                            Label(type.rawValue.capitalized, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Details")) {
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text("\(Int(duration)) minutes")
                    }
                    Slider(value: $duration, in: 5...180, step: 5)
                    
                    HStack {
                        Text("Calories")
                        Spacer()
                        Text("\(Int(calories))")
                    }
                    Slider(value: $calories, in: 50...1000, step: 25)
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
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
    
    private func saveWorkout() {
        let newWorkout = Workout(
            type: workoutType,
            duration: duration * 60, // Convert to seconds
            date: date,
            calories: calories,
            notes: notes.isEmpty ? nil : notes
        )
        
        dataStore.completeWorkout(newWorkout)
    }
}

struct NewWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        NewWorkoutView()
            .environmentObject(AppDataStore())
    }
} 