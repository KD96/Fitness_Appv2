import SwiftUI

/// Sistema de colores para la experiencia "PureLife"
struct PureLifeColors {
    // MARK: - Colores de fondo
    
    /// Color de fondo principal
    static let background = Color(red: 252/255, green: 252/255, blue: 252/255)
    
    /// Color de fondo oscuro para secciones de contraste
    static let darkBackground = Color(red: 28/255, green: 28/255, blue: 30/255)
    
    /// Color del logo - verde menta claro
    static let logoGreen = Color(red: 199/255, green: 227/255, blue: 214/255)
    
    /// Color de superficie, usado para tarjetas y elementos elevados
    static let surface = Color.white
    
    /// Color de superficie cuando se necesita un fondo más oscuro
    static let darkSurface = Color(red: 40/255, green: 42/255, blue: 46/255)
    
    /// Color de superficie secundaria, un tono suave del verde del logo
    static let secondarySurface = Color(red: 245/255, green: 250/255, blue: 248/255)
    
    /// Color para elementos que necesitan un poco más de contraste
    static let elevatedSurface = Color(red: 245/255, green: 245/255, blue: 245/255)
    
    // MARK: - Colores de acento
    
    /// Color principal verde de PureLife - más cercano al verde del logo
    static let pureGreen = Color(red: 170/255, green: 220/255, blue: 200/255)
    
    /// Variante más oscura del verde principal
    static let pureGreenDark = Color(red: 130/255, green: 195/255, blue: 170/255)
    
    /// Variante más clara del verde principal (más cercana al logo)
    static let pureGreenLight = Color(red: 199/255, green: 227/255, blue: 214/255)
    
    // MARK: - Colores para estado
    
    /// Color para éxito o confirmación
    static let success = Color(red: 82/255, green: 196/255, blue: 109/255)
    
    /// Color para advertencias
    static let warning = Color(red: 255/255, green: 159/255, blue: 10/255)
    
    /// Color para errores
    static let error = Color(red: 235/255, green: 80/255, blue: 70/255)
    
    // MARK: - Colores para texto
    
    /// Texto principal, negro con alta legibilidad
    static let textPrimary = Color(red: 30/255, green: 30/255, blue: 30/255)
    
    /// Texto secundario
    static let textSecondary = Color(red: 90/255, green: 90/255, blue: 95/255)
    
    /// Texto terciario, para elementos menos importantes
    static let textTertiary = Color(red: 150/255, green: 150/255, blue: 155/255)
    
    /// Color para texto sobre fondos oscuros
    static let textOnDark = Color.white
    
    /// Color para divisores
    static let divider = Color(red: 240/255, green: 240/255, blue: 240/255)
    
    // MARK: - Gradientes
    
    /// Gradiente principal de acento - más sutil
    static let accentGradient = LinearGradient(
        gradient: Gradient(colors: [pureGreenLight, pureGreen]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Gradiente para tarjetas premium
    static let premiumGradient = LinearGradient(
        gradient: Gradient(colors: [
            pureGreenLight,
            pureGreen.opacity(0.9)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

/// Componentes UI para el sistema de diseño "PureLife"
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
                                PureLifeColors.pureGreenLight,
                                lineWidth: 2
                            )
                    )
                    .shadow(color: PureLifeColors.pureGreenLight.opacity(0.1), radius: 8, x: 0, y: 2)
            )
    }
    
    // MARK: - Botones
    
    /// Estilo para botón principal - más minimalista
    static func primaryButton<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .foregroundColor(PureLifeColors.textPrimary)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(PureLifeColors.pureGreenLight)
            .cornerRadius(12)
    }
    
    /// Estilo para botón secundario - más minimalista
    static func secondaryButton<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .foregroundColor(PureLifeColors.pureGreenDark)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(PureLifeColors.secondarySurface)
            .cornerRadius(12)
    }
    
    /// Estilo para botón sutil
    static func subtleButton<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .foregroundColor(PureLifeColors.textSecondary)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(PureLifeColors.elevatedSurface)
            .cornerRadius(8)
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
    
    /// Barra de progreso
    static func progressBar(value: Double, color: Color = PureLifeColors.pureGreen) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Fondo
                Capsule()
                    .fill(PureLifeColors.elevatedSurface)
                    .frame(height: 6)
                
                // Progreso
                Capsule()
                    .fill(color)
                    .frame(width: min(CGFloat(value) * geometry.size.width, geometry.size.width), height: 6)
            }
        }
        .frame(height: 6)
    }
} 