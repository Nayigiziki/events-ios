import SwiftUI

struct SwipeCardView: View {
    let user: UserProfile
    var isTopCard: Bool = true
    var onSwipeLeft: (() -> Void)?
    var onSwipeRight: (() -> Void)?

    @State private var offset: CGSize = .zero
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var likeOpacity: Double {
        max(0, Double(offset.width) / 150.0)
    }

    private var passOpacity: Double {
        max(0, Double(-offset.width) / 150.0)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Photo
                AsyncImage(url: URL(string: user.photos.first ?? user.avatarUrl ?? "")) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        photoPlaceholder
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.dnMuted)
                    @unknown default:
                        photoPlaceholder
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()

                // Gradient overlay
                GradientOverlay(opacity: 0.7)

                // Like indicator
                Circle()
                    .fill(Color.dnSuccess.opacity(0.9))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "heart.fill")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .opacity(likeOpacity)
                    .position(x: geometry.size.width - 60, y: 60)

                // Pass indicator
                Circle()
                    .fill(Color.dnDestructive.opacity(0.9))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .opacity(passOpacity)
                    .position(x: 60, y: 60)

                // User info overlay
                VStack(alignment: .leading, spacing: DNSpace.sm) {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: DNSpace.xs) {
                            Text("\(user.name), \(user.age ?? 0)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)

                            if let bio = user.bio {
                                Text(bio)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineLimit(2)
                            }
                        }
                        Spacer()
                    }

                    // Interest chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DNSpace.sm) {
                            ForEach(user.interests.prefix(4), id: \.self) { interest in
                                DNOverlayChip(text: interest.uppercased())
                            }
                        }
                    }
                }
                .padding(DNSpace.lg)
            }
            .clipShape(RoundedRectangle(cornerRadius: DNRadius.xl, style: .continuous))
            .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
            .rotationEffect(.degrees(Double(offset.width) / 20))
            .offset(x: offset.width, y: offset.height)
            .gesture(
                isTopCard ?
                    DragGesture()
                    .onChanged { value in
                        offset = value.translation
                    }
                    .onEnded { value in
                        handleSwipeEnd(translation: value.translation)
                    }
                    : nil
            )
        }
    }

    private var photoPlaceholder: some View {
        Rectangle()
            .fill(Color.dnMuted)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.dnTextTertiary)
            )
    }

    private func handleSwipeEnd(translation: CGSize) {
        if abs(translation.width) > 150 {
            let flyDirection: CGFloat = translation.width > 0 ? 500 : -500
            withAnimation(.easeOut(duration: 0.3)) {
                offset = CGSize(width: flyDirection, height: translation.height)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if translation.width > 0 {
                    onSwipeRight?()
                } else {
                    onSwipeLeft?()
                }
                offset = .zero
            }
        } else {
            withAnimation(reduceMotion ? .none : .dnCardEntry) {
                offset = .zero
            }
        }
    }
}
