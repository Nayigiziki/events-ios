import SwiftUI

struct FilterChip: View {
    let title: String
    @Binding var isActive: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            isActive.toggle()
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isActive ? .dnPrimary : .dnTextSecondary)
                .padding(.horizontal, DNSpace.lg)
                .padding(.vertical, DNSpace.sm)
                .frame(minHeight: 44)
        }
        .buttonStyle(.plain)
        .modifier(ChipStyleModifier(isActive: isActive))
        .animation(reduceMotion ? .none : .dnButtonPress, value: isActive)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }
}

private struct ChipStyleModifier: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        if isActive {
            content.dnNeuPressed(cornerRadius: DNRadius.full)
        } else {
            content.dnNeuRaised(cornerRadius: DNRadius.full)
        }
    }
}
