import SwiftUI

// MARK: - Button Variant

enum DNButtonVariant {
    case primary
    case secondary
    case accent

    var backgroundColor: Color {
        switch self {
        case .primary: .dnPrimary
        case .secondary: .dnBackground
        case .accent: .dnAccentPink
        }
    }

    var foregroundColor: Color {
        switch self {
        case .primary: .white
        case .secondary: .dnTextPrimary
        case .accent: .white
        }
    }

    /// Primary CTA: 76pt, Secondary: 56pt
    var height: CGFloat {
        switch self {
        case .primary, .accent: 76
        case .secondary: 56
        }
    }

    /// Primary CTA: 20px bold, Secondary: 16px bold
    var fontSize: CGFloat {
        switch self {
        case .primary, .accent: 20
        case .secondary: 16
        }
    }

    /// Primary CTA: +0.05, Secondary: -0.47
    var tracking: CGFloat {
        switch self {
        case .primary, .accent: 0.05
        case .secondary: -0.47
        }
    }
}

// MARK: - DNButton

struct DNButton: View {
    let title: String
    let variant: DNButtonVariant
    let action: () -> Void

    @State private var isPressed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(
        _ title: String,
        variant: DNButtonVariant = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.action = action
    }

    var body: some View {
        buttonContent
            .animation(reduceMotion ? .none : .dnButtonPress, value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed { isPressed = true }
                    }
                    .onEnded { _ in
                        isPressed = false
                        action()
                    }
            )
            .accessibilityLabel(title)
            .accessibilityAddTraits(.isButton)
    }

    @ViewBuilder
    private var buttonContent: some View {
        let label = Text(title.uppercased())
            .font(.system(size: variant.fontSize, weight: .bold))
            .tracking(variant.tracking)
            .foregroundColor(variant.foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: variant.height)
            .padding(.horizontal, DNSpace.xxl)
            .background(
                RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous)
                    .fill(variant.backgroundColor)
            )

        switch variant {
        case .primary, .accent:
            label.dnNeuCTAButton(cornerRadius: DNRadius.md, isPressed: isPressed)
        case .secondary:
            label.dnNeuButton(cornerRadius: DNRadius.md, isPressed: isPressed)
        }
    }
}
