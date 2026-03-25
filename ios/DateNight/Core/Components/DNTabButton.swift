import SwiftUI

struct DNTabButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            VStack(spacing: DNSpace.xs) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isActive ? .white : .dnTextSecondary)

                Text(label.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.5)
                    .foregroundColor(isActive ? .white : .dnTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(minWidth: 44, minHeight: 44)
            .padding(.horizontal, DNSpace.sm)
            .padding(.vertical, DNSpace.xs)
        }
        .buttonStyle(.plain)
        .modifier(TabButtonStyleModifier(isActive: isActive))
        .animation(reduceMotion ? .none : .dnTabSwitch, value: isActive)
        .accessibilityLabel(label)
        .accessibilityAddTraits(.isButton)
    }
}

/// Active tab: purple bg with inset shadow (light intensity — 4px 4px 8px)
/// Inactive tab: standard neumorphic raised
private struct TabButtonStyleModifier: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        if isActive {
            content
                .background(
                    RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous)
                        .fill(Color.dnPrimary)
                )
                .dnNeuPressed(intensity: .light, cornerRadius: DNRadius.md)
        } else {
            content.dnNeuRaised(intensity: .light, cornerRadius: DNRadius.md)
        }
    }
}
