import SwiftUI

struct DNInfoPill: View {
    let icon: String
    let text: String
    var iconColor: Color = .dnPrimary

    var body: some View {
        HStack(spacing: DNSpace.md) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(iconColor)
            Text(text)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.dnTextPrimary)
        }
        .padding(DNSpace.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .dnNeuPressed(cornerRadius: DNRadius.md)
    }
}
