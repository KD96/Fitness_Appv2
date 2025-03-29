import SwiftUI
import UIKit

struct UserStatsView: View {
    @EnvironmentObject var dataStore: AppDataStore
    
    var body: some View {
        VStack(spacing: 10) {
            // Nombre del usuario y avatar
            HStack {
                Text("¡Hola, \(dataStore.currentUser.name)!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color(red: 0.0, green: 0.7, blue: 0.9))
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(radius: 2)
            }
            .padding(.horizontal)
            
            // Estadísticas principales
            HStack(spacing: 15) {
                StatCard(
                    title: "Workouts",
                    value: "\(dataStore.currentUser.completedWorkouts.count)",
                    icon: "figure.run",
                    color: Color.blue
                )
                
                StatCard(
                    title: "Tokens",
                    value: "\(Int(dataStore.currentUser.tokenBalance))",
                    icon: "dollarsign.circle",
                    color: Color.green
                )
                
                StatCard(
                    title: "Streak",
                    value: "\(dataStore.currentUser.workoutStreak)",
                    icon: "flame.fill",
                    color: Color.orange
                )
            }
            .padding(.horizontal, 10)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 22, weight: .bold))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: color.opacity(0.1), radius: 3, x: 0, y: 1)
        )
    }
}

struct UserStatsView_Previews: PreviewProvider {
    static var previews: some View {
        UserStatsView()
            .environmentObject(AppDataStore())
            .padding()
            .previewLayout(.sizeThatFits)
    }
} 