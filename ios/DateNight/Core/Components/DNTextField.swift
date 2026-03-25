import SwiftUI

struct DNTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String?
    var label: String?

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: DNSpace.sm) {
            if let icon {
                Image(systemName: icon)
                    .foregroundColor(isFocused ? .dnPrimary : .dnTextTertiary)
                    .font(.system(size: 16, weight: .medium))
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
            }

            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.dnTextPrimary)
                .focused($isFocused)
        }
        .padding(.horizontal, DNSpace.lg)
        .frame(minHeight: 44)
        .dnNeuPressed(cornerRadius: DNRadius.md)
        .accessibilityLabel(label ?? placeholder)
    }
}
