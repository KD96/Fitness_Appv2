import SwiftUI

/// Sistema de tipografía para la experiencia "PureLife"
enum Typography {
    // MARK: - Font Sizes
    
    enum FontSize {
        /// Texto extra pequeño (10pt)
        static let xs: CGFloat = 10
        
        /// Texto pequeño (12pt)
        static let sm: CGFloat = 12
        
        /// Texto base (14pt)
        static let base: CGFloat = 14
        
        /// Texto mediano (16pt)
        static let md: CGFloat = 16
        
        /// Texto grande (18pt)
        static let lg: CGFloat = 18
        
        /// Título pequeño (20pt)
        static let xl: CGFloat = 20
        
        /// Título mediano (24pt)
        static let xxl: CGFloat = 24
        
        /// Título grande (28pt)
        static let xxxl: CGFloat = 28
        
        /// Título principal (32pt)
        static let xxxxl: CGFloat = 32
    }
    
    // MARK: - Font Weights
    
    enum FontWeight {
        /// Regular (400)
        static let regular = Font.Weight.regular
        
        /// Medium (500)
        static let medium = Font.Weight.medium
        
        /// Semibold (600)
        static let semibold = Font.Weight.semibold
        
        /// Bold (700)
        static let bold = Font.Weight.bold
        
        /// Heavy (800)
        static let heavy = Font.Weight.heavy
    }
    
    // MARK: - Line Heights
    
    enum LineHeight {
        /// Compacto (1.0)
        static let compact: CGFloat = 1.0
        
        /// Estándar (1.2)
        static let standard: CGFloat = 1.2
        
        /// Relajado (1.5)
        static let relaxed: CGFloat = 1.5
        
        /// Espaciado (1.8)
        static let loose: CGFloat = 1.8
    }
    
    // MARK: - Text Styles
    
    /// Fuente de sistema redondeada con tamaño y peso personalizados
    static func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .system(size: size, weight: weight, design: .rounded)
    }
    
    /// Modificador para dar formato a textos largos (párrafos)
    struct ParagraphStyle: ViewModifier {
        let size: CGFloat
        let weight: Font.Weight
        let lineHeight: CGFloat
        let color: Color
        
        func body(content: Content) -> some View {
            content
                .font(.system(size: size, weight: weight, design: .rounded))
                .lineSpacing((lineHeight - 1.0) * size)
                .foregroundColor(color)
        }
    }
    
    // MARK: - Typography Presets
    
    /// Estilo para títulos principales
    static func h1(_ content: some View, color: Color = PureLifeColors.textPrimary) -> some View {
        content
            .font(font(size: FontSize.xxxxl, weight: FontWeight.bold))
            .foregroundColor(color)
    }
    
    /// Estilo para títulos secundarios
    static func h2(_ content: some View, color: Color = PureLifeColors.textPrimary) -> some View {
        content
            .font(font(size: FontSize.xxxl, weight: FontWeight.bold))
            .foregroundColor(color)
    }
    
    /// Estilo para títulos de sección
    static func h3(_ content: some View, color: Color = PureLifeColors.textPrimary) -> some View {
        content
            .font(font(size: FontSize.xxl, weight: FontWeight.bold))
            .foregroundColor(color)
    }
    
    /// Estilo para subtítulos
    static func h4(_ content: some View, color: Color = PureLifeColors.textPrimary) -> some View {
        content
            .font(font(size: FontSize.xl, weight: FontWeight.bold))
            .foregroundColor(color)
    }
    
    /// Estilo para texto de cuerpo grande
    static func bodyLarge(_ content: some View, color: Color = PureLifeColors.textPrimary) -> some View {
        content
            .font(font(size: FontSize.md, weight: FontWeight.medium))
            .foregroundColor(color)
    }
    
    /// Estilo para texto de cuerpo estándar
    static func body(_ content: some View, color: Color = PureLifeColors.textPrimary) -> some View {
        content
            .font(font(size: FontSize.base, weight: FontWeight.regular))
            .foregroundColor(color)
    }
    
    /// Estilo para texto pequeño
    static func small(_ content: some View, color: Color = PureLifeColors.textSecondary) -> some View {
        content
            .font(font(size: FontSize.sm, weight: FontWeight.regular))
            .foregroundColor(color)
    }
    
    /// Estilo para etiquetas y metadatos
    static func caption(_ content: some View, color: Color = PureLifeColors.textSecondary) -> some View {
        content
            .font(font(size: FontSize.xs, weight: FontWeight.medium))
            .foregroundColor(color)
            .textCase(.uppercase)
    }
    
    /// Párrafo con buen espaciado para lectura
    static func paragraph(_ content: some View) -> some View {
        content.modifier(ParagraphStyle(
            size: FontSize.base,
            weight: FontWeight.regular,
            lineHeight: LineHeight.relaxed,
            color: PureLifeColors.textPrimary
        ))
    }
} 