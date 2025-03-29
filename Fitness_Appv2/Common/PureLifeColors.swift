import SwiftUI

/// Sistema de colores para la experiencia "PureLife"
struct PureLifeColors {
    // MARK: - Primary Palette
    
    /// Verde principal de la marca, verde mint ajustado para más vibración
    static let logoGreen = Color(red: 94/255, green: 190/255, blue: 164/255)
    
    /// Variante más oscura del verde de la marca
    static let logoGreenDark = Color(red: 65/255, green: 160/255, blue: 134/255)
    
    /// Versión más clara para fondos y áreas grandes
    static let logoGreenLight = Color(red: 226/255, green: 247/255, blue: 240/255)
    
    // MARK: - Background Colors
    
    /// Fondo principal de la app (claro)
    static let background = Color(red: 250/255, green: 250/255, blue: 250/255)
    
    /// Fondo oscuro para modo oscuro o áreas de contraste
    static let darkBackground = Color(red: 18/255, green: 18/255, blue: 18/255)
    
    // MARK: - Surface Colors
    
    /// Superficie principal para tarjetas y elementos elevados
    static let surface = Color.white
    
    /// Superficie con elevación para elementos secundarios
    static let elevatedSurface = Color(red: 245/255, green: 245/255, blue: 245/255)
    
    /// Superficie oscura para modo oscuro o áreas de contraste
    static let darkSurface = Color(red: 32/255, green: 32/255, blue: 34/255)
    
    /// Superficie oscura secundaria
    static let darkSurfaceSecondary = Color(red: 48/255, green: 48/255, blue: 50/255)
    
    // MARK: - Text Colors
    
    /// Texto principal
    static let textPrimary = Color(red: 30/255, green: 30/255, blue: 30/255)
    
    /// Texto secundario para labels menos importantes
    static let textSecondary = Color(red: 115/255, green: 115/255, blue: 120/255)
    
    /// Texto para modo oscuro
    static let darkTextPrimary = Color.white
    
    /// Texto secundario para modo oscuro
    static let darkTextSecondary = Color(red: 185/255, green: 185/255, blue: 195/255)
    
    // MARK: - UI Element Colors
    
    /// Color para divisores y bordes
    static let divider = Color(red: 230/255, green: 230/255, blue: 230/255)
    
    /// Divider for dark mode
    static let darkDivider = Color(red: 70/255, green: 70/255, blue: 75/255)
    
    /// Gradiente principal para botones y acentos
    static let accentGradient = LinearGradient(
        gradient: Gradient(colors: [logoGreen, logoGreenDark]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /// Gradiente secundario para fondos sutiles
    static let subtleGradient = LinearGradient(
        gradient: Gradient(colors: [logoGreenLight.opacity(0.5), logoGreenLight.opacity(0.2)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Semantic Colors
    
    /// Color para elementos de éxito
    static let success = Color(red: 72/255, green: 190/255, blue: 126/255)
    
    /// Color para advertencias
    static let warning = Color(red: 245/255, green: 158/255, blue: 11/255)
    
    /// Color para errores
    static let error = Color(red: 239/255, green: 68/255, blue: 68/255)
    
    /// Color para información
    static let info = Color(red: 59/255, green: 130/255, blue: 246/255)
    
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
    
    // Efecto de glassmorphism
    static let glassMorphism = Color.white.opacity(0.85)
    static let darkGlassMorphism = Color.black.opacity(0.7)
    
    // Campos de texto
    static let inputBackground = Color.white
    static let inputBorder = divider
    static let inputText = textPrimary
    static let inputPlaceholder = textSecondary
    
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
            return ShadowModifier(radius: 4, y: 1, scheme: scheme)
        case 2:
            // Medium elevation (floating elements, popovers)
            return ShadowModifier(radius: 8, y: 2, scheme: scheme)
        case 3:
            // High elevation (dialogs, modals)
            return ShadowModifier(radius: 16, y: 3, scheme: scheme)
        default:
            // Default to level 1
            return ShadowModifier(radius: 4, y: 1, scheme: scheme)
        }
    }
    
    private struct ShadowModifier: ViewModifier {
        let radius: CGFloat
        let y: CGFloat
        let scheme: ColorScheme
        
        func body(content: Content) -> some View {
            let color = scheme == .dark ? 
                Color.black.opacity(0.2) : 
                Color.black.opacity(0.1)
            
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
    static func modernCard(cornerRadius: CGFloat = 20, padding: CGFloat = 16, scheme: ColorScheme) -> some ViewModifier {
        ModernCardStyle(cornerRadius: cornerRadius, padding: padding, scheme: scheme)
    }
    
    /// Glass effect card style
    static func glassCard(cornerRadius: CGFloat = 24, padding: CGFloat = 16, scheme: ColorScheme) -> some ViewModifier {
        GlassCardStyle(cornerRadius: cornerRadius, padding: padding, scheme: scheme)
    }
    
    /// Outline card style with brand color
    static func outlineCard(cornerRadius: CGFloat = 20, padding: CGFloat = 16, scheme: ColorScheme) -> some ViewModifier {
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
                    radius: 6,
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
                    PureLifeColors.adaptiveGlass(scheme: scheme)
                        .background(.ultraThinMaterial)
                )
                .cornerRadius(cornerRadius)
                .shadow(
                    color: PureLifeColors.adaptiveCardShadow(scheme: scheme),
                    radius: 8,
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
                        .stroke(PureLifeColors.logoGreen.opacity(0.5), lineWidth: 1.5)
                )
                .shadow(
                    color: PureLifeColors.adaptiveCardShadow(scheme: scheme),
                    radius: 4,
                    x: 0,
                    y: 2
                )
        }
    }
} 