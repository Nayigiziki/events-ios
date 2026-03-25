import SwiftUI

struct DNTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String?
    var label: String?

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 0) {
            if let icon {
                Image(systemName: icon)
                    .foregroundColor(isFocused ? .dnPrimary : .dnTextTertiary)
                    .font(.system(size: 24, weight: .medium))
                    .frame(width: 24, height: 24)
                    .padding(.leading, 20)
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
            }

            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .semibold))
                .tracking(-0.47)
                .foregroundColor(.dnTextPrimary)
                .focused($isFocused)
                .padding(.leading, icon != nil ? 12 : 56)
                .padding(.trailing, 20)
        }
        .padding(.vertical, 20)
        .frame(height: 64)
        .dnNeuPressed(intensity: .medium, cornerRadius: DNRadius.md)
        .accessibilityLabel(label ?? placeholder)
    }
}
