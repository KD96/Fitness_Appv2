import SwiftUI

/// Collection of modern UI components for enhancing the app's visual design
struct UIComponents {
    
    // MARK: - Background Components
    
    /// Base view container for tab content to ensure consistent behavior
    struct TabContentView<Content: View>: View {
        let content: Content
        var backgroundImage: String? = nil
        var backgroundOpacity: Double = 0.07
        var backgroundColor: Color? = nil
        
        @Environment(\.colorScheme) var colorScheme
        
        init(
            backgroundImage: String? = nil,
            backgroundOpacity: Double = 0.07,
            backgroundColor: Color? = nil,
            @ViewBuilder content: () -> Content
        ) {
            self.backgroundImage = backgroundImage
            self.backgroundOpacity = backgroundOpacity
            self.backgroundColor = backgroundColor
            self.content = content()
        }
        
        var body: some View {
            ZStack {
                // Base background color
                (backgroundColor ?? PureLifeColors.adaptiveBackground(scheme: colorScheme))
                    .edgesIgnoringSafeArea(.all)
                
                // Optional background image
                if let imageName = backgroundImage, let uiImage = UIImage(named: imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .opacity(backgroundOpacity)
                        .blendMode(colorScheme == .dark ? .overlay : .multiply)
                        .edgesIgnoringSafeArea(.all)
                }
                
                // Main content
                content
                    .edgesIgnoringSafeArea(.bottom)
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
        let content: Content
        var cornerRadius: CGFloat = 24
        var showAthlete: Bool = false
        var athleteImage: String = "athlete1"
        var athleteOpacity: Double = 0.08
        
        @Environment(\.colorScheme) var colorScheme
        
        init(
            cornerRadius: CGFloat = 24,
            showAthlete: Bool = false,
            athleteImage: String = "athlete1",
            athleteOpacity: Double = 0.08,
            @ViewBuilder content: () -> Content
        ) {
            self.cornerRadius = cornerRadius
            self.showAthlete = showAthlete
            self.athleteImage = athleteImage
            self.athleteOpacity = athleteOpacity
            self.content = content()
        }
        
        var body: some View {
            ZStack {
                // Card background
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(PureLifeColors.adaptiveSurface(scheme: colorScheme))
                    .shadow(
                        color: colorScheme == .dark ? 
                            Color.black.opacity(0.3) : 
                            PureLifeColors.adaptiveCardShadow(scheme: colorScheme),
                        radius: 15,
                        x: 0,
                        y: 5
                    )
                
                // Athlete image if enabled
                if showAthlete, let uiImage = UIImage(named: athleteImage) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .opacity(athleteOpacity)
                        .blendMode(colorScheme == .dark ? .overlay : .multiply)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                }
                
                // Content layer
                content
            }
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
                                .font(.system(size: Typography.FontSize.md))
                                .foregroundColor(PureLifeColors.logoGreen)
                        }
                        
                        Text(title)
                            .font(.system(size: Typography.FontSize.lg, weight: .bold, design: .rounded))
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
        let content: Content
        var cornerRadius: CGFloat = 24
        var blurRadius: CGFloat = 5
        
        @Environment(\.colorScheme) var colorScheme
        
        init(
            cornerRadius: CGFloat = 24,
            blurRadius: CGFloat = 5,
            @ViewBuilder content: () -> Content
        ) {
            self.cornerRadius = cornerRadius
            self.blurRadius = blurRadius
            self.content = content()
        }
        
        var body: some View {
            ZStack {
                // Glass effect background
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(PureLifeColors.adaptiveSurface(scheme: colorScheme).opacity(0.7))
                    .background(
                        PureLifeColors.adaptiveSurface(scheme: colorScheme)
                            .opacity(0.2)
                    )
                    .blur(radius: blurRadius)
                
                // Border
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.1 : 0.5),
                                Color.clear,
                                PureLifeColors.logoGreen.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                
                // Content
                content
            }
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
        let text: String
        let action: () -> Void
        var iconName: String? = nil
        var isLoading: Bool = false
        var isDisabled: Bool = false
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            Button(action: isDisabled ? {} : action) {
                HStack(spacing: Spacing.xs) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else if let icon = iconName {
                        Image(systemName: icon)
                            .font(.system(size: Typography.FontSize.base))
                    }
                    
                    Text(text)
                        .font(.system(size: Typography.FontSize.md, weight: .bold, design: .rounded))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            isDisabled ? PureLifeColors.logoGreen.opacity(0.5) : PureLifeColors.logoGreen,
                            isDisabled ? PureLifeColors.logoGreenDark.opacity(0.5) : PureLifeColors.logoGreenDark
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(28)
                .shadow(color: PureLifeColors.logoGreen.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(isDisabled || isLoading)
        }
    }
    
    /// Secondary button with less prominent style
    struct SecondaryButton: View {
        let text: String
        let action: () -> Void
        var iconName: String? = nil
        var isLoading: Bool = false
        var isDisabled: Bool = false
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            Button(action: isDisabled ? {} : action) {
                HStack(spacing: Spacing.xs) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: PureLifeColors.logoGreen))
                            .scaleEffect(0.8)
                    } else if let icon = iconName {
                        Image(systemName: icon)
                            .font(.system(size: Typography.FontSize.base))
                    }
                    
                    Text(text)
                        .font(.system(size: Typography.FontSize.md, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(PureLifeColors.adaptiveSurface(scheme: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(
                            PureLifeColors.logoGreen.opacity(isDisabled ? 0.5 : 1),
                            lineWidth: 1.5
                        )
                )
                .foregroundColor(
                    PureLifeColors.logoGreen.opacity(isDisabled ? 0.5 : 1)
                )
                .cornerRadius(28)
            }
            .disabled(isDisabled || isLoading)
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
                        .font(.system(size: Typography.FontSize.sm))
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
                    .font(.system(size: fontSize, weight: .semibold, design: .rounded))
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
                    .font(.system(size: Typography.FontSize.sm, weight: .medium, design: .rounded))
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
                            .font(.system(size: Typography.FontSize.md))
                            .foregroundColor(iconColor)
                    }
                    
                    Text(title)
                        .font(.system(size: Typography.FontSize.base, weight: .medium, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                }
                
                // Main value
                Text(value)
                    .font(.system(size: Typography.FontSize.xxl, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                
                // Trend
                if let trend = trend, let label = trendLabel {
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: Typography.FontSize.xs))
                            .foregroundColor(PureLifeColors.success)
                        
                        Text(trend)
                            .font(.system(size: Typography.FontSize.sm, weight: .semibold, design: .rounded))
                            .foregroundColor(PureLifeColors.success)
                        
                        Text(label)
                            .font(.system(size: Typography.FontSize.xs, design: .rounded))
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
                    .font(.system(size: Typography.FontSize.xl, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(.system(size: Typography.FontSize.base, design: .rounded))
                    .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xxl)
                
                if let action = action {
                    PrimaryButton(text: actionTitle, action: action)
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
                        .font(.system(size: Typography.FontSize.md))
                }
                
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(title)
                        .font(.system(size: Typography.FontSize.base, weight: .bold, design: .rounded))
                        .foregroundColor(PureLifeColors.adaptiveTextPrimary(scheme: colorScheme))
                    
                    if let message = message {
                        Text(message)
                            .font(.system(size: Typography.FontSize.sm, design: .rounded))
                            .foregroundColor(PureLifeColors.adaptiveTextSecondary(scheme: colorScheme))
                    }
                }
                
                Spacer()
                
                if let onDismiss = onDismiss {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: Typography.FontSize.md))
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
} 