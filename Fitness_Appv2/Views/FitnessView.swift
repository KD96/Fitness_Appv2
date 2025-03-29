import SwiftUI
import UIKit

struct FitnessView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showingNewWorkout = false
    @State private var selectedWorkout: Workout?
    
    var body: some View {
        NavigationView {
            VStack {
                // User stats summary
                UserStatsView()
                    .padding()
                
                // Recent workouts list
                List {
                    ForEach(dataStore.currentUser.completedWorkouts.sorted(by: { $0.date > $1.date })) { workout in
                        WorkoutRowView(workout: workout)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedWorkout = workout
                            }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Fitness")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewWorkout = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewWorkout) {
                NewWorkoutView()
            }
            .sheet(item: $selectedWorkout) { workout in
                WorkoutDetailView(workout: workout)
            }
        }
    }
}

struct UserStatsView: View {
    @EnvironmentObject var dataStore: AppDataStore
    
    var body: some View {
        HStack(spacing: 20) {
            VStack {
                Text("\(dataStore.currentUser.completedWorkouts.count)")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Workouts")
                    .font(.caption)
            }
            
            Divider()
            
            VStack {
                Text("\(Int(dataStore.currentUser.tokenBalance))")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Tokens")
                    .font(.caption)
            }
            
            Divider()
            
            VStack {
                Text("\(dataStore.currentUser.workoutStreak)")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Streak")
                    .font(.caption)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct WorkoutRowView: View {
    let workout: Workout
    
    var body: some View {
        HStack {
            Image(systemName: workout.type.icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(workout.type.rawValue.capitalized)
                    .font(.headline)
                
                Text("\(Int(workout.duration / 60)) min • \(Int(workout.calories)) cal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(formattedDate(workout.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("+\(String(format: "%.1f", workout.tokenReward)) tokens")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct FitnessView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessView()
            .environmentObject(AppDataStore())
    }
} 