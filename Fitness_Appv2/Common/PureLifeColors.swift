import SwiftUI

/// Sistema de colores para la experiencia "PureLife"
struct PureLifeColors {
    // MARK: - Primary Palette
    
    /// Verde principal de la marca, verde mint
    static let logoGreen = Color(red: 199/255, green: 227/255, blue: 214/255)
    
    /// Variante más oscura del verde de la marca
    static let logoGreenDark = logoGreen.opacity(0.8)
    
    /// Versión más clara para fondos y áreas grandes
    static let logoGreenLight = logoGreen.opacity(0.3)
    
    // MARK: - Background Colors
    
    /// Fondo principal de la app (claro)
    static let background = Color(red: 250/255, green: 250/255, blue: 250/255)
    
    /// Fondo oscuro para modo oscuro o áreas de contraste
    static let darkBackground = Color(red: 28/255, green: 28/255, blue: 30/255)
    
    // MARK: - Surface Colors
    
    /// Superficie principal para tarjetas y elementos elevados
    static let surface = Color.white
    
    /// Superficie con elevación para elementos secundarios
    static let elevatedSurface = Color(red: 245/255, green: 245/255, blue: 245/255)
    
    /// Superficie oscura para modo oscuro o áreas de contraste
    static let darkSurface = Color(red: 44/255, green: 44/255, blue: 46/255)
    
    /// Superficie oscura secundaria
    static let darkSurfaceSecondary = Color(red: 54/255, green: 54/255, blue: 56/255)
    
    // MARK: - Text Colors
    
    /// Texto principal
    static let textPrimary = Color.black
    
    /// Texto secundario para labels menos importantes
    static let textSecondary = Color(red: 120/255, green: 120/255, blue: 128/255)
    
    /// Texto para modo oscuro
    static let darkTextPrimary = Color.white
    
    /// Texto secundario para modo oscuro
    static let darkTextSecondary = Color(red: 180/255, green: 180/255, blue: 190/255)
    
    // MARK: - UI Element Colors
    
    /// Color para divisores y bordes
    static let divider = Color(red: 224/255, green: 224/255, blue: 224/255)
    
    /// Gradiente principal para botones y acentos
    static let accentGradient = LinearGradient(
        gradient: Gradient(colors: [logoGreen, logoGreenLight]),
        startPoint: .leading,
        endPoint: .trailing
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
    
    // MARK: - UI Component Aliases
    
    // Botones
    static let primaryButtonBackground = logoGreen
    static let primaryButtonText = Color.white
    static let secondaryButtonBackground = logoGreenLight
    static let secondaryButtonText = logoGreenDark
    
    // Tarjetas
    static let cardBackground = surface
    static let cardBorder = divider
    static let cardShadow = Color.black.opacity(0.04)
    
    // Campos de texto
    static let inputBackground = elevatedSurface
    static let inputBorder = divider
    static let inputText = textPrimary
    static let inputPlaceholder = textSecondary
    
    // Estados de navegación
    static let tabBarActive = logoGreen
    static let tabBarInactive = textSecondary
    static let navigationBarBackground = surface
    
    // MARK: - Card Styles
    
    /// Card style - aplicar a un contenedor con .modifier(PureLifeColors.cardStyle())
    static func cardStyle(cornerRadius: CGFloat = 16) -> some ViewModifier {
        CardStyle(cornerRadius: cornerRadius)
    }
    
    private struct CardStyle: ViewModifier {
        let cornerRadius: CGFloat
        
        func body(content: Content) -> some View {
            content
                .padding(16)
                .background(PureLifeColors.cardBackground)
                .cornerRadius(cornerRadius)
                .shadow(color: PureLifeColors.cardShadow, radius: 5, x: 0, y: 2)
        }
    }
} 