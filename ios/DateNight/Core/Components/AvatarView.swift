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
        .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
    }

    private var placeholderView: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(.dnMuted)
    }
}
