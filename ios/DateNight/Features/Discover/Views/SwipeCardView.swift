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
                DNAsyncImage(
                    url: URL(string: user.photos.first ?? user.avatarUrl ?? ""),
                    height: geometry.size.height,
                    cornerRadius: 0
                )

                // Gradient overlay: from #101828 at bottom to clear at top
                LinearGradient(
                    stops: [
                        .init(color: Color(hex: "101828").opacity(0.85), location: 0),
                        .init(color: Color(hex: "101828").opacity(0.4), location: 0.5),
                        .init(color: .clear, location: 1.0)
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )

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
                            // Name: 30px black weight
                            Text("\(user.name), \(user.age ?? 0)")
                                .font(.system(size: 30, weight: .black))
                                .tracking(-0.2)
                                .foregroundColor(.white)

                            // Occupation line
                            if let bio = user.bio {
                                HStack(spacing: DNSpace.sm) {
                                    Image(systemName: "briefcase.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.8))
                                    Text(bio)
                                        .font(.system(size: 16, weight: .semibold))
                                        .tracking(-0.47)
                                        .foregroundColor(.white.opacity(0.8))
                                        .lineLimit(1)
                                }
                            }

                            // Distance line
                            HStack(spacing: DNSpace.sm) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.8))
                                Text("A 2 km de distancia")
                                    .font(.system(size: 16, weight: .semibold))
                                    .tracking(-0.47)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        Spacer()

                        // Info button: 48pt circle
                        Button {} label: {
                            Image(systemName: "info")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 48, height: 48)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                        .buttonStyle(.plain)
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
            // Standard drop shadow, NOT neumorphic
            .shadow(color: Color.black.opacity(0.25), radius: 25, x: 0, y: 25)
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
