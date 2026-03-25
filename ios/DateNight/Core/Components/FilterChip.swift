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
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(isActive ? .white : .dnTextSecondary)
                .padding(.horizontal, DNSpace.xl)
                .padding(.vertical, DNSpace.md)
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
            content
                .background(
                    RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous)
                        .fill(Color.dnPrimary)
                )
                .dnNeuPressed(cornerRadius: DNRadius.md)
        } else {
            content.dnNeuRaised(intensity: .heavy, cornerRadius: DNRadius.md)
        }
    }
}
