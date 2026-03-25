import SwiftUI

// MARK: - Shadow Intensity

enum DNShadowIntensity {
    case light, medium, heavy, extraHeavy

    var offset: CGFloat {
        switch self {
        case .light: 4
        case .medium: 6
        case .heavy: 6
        case .extraHeavy: 12
        }
    }

    var radius: CGFloat {
        switch self {
        case .light: 8
        case .medium: 12
        case .heavy: 12
        case .extraHeavy: 24
        }
    }
}

// MARK: - Raised Modifier

/// Neumorphic raised effect — element appears extruded from the surface.
/// Figma: box-shadow: 6px 6px 12px #a3b1c6, -6px -6px 12px white
/// SwiftUI shadows bleed more than CSS — calibrated to 0.50 dark / 0.95 light.
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
                color: Color(hex: "a3b1c6").opacity(0.50),
                radius: intensity.radius,
                x: intensity.offset,
                y: intensity.offset
            )
            .shadow(
                color: Color.white.opacity(0.95),
                radius: intensity.radius,
                x: -intensity.offset,
                y: -intensity.offset
            )
    }
}

// MARK: - Pressed Modifier

/// Neumorphic pressed/inset effect — element appears pushed into the surface.
/// Figma medium inset: inset 6px 6px 12px #a3b1c6, inset -6px -6px 12px white
/// Figma light inset: inset 4px 4px 8px #a3b1c6, inset -4px -4px 8px white
struct DNNeuPressed: ViewModifier {
    var intensity: DNShadowIntensity = .medium
    var cornerRadius: CGFloat = DNRadius.lg

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.dnBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.clear)
                    .overlay(
                        // Dark inner shadow (bottom-right) — #a3b1c6
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color(hex: "a3b1c6").opacity(0.60), lineWidth: intensity.offset * 1.5)
                            .blur(radius: intensity.radius * 0.6)
                            .offset(x: intensity.offset * 0.75, y: intensity.offset * 0.75)
                    )
                    .overlay(
                        // Light inner shadow (top-left) — white
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.90), lineWidth: intensity.offset * 1.5)
                            .blur(radius: intensity.radius * 0.6)
                            .offset(x: -intensity.offset * 0.75, y: -intensity.offset * 0.75)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .allowsHitTesting(false)
            )
    }
}

// MARK: - CTA Button Modifier

/// Primary CTA button shadow — NOT standard neumorphic.
/// Figma: box-shadow: 8px 8px 16px rgba(0,0,0,0.2), -2px -2px 8px rgba(255,255,255,0.1)
/// Uses black-based shadow instead of #a3b1c6.
struct DNNeuCTAButton: ViewModifier {
    var cornerRadius: CGFloat = DNRadius.md
    var isPressed: Bool = false

    func body(content: Content) -> some View {
        content
            .shadow(
                color: isPressed ? .clear : Color.black.opacity(0.20),
                radius: isPressed ? 0 : 16,
                x: isPressed ? 0 : 8,
                y: isPressed ? 0 : 8
            )
            .shadow(
                color: isPressed ? .clear : Color.white.opacity(0.10),
                radius: isPressed ? 0 : 8,
                x: isPressed ? 0 : -2,
                y: isPressed ? 0 : -2
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
    }
}

// MARK: - Button Modifier (Legacy — wraps CTA for backward compat)

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
                color: isPressed ? .clear : Color(hex: "a3b1c6").opacity(0.50),
                radius: isPressed ? 0 : 12,
                x: isPressed ? 0 : 6,
                y: isPressed ? 0 : 6
            )
            .shadow(
                color: isPressed ? .clear : Color.white.opacity(0.95),
                radius: isPressed ? 0 : 12,
                x: isPressed ? 0 : -6,
                y: isPressed ? 0 : -6
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
        intensity: DNShadowIntensity = .medium,
        cornerRadius: CGFloat = DNRadius.lg
    ) -> some View {
        modifier(DNNeuPressed(intensity: intensity, cornerRadius: cornerRadius))
    }

    func dnNeuCTAButton(
        cornerRadius: CGFloat = DNRadius.md,
        isPressed: Bool = false
    ) -> some View {
        modifier(DNNeuCTAButton(cornerRadius: cornerRadius, isPressed: isPressed))
    }

    func dnNeuButton(
        cornerRadius: CGFloat = DNRadius.md,
        isPressed: Bool = false
    ) -> some View {
        modifier(DNNeuButton(cornerRadius: cornerRadius, isPressed: isPressed))
    }
}
