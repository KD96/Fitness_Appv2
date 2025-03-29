import SwiftUI

/// Sistema de espaciado para la experiencia "PureLife"
enum Spacing {
    // MARK: - Basic Spacing Scale
    
    /// Espaciado extra pequeño (4pt)
    static let xxs: CGFloat = 4
    
    /// Espaciado muy pequeño (8pt)
    static let xs: CGFloat = 8
    
    /// Espaciado pequeño (12pt)
    static let sm: CGFloat = 12
    
    /// Espaciado base (16pt)
    static let md: CGFloat = 16
    
    /// Espaciado grande (20pt)
    static let lg: CGFloat = 20
    
    /// Espaciado extra grande (24pt)
    static let xl: CGFloat = 24
    
    /// Espaciado doble grande (32pt)
    static let xxl: CGFloat = 32
    
    /// Espaciado triple grande (40pt)
    static let xxxl: CGFloat = 40
    
    /// Espaciado cuádruple grande (48pt)
    static let xxxxl: CGFloat = 48
    
    // MARK: - Component Specific
    
    /// Espaciado estándar para contenido dentro de tarjetas
    static let cardPadding: CGFloat = md
    
    /// Espaciado horizontal estándar para contenedores de pantalla
    static let screenHorizontalPadding: CGFloat = xl
    
    /// Espaciado vertical estándar para contenedores de pantalla
    static let screenVerticalPadding: CGFloat = lg
    
    /// Espaciado entre elementos de lista
    static let listItemSpacing: CGFloat = sm
    
    /// Espaciado entre secciones
    static let sectionSpacing: CGFloat = xl
    
    /// Radio de esquina estándar para componentes
    static let cornerRadius: CGFloat = 16
    
    /// Radio de esquina para botones
    static let buttonCornerRadius: CGFloat = 16
    
    // MARK: - Helper methods
    
    /// Aplica espaciado horizontal estándar a una vista
    static func horizontalPadding<Content: View>(_ content: Content) -> some View {
        content.padding(.horizontal, screenHorizontalPadding)
    }
    
    /// Aplica espaciado de tarjeta estándar a una vista
    static func cardPadding<Content: View>(_ content: Content) -> some View {
        content.padding(cardPadding)
    }
    
    /// Crea un Spacer vertical con altura definida
    static func vSpacer(height: CGFloat) -> some View {
        Spacer()
            .frame(height: height)
    }
    
    /// Crea un Spacer horizontal con ancho definido
    static func hSpacer(width: CGFloat) -> some View {
        Spacer()
            .frame(width: width)
    }
}

// MARK: - View Extensions

extension View {
    /// Aplica el espaciado horizontal estándar de pantalla
    func standardHorizontalPadding() -> some View {
        self.padding(.horizontal, Spacing.screenHorizontalPadding)
    }
    
    /// Aplica el espaciado para tarjetas
    func cardPadding() -> some View {
        self.padding(Spacing.cardPadding)
    }
    
    /// Aplica espaciado entre secciones
    func sectionSpacing() -> some View {
        self.padding(.vertical, Spacing.sectionSpacing)
    }
    
    /// Aplica el radio de esquina estándar
    func standardCornerRadius() -> some View {
        self.cornerRadius(Spacing.cornerRadius)
    }
} 