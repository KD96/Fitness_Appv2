import SwiftUI

struct AthleteCarouselView: View {
    var workoutType: WorkoutType?
    var images: [String]
    var height: CGFloat = 180
    var showGradient: Bool = true
    
    @Environment(\.colorScheme) var colorScheme
    
    init(workoutType: WorkoutType? = nil, images: [String] = [], height: CGFloat = 180, showGradient: Bool = true) {
        self.workoutType = workoutType
        
        // If specific images are provided, use them
        if !images.isEmpty {
            self.images = images
        }
        // Otherwise try to get images related to the workout type
        else if let type = workoutType {
            self.images = Self.getWorkoutTypeImages(type)
        }
        // Default fallback
        else {
            self.images = ["athlete1", "athlete2"]
        }
        
        self.height = height
        self.showGradient = showGradient
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(images, id: \.self) { imageName in
                    athleteCard(imageName: imageName)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .frame(height: height)
    }
    
    private func athleteCard(imageName: String) -> some View {
        ZStack(alignment: .bottom) {
            if let image = UIImage(named: imageName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: height * 0.8, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        showGradient ?
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .clear,
                                        Color.black.opacity(0.4)
                                    ]),
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                            )
                        : nil
                    )
            } else {
                // Placeholder with theme-related icon if image not available
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(PureLifeColors.adaptiveSurfaceSecondary(scheme: colorScheme))
                    
                    if let type = workoutType {
                        Image(systemName: type.icon)
                            .font(.system(size: 40))
                            .foregroundColor(PureLifeColors.logoGreen)
                    } else {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 40))
                            .foregroundColor(PureLifeColors.logoGreen)
                    }
                }
                .frame(width: height * 0.8, height: height)
            }
            
            // Optional workout type label at the bottom
            if let type = workoutType, showGradient {
                Text(type.rawValue.capitalized)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .padding(.bottom, 15)
            }
        }
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    // Helper to get relevant images for a workout type
    static func getWorkoutTypeImages(_ type: WorkoutType) -> [String] {
        switch type {
        case .running:
            return ["workout_types/running"]
        case .walking:
            return ["workout_types/running"] // Reuse similar
        case .cycling:
            return ["workout_types/cycling"]
        case .swimming:
            return ["workout_types/swimming"]
        case .strength:
            return ["workout_types/weight_lifting"]
        case .yoga:
            return ["workout_types/yoga"]
        case .hiit:
            return ["workout_types/hiit"]
        case .other:
            return ["athlete1", "athlete2"]
        }
    }
} 