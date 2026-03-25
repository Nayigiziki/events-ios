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
        Text(title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(variant.foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .padding(.horizontal, DNSpace.lg)
            .background(
                RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous)
                    .fill(variant.backgroundColor)
            )
            .dnNeuButton(cornerRadius: DNRadius.md, isPressed: isPressed)
            .scaleEffect(isPressed ? 0.98 : 1.0)
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
}
