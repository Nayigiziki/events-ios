import SwiftUI

struct EventSwipeCardView: View {
    let event: Event
    var isTopCard: Bool = true
    var onSwipeLeft: (() -> Void)?
    var onSwipeRight: (() -> Void)?

    @State private var offset: CGSize = .zero
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var interestedOpacity: Double {
        max(0, Double(offset.width) / 150.0)
    }

    private var skipOpacity: Double {
        max(0, Double(-offset.width) / 150.0)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Event image
                DNAsyncImage(
                    url: URL(string: event.imageUrl ?? ""),
                    height: geometry.size.height,
                    cornerRadius: 0
                )

                // Gradient overlay
                LinearGradient(
                    stops: [
                        .init(color: Color(hex: "101828").opacity(0.85), location: 0),
                        .init(color: Color(hex: "101828").opacity(0.4), location: 0.5),
                        .init(color: .clear, location: 1.0)
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )

                // Category badge (top-left)
                DNCategoryBadge(category: event.category)
                    .position(x: 70, y: 40)

                // Price badge (top-right)
                Text(event.price)
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.horizontal, DNSpace.lg)
                    .padding(.vertical, DNSpace.sm)
                    .background(
                        Capsule()
                            .fill(Color.dnSuccess)
                    )
                    .position(x: geometry.size.width - 50, y: 40)

                // Interested indicator
                Circle()
                    .fill(Color.dnSuccess.opacity(0.9))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "heart.fill")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .opacity(interestedOpacity)
                    .position(x: geometry.size.width - 60, y: 100)

                // Skip indicator
                Circle()
                    .fill(Color.dnDestructive.opacity(0.9))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .opacity(skipOpacity)
                    .position(x: 60, y: 100)

                // Event info overlay
                VStack(alignment: .leading, spacing: DNSpace.sm) {
                    Text(event.title)
                        .font(.system(size: 28, weight: .black))
                        .tracking(-0.2)
                        .foregroundColor(.white)
                        .lineLimit(2)

                    HStack(spacing: DNSpace.sm) {
                        Image(systemName: "calendar")
                            .font(.system(size: 15, weight: .bold))
                        Text(event.date)
                            .font(.system(size: 15, weight: .bold))
                        Text("\u{2022}")
                        Text(event.time)
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white.opacity(0.9))

                    HStack(spacing: DNSpace.sm) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 15, weight: .bold))
                        Text(event.venue)
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white.opacity(0.8))

                    // Attendee interests
                    if let attendees = event.attendees, !attendees.isEmpty {
                        let allInterests = Array(Set(attendees.flatMap(\.interests))).prefix(4)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DNSpace.sm) {
                                ForEach(Array(allInterests), id: \.self) { interest in
                                    DNOverlayChip(text: interest.uppercased())
                                }
                            }
                        }
                    }
                }
                .padding(DNSpace.lg)
            }
            .clipShape(RoundedRectangle(cornerRadius: DNRadius.xl, style: .continuous))
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

    // imagePlaceholder removed — DNAsyncImage handles placeholder internally

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
