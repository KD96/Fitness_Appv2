import SwiftUI
import UIKit

struct FitnessView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showingNewWorkout = false
    @State private var selectedWorkout: Workout?
    
    // Colores de PureLife
    private let pureLifeGreen = Color(red: 199/255, green: 227/255, blue: 214/255)
    private let pureLifeLightGreen = Color(red: 220/255, green: 237/255, blue: 230/255)
    private let pureLifeBlack = Color.black
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Logo y título de la app
                    HStack {
                        Text("pure")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(pureLifeBlack) +
                        Text("life")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(pureLifeBlack) +
                        Text(".")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(pureLifeBlack)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                    
                    // User stats summary
                    UserStatsView()
                        .padding(.horizontal)
                    
                    // Weekly activity summary
                    WeeklyActivityView()
                        .padding(.horizontal)
                    
                    // Recent workouts header
                    HStack {
                        Text("Recent Workouts")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(pureLifeBlack)
                        
                        Spacer()
                        
                        Button(action: {
                            showingNewWorkout = true
                        }) {
                            Label("Add Workout", systemImage: "plus.circle.fill")
                                .font(.subheadline)
                                .foregroundColor(pureLifeBlack)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Recent workouts list
                    VStack(spacing: 12) {
                        if dataStore.currentUser.completedWorkouts.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "figure.run")
                                    .font(.system(size: 60))
                                    .foregroundColor(.secondary)
                                    .padding()
                                
                                Text("No workouts yet")
                                    .font(.headline)
                                    .foregroundColor(pureLifeBlack)
                                
                                Text("Start your fitness journey by adding your first workout")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button(action: {
                                    showingNewWorkout = true
                                }) {
                                    Text("Add Your First Workout")
                                        .font(.headline)
                                        .foregroundColor(pureLifeBlack)
                                        .padding()
                                        .background(pureLifeGreen)
                                        .cornerRadius(10)
                                }
                                .padding(.top, 10)
                            }
                            .padding(.vertical, 30)
                        } else {
                            ForEach(dataStore.currentUser.completedWorkouts.sorted(by: { $0.date > $1.date })) { workout in
                                WorkoutRowView(workout: workout)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedWorkout = workout
                                    }
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(pureLifeLightGreen.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewWorkout = true
                    }) {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundColor(pureLifeBlack)
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

struct WeeklyActivityView: View {
    let days = ["M", "T", "W", "T", "F", "S", "S"]
    // Valores simulados de actividad para cada día (0-1)
    let activityLevels: [Double] = [0.3, 0.7, 0.5, 0.8, 0.2, 0.9, 0.6]
    
    // Colores de PureLife
    private let pureLifeGreen = Color(red: 199/255, green: 227/255, blue: 214/255)
    private let pureLifeBlack = Color.black
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Weekly Activity")
                .font(.headline)
                .foregroundColor(pureLifeBlack)
                .padding(.bottom, 5)
            
            HStack(spacing: 8) {
                ForEach(0..<7) { index in
                    VStack(spacing: 5) {
                        ZStack(alignment: .bottom) {
                            Rectangle()
                                .foregroundColor(Color(UIColor.systemGray6))
                                .frame(width: 30, height: 100)
                                .cornerRadius(6)
                            
                            Rectangle()
                                .foregroundColor(activityColor(activityLevels[index]))
                                .frame(width: 30, height: activityLevels[index] * 100)
                                .cornerRadius(6)
                        }
                        
                        Text(days[index])
                            .font(.caption2)
                            .foregroundColor(pureLifeBlack.opacity(0.6))
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    func activityColor(_ level: Double) -> Color {
        if level < 0.3 {
            return pureLifeGreen.opacity(0.5)
        } else if level < 0.7 {
            return pureLifeGreen.opacity(0.7)
        } else {
            return pureLifeGreen
        }
    }
}

struct WorkoutRowView: View {
    let workout: Workout
    
    // Colores de PureLife
    private let pureLifeGreen = Color(red: 199/255, green: 227/255, blue: 214/255)
    private let pureLifeBlack = Color.black
    
    var body: some View {
        HStack(spacing: 15) {
            // Icono del tipo de ejercicio
            Image(systemName: workout.type.icon)
                .font(.title2)
                .foregroundColor(pureLifeBlack)
                .frame(width: 50, height: 50)
                .background(pureLifeGreen)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.type.rawValue.capitalized)
                    .font(.headline)
                    .foregroundColor(pureLifeBlack)
                
                HStack(spacing: 10) {
                    Label("\(Int(workout.duration / 60)) min", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(pureLifeBlack.opacity(0.6))
                    
                    Label("\(Int(workout.calories)) cal", systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundColor(pureLifeBlack.opacity(0.6))
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formattedDate(workout.date))
                    .font(.caption)
                    .foregroundColor(pureLifeBlack.opacity(0.6))
                
                Text("+\(String(format: "%.1f", workout.tokenReward))")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(pureLifeBlack)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        )
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