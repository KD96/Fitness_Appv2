import SwiftUI

// Extensiones para View
extension View {
    // Función que permite aplicar cornerRadius solo a ciertas esquinas
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorners(radius: radius, corners: corners))
    }
    
    // Apply responsive horizontal padding that adjusts to screen size
    func responsivePadding() -> some View {
        self.padding(.horizontal, UIScreen.main.bounds.width < 375 ? 16 : 20)
    }
    
    // Apply a press action modifier that detects when a view is pressed/released
    func pressAction(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(PressActionModifier(onPress: onPress, onRelease: onRelease))
    }
    
    // Apply adaptive padding that scales with device size
    func adaptivePadding(_ edges: Edge.Set = .all, _ size: CGFloat = 20) -> some View {
        let scaleFactor = UIScreen.main.bounds.width / 390 // Base device width (iPhone 13/14)
        let scaledPadding = size * min(max(scaleFactor, 0.8), 1.2) // Limit scaling between 80-120%
        
        return self.padding(edges, scaledPadding)
    }
    
    // Apply conditional modifier based on condition
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    // Create snapshot of view with proper afterScreenUpdates parameter
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

// Forma para crear esquinas redondeadas personalizadas
struct RoundedCorners: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// Modifier that detects press and release gestures
struct PressActionModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            onPress()
                        }
                    }
                    .onEnded { _ in
                        if isPressed {
                            isPressed = false
                            onRelease()
                        }
                    }
            )
            .onDisappear {
                // Make sure to release if view disappears while pressed
                if isPressed {
                    isPressed = false
                    onRelease()
                }
            }
    }
} 