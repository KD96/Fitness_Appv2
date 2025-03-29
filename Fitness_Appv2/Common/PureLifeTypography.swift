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
        
        /// Título hero (40pt)
        static let xxxxxl: CGFloat = 40
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
    
    // MARK: - Letter Spacing
    
    enum LetterSpacing {
        /// Apretado (-0.5)
        static let tight: CGFloat = -0.5
        
        /// Normal (0)
        static let normal: CGFloat = 0
        
        /// Ligeramente expandido (0.5)
        static let wide: CGFloat = 0.5
        
        /// Expandido para títulos y etiquetas (1.0)
        static let expanded: CGFloat = 1.0
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
        let tracking: CGFloat
        
        init(
            size: CGFloat,
            weight: Font.Weight = .regular,
            lineHeight: CGFloat = LineHeight.relaxed,
            color: Color = PureLifeColors.textPrimary,
            tracking: CGFloat = LetterSpacing.normal
        ) {
            self.size = size
            self.weight = weight
            self.lineHeight = lineHeight
            self.color = color
            self.tracking = tracking
        }
        
        func body(content: Content) -> some View {
            content
                .font(.system(size: size, weight: weight, design: .rounded))
                .lineSpacing((lineHeight - 1.0) * size)
                .tracking(tracking)
                .foregroundColor(color)
        }
    }
    
    // MARK: - Modern Typography Presets
    
    /// Título hero para pantallas principales
    static func hero(_ content: some View, color: Color = PureLifeColors.textPrimary) -> some View {
        content
            .font(font(size: FontSize.xxxxxl, weight: FontWeight.bold))
            .tracking(LetterSpacing.tight)
            .foregroundColor(color)
    }
    
    /// Título principal grande 
    static func h1(_ content: some View, color: Color = PureLifeColors.textPrimary) -> some View {
        content
            .font(font(size: FontSize.xxxxl, weight: FontWeight.bold))
            .tracking(LetterSpacing.tight)
            .foregroundColor(color)
    }
    
    /// Título secundario
    static func h2(_ content: some View, color: Color = PureLifeColors.textPrimary) -> some View {
        content
            .font(font(size: FontSize.xxxl, weight: FontWeight.bold))
            .tracking(LetterSpacing.tight)
            .foregroundColor(color)
    }
    
    /// Título de sección
    static func h3(_ content: some View, color: Color = PureLifeColors.textPrimary) -> some View {
        content
            .font(font(size: FontSize.xxl, weight: FontWeight.bold))
            .tracking(LetterSpacing.tight)
            .foregroundColor(color)
    }
    
    /// Título para tarjetas y subsecciones
    static func h4(_ content: some View, color: Color = PureLifeColors.textPrimary) -> some View {
        content
            .font(font(size: FontSize.xl, weight: FontWeight.semibold))
            .tracking(LetterSpacing.normal)
            .foregroundColor(color)
    }
    
    /// Título para elementos pequeños
    static func h5(_ content: some View, color: Color = PureLifeColors.textPrimary) -> some View {
        content
            .font(font(size: FontSize.lg, weight: FontWeight.semibold))
            .tracking(LetterSpacing.normal)
            .foregroundColor(color)
    }
    
    /// Texto de cuerpo grande (enfatizado)
    static func bodyLarge(_ content: some View, color: Color = PureLifeColors.textPrimary) -> some View {
        content
            .font(font(size: FontSize.md, weight: FontWeight.medium))
            .tracking(LetterSpacing.normal)
            .foregroundColor(color)
    }
    
    /// Texto de cuerpo estándar
    static func body(_ content: some View, color: Color = PureLifeColors.textPrimary) -> some View {
        content
            .font(font(size: FontSize.base, weight: FontWeight.regular))
            .tracking(LetterSpacing.normal)
            .foregroundColor(color)
    }
    
    /// Texto pequeño para información secundaria
    static func small(_ content: some View, color: Color = PureLifeColors.textSecondary) -> some View {
        content
            .font(font(size: FontSize.sm, weight: FontWeight.regular))
            .tracking(LetterSpacing.normal)
            .foregroundColor(color)
    }
    
    /// Texto para etiquetas y metadatos (todo en mayúsculas)
    static func caption(_ content: some View, color: Color = PureLifeColors.textSecondary) -> some View {
        content
            .font(font(size: FontSize.xs, weight: FontWeight.medium))
            .tracking(LetterSpacing.expanded)
            .foregroundColor(color)
            .textCase(.uppercase)
    }
    
    /// Texto destacado con acento visual
    static func highlight(_ content: some View) -> some View {
        content
            .font(font(size: FontSize.base, weight: FontWeight.semibold))
            .foregroundColor(PureLifeColors.logoGreen)
    }
    
    /// Párrafo con buen espaciado para lecturas largas
    static func paragraph(_ content: some View, color: Color = PureLifeColors.textPrimary) -> some View {
        content.modifier(ParagraphStyle(
            size: FontSize.base,
            weight: FontWeight.regular,
            lineHeight: LineHeight.relaxed,
            color: color
        ))
    }
    
    // MARK: - Botones y elementos interactivos
    
    /// Estilo para botones principales
    static func primaryButton(_ content: some View) -> some View {
        content
            .font(font(size: FontSize.md, weight: FontWeight.semibold))
            .tracking(LetterSpacing.wide)
    }
    
    /// Estilo para botones secundarios
    static func secondaryButton(_ content: some View) -> some View {
        content
            .font(font(size: FontSize.md, weight: FontWeight.medium))
            .tracking(LetterSpacing.wide)
    }
    
    /// Etiqueta para elementos interactivos
    static func actionLabel(_ content: some View, color: Color = PureLifeColors.logoGreen) -> some View {
        content
            .font(font(size: FontSize.sm, weight: FontWeight.semibold))
            .tracking(LetterSpacing.normal)
            .foregroundColor(color)
    }
    
    // MARK: - Adaptative Typography
    
    /// Texto adaptativo que cambia según el modo claro/oscuro
    static func adaptiveText(_ content: some View, lightColor: Color, darkColor: Color, scheme: ColorScheme) -> some View {
        content
            .foregroundColor(
                scheme == .dark ? darkColor : lightColor
            )
    }
} 