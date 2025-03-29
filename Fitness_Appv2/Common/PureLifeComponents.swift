import SwiftUI

/// Componentes de UI reutilizables para la experiencia "PureLife"
struct Components {
    // MARK: - Buttons
    
    /// Botón principal con estilo de acción primaria
    struct PrimaryButton: View {
        let text: String
        let action: () -> Void
        var iconName: String? = nil
        var isLoading: Bool = false
        var isDisabled: Bool = false
        
        var body: some View {
            Button(action: isDisabled ? {} : action) {
                HStack(spacing: Spacing.xs) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: PureLifeColors.primaryButtonText))
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
                    isDisabled 
                    ? PureLifeColors.primaryButtonBackground.opacity(0.5)
                    : PureLifeColors.primaryButtonBackground
                )
                .foregroundColor(PureLifeColors.primaryButtonText)
                .cornerRadius(Spacing.buttonCornerRadius)
            }
            .disabled(isDisabled || isLoading)
        }
    }
    
    /// Botón secundario con estilo menos prominente
    struct SecondaryButton: View {
        let text: String
        let action: () -> Void
        var iconName: String? = nil
        var isLoading: Bool = false
        var isDisabled: Bool = false
        
        var body: some View {
            Button(action: isDisabled ? {} : action) {
                HStack(spacing: Spacing.xs) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: PureLifeColors.secondaryButtonText))
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
                .background(
                    isDisabled 
                    ? PureLifeColors.secondaryButtonBackground.opacity(0.5)
                    : PureLifeColors.secondaryButtonBackground
                )
                .foregroundColor(
                    isDisabled 
                    ? PureLifeColors.secondaryButtonText.opacity(0.5)
                    : PureLifeColors.secondaryButtonText
                )
                .cornerRadius(Spacing.buttonCornerRadius)
            }
            .disabled(isDisabled || isLoading)
        }
    }
    
    /// Botón de icono circular
    struct IconButton: View {
        let iconName: String
        let action: () -> Void
        var iconColor: Color = PureLifeColors.logoGreen
        var backgroundColor: Color = PureLifeColors.logoGreenLight.opacity(0.3)
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
    
    // MARK: - Cards
    
    /// Tarjeta estándar con título y contenido
    struct Card<Content: View>: View {
        let title: String
        let content: Content
        var icon: String? = nil
        var cornerRadius: CGFloat = Spacing.cornerRadius
        
        init(title: String, icon: String? = nil, cornerRadius: CGFloat = Spacing.cornerRadius, @ViewBuilder content: () -> Content) {
            self.title = title
            self.icon = icon
            self.cornerRadius = cornerRadius
            self.content = content()
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                // Header
                HStack(spacing: Spacing.xs) {
                    if let iconName = icon {
                        Image(systemName: iconName)
                            .font(.system(size: Typography.FontSize.md))
                            .foregroundColor(PureLifeColors.logoGreen)
                    }
                    
                    Text(title)
                        .font(.system(size: Typography.FontSize.lg, weight: .bold, design: .rounded))
                        .foregroundColor(PureLifeColors.textPrimary)
                }
                
                // Contenido
                content
            }
            .padding(Spacing.cardPadding)
            .background(PureLifeColors.cardBackground)
            .cornerRadius(cornerRadius)
            .shadow(color: PureLifeColors.cardShadow, radius: 5, x: 0, y: 2)
        }
    }
    
    // MARK: - Input Fields
    
    /// Campo de texto con estilo consistente
    struct TextField: View {
        let placeholder: String
        @Binding var text: String
        var icon: String? = nil
        var keyboardType: UIKeyboardType = .default
        var isSecure: Bool = false
        var errorMessage: String? = nil
        var onSubmit: (() -> Void)? = nil
        
        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                HStack(spacing: Spacing.xs) {
                    if let iconName = icon {
                        Image(systemName: iconName)
                            .foregroundColor(PureLifeColors.textSecondary)
                            .frame(width: 24)
                    }
                    
                    if isSecure {
                        SecureField(placeholder, text: $text)
                            .foregroundColor(PureLifeColors.inputText)
                    } else {
                        SwiftUI.TextField(placeholder, text: $text)
                            .foregroundColor(PureLifeColors.inputText)
                            .keyboardType(keyboardType)
                    }
                }
                .padding(Spacing.sm)
                .background(PureLifeColors.inputBackground)
                .cornerRadius(Spacing.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.cornerRadius)
                        .strokeBorder(
                            errorMessage != nil ? PureLifeColors.error : PureLifeColors.inputBorder,
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
    
    /// Avatar de usuario con iniciales
    struct UserAvatar: View {
        let initials: String
        var size: CGFloat = 40
        var fontSize: CGFloat = 16
        
        var body: some View {
            ZStack {
                Circle()
                    .fill(PureLifeColors.logoGreenLight.opacity(0.2))
                    .frame(width: size, height: size)
                
                Text(initials)
                    .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                    .foregroundColor(PureLifeColors.logoGreenDark)
            }
        }
    }
    
    /// Indicador de estado de carga
    struct LoadingIndicator: View {
        var message: String = "Cargando..."
        var color: Color = PureLifeColors.logoGreen
        
        var body: some View {
            VStack(spacing: Spacing.sm) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: color))
                    .scaleEffect(1.2)
                
                Text(message)
                    .font(.system(size: Typography.FontSize.sm, weight: .medium, design: .rounded))
                    .foregroundColor(PureLifeColors.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.05))
        }
    }
    
    // MARK: - Data Visualization
    
    /// Barra de progreso
    struct ProgressBar: View {
        let value: Double
        var backgroundColor: Color = PureLifeColors.elevatedSurface
        var foregroundColor: Color = PureLifeColors.logoGreen
        var height: CGFloat = 8
        
        var body: some View {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(backgroundColor)
                        .cornerRadius(height / 2)
                    
                    Rectangle()
                        .fill(foregroundColor)
                        .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width))
                        .cornerRadius(height / 2)
                }
            }
            .frame(height: height)
        }
    }
    
    /// Tarjeta de estadística con icono, valor y etiqueta
    struct StatCard: View {
        let icon: String
        let title: String
        let value: String
        var trend: String? = nil
        var trendLabel: String? = nil
        var iconColor: Color = PureLifeColors.logoGreen
        
        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                // Icono y título
                HStack(spacing: Spacing.xs) {
                    Image(systemName: icon)
                        .font(.system(size: Typography.FontSize.md))
                        .foregroundColor(iconColor)
                        .frame(width: 32, height: 32)
                        .background(iconColor.opacity(0.1))
                        .cornerRadius(8)
                    
                    Text(title)
                        .font(.system(size: Typography.FontSize.base, weight: .medium, design: .rounded))
                        .foregroundColor(PureLifeColors.textSecondary)
                }
                
                // Valor principal
                Text(value)
                    .font(.system(size: Typography.FontSize.xxl, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.textPrimary)
                
                // Tendencia
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
                            .foregroundColor(PureLifeColors.textSecondary)
                    }
                }
            }
            .padding(Spacing.md)
            .background(PureLifeColors.cardBackground)
            .cornerRadius(Spacing.cornerRadius)
            .shadow(color: PureLifeColors.cardShadow, radius: 5, x: 0, y: 2)
        }
    }
    
    // MARK: - Empty States
    
    /// Vista para estados vacíos con icono y mensajes
    struct EmptyState: View {
        let icon: String
        let title: String
        let message: String
        var action: (() -> Void)? = nil
        var actionTitle: String = "Acción"
        
        var body: some View {
            VStack(spacing: Spacing.lg) {
                Spacer()
                
                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundColor(PureLifeColors.logoGreenLight)
                    .padding(Spacing.md)
                
                Text(title)
                    .font(.system(size: Typography.FontSize.xl, weight: .bold, design: .rounded))
                    .foregroundColor(PureLifeColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(.system(size: Typography.FontSize.base, design: .rounded))
                    .foregroundColor(PureLifeColors.textSecondary)
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
    
    /// Banner de información o notificación
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
        
        var body: some View {
            HStack(alignment: .top, spacing: Spacing.sm) {
                Image(systemName: type.icon)
                    .foregroundColor(type.color)
                    .font(.system(size: Typography.FontSize.lg))
                
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(title)
                        .font(.system(size: Typography.FontSize.base, weight: .bold, design: .rounded))
                        .foregroundColor(PureLifeColors.textPrimary)
                    
                    if let message = message {
                        Text(message)
                            .font(.system(size: Typography.FontSize.sm, design: .rounded))
                            .foregroundColor(PureLifeColors.textSecondary)
                    }
                }
                
                Spacer()
                
                if let onDismiss = onDismiss {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: Typography.FontSize.md))
                            .foregroundColor(PureLifeColors.textSecondary)
                    }
                }
            }
            .padding(Spacing.md)
            .background(type.color.opacity(0.1))
            .cornerRadius(Spacing.cornerRadius)
        }
    }
} 