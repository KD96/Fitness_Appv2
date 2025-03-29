import SwiftUI

struct SocialView: View {
    @EnvironmentObject var dataStore: AppDataStore
    
    // Colores de PureLife
    private let pureLifeGreen = Color(red: 199/255, green: 227/255, blue: 214/255)
    private let pureLifeLightGreen = Color(red: 220/255, green: 237/255, blue: 230/255)
    private let pureLifeBlack = Color.black
    
    var body: some View {
        NavigationView {
            ZStack {
                pureLifeLightGreen.ignoresSafeArea()
                
                VStack(spacing: 0) {
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
                    .padding(.bottom, 15)
                    .padding(.top, 10)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Friends section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Friends")
                                    .font(.headline)
                                    .foregroundColor(pureLifeBlack)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 20) {
                                        ForEach(dataStore.friends) { friend in
                                            VStack {
                                                Image(systemName: friend.profileImage ?? "person.circle.fill")
                                                    .font(.system(size: 40))
                                                    .foregroundColor(pureLifeBlack)
                                                    .frame(width: 60, height: 60)
                                                    .background(pureLifeGreen)
                                                    .clipShape(Circle())
                                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                                    .shadow(color: Color.black.opacity(0.1), radius: 2)
                                                
                                                Text(friend.name)
                                                    .font(.caption)
                                                    .foregroundColor(pureLifeBlack)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .padding(.vertical, 8)
                            }
                            .padding(.vertical)
                            .background(Color.white.cornerRadius(15))
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                            
                            // Activity feed
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Activity Feed")
                                    .font(.headline)
                                    .foregroundColor(pureLifeBlack)
                                    .padding(.horizontal)
                                
                                if dataStore.socialFeed.isEmpty {
                                    VStack {
                                        Text("No activities yet")
                                            .foregroundColor(pureLifeBlack.opacity(0.7))
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding()
                                    }
                                    .padding(.vertical)
                                    .background(Color.white.cornerRadius(10))
                                    .padding(.horizontal)
                                } else {
                                    VStack(spacing: 12) {
                                        ForEach(dataStore.socialFeed.sorted(by: { $0.timestamp > $1.timestamp })) { activity in
                                            SocialActivityRow(activity: activity)
                                                .padding(.horizontal)
                                                .padding(.vertical, 10)
                                                .background(Color.white.cornerRadius(10))
                                                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                                                .padding(.horizontal)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct SocialActivityRow: View {
    let activity: SocialActivity
    
    // Colores de PureLife
    private let pureLifeGreen = Color(red: 199/255, green: 227/255, blue: 214/255)
    private let pureLifeBlack = Color.black
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.title)
                .foregroundColor(pureLifeBlack)
                .frame(width: 40, height: 40)
                .background(pureLifeGreen.opacity(0.3))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.userName)
                    .font(.headline)
                    .foregroundColor(pureLifeBlack)
                
                if let message = activity.message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(pureLifeBlack.opacity(0.8))
                }
                
                if activity.activityType == .completedWorkout, let workoutType = activity.workoutType {
                    HStack {
                        Image(systemName: workoutType.icon)
                            .foregroundColor(pureLifeBlack)
                        Text(workoutType.rawValue.capitalized)
                            .font(.subheadline)
                            .foregroundColor(pureLifeBlack.opacity(0.7))
                    }
                }
                
                if let tokens = activity.tokenEarned {
                    Text("+\(String(format: "%.1f", tokens))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(pureLifeBlack)
                        .padding(.top, 2)
                }
                
                Text(timeAgo(from: activity.timestamp))
                    .font(.caption)
                    .foregroundColor(pureLifeBlack.opacity(0.6))
                    .padding(.top, 2)
            }
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct SocialView_Previews: PreviewProvider {
    static var previews: some View {
        SocialView()
            .environmentObject(AppDataStore())
    }
} 