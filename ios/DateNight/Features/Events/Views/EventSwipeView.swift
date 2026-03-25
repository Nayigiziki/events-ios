import SwiftUI

struct EventSwipeView: View {
    @StateObject private var viewModel = EventSwipeViewModel()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        DNScreen {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: DNSpace.xs) {
                        Text("Events")
                            .dnH2()
                        Text("\(viewModel.events.count - viewModel.currentIndex) events to explore")
                            .dnCaption()
                    }
                    Spacer()
                }
                .padding(.horizontal, DNSpace.lg)
                .padding(.vertical, DNSpace.md)

                if let currentEvent = viewModel.currentEvent {
                    // Card deck
                    ZStack {
                        // Next card (behind)
                        if let nextEvent = viewModel.nextEvent {
                            EventSwipeCardView(
                                event: nextEvent,
                                isTopCard: false
                            )
                            .scaleEffect(0.95)
                            .opacity(0.5)
                        }

                        // Current card (top)
                        EventSwipeCardView(
                            event: currentEvent,
                            isTopCard: true,
                            onSwipeLeft: {
                                viewModel.swipeLeft()
                            },
                            onSwipeRight: {
                                viewModel.swipeRight()
                            }
                        )
                        .id(viewModel.currentIndex)
                    }
                    .padding(.horizontal, DNSpace.lg)
                    .padding(.top, DNSpace.sm)

                    Spacer(minLength: DNSpace.md)

                    // Action buttons
                    HStack(spacing: DNSpace.xxl) {
                        // Skip button
                        Button {
                            viewModel.swipeLeft()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.dnDestructive)
                                .frame(width: 64, height: 64)
                                .dnNeuRaised(intensity: .heavy, cornerRadius: DNRadius.full)
                        }
                        .buttonStyle(.plain)

                        // Interested button
                        Button {
                            viewModel.swipeRight()
                        } label: {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 80, height: 80)
                                .background(
                                    Circle()
                                        .fill(Color.dnPrimary)
                                )
                                .dnNeuCTAButton(cornerRadius: DNRadius.full)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.bottom, DNSpace.xl)
                } else {
                    // Empty state
                    Spacer()
                    VStack(spacing: DNSpace.md) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 48))
                            .foregroundColor(.dnTextTertiary)
                        Text("No more events")
                            .dnH3()
                        Text("Come back later for new events")
                            .dnCaption()
                    }
                    Spacer()
                }
            }
        }
    }
}
