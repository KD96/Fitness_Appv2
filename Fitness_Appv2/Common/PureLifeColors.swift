import SwiftUI

/// Sistema de colores para la experiencia "PureLife"
struct PureLifeColors {
    // MARK: - Primary Palette
    
    /// Verde principal de la marca, verde mint ajustado for vibrancy
    static let logoGreen = Color(red: 82/255, green: 196/255, blue: 164/255)
    
    /// Variante más oscura del verde de la marca
    static let logoGreenDark = Color(red: 58/255, green: 157/255, blue: 130/255)
    
    /// Versión más clara para fondos y áreas grandes
    static let logoGreenLight = Color(red: 226/255, green: 247/255, blue: 240/255)
    
    // MARK: - Accent Colors (New)
    
    /// Blue accent color for fitness activities
    static let accentBlue = Color(red: 50/255, green: 130/255, blue: 240/255)
    
    /// Vibrant coral for energy and motivation
    static let accentCoral = Color(red: 255/255, green: 111/255, blue: 97/255)
    
    /// Deep purple for rewards and achievements
    static let accentPurple = Color(red: 125/255, green: 95/255, blue: 255/255)
    
    /// Accent color for nutrition content
    static let accentTeal = Color(red: 48/255, green: 170/255, blue: 180/255)
    
    // MARK: - Background Colors
    
    /// Fondo principal de la app (claro) - slightly warmer
    static let background = Color(red: 250/255, green: 251/255, blue: 252/255)
    
    /// Fondo oscuro para modo oscuro o áreas de contraste - less harsh
    static let darkBackground = Color(red: 22/255, green: 26/255, blue: 30/255)
    
    // MARK: - Surface Colors
    
    /// Superficie principal para tarjetas y elementos elevados
    static let surface = Color.white
    
    /// Superficie con elevación para elementos secundarios
    static let elevatedSurface = Color(red: 246/255, green: 248/255, blue: 250/255)
    
    /// Superficie oscura para modo oscuro o áreas de contraste
    static let darkSurface = Color(red: 34/255, green: 38/255, blue: 42/255)
    
    /// Superficie oscura secundaria
    static let darkSurfaceSecondary = Color(red: 44/255, green: 48/255, blue: 54/255)
    
    // MARK: - Text Colors
    
    /// Texto principal - slightly softer
    static let textPrimary = Color(red: 32/255, green: 36/255, blue: 40/255)
    
    /// Texto secundario para labels menos importantes - warmer gray
    static let textSecondary = Color(red: 120/255, green: 125/255, blue: 135/255)
    
    /// Texto terciario para hint text y placeholders - new!
    static let textTertiary = Color(red: 160/255, green: 165/255, blue: 175/255)
    
    /// Texto para modo oscuro - slightly less harsh
    static let darkTextPrimary = Color(red: 245/255, green: 248/255, blue: 250/255)
    
    /// Texto secundario para modo oscuro - warmer gray
    static let darkTextSecondary = Color(red: 190/255, green: 195/255, blue: 205/255)
    
    /// Texto terciario para modo oscuro - new!
    static let darkTextTertiary = Color(red: 140/255, green: 145/255, blue: 155/255)
    
    // MARK: - UI Element Colors
    
    /// Color para divisores y bordes - subtler
    static let divider = Color(red: 235/255, green: 238/255, blue: 242/255)
    
    /// Divider for dark mode - subtler
    static let darkDivider = Color(red: 60/255, green: 65/255, blue: 70/255)
    
    /// Gradiente principal para botones y acentos - more vibrant
    static let accentGradient = LinearGradient(
        gradient: Gradient(colors: [logoGreen, logoGreenDark]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /// Gradiente secundario para fondos sutiles
    static let subtleGradient = LinearGradient(
        gradient: Gradient(colors: [logoGreenLight.opacity(0.6), logoGreenLight.opacity(0.2)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - New Gradients for Modern UI
    
    /// Blue fitness gradient
    static let blueGradient = LinearGradient(
        gradient: Gradient(colors: [accentBlue, accentBlue.opacity(0.7)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Purple rewards gradient
    static let purpleGradient = LinearGradient(
        gradient: Gradient(colors: [accentPurple, accentPurple.opacity(0.7)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Coral energy gradient
    static let coralGradient = LinearGradient(
        gradient: Gradient(colors: [accentCoral, accentCoral.opacity(0.7)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Teal nutrition gradient
    static let tealGradient = LinearGradient(
        gradient: Gradient(colors: [accentTeal, accentTeal.opacity(0.7)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Semantic Colors
    
    /// Color para elementos de éxito - warmer green
    static let success = Color(red: 68/255, green: 190/255, blue: 124/255)
    
    /// Color para advertencias - warmer orange
    static let warning = Color(red: 250/255, green: 155/255, blue: 55/255)
    
    /// Color para errores - less harsh red
    static let error = Color(red: 245/255, green: 75/255, blue: 75/255)
    
    /// Color para información - warmer blue
    static let info = Color(red: 65/255, green: 145/255, blue: 250/255)
    
    // MARK: - Modern UI Component Tokens
    
    // Botones
    static let primaryButtonBackground = logoGreen
    static let primaryButtonText = Color.white
    static let secondaryButtonBackground = Color.white
    static let secondaryButtonText = logoGreen
    static let tertiaryButtonBackground = logoGreenLight
    static let tertiaryButtonText = logoGreenDark
    
    // Tarjetas
    static let cardBackground = surface
    static let cardBorder = divider
    static let cardShadow = Color.black.opacity(0.04)
    
    // Efecto de glassmorphism - more subtle
    static let glassMorphism = Color.white.opacity(0.8)
    static let darkGlassMorphism = Color.black.opacity(0.65)
    
    // Campos de texto
    static let inputBackground = Color.white
    static let inputBorder = divider
    static let inputText = textPrimary
    static let inputPlaceholder = textTertiary
    
    // Estados de navegación
    static let tabBarActive = logoGreen
    static let tabBarInactive = textSecondary
    static let navigationBarBackground = surface
    
    // MARK: - Elevation System
    
    // Sombras con diferentes niveles de elevación
    static func elevationShadow(level: Int, scheme: ColorScheme) -> some ViewModifier {
        switch level {
        case 1:
            // Subtle elevation (cards, clickable items)
            return ShadowModifier(radius: 6, y: 1, opacity: 0.05, scheme: scheme)
        case 2:
            // Medium elevation (floating elements, popovers)
            return ShadowModifier(radius: 10, y: 2, opacity: 0.08, scheme: scheme)
        case 3:
            // High elevation (dialogs, modals)
            return ShadowModifier(radius: 18, y: 3, opacity: 0.12, scheme: scheme)
        default:
            // Default to level 1
            return ShadowModifier(radius: 6, y: 1, opacity: 0.05, scheme: scheme)
        }
    }
    
    private struct ShadowModifier: ViewModifier {
        let radius: CGFloat
        let y: CGFloat
        let opacity: Double
        let scheme: ColorScheme
        
        func body(content: Content) -> some View {
            let color = scheme == .dark ? 
                Color.black.opacity(opacity * 2) : 
                Color.black.opacity(opacity)
            
            return content
                .shadow(color: color, radius: radius, x: 0, y: y)
        }
    }
    
    // MARK: - Color Adaptations for Dark Mode
    
    /// Helper to adapt colors based on color scheme
    static func adaptiveColor(light: Color, dark: Color, scheme: ColorScheme) -> Color {
        switch scheme {
        case .light:
            return light
        case .dark:
            return dark
        @unknown default:
            return light
        }
    }
    
    /// Adaptive background color
    static func adaptiveBackground(scheme: ColorScheme) -> Color {
        adaptiveColor(light: background, dark: darkBackground, scheme: scheme)
    }
    
    /// Adaptive surface color
    static func adaptiveSurface(scheme: ColorScheme) -> Color {
        adaptiveColor(light: surface, dark: darkSurface, scheme: scheme)
    }
    
    /// Adaptive elevated surface color
    static func adaptiveElevatedSurface(scheme: ColorScheme) -> Color {
        adaptiveColor(light: elevatedSurface, dark: darkSurfaceSecondary, scheme: scheme)
    }
    
    /// Adaptive surface secondary color
    static func adaptiveSurfaceSecondary(scheme: ColorScheme) -> Color {
        adaptiveColor(light: elevatedSurface, dark: darkSurfaceSecondary, scheme: scheme)
    }
    
    /// Adaptive text primary color
    static func adaptiveTextPrimary(scheme: ColorScheme) -> Color {
        adaptiveColor(light: textPrimary, dark: darkTextPrimary, scheme: scheme)
    }
    
    /// Adaptive text secondary color
    static func adaptiveTextSecondary(scheme: ColorScheme) -> Color {
        adaptiveColor(light: textSecondary, dark: darkTextSecondary, scheme: scheme)
    }
    
    /// Adaptive text tertiary color
    static func adaptiveTextTertiary(scheme: ColorScheme) -> Color {
        adaptiveColor(light: textTertiary, dark: darkTextTertiary, scheme: scheme)
    }
    
    /// Adaptive card shadow color
    static func adaptiveCardShadow(scheme: ColorScheme) -> Color {
        adaptiveColor(light: Color.black.opacity(0.04), dark: Color.black.opacity(0.1), scheme: scheme)
    }
    
    /// Adaptive divider color
    static func adaptiveDivider(scheme: ColorScheme) -> Color {
        adaptiveColor(light: divider, dark: darkDivider, scheme: scheme)
    }
    
    /// Adaptive glassmorphism effect
    static func adaptiveGlass(scheme: ColorScheme) -> Color {
        adaptiveColor(light: glassMorphism, dark: darkGlassMorphism, scheme: scheme)
    }
    
    // MARK: - Card Styles
    
    /// Modern card style with customizable corner radius and padding
    static func modernCard(cornerRadius: CGFloat = 16, padding: CGFloat = 16, scheme: ColorScheme) -> some ViewModifier {
        ModernCardStyle(cornerRadius: cornerRadius, padding: padding, scheme: scheme)
    }
    
    /// Glass effect card style
    static func glassCard(cornerRadius: CGFloat = 20, padding: CGFloat = 16, scheme: ColorScheme) -> some ViewModifier {
        GlassCardStyle(cornerRadius: cornerRadius, padding: padding, scheme: scheme)
    }
    
    /// Outline card style with brand color
    static func outlineCard(cornerRadius: CGFloat = 16, padding: CGFloat = 16, scheme: ColorScheme) -> some ViewModifier {
        OutlineCardStyle(cornerRadius: cornerRadius, padding: padding, scheme: scheme)
    }
    
    private struct ModernCardStyle: ViewModifier {
        let cornerRadius: CGFloat
        let padding: CGFloat
        let scheme: ColorScheme
        
        func body(content: Content) -> some View {
            content
                .padding(padding)
                .background(PureLifeColors.adaptiveSurface(scheme: scheme))
                .cornerRadius(cornerRadius)
                .shadow(
                    color: PureLifeColors.adaptiveCardShadow(scheme: scheme),
                    radius: 10,
                    x: 0,
                    y: 2
                )
        }
    }
    
    private struct GlassCardStyle: ViewModifier {
        let cornerRadius: CGFloat
        let padding: CGFloat
        let scheme: ColorScheme
        
        func body(content: Content) -> some View {
            content
                .padding(padding)
                .background(
                    ZStack {
                        PureLifeColors.adaptiveGlass(scheme: scheme)
                        
                        // Add subtle gradient overlay
                        LinearGradient(
                            gradient: Gradient(
                                colors: [
                                    Color.white.opacity(scheme == .dark ? 0.05 : 0.25),
                                    Color.white.opacity(scheme == .dark ? 0.02 : 0.1)
                                ]
                            ),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                    .background(.ultraThinMaterial)
                )
                .cornerRadius(cornerRadius)
                .shadow(
                    color: PureLifeColors.adaptiveCardShadow(scheme: scheme),
                    radius: 12,
                    x: 0,
                    y: 4
                )
        }
    }
    
    private struct OutlineCardStyle: ViewModifier {
        let cornerRadius: CGFloat
        let padding: CGFloat
        let scheme: ColorScheme
        
        func body(content: Content) -> some View {
            content
                .padding(padding)
                .background(PureLifeColors.adaptiveSurface(scheme: scheme))
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        PureLifeColors.logoGreen.opacity(0.7),
                                        PureLifeColors.logoGreen.opacity(0.4)
                                    ]
                                ),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(
                    color: PureLifeColors.adaptiveCardShadow(scheme: scheme),
                    radius: 6,
                    x: 0,
                    y: 2
                )
        }
    }
} 