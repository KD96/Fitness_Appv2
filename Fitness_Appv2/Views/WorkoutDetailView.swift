import SwiftUI

struct WorkoutDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataStore: AppDataStore
    
    let workout: Workout
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: workout.type.icon)
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                            .frame(width: 60, height: 60)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading) {
                            Text(workout.type.rawValue.capitalized)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(formattedDate(workout.date))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 10)
                }
                
                Section(header: Text("Stats")) {
                    DetailRow(title: "Duration", value: "\(Int(workout.duration / 60)) minutes")
                    DetailRow(title: "Calories", value: "\(Int(workout.calories)) cal")
                    DetailRow(title: "Tokens earned", value: "\(String(format: "%.1f", workout.tokenReward))")
                }
                
                if let notes = workout.notes {
                    Section(header: Text("Notes")) {
                        Text(notes)
                            .font(.body)
                            .padding(.vertical, 8)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Workout Details")
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleWorkout = Workout(
            type: .running,
            duration: 1800, // 30 minutes
            date: Date(),
            calories: 250
        )
        
        return WorkoutDetailView(workout: sampleWorkout)
            .environmentObject(AppDataStore())
    }
} 