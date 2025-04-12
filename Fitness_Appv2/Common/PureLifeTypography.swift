import SwiftUI

/// Sistema tipográfico para la app de fitness
struct PureLifeTypography {
    // MARK: - Primary Font Families
    
    // Regular text uses system rounded for a friendly, modern feel
    static let bodyFamily = Font.Design.rounded
    
    // Display text (headers) can use a more dynamic font
    static let displayFamily = Font.Design.rounded
    
    // MARK: - Font Sizes
    
    // Modern font scale with better hierarchy
    static let display1: CGFloat = 40  // Very large headers
    static let display2: CGFloat = 32  // Primary headers
    static let heading1: CGFloat = 28  // Section headers
    static let heading2: CGFloat = 24  // Secondary headers
    static let heading3: CGFloat = 20  // Subsection headers
    static let heading4: CGFloat = 18  // Card headers
    static let heading5: CGFloat = 16  // Minor headers
    static let body1: CGFloat = 16     // Primary body text
    static let body2: CGFloat = 15     // Secondary body text
    static let caption1: CGFloat = 14  // Primary captions
    static let caption2: CGFloat = 13  // Secondary captions
    static let small: CGFloat = 12     // Small text, disclaimers
    static let micro: CGFloat = 11     // Very small text, legal
    
    // MARK: - Letter Spacing
    
    static let tightSpacing: CGFloat = -0.5
    static let normalSpacing: CGFloat = 0
    static let looseSpacing: CGFloat = 0.5
    
    // MARK: - Line Heights
    
    static let tightLineHeight: CGFloat = 1.15
    static let normalLineHeight: CGFloat = 1.25
    static let looseLineHeight: CGFloat = 1.5
    
    // MARK: - Font Weights
    
    static let ultraLight: Font.Weight = .ultraLight
    static let thin: Font.Weight = .thin
    static let light: Font.Weight = .light
    static let regular: Font.Weight = .regular
    static let medium: Font.Weight = .medium
    static let semibold: Font.Weight = .semibold
    static let bold: Font.Weight = .bold
    static let heavy: Font.Weight = .heavy
    static let black: Font.Weight = .black
    
    // MARK: - Text Styles
    
    // Display Styles (Large headers)
    
    static var display1Style: Font {
        .system(size: display1, weight: bold, design: displayFamily)
    }
    
    static var display2Style: Font {
        .system(size: display2, weight: bold, design: displayFamily)
    }
    
    // Heading Styles
    
    static var heading1Style: Font {
        .system(size: heading1, weight: bold, design: displayFamily)
    }
    
    static var heading2Style: Font {
        .system(size: heading2, weight: semibold, design: displayFamily)
    }
    
    static var heading3Style: Font {
        .system(size: heading3, weight: semibold, design: displayFamily)
    }
    
    static var heading4Style: Font {
        .system(size: heading4, weight: semibold, design: displayFamily)
    }
    
    static var heading5Style: Font {
        .system(size: heading5, weight: medium, design: displayFamily)
    }
    
    // Body Text Styles
    
    static var body1Style: Font {
        .system(size: body1, weight: regular, design: bodyFamily)
    }
    
    static var body1EmphasisStyle: Font {
        .system(size: body1, weight: medium, design: bodyFamily)
    }
    
    static var body2Style: Font {
        .system(size: body2, weight: regular, design: bodyFamily)
    }
    
    static var body2EmphasisStyle: Font {
        .system(size: body2, weight: medium, design: bodyFamily)
    }
    
    // Caption Styles
    
    static var caption1Style: Font {
        .system(size: caption1, weight: regular, design: bodyFamily)
    }
    
    static var caption1EmphasisStyle: Font {
        .system(size: caption1, weight: medium, design: bodyFamily)
    }
    
    static var caption2Style: Font {
        .system(size: caption2, weight: regular, design: bodyFamily)
    }
    
    // Small Text Styles
    
    static var smallStyle: Font {
        .system(size: small, weight: regular, design: bodyFamily)
    }
    
    static var smallEmphasisStyle: Font {
        .system(size: small, weight: medium, design: bodyFamily)
    }
    
    static var microStyle: Font {
        .system(size: micro, weight: regular, design: bodyFamily)
    }
    
    // MARK: - Typography Modifiers
    
    // Heading modifiers with better spacing and weights
    
    struct Display1: ViewModifier {
        let color: Color
        
        func body(content: Content) -> some View {
            content
                .font(PureLifeTypography.display1Style)
                .foregroundColor(color)
                .lineSpacing(4)
                .tracking(tightSpacing)
        }
    }
    
    struct Display2: ViewModifier {
        let color: Color
        
        func body(content: Content) -> some View {
            content
                .font(PureLifeTypography.display2Style)
                .foregroundColor(color)
                .lineSpacing(2)
                .tracking(tightSpacing)
        }
    }
    
    struct Heading1: ViewModifier {
        let color: Color
        
        func body(content: Content) -> some View {
            content
                .font(PureLifeTypography.heading1Style)
                .foregroundColor(color)
                .lineSpacing(2)
                .tracking(tightSpacing)
        }
    }
    
    struct Heading2: ViewModifier {
        let color: Color
        
        func body(content: Content) -> some View {
            content
                .font(PureLifeTypography.heading2Style)
                .foregroundColor(color)
                .lineSpacing(1)
                .tracking(tightSpacing)
        }
    }
    
    struct Heading3: ViewModifier {
        let color: Color
        
        func body(content: Content) -> some View {
            content
                .font(PureLifeTypography.heading3Style)
                .foregroundColor(color)
                .tracking(tightSpacing)
        }
    }
    
    struct Heading4: ViewModifier {
        let color: Color
        
        func body(content: Content) -> some View {
            content
                .font(PureLifeTypography.heading4Style)
                .foregroundColor(color)
        }
    }
    
    struct Heading5: ViewModifier {
        let color: Color
        
        func body(content: Content) -> some View {
            content
                .font(PureLifeTypography.heading5Style)
                .foregroundColor(color)
        }
    }
    
    // Body modifiers with improved readability
    
    struct Body1: ViewModifier {
        let color: Color
        
        func body(content: Content) -> some View {
            content
                .font(PureLifeTypography.body1Style)
                .foregroundColor(color)
                .lineSpacing(3)
        }
    }
    
    struct Body1Emphasis: ViewModifier {
        let color: Color
        
        func body(content: Content) -> some View {
            content
                .font(PureLifeTypography.body1EmphasisStyle)
                .foregroundColor(color)
                .lineSpacing(3)
        }
    }
    
    struct Body2: ViewModifier {
        let color: Color
        
        func body(content: Content) -> some View {
            content
                .font(PureLifeTypography.body2Style)
                .foregroundColor(color)
                .lineSpacing(2)
        }
    }
    
    struct Body2Emphasis: ViewModifier {
        let color: Color
        
        func body(content: Content) -> some View {
            content
                .font(PureLifeTypography.body2EmphasisStyle)
                .foregroundColor(color)
                .lineSpacing(2)
        }
    }
    
    // Caption modifiers
    
    struct Caption1: ViewModifier {
        let color: Color
        
        func body(content: Content) -> some View {
            content
                .font(PureLifeTypography.caption1Style)
                .foregroundColor(color)
                .lineSpacing(1)
        }
    }
    
    struct Caption1Emphasis: ViewModifier {
        let color: Color
        
        func body(content: Content) -> some View {
            content
                .font(PureLifeTypography.caption1EmphasisStyle)
                .foregroundColor(color)
                .lineSpacing(1)
        }
    }
    
    struct Caption2: ViewModifier {
        let color: Color
        
        func body(content: Content) -> some View {
            content
                .font(PureLifeTypography.caption2Style)
                .foregroundColor(color)
                .lineSpacing(1)
        }
    }
    
    // Small modifiers
    
    struct Small: ViewModifier {
        let color: Color
        
        func body(content: Content) -> some View {
            content
                .font(PureLifeTypography.smallStyle)
                .foregroundColor(color)
        }
    }
    
    struct SmallEmphasis: ViewModifier {
        let color: Color
        
        func body(content: Content) -> some View {
            content
                .font(PureLifeTypography.smallEmphasisStyle)
                .foregroundColor(color)
        }
    }
    
    struct Micro: ViewModifier {
        let color: Color
        
        func body(content: Content) -> some View {
            content
                .font(PureLifeTypography.microStyle)
                .foregroundColor(color)
        }
    }
}

// MARK: - Extension for View to apply typography modifiers
extension View {
    // Display styles
    
    func display1Style(color: Color = PureLifeColors.textPrimary) -> some View {
        modifier(PureLifeTypography.Display1(color: color))
    }
    
    func display2Style(color: Color = PureLifeColors.textPrimary) -> some View {
        modifier(PureLifeTypography.Display2(color: color))
    }
    
    // Heading styles
    
    func heading1Style(color: Color = PureLifeColors.textPrimary) -> some View {
        modifier(PureLifeTypography.Heading1(color: color))
    }
    
    func heading2Style(color: Color = PureLifeColors.textPrimary) -> some View {
        modifier(PureLifeTypography.Heading2(color: color))
    }
    
    func heading3Style(color: Color = PureLifeColors.textPrimary) -> some View {
        modifier(PureLifeTypography.Heading3(color: color))
    }
    
    func heading4Style(color: Color = PureLifeColors.textPrimary) -> some View {
        modifier(PureLifeTypography.Heading4(color: color))
    }
    
    func heading5Style(color: Color = PureLifeColors.textPrimary) -> some View {
        modifier(PureLifeTypography.Heading5(color: color))
    }
    
    // Body styles
    
    func body1Style(color: Color = PureLifeColors.textPrimary) -> some View {
        modifier(PureLifeTypography.Body1(color: color))
    }
    
    func body1EmphasisStyle(color: Color = PureLifeColors.textPrimary) -> some View {
        modifier(PureLifeTypography.Body1Emphasis(color: color))
    }
    
    func body2Style(color: Color = PureLifeColors.textPrimary) -> some View {
        modifier(PureLifeTypography.Body2(color: color))
    }
    
    func body2EmphasisStyle(color: Color = PureLifeColors.textPrimary) -> some View {
        modifier(PureLifeTypography.Body2Emphasis(color: color))
    }
    
    // Caption styles
    
    func caption1Style(color: Color = PureLifeColors.textSecondary) -> some View {
        modifier(PureLifeTypography.Caption1(color: color))
    }
    
    func caption1EmphasisStyle(color: Color = PureLifeColors.textSecondary) -> some View {
        modifier(PureLifeTypography.Caption1Emphasis(color: color))
    }
    
    func caption2Style(color: Color = PureLifeColors.textSecondary) -> some View {
        modifier(PureLifeTypography.Caption2(color: color))
    }
    
    // Small styles
    
    func smallStyle(color: Color = PureLifeColors.textSecondary) -> some View {
        modifier(PureLifeTypography.Small(color: color))
    }
    
    func smallEmphasisStyle(color: Color = PureLifeColors.textSecondary) -> some View {
        modifier(PureLifeTypography.SmallEmphasis(color: color))
    }
    
    func microStyle(color: Color = PureLifeColors.textSecondary) -> some View {
        modifier(PureLifeTypography.Micro(color: color))
    }
} 