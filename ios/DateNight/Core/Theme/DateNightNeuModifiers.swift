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
/// CSS uses full-opacity rgb(163,177,198), but SwiftUI shadows bleed more
/// outward, so we reduce opacity to 0.40 dark / 0.85 light for visual parity.
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
                color: Color(hex: "a3b1c6").opacity(0.40),
                radius: intensity.radius,
                x: intensity.offset,
                y: intensity.offset
            )
            .shadow(
                color: Color.white.opacity(0.85),
                radius: intensity.radius,
                x: -intensity.offset,
                y: -intensity.offset
            )
    }
}

// MARK: - Pressed Modifier

/// Neumorphic pressed/inset effect — element appears pushed into the surface.
/// SwiftUI has no native inset shadow, so we simulate it with overlaid strokes
/// blurred and clipped. Matches React CSS: inset 4px 4px 8px rgb(163,177,198).
struct DNNeuPressed: ViewModifier {
    var intensity: DNShadowIntensity = .light
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
                    .fill(Color.clear)
                    .overlay(
                        // Dark inner shadow (bottom-right)
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color(hex: "a3b1c6").opacity(0.50), lineWidth: intensity.offset)
                            .blur(radius: intensity.radius / 2)
                            .offset(x: intensity.offset / 2, y: intensity.offset / 2)
                    )
                    .overlay(
                        // Light inner shadow (top-left)
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.70), lineWidth: intensity.offset)
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
    var cornerRadius: CGFloat = DNRadius.md
    var isPressed: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.dnBackground)
            )
            .shadow(
                color: isPressed ? .clear : Color(hex: "a3b1c6").opacity(0.40),
                radius: isPressed ? 0 : 16,
                x: isPressed ? 0 : 8,
                y: isPressed ? 0 : 8
            )
            .shadow(
                color: isPressed ? .clear : Color.white.opacity(0.85),
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
        intensity: DNShadowIntensity = .light,
        cornerRadius: CGFloat = DNRadius.lg
    ) -> some View {
        modifier(DNNeuPressed(intensity: intensity, cornerRadius: cornerRadius))
    }

    func dnNeuButton(
        cornerRadius: CGFloat = DNRadius.md,
        isPressed: Bool = false
    ) -> some View {
        modifier(DNNeuButton(cornerRadius: cornerRadius, isPressed: isPressed))
    }
}
