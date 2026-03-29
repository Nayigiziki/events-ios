import SwiftUI

struct MatchesView: View {
    @StateObject private var viewModel = MatchesViewModel()
    @State private var showMyDates = false

    var body: some View {
        NavigationStack {
            DNScreen {
                ScrollView {
                    VStack(spacing: DNSpace.lg) {
                        // Header
                        VStack(alignment: .leading, spacing: DNSpace.xs) {
                            Text("matches_title".localized())
                                .font(.system(size: 28, weight: .black))
                                .tracking(-0.6)
                                .foregroundColor(.dnTextPrimary)
                                .textCase(.uppercase)

                            Text("matches_subtitle".localized())
                                .dnCaption()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, DNSpace.lg)
                        .padding(.top, DNSpace.md)

                        // Segmented picker
                        HStack(spacing: 0) {
                            tabButton(title: "matches_available_dates".localized(), index: 0)
                            tabButton(title: "matches_your_dates".localized(), index: 1)
                        }
                        .padding(4)
                        .dnNeuRaised(cornerRadius: DNRadius.xl)
                        .padding(.horizontal, DNSpace.lg)

                        // Content
                        if viewModel.isLoading {
                            ProgressView()
                                .padding(.top, 60)
                        } else if viewModel.selectedTab == 0 {
                            availableDatesContent
                        } else {
                            yourDatesContent

                            // Link to full My Dates view
                            NavigationLink {
                                MyDatesView()
                            } label: {
                                DNCard {
                                    HStack {
                                        Text("matches_view_all_dates".localized())
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.dnPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.dnPrimary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, DNSpace.lg)
                        }

                        // Create your own date card
                        createDateCard
                            .padding(.horizontal, DNSpace.lg)
                    }
                    .padding(.bottom, DNSpace.xxl * 3)
                }
                .refreshable {
                    await viewModel.loadDates()
                }
            }
        }
        .task {
            await viewModel.loadDates()
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
                .font(.system(size: 13, weight: .bold))
                .textCase(.uppercase)
                .foregroundColor(
                    viewModel.selectedTab == index
                        ? .white
                        : .dnTextSecondary
                )
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
                .background(
                    Group {
                        if viewModel.selectedTab == index {
                            Capsule()
                                .fill(Color.dnPrimary)
                        }
                    }
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Available Dates

    private var availableDatesContent: some View {
        LazyVStack(spacing: DNSpace.lg) {
            ForEach(Array(viewModel.availableDates.enumerated()), id: \.element.id) { index, dateReq in
                DateRequestCard(
                    dateRequest: dateReq,
                    onJoin: {
                        Task { await viewModel.joinDate(requestId: dateReq.id) }
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

    // MARK: - Create Date Card

    private var createDateCard: some View {
        DNCard(cornerRadius: DNRadius.xxl) {
            VStack(spacing: DNSpace.md) {
                ZStack {
                    Circle()
                        .fill(Color.dnBackground)
                        .frame(width: 64, height: 64)
                        .dnNeuPressed(cornerRadius: DNRadius.full)

                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.dnPrimary)
                }

                Text("matches_create_date".localized())
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.dnTextPrimary)
                    .multilineTextAlignment(.center)

                Text("matches_create_date_subtitle".localized())
                    .dnCaption()
                    .multilineTextAlignment(.center)

                NavigationLink {
                    EventSwipeView()
                } label: {
                    Text("matches_browse_events".localized())
                        .font(.system(size: 16, weight: .bold))
                        .tracking(-0.47)
                        .foregroundColor(.dnTextPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous)
                                .fill(Color.dnBackground)
                        )
                        .dnNeuRaised(intensity: .heavy, cornerRadius: DNRadius.md)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, DNSpace.lg)
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

            Text("matches_no_dates_yet".localized())
                .dnH3()

            Text("matches_explore_events".localized())
                .dnCaption()
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
        .padding(.horizontal, DNSpace.xxl)
    }
}
