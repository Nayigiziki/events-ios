import SwiftUI

struct MatchesView: View {
    @StateObject private var viewModel = MatchesViewModel()

    var body: some View {
        DNScreen {
            ScrollView {
                VStack(spacing: DNSpace.lg) {
                    // Header
                    HStack {
                        Text("Dates")
                            .dnH2()
                        Spacer()
                    }
                    .padding(.horizontal, DNSpace.lg)
                    .padding(.top, DNSpace.md)

                    // Segmented picker
                    DNCard(cornerRadius: DNRadius.xl) {
                        HStack(spacing: DNSpace.sm) {
                            tabButton(title: "Available", index: 0)
                            tabButton(title: "Your Dates", index: 1)
                        }
                    }
                    .padding(.horizontal, DNSpace.lg)

                    // Content
                    if viewModel.selectedTab == 0 {
                        availableDatesContent
                    } else {
                        yourDatesContent
                    }
                }
                .padding(.bottom, DNSpace.xxl)
            }
        }
    }

    // MARK: - Tab Button

    private func tabButton(title: String, index: Int) -> some View {
        Button {
            withAnimation(.dnTabSwitch) {
                viewModel.selectedTab = index
            }
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .textCase(.uppercase)
                .foregroundColor(
                    viewModel.selectedTab == index
                        ? .dnPrimary
                        : .dnTextSecondary
                )
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
        }
        .buttonStyle(.plain)
        .if(viewModel.selectedTab == index) { view in
            view.dnNeuPressed(cornerRadius: DNRadius.md)
        }
        .if(viewModel.selectedTab != index) { view in
            view.dnNeuRaised(cornerRadius: DNRadius.md)
        }
    }

    // MARK: - Available Dates

    private var availableDatesContent: some View {
        LazyVStack(spacing: DNSpace.lg) {
            ForEach(Array(viewModel.availableDates.enumerated()), id: \.element.id) { index, dateReq in
                DateRequestCard(
                    dateRequest: dateReq,
                    onJoin: {
                        viewModel.joinDate(requestId: dateReq.id)
                    }
                )
                .padding(.horizontal, DNSpace.lg)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))
                .animation(
                    Animation.dnCardEntry.delay(Double(index) * 0.1),
                    value: viewModel.selectedTab
                )
            }
        }
    }

    // MARK: - Your Dates

    private var yourDatesContent: some View {
        Group {
            if viewModel.myDates.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: DNSpace.lg) {
                    ForEach(viewModel.myDates) { dateReq in
                        DateRequestCard(dateRequest: dateReq)
                            .padding(.horizontal, DNSpace.lg)
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: DNSpace.md) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.dnTextTertiary)
                .frame(width: 80, height: 80)
                .dnNeuRaised(cornerRadius: DNRadius.full)

            Text("No dates yet")
                .dnH3()

            Text("Browse events and create a date to get started")
                .dnCaption()
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
        .padding(.horizontal, DNSpace.xxl)
    }
}
