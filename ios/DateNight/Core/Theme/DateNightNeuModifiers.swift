import SwiftUI

// MARK: - Shadow Intensity

enum DNShadowIntensity {
    case light, medium, heavy, extraHeavy

    var offset: CGFloat {
        switch self {
        case .light: 4
        case .medium: 6
        case .heavy: 8
        case .extraHeavy: 12
        }
    }

    var radius: CGFloat {
        switch self {
        case .light: 8
        case .medium: 12
        case .heavy: 16
        case .extraHeavy: 24
        }
    }
}

// MARK: - Raised Modifier

/// Neumorphic raised effect — element appears extruded from the surface.
/// Shadow values calibrated to visually match React CSS box-shadow rendering.
/// CSS uses full-opacity rgb(163,177,198), but SwiftUI shadows bleed more,
/// so we use 0.45 dark / 0.9 light to get the same visual depth.
struct DNNeuRaised: ViewModifier {
    var intensity: DNShadowIntensity = .heavy
    var cornerRadius: CGFloat = DNRadius.lg

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.dnBackground)
            )
            .shadow(
                color: Color(hex: "a3b1c6").opacity(0.45),
                radius: intensity.radius,
                x: intensity.offset,
                y: intensity.offset
            )
            .shadow(
                color: Color.white.opacity(0.9),
                radius: intensity.radius,
                x: -intensity.offset,
                y: -intensity.offset
            )
    }
}

// MARK: - Pressed Modifier

/// Neumorphic pressed/inset effect — element appears pushed into the surface.
/// SwiftUI has no native inset shadow, so we simulate it:
/// - Inner dark shadow (top-left light source casts shadow inside bottom-right)
/// - Inner light shadow (reflected light inside top-left)
/// Uses overlaid shapes with shadows clipped to create the inset illusion.
struct DNNeuPressed: ViewModifier {
    var intensity: DNShadowIntensity = .heavy
    var cornerRadius: CGFloat = DNRadius.lg

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.dnBackground)
            )
            .overlay(
                // Inner shadow simulation
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.dnBackground)
                    .overlay(
                        // Dark inner shadow (bottom-right)
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color(hex: "a3b1c6"), lineWidth: intensity.offset)
                            .blur(radius: intensity.radius / 2)
                            .offset(x: intensity.offset / 2, y: intensity.offset / 2)
                    )
                    .overlay(
                        // Light inner shadow (top-left)
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white, lineWidth: intensity.offset)
                            .blur(radius: intensity.radius / 2)
                            .offset(x: -intensity.offset / 2, y: -intensity.offset / 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .allowsHitTesting(false)
            )
    }
}

// MARK: - Button Modifier

/// Neumorphic button — raised when idle, flat/pressed when tapped.
struct DNNeuButton: ViewModifier {
    var cornerRadius: CGFloat = DNRadius.lg
    var isPressed: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.dnBackground)
            )
            .shadow(
                color: isPressed ? .clear : Color(hex: "a3b1c6").opacity(0.45),
                radius: isPressed ? 0 : 16,
                x: isPressed ? 0 : 8,
                y: isPressed ? 0 : 8
            )
            .shadow(
                color: isPressed ? .clear : Color.white.opacity(0.9),
                radius: isPressed ? 0 : 16,
                x: isPressed ? 0 : -8,
                y: isPressed ? 0 : -8
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
    }
}

// MARK: - View Extensions

extension View {
    func dnNeuRaised(
        intensity: DNShadowIntensity = .heavy,
        cornerRadius: CGFloat = DNRadius.lg
    ) -> some View {
        modifier(DNNeuRaised(intensity: intensity, cornerRadius: cornerRadius))
    }

    func dnNeuPressed(
        intensity: DNShadowIntensity = .heavy,
        cornerRadius: CGFloat = DNRadius.lg
    ) -> some View {
        modifier(DNNeuPressed(intensity: intensity, cornerRadius: cornerRadius))
    }

    func dnNeuButton(
        cornerRadius: CGFloat = DNRadius.lg,
        isPressed: Bool = false
    ) -> some View {
        modifier(DNNeuButton(cornerRadius: cornerRadius, isPressed: isPressed))
    }
}
