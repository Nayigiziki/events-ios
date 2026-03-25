import SwiftUI

struct StatusBadge: View {
    let status: String

    private var backgroundColor: Color {
        switch status.lowercased() {
        case "open": .dnSuccess
        case "full": .dnWarning
        case "confirmed": .dnPrimary
        default: .dnMuted
        }
    }

    var body: some View {
        Text(status)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(backgroundColor)
            )
    }
}
