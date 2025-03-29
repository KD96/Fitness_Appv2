import SwiftUI

struct SocialView: View {
    @EnvironmentObject var dataStore: AppDataStore
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Friends")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(dataStore.friends) { friend in
                                VStack {
                                    Image(systemName: friend.profileImage ?? "person.circle.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.blue)
                                    Text(friend.name)
                                        .font(.caption)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    .frame(height: 80)
                }
                
                Section(header: Text("Activity Feed")) {
                    if dataStore.socialFeed.isEmpty {
                        Text("No activities yet")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ForEach(dataStore.socialFeed.sorted(by: { $0.timestamp > $1.timestamp })) { activity in
                            SocialActivityRow(activity: activity)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Social")
        }
    }
}

struct SocialActivityRow: View {
    let activity: SocialActivity
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.title)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.userName)
                    .font(.headline)
                
                if let message = activity.message {
                    Text(message)
                        .font(.subheadline)
                }
                
                if activity.activityType == .completedWorkout, let workoutType = activity.workoutType {
                    HStack {
                        Image(systemName: workoutType.icon)
                            .foregroundColor(.blue)
                        Text(workoutType.rawValue.capitalized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let tokens = activity.tokenEarned {
                    Text("+\(String(format: "%.1f", tokens)) tokens")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.top, 2)
                }
                
                Text(timeAgo(from: activity.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 8)
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