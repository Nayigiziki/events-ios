import SwiftUI

struct DNCategoryBadge: View {
    let category: String

    var body: some View {
        Text(category.uppercased())
            .font(.system(size: 11, weight: .heavy))
            .tracking(0.8)
            .foregroundColor(.white)
            .padding(.horizontal, DNSpace.lg)
            .padding(.vertical, DNSpace.sm)
            .background(
                Capsule()
                    .fill(color(for: category))
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 2)
            )
    }

    private func color(for category: String) -> Color {
        switch category {
        case "Music": .dnPrimary
        case "Art": .dnAccentPink
        case "Comedy": .dnWarning
        case "Food": .dnSuccess
        case "Wellness": .dnInfo
        case "Wine": .dnDestructive
        case "Social": .dnInfo
        default: .dnPrimary
        }
    }
}
