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

    var darkOpacity: Double { 0.15 }
    var lightOpacity: Double { 0.8 }
}

// MARK: - Raised Modifier

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
                color: Color(hex: "a3b1c6").opacity(intensity.darkOpacity),
                radius: intensity.radius,
                x: intensity.offset,
                y: intensity.offset
            )
            .shadow(
                color: Color.white.opacity(intensity.lightOpacity),
                radius: intensity.radius,
                x: -intensity.offset,
                y: -intensity.offset
            )
    }
}

// MARK: - Pressed Modifier

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
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color(hex: "a3b1c6").opacity(0.3), lineWidth: 1)
            )
            .shadow(
                color: Color(hex: "a3b1c6").opacity(intensity.darkOpacity),
                radius: intensity.radius / 2,
                x: intensity.offset / 2,
                y: intensity.offset / 2
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(
                color: Color.white.opacity(intensity.lightOpacity),
                radius: intensity.radius / 2,
                x: -intensity.offset / 2,
                y: -intensity.offset / 2
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// MARK: - Button Modifier

struct DNNeuButton: ViewModifier {
    var cornerRadius: CGFloat = DNRadius.lg
    var isPressed: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if isPressed {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.dnBackground)
                    } else {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.dnBackground)
                    }
                }
            )
            .shadow(
                color: isPressed ? .clear : Color(hex: "a3b1c6").opacity(0.15),
                radius: isPressed ? 0 : 16,
                x: isPressed ? 0 : 8,
                y: isPressed ? 0 : 8
            )
            .shadow(
                color: isPressed ? .clear : Color.white.opacity(0.8),
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
