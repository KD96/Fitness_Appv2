import SwiftUI
import UIKit

struct UserStatsView: View {
    @EnvironmentObject var dataStore: AppDataStore
    
    // Colores de PureLife
    private let pureLifeGreen = Color(red: 199/255, green: 227/255, blue: 214/255)
    private let pureLifeBlack = Color.black
    
    var body: some View {
        VStack(spacing: 10) {
            // Nombre del usuario y avatar
            HStack {
                Text("Hello, \(dataStore.currentUser.name)")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(pureLifeBlack)
                
                Spacer()
                
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(pureLifeBlack)
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(pureLifeGreen, lineWidth: 2)
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
                    color: pureLifeBlack,
                    backgroundColor: pureLifeGreen
                )
                
                StatCard(
                    title: "Tokens",
                    value: "\(Int(dataStore.currentUser.tokenBalance))",
                    icon: "dollarsign.circle",
                    color: pureLifeBlack,
                    backgroundColor: pureLifeGreen
                )
                
                StatCard(
                    title: "Streak",
                    value: "\(dataStore.currentUser.workoutStreak)",
                    icon: "flame.fill",
                    color: pureLifeBlack,
                    backgroundColor: pureLifeGreen
                )
            }
            .padding(.horizontal, 10)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let backgroundColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(color.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
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