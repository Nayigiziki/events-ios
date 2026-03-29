import SwiftUI

struct EventDetailView: View {
    @StateObject private var viewModel: EventDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedUser: UserProfile?
    @State private var showUserProfile = false

    init(event: Event) {
        _viewModel = StateObject(wrappedValue: EventDetailViewModel(event: event))
    }

    var body: some View {
        if let event = viewModel.event {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        heroSection(event: event)
                        detailContent(event: event)
                    }
                    .padding(.bottom, 100)
                }
                .ignoresSafeArea(edges: .top)

                stickyBottomBar(event: event)
            }
            .background(Color.dnBackground)
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showCreateDate) {
                CreateDateSheet(viewModel: viewModel)
            }
            .fullScreenCover(isPresented: $showUserProfile) {
                if let user = selectedUser {
                    UserProfileModal(user: user)
                }
            }
            .sheet(isPresented: $viewModel.showShareSheet) {
                if let event = viewModel.event {
                    ShareSheet(items: [viewModel.shareText])
                }
            }
            .task {
                await viewModel.loadComments()
            }
        }
    }

    // MARK: - Hero Section

    private func heroSection(event: Event) -> some View {
        ZStack(alignment: .topLeading) {
            heroImage(event: event)
            heroOverlayContent(event: event)
        }
    }

    private func heroImage(event: Event) -> some View {
        DNAsyncImage(
            url: URL(string: event.imageUrl ?? ""),
            height: UIScreen.main.bounds.height * 0.6,
            cornerRadius: 0
        )
        .overlay(
            LinearGradient(
                colors: [
                    .black.opacity(0.4),
                    .clear,
                    .clear,
                    .black.opacity(0.7)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func heroOverlayContent(event: Event) -> some View {
        VStack {
            heroNavigationBar
            Spacer()
            heroEventInfo(event: event)
        }
    }

    private var heroNavigationBar: some View {
        HStack {
            Button { dismiss() } label: {
                heroCircleButton(icon: "chevron.left")
            }
            Spacer()
            Button { viewModel.showShareSheet = true } label: {
                heroCircleButton(icon: "square.and.arrow.up")
            }
        }
        .padding(.horizontal, DNSpace.lg)
        .padding(.top, 56)
    }

    private func heroCircleButton(icon: String) -> some View {
        Image(systemName: icon)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.dnTextPrimary)
            .frame(width: 48, height: 48)
            .background(Circle().fill(Color.dnBackground))
            .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
    }

    private func heroEventInfo(event: Event) -> some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            HStack(spacing: DNSpace.sm) {
                DNCategoryBadge(category: event.category)
                Text(event.venue)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }

            Text(event.title)
                .font(.system(size: 30, weight: .heavy))
                .tracking(-0.5)
                .foregroundColor(.white)
                .lineLimit(3)

            VStack(alignment: .leading, spacing: DNSpace.sm) {
                HStack(spacing: DNSpace.sm) {
                    Image(systemName: "calendar")
                        .font(.system(size: 15, weight: .bold))
                    Text(event.date)
                        .font(.system(size: 15, weight: .bold))
                    Text("\u{2022}")
                    Image(systemName: "clock")
                        .font(.system(size: 15, weight: .bold))
                    Text(event.time)
                        .font(.system(size: 15, weight: .bold))
                }
                HStack(spacing: DNSpace.sm) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 15, weight: .bold))
                    Text(event.location)
                        .font(.system(size: 15, weight: .bold))
                }
            }
            .foregroundColor(.white)
        }
        .padding(.horizontal, DNSpace.xl)
        .padding(.bottom, DNSpace.xl)
    }

    // heroPlaceholder removed — DNAsyncImage handles placeholder internally

    // MARK: - Detail Content

    private func detailContent(event: Event) -> some View {
        VStack(alignment: .leading, spacing: DNSpace.xl) {
            // Quick Info Grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: DNSpace.lg),
                GridItem(.flexible(), spacing: DNSpace.lg)
            ], spacing: DNSpace.lg) {
                DNStatCard(
                    icon: "calendar",
                    label: "event_detail_date".localized(),
                    value: event.date,
                    accentColor: .dnAccentPink
                )
                DNStatCard(
                    icon: "clock",
                    label: "event_detail_time".localized(),
                    value: event.time,
                    accentColor: .dnPrimary
                )
                DNStatCard(
                    icon: "building.2",
                    label: "event_detail_venue".localized(),
                    value: event.venue,
                    accentColor: .dnInfo
                )
                DNStatCard(
                    icon: "dollarsign.circle",
                    label: "event_detail_price".localized(),
                    value: event.price,
                    accentColor: .dnSuccess
                )
            }

            // Description
            VStack(alignment: .leading, spacing: DNSpace.md) {
                Text("event_detail_about".localized())
                    .dnH3()
                Text(event.description)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.dnTextSecondary)
                    .lineSpacing(4)
            }

            // Attendees
            attendeesSection(event: event)

            // Comments
            commentsSection
        }
        .padding(DNSpace.xl)
    }

    // MARK: - Attendees

    private func attendeesSection(event: Event) -> some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            HStack {
                Text("event_detail_whos_going".localized())
                    .dnH3()
                Spacer()
                HStack(spacing: DNSpace.xs) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 14, weight: .bold))
                    Text(String(format: "event_detail_interested".localized(), event.attendees?.count ?? 0))
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.dnPrimary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DNSpace.md) {
                    ForEach(event.attendees ?? []) { user in
                        Button {
                            selectedUser = user
                            showUserProfile = true
                        } label: {
                            VStack(spacing: DNSpace.sm) {
                                AvatarView(
                                    url: URL(string: user.avatarUrl ?? ""),
                                    size: 64
                                )
                                Text(user.name)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.dnTextPrimary)
                                    .frame(width: 64)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Comments

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            HStack {
                Text("event_detail_comments".localized())
                    .dnH3()
                Spacer()
                HStack(spacing: DNSpace.xs) {
                    Image(systemName: "bubble.left.fill")
                        .font(.system(size: 14, weight: .bold))
                    Text("\(viewModel.comments.count)")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.dnPrimary)
            }

            // Comment input
            HStack(spacing: DNSpace.sm) {
                DNTextField(
                    placeholder: "event_detail_add_comment".localized(),
                    text: $viewModel.newCommentText,
                    icon: "text.bubble"
                )

                Button { Task { await viewModel.addComment() } } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 52, height: 52)
                        .background(Circle().fill(Color.dnPrimary))
                        .dnNeuCTAButton(cornerRadius: DNRadius.full)
                }
                .buttonStyle(.plain)
                .opacity(viewModel.newCommentText.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
            }

            // Comment list
            LazyVStack(spacing: DNSpace.md) {
                ForEach(viewModel.comments) { comment in
                    commentRow(comment)
                }
            }
        }
    }

    private func commentRow(_ comment: EventComment) -> some View {
        DNCard {
            HStack(alignment: .top, spacing: DNSpace.md) {
                AvatarView(
                    url: URL(string: comment.avatarUrl ?? ""),
                    size: 40
                )

                VStack(alignment: .leading, spacing: DNSpace.xs) {
                    HStack {
                        Text(comment.userName)
                            .dnLabel()
                        Spacer()
                        Text(comment.timestamp)
                            .dnSmall()
                    }

                    Text(comment.text)
                        .dnBody()
                        .fixedSize(horizontal: false, vertical: true)

                    commentVoteButtons(comment)
                }
            }
        }
    }

    private func commentVoteButtons(_ comment: EventComment) -> some View {
        HStack(spacing: DNSpace.lg) {
            Button {
                Task { await viewModel.vote(commentId: comment.id, direction: .up) }
            } label: {
                HStack(spacing: DNSpace.xs) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 14, weight: .bold))
                    Text("\(comment.upvotes)")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(comment.userVote == .up ? .dnSuccess : .dnTextTertiary)
            }
            .buttonStyle(.plain)

            Button {
                Task { await viewModel.vote(commentId: comment.id, direction: .down) }
            } label: {
                HStack(spacing: DNSpace.xs) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 14, weight: .bold))
                    Text("\(comment.downvotes)")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(comment.userVote == .down ? .dnDestructive : .dnTextTertiary)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.top, DNSpace.xs)
    }

    // MARK: - Sticky Bottom Bar

    private func stickyBottomBar(event: Event) -> some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: DNSpace.xs) {
                    Text("event_detail_price".localized())
                        .dnCaption()
                    Text(event.price)
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundColor(.dnTextPrimary)
                }
                Spacer()

                Button {
                    Task {
                        if viewModel.isAttending {
                            await viewModel.unrsvp()
                        } else {
                            await viewModel.rsvp()
                        }
                    }
                } label: {
                    Image(systemName: viewModel.isAttending ? "heart.fill" : "heart")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(viewModel.isAttending ? .dnAccentPink : .dnTextSecondary)
                        .frame(width: 52, height: 52)
                        .background(Circle().fill(Color.dnBackground))
                        .dnNeuRaised(intensity: .medium, cornerRadius: DNRadius.full)
                }
                .buttonStyle(.plain)

                DNButton("event_detail_create_date".localized(), variant: .primary) {
                    viewModel.showCreateDate = true
                }
                .frame(maxWidth: 180)
            }
            .padding(.horizontal, DNSpace.xl)
            .padding(.vertical, DNSpace.lg)
            .background(Color.dnBackground)
            .dnNeuRaised(intensity: .medium, cornerRadius: 0)
        }
    }
}
