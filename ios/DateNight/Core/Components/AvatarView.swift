import SwiftUI

struct AvatarView: View {
    let url: URL?
    var size: CGFloat = 40

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                placeholderView
            case .empty:
                placeholderView
            @unknown default:
                placeholderView
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .shadow(
            color: Color(hex: "a3b1c6").opacity(0.15),
            radius: 8,
            x: 4,
            y: 4
        )
        .shadow(
            color: Color.white.opacity(0.8),
            radius: 8,
            x: -4,
            y: -4
        )
    }

    private var placeholderView: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(.dnMuted)
    }
}
