import SwiftUI

/// Collection of modern UI components for enhancing the app's visual design
struct UIComponents {
    
    // MARK: - Background Components
    
    /// Base view container for tab content to ensure consistent behavior
    struct TabContentView<Content: View>: View {
        var backgroundImage: String? = nil
        var backgroundOpacity: Double = 0.1
        var backgroundColor: Color = Color(.systemBackground)
        var backgroundBlur: CGFloat = 0
        var content: Content
        @Environment(\.colorScheme) var colorScheme
        
        init(backgroundImage: String? = nil, 
             backgroundOpacity: Double = 0.1,
             backgroundColor: Color = Color(.systemBackground),
             backgroundBlur: CGFloat = 0,
             @ViewBuilder content: () -> Content) {
            self.backgroundImage = backgroundImage
            self.backgroundOpacity = backgroundOpacity
            self.backgroundColor = backgroundColor
            self.backgroundBlur = backgroundBlur
            self.content = content()
        }
        
        var body: some View {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    // Base background color
                    backgroundColor
                        .edgesIgnoringSafeArea(.all)
                    
                    // Background image with proper sizing
                    if let imageName = backgroundImage, let image = UIImage(named: imageName) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .opacity(backgroundOpacity)
                            .blur(radius: backgroundBlur)
                            .edgesIgnoringSafeArea(.all)
                    }
                    
                    // Main content
                    content
                        .frame(width: geometry.size.width)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
    
    /// A gradient background with an athlete image overlay
    struct AthleteBackground: View {
        var imageName: String = "athlete1"
        var opacity: Double = 0.15
        var gradientColors: [Color] = [
            PureLifeColors.logoGreen.opacity(0.7),
            PureLifeColors.background
        ]
        
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            ZStack {
                // Base gradient
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                // Athlete image overlay with mask
                if let uiImage = UIImage(named: imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .opacity(opacity)
                        .blendMode(colorScheme == .dark ? .overlay : .multiply)
                        .edgesIgnoringSafeArea(.all)
                }
            }
        }
    }
    
    // MARK: - Card Components
    
    /// A modern card with optional athlete image background
    struct ModernCard<Content: View>: View {
        var cornerRadius: CGFloat = 16
        let content: Content
        @Environment(\.colorScheme) var colorScheme
        
        init(cornerRadius: CGFloat = 16, @ViewBuilder content: () -> Content) {
            self.cornerRadius = cornerRadius
            self.content = content()
        }
        
        var body: some View {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(PureLifeColors.adaptiveSurface(scheme: colorScheme))
                )
                .shadow(
                    color: PureLifeColors.adaptiveCardShadow(scheme: colorScheme),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        }
    }
    
    /// Standard card with title and content
    struct Card<Content: View>: View {
        let title: String
        let content: Content
        var icon: String? = nil
        var cornerRadius: CGFloat = 20
        @Environment(\.colorScheme) var colorScheme
        
        init(title: String, icon: String? = nil, cornerRadius: CGFloat = 20, @ViewBuilder content: () -> Content) {
            self.title = title
            self.icon = icon
            self.cornerRadius = cornerRadius
            self.content = content()
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                // Header
                if !title.isEmpty {
                    HStack(spacing: Spacing.xs) {
                        if let iconName = icon {
                            Image(systemName: iconName)
                                .font(.system(size: PureLifeTypography.body1))
                                .foregroundColor(PureLifeColors.logoGreen)
                        }
                        
                        Text(title)
                            .font(.system(size: PureLifeTypography.heading4, weight: .bold, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                    }
                }
                
                // Content
                content
            }
            .padding(Spacing.cardPadding)
            .background(PureLifeColors.adaptiveSurface(scheme: colorScheme))
            .cornerRadius(cornerRadius)
            .shadow(color: PureLifeColors.adaptiveCardShadow(scheme: colorScheme), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Reward/Feature Cards
    
    /// A modern card with glassmorphism effect
    struct GlassMorphicCard<Content: View>: View {
        var cornerRadius: CGFloat = 20
        let content: Content
        @Environment(\.colorScheme) var colorScheme
        
        init(cornerRadius: CGFloat = 20, @ViewBuilder content: () -> Content) {
            self.cornerRadius = cornerRadius
            self.content = content()
        }
        
        var body: some View {
            content
                .background(
                    ZStack {
                        // Blurred background
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(PureLifeColors.adaptiveGlass(scheme: colorScheme))
                            .background(Material.ultraThinMaterial)
                            .cornerRadius(cornerRadius)
                            
                        // Subtle gradient overlay for depth
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(
                                        colors: [
                                            Color.white.opacity(colorScheme == .dark ? 0.05 : 0.2),
                                            Color.white.opacity(colorScheme == .dark ? 0.02 : 0.05)
                                        ]
                                    ),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            
                        // Very subtle border
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .strokeBorder(
                                LinearGradient(
                                    gradient: Gradient(
                                        colors: [
                                            Color.white.opacity(colorScheme == .dark ? 0.15 : 0.5),
                                            Color.white.opacity(colorScheme == .dark ? 0.05 : 0.2)
                                        ]
                                    ),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    }
                )
                .shadow(
                    color: PureLifeColors.adaptiveCardShadow(scheme: colorScheme),
                    radius: 12,
                    x: 0,
                    y: 5
                )
        }
    }
    
    // MARK: - Profile Components
    
    /// Modern profile image with circular crop and decorative elements
    struct ProfileImage: View {
        var image: String
        var size: CGFloat = 120
        var showBorder: Bool = true
        
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            ZStack {
                // Main image
                if let uiImage = UIImage(named: image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                } else {
                    // Fallback to system image if custom image not available
                    Circle()
                        .fill(PureLifeColors.logoGreen.opacity(0.2))
                        .frame(width: size, height: size)
                    
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size * 0.6)
                        .foregroundColor(PureLifeColors.logoGreen)
                }
                
                // Border if enabled
                if showBorder {
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    PureLifeColors.logoGreen,
                                    PureLifeColors.logoGreen.opacity(0.5)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: size, height: size)
                }
            }
            .shadow(
                color: PureLifeColors.logoGreen.opacity(0.3),
                radius: 10,
                x: 0,
                y: 0
            )
        }
    }
    
    // MARK: - Buttons
    
    /// Primary action button with prominent style
    struct PrimaryButton: View {
        var title: String
        var icon: String? = nil
        var action: () -> Void
        var fullWidth: Bool = false
        var height: CGFloat = 50
        @State private var isPressed = false
        
        var body: some View {
            Button(action: {
                // Add haptic feedback
                let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
                impactGenerator.impactOccurred()
                
                action()
            }) {
                HStack(spacing: 12) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: PureLifeTypography.body1))
                    }
                    
                    Text(title)
                        .font(.system(size: PureLifeTypography.body2, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .frame(height: height)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .background(
                    ZStack {
                        // Base gradient
                        LinearGradient(
                            gradient: Gradient(colors: [
                                PureLifeColors.logoGreen,
                                PureLifeColors.logoGreenDark
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // Subtle highlight overlay
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.05)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                )
                .cornerRadius(height / 2) // Pill shape
                .shadow(
                    color: PureLifeColors.logoGreen.opacity(isPressed ? 0.2 : 0.3),
                    radius: isPressed ? 4 : 8, 
                    x: 0, 
                    y: isPressed ? 2 : 4
                )
                .scaleEffect(isPressed ? 0.97 : 1)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            }
            .buttonStyle(PlainButtonStyle())
            .pressAction(onPress: {
                isPressed = true
            }, onRelease: {
                isPressed = false
            })
            .accessibilityLabel(title)
        }
    }
    
    /// Secondary button with less prominent style
    struct SecondaryButton: View {
        var title: String
        var icon: String? = nil
        var action: () -> Void
        var fullWidth: Bool = false
        var height: CGFloat = 50
        @Environment(\.colorScheme) var colorScheme
        @State private var isPressed = false
        
        var body: some View {
            Button(action: {
                let impactGenerator = UIImpactFeedbackGenerator(style: .light)
                impactGenerator.impactOccurred()
                
                action()
            }) {
                HStack(spacing: 12) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: PureLifeTypography.body1))
                    }
                    
                    Text(title)
                        .font(.system(size: PureLifeTypography.body2, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                }
                .foregroundColor(PureLifeColors.logoGreen)
                .padding(.horizontal, 24)
                .frame(height: height)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .background(
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(PureLifeColors.adaptiveSurface(scheme: colorScheme))
                        .overlay(
                            RoundedRectangle(cornerRadius: height / 2)
                                .strokeBorder(
                                    LinearGradient(
                                        gradient: Gradient(
                                            colors: [
                                                PureLifeColors.logoGreen.opacity(0.8),
                                                PureLifeColors.logoGreen.opacity(0.4)
                                            ]
                                        ),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                )
                .shadow(
                    color: PureLifeColors.adaptiveCardShadow(scheme: colorScheme),
                    radius: isPressed ? 2 : 4,
                    x: 0,
                    y: isPressed ? 1 : 2
                )
                .scaleEffect(isPressed ? 0.98 : 1)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            }
            .buttonStyle(PlainButtonStyle())
            .pressAction(onPress: {
                isPressed = true
            }, onRelease: {
                isPressed = false
            })
            .accessibilityLabel(title)
        }
    }
    
    /// Circular icon button
    struct IconButton: View {
        let iconName: String
        let action: () -> Void
        var iconColor: Color = PureLifeColors.logoGreen
        var backgroundColor: Color = PureLifeColors.logoGreen.opacity(0.12)
        var size: CGFloat = 40
        
        var body: some View {
            Button(action: action) {
                Image(systemName: iconName)
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundColor(iconColor)
                    .frame(width: size, height: size)
                    .background(backgroundColor)
                    .cornerRadius(size / 2)
            }
        }
    }
    
    // MARK: - Input Fields
    
    /// Styled text field with consistent design
    struct TextField: View {
        let placeholder: String
        @Binding var text: String
        var icon: String? = nil
        var keyboardType: UIKeyboardType = .default
        var isSecure: Bool = false
        var errorMessage: String? = nil
        var onSubmit: (() -> Void)? = nil
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                HStack(spacing: Spacing.xs) {
                    if let iconName = icon {
                        Image(systemName: iconName)
                            .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                            .frame(width: 24)
                    }
                    
                    if isSecure {
                        SecureField(placeholder, text: $text)
                            .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                    } else {
                        SwiftUI.TextField(placeholder, text: $text)
                            .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                            .keyboardType(keyboardType)
                    }
                }
                .padding(Spacing.sm)
                .background(PureLifeColors.adaptiveSurfaceSecondary(scheme: colorScheme))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            errorMessage != nil ? PureLifeColors.error : PureLifeColors.adaptiveDivider(scheme: colorScheme),
                            lineWidth: 1
                        )
                )
                
                if let error = errorMessage {
                    Text(error)
                        .font(.system(size: PureLifeTypography.caption1))
                        .foregroundColor(PureLifeColors.error)
                        .padding(.horizontal, Spacing.xxs)
                }
            }
        }
    }
    
    // MARK: - Avatar & User Display
    
    /// User avatar with initials
    struct UserAvatar: View {
        let initials: String
        var size: CGFloat = 40
        var fontSize: CGFloat = 16
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            ZStack {
                Circle()
                    .fill(PureLifeColors.logoGreen.opacity(0.2))
                    .frame(width: size, height: size)
                
                Text(initials)
                    .font(.system(size: PureLifeTypography.body2, weight: .semibold, design: .rounded))
                    .foregroundColor(PureLifeColors.logoGreen)
            }
        }
    }
    
    /// Loading state indicator
    struct LoadingIndicator: View {
        var message: String = "Loading..."
        var color: Color = PureLifeColors.logoGreen
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            VStack(spacing: Spacing.sm) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: color))
                    .scaleEffect(1.2)
                
                Text(message)
                    .font(.system(size: PureLifeTypography.caption1, weight: .medium, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(PureLifeColors.adaptiveBackground(scheme: colorScheme).opacity(0.8))
        }
    }
    
    // MARK: - Data Visualization
    
    /// Progress bar component
    struct ProgressBar: View {
        let value: Double
        var backgroundColor: Color = PureLifeColors.logoGreen.opacity(0.2)
        var foregroundColor: Color = PureLifeColors.logoGreen
        var height: CGFloat = 8
        
        var body: some View {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(backgroundColor)
                        .cornerRadius(height / 2)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [foregroundColor, foregroundColor.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width))
                        .cornerRadius(height / 2)
                }
            }
            .frame(height: height)
        }
    }
    
    /// Statistic card with icon, value and label
    struct StatCard: View {
        let icon: String
        let title: String
        let value: String
        var trend: String? = nil
        var trendLabel: String? = nil
        var iconColor: Color = PureLifeColors.logoGreen
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                // Icon and title
                HStack(spacing: Spacing.xs) {
                    ZStack {
                        Circle()
                            .fill(iconColor.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: icon)
                            .font(.system(size: PureLifeTypography.body1))
                            .foregroundColor(iconColor)
                    }
                    
                    Text(title)
                        .font(.system(size: PureLifeTypography.body2, weight: .medium, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                }
                
                // Main value
                Text(value)
                    .font(.system(size: PureLifeTypography.heading3, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                
                // Trend
                if let trend = trend, let label = trendLabel {
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: PureLifeTypography.caption1))
                            .foregroundColor(PureLifeColors.success)
                        
                        Text(trend)
                            .font(.system(size: PureLifeTypography.caption1, weight: .semibold, design: .rounded))
                            .foregroundColor(PureLifeColors.success)
                        
                        Text(label)
                            .font(.system(size: PureLifeTypography.caption1, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    }
                }
            }
            .padding(Spacing.md)
            .background(PureLifeColors.adaptiveSurface(scheme: colorScheme))
            .cornerRadius(20)
            .shadow(color: PureLifeColors.adaptiveCardShadow(scheme: colorScheme), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Empty States
    
    /// Empty state view with icon and messages
    struct EmptyState: View {
        let icon: String
        let title: String
        let message: String
        var action: (() -> Void)? = nil
        var actionTitle: String = "Action"
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            VStack(spacing: Spacing.lg) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(PureLifeColors.logoGreen.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: icon)
                        .font(.system(size: 50))
                        .foregroundColor(PureLifeColors.logoGreen.opacity(0.8))
                }
                
                Text(title)
                    .font(.system(size: PureLifeTypography.heading2, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(.system(size: PureLifeTypography.body1, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xxl)
                
                if let action = action {
                    PrimaryButton(title: actionTitle, icon: nil, action: action)
                        .padding(.horizontal, Spacing.xxl)
                        .padding(.top, Spacing.md)
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Messages & Alerts
    
    /// Information or notification banner
    struct Banner: View {
        enum BannerType {
            case info, success, warning, error
            
            var icon: String {
                switch self {
                case .info: return "info.circle.fill"
                case .success: return "checkmark.circle.fill"
                case .warning: return "exclamationmark.triangle.fill"
                case .error: return "xmark.circle.fill"
                }
            }
            
            var color: Color {
                switch self {
                case .info: return PureLifeColors.info
                case .success: return PureLifeColors.success
                case .warning: return PureLifeColors.warning
                case .error: return PureLifeColors.error
                }
            }
        }
        
        let type: BannerType
        let title: String
        var message: String? = nil
        var onDismiss: (() -> Void)? = nil
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            HStack(alignment: .top, spacing: Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(type.color.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: type.icon)
                        .foregroundColor(type.color)
                        .font(.system(size: PureLifeTypography.body1))
                }
                
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(title)
                        .font(.system(size: PureLifeTypography.body2, weight: .bold, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                    
                    if let message = message {
                        Text(message)
                            .font(.system(size: PureLifeTypography.caption1, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    }
                }
                
                Spacer()
                
                if let onDismiss = onDismiss {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: PureLifeTypography.body1))
                            .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    }
                }
            }
            .padding(Spacing.md)
            .background(PureLifeColors.adaptiveSurface(scheme: colorScheme))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(type.color.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(16)
        }
    }
    
    // MARK: - Modern Action Button
    
    struct ActionButton: View {
        var icon: String
        var size: CGFloat = 56
        var color: Color = PureLifeColors.logoGreen
        var action: () -> Void
        @State private var isPressed = false
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            Button(action: {
                let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
                impactGenerator.impactOccurred()
                
                action()
            }) {
                ZStack {
                    // Background
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    color,
                                    color.opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Highlight overlay
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Icon
                    Image(systemName: icon)
                        .font(.system(size: size * 0.4, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(width: size, height: size)
                .shadow(
                    color: color.opacity(isPressed ? 0.2 : 0.3),
                    radius: isPressed ? 4 : 8, 
                    x: 0, 
                    y: isPressed ? 2 : 4
                )
                .scaleEffect(isPressed ? 0.95 : 1)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            }
            .buttonStyle(PlainButtonStyle())
            .pressAction(onPress: {
                isPressed = true
            }, onRelease: {
                isPressed = false
            })
            .accessibilityLabel("Action Button")
        }
    }
} 