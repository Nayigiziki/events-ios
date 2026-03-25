import SwiftUI

struct DNLikeButton: View {
    let isLiked: Bool
    let action: () -> Void
    var size: CGFloat = 48

    var body: some View {
        Button(action: action) {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .font(.system(size: size * 0.42, weight: .bold))
                .foregroundColor(isLiked ? .white : .dnAccentPink)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(isLiked ? Color.dnAccentPink : Color.dnBackground)
                )
        }
        .buttonStyle(.plain)
        .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
        .animation(.dnButtonPress, value: isLiked)
    }
}
