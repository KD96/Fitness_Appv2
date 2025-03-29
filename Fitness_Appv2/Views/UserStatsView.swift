import SwiftUI
import UIKit

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
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
} 