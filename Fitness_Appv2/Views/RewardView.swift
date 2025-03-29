import SwiftUI
import UIKit

struct RewardView: View {
    @EnvironmentObject var dataStore: AppDataStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Token balance card
                    VStack {
                        Text("Token Balance")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("\(String(format: "%.1f", dataStore.currentUser.tokenBalance))")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Text("FTNS")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Earning opportunities
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Earning Opportunities")
                            .font(.headline)
                        
                        ForEach(earningOpportunities, id: \.title) { opportunity in
                            HStack {
                                Image(systemName: opportunity.icon)
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .frame(width: 40, height: 40)
                                
                                VStack(alignment: .leading) {
                                    Text(opportunity.title)
                                        .font(.headline)
                                    
                                    Text(opportunity.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("+\(opportunity.reward)")
                                    .font(.headline)
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Recent earnings
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Earnings")
                            .font(.headline)
                        
                        if dataStore.currentUser.completedWorkouts.isEmpty {
                            Text("No recent workouts")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(dataStore.currentUser.completedWorkouts.sorted(by: { $0.date > $1.date }).prefix(3), id: \.id) { workout in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(workout.type.rawValue.capitalized)
                                            .font(.headline)
                                        
                                        Text(formattedDate(workout.date))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("+\(String(format: "%.1f", workout.tokenReward))")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .navigationTitle("Rewards")
        }
    }
    
    private var earningOpportunities: [(title: String, description: String, reward: String, icon: String)] {
        [
            (
                title: "Complete a workout",
                description: "Earn 1 token per 10 minutes of activity",
                reward: "1-10",
                icon: "figure.run"
            ),
            (
                title: "Maintain a streak",
                description: "Earn bonus tokens for consecutive days",
                reward: "5",
                icon: "flame"
            ),
            (
                title: "Invite friends",
                description: "Earn tokens when friends join",
                reward: "10",
                icon: "person.2"
            )
        ]
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct RewardView_Previews: PreviewProvider {
    static var previews: some View {
        RewardView()
            .environmentObject(AppDataStore())
    }
} 