import SwiftUI

struct EventSwipeView: View {
    @StateObject private var viewModel = EventSwipeViewModel()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedEvent: Event?

    var body: some View {
        NavigationStack {
            DNScreen {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: DNSpace.xs) {
                            Text("swipe_title".localized())
                                .dnH2()
                            Text(String(
                                format: "swipe_events_to_explore".localized(),
                                viewModel.events.count - viewModel.currentIndex
                            ))
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
                                    Task { await viewModel.swipeLeft() }
                                },
                                onSwipeRight: {
                                    Task { await viewModel.swipeRight() }
                                }
                            )
                            .id(viewModel.currentIndex)
                            .onTapGesture {
                                selectedEvent = currentEvent
                            }
                        }
                        .padding(.horizontal, DNSpace.lg)
                        .padding(.top, DNSpace.sm)

                        Spacer(minLength: DNSpace.md)

                        // Action buttons
                        HStack(spacing: DNSpace.xxl) {
                            // Skip button
                            Button {
                                Task { await viewModel.swipeLeft() }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.dnDestructive)
                                    .frame(width: 64, height: 64)
                                    .dnNeuRaised(intensity: .heavy, cornerRadius: DNRadius.full)
                            }
                            .buttonStyle(.plain)

                            // Undo button
                            Button {
                                viewModel.undoLastSwipe()
                            } label: {
                                Image(systemName: "arrow.uturn.backward")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(viewModel.canUndo ? .dnPrimary : .dnTextTertiary)
                                    .frame(width: 52, height: 52)
                                    .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
                            }
                            .buttonStyle(.plain)
                            .disabled(!viewModel.canUndo)

                            // Interested button
                            Button {
                                Task { await viewModel.swipeRight() }
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
                            Text("swipe_no_more".localized())
                                .dnH3()
                            Text("swipe_come_back".localized())
                                .dnCaption()
                        }
                        Spacer()
                    }
                }
            }
            .task {
                await viewModel.loadEvents()
            }
            .fullScreenCover(item: $selectedEvent) { event in
                NavigationStack {
                    EventDetailView(event: event)
                }
            }
        }
    }
}
