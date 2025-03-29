import SwiftUI

/// Capa de compatibilidad para migrar a los nuevos componentes
/// Usar Components para nuevos desarrollos
struct PureLifeUI {
    // MARK: - Modificadores para tarjetas
    
    /// Crea una tarjeta con estilo estándar de PureLife - más minimalista
    static func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.vertical, 18)
            .padding(.horizontal, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(PureLifeColors.surface)
                    .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
            )
    }
    
    /// Crea una tarjeta con borde sutil
    static func outlinedCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.vertical, 18)
            .padding(.horizontal, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(PureLifeColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                PureLifeColors.divider,
                                lineWidth: 1
                            )
                    )
            )
    }
    
    /// Crea una tarjeta con acento verde
    static func accentedCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.vertical, 18)
            .padding(.horizontal, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(PureLifeColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                PureLifeColors.logoGreen,
                                lineWidth: 2
                            )
                    )
                    .shadow(color: PureLifeColors.logoGreen.opacity(0.1), radius: 8, x: 0, y: 2)
            )
    }
    
    // MARK: - Tipografía
    
    /// Título grande (32pt)
    static func titleLarge(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .lineSpacing(2)
    }
    
    /// Título mediano (24pt)
    static func titleMedium(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .lineSpacing(1)
    }
    
    /// Título pequeño (18pt)
    static func titleSmall(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 18, weight: .bold, design: .rounded))
    }
    
    /// Texto para cuerpo de tamaño grande (16pt)
    static func bodyLarge(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .lineSpacing(4)
    }
    
    /// Texto para cuerpo de tamaño medio (14pt)
    static func bodyMedium(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .lineSpacing(3)
    }
    
    /// Texto para cuerpo de tamaño pequeño (12pt)
    static func bodySmall(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .lineSpacing(2)
    }
    
    /// Etiqueta pequeña (10pt)
    static func label(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .tracking(0.5)
            .textCase(.uppercase)
    }
    
    // MARK: - Iconos y Componentes
    
    /// Icono para estadísticas
    static func statIcon(systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 14))
            .foregroundColor(color)
            .frame(width: 28, height: 28)
            .background(
                Circle()
                    .fill(color.opacity(0.1))
            )
    }
} 