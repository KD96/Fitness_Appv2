import SwiftUI
import UIKit

struct RewardView: View {
    @EnvironmentObject var dataStore: AppDataStore
    
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
                    
                    // Token balance card
                    VStack {
                        Text("Token Balance")
                            .font(.headline)
                            .foregroundColor(pureLifeBlack.opacity(0.7))
                        
                        Text("\(String(format: "%.1f", dataStore.currentUser.tokenBalance))")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(pureLifeBlack)
                        
                        Text("PURE")
                            .font(.caption)
                            .foregroundColor(pureLifeBlack.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(pureLifeGreen)
                    .cornerRadius(16)
                    
                    // Earning opportunities
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Earning Opportunities")
                            .font(.headline)
                            .foregroundColor(pureLifeBlack)
                        
                        ForEach(earningOpportunities, id: \.title) { opportunity in
                            HStack {
                                Image(systemName: opportunity.icon)
                                    .font(.title2)
                                    .foregroundColor(pureLifeBlack)
                                    .frame(width: 40, height: 40)
                                
                                VStack(alignment: .leading) {
                                    Text(opportunity.title)
                                        .font(.headline)
                                        .foregroundColor(pureLifeBlack)
                                    
                                    Text(opportunity.description)
                                        .font(.subheadline)
                                        .foregroundColor(pureLifeBlack.opacity(0.7))
                                }
                                
                                Spacer()
                                
                                Text("+\(opportunity.reward)")
                                    .font(.headline)
                                    .foregroundColor(pureLifeBlack)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Recent earnings
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Earnings")
                            .font(.headline)
                            .foregroundColor(pureLifeBlack)
                        
                        if dataStore.currentUser.completedWorkouts.isEmpty {
                            Text("No recent workouts")
                                .foregroundColor(pureLifeBlack.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(dataStore.currentUser.completedWorkouts.sorted(by: { $0.date > $1.date }).prefix(3), id: \.id) { workout in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(workout.type.rawValue.capitalized)
                                            .font(.headline)
                                            .foregroundColor(pureLifeBlack)
                                        
                                        Text(formattedDate(workout.date))
                                            .font(.caption)
                                            .foregroundColor(pureLifeBlack.opacity(0.7))
                                    }
                                    
                                    Spacer()
                                    
                                    Text("+\(String(format: "%.1f", workout.tokenReward))")
                                        .font(.headline)
                                        .foregroundColor(pureLifeBlack)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .background(pureLifeLightGreen.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
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