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
                    .foregroundColor(isActive ? .dnPrimary : .dnTextSecondary)

                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(isActive ? .dnPrimary : .dnTextSecondary)
            }
            .frame(minWidth: 44, minHeight: 44)
            .scaleEffect(isActive ? 1.05 : 1.0)
            .animation(reduceMotion ? .none : .dnTabSwitch, value: isActive)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(.isButton)
    }
}
