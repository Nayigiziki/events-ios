import SwiftUI

struct MatchDetailView: View {
    @StateObject var viewModel: MatchDetailViewModel
    @Environment(\.dismiss) private var dismiss

    var currentUser: UserProfile?
    let onSendMessage: () -> Void
    let onKeepSwiping: () -> Void

    @State private var showConfetti = false
    @State private var avatarsAppeared = false
    @State private var showChat = false

    var body: some View {
        DNScreen {
            VStack(spacing: DNSpace.xl) {
                Spacer()

                // Confetti / celebration
                confettiSection

                // Heading
                Text("match_its_a_match".localized())
                    .font(.system(size: 42, weight: .black))
                    .tracking(-0.85)
                    .foregroundColor(.dnPrimary)
                    .opacity(avatarsAppeared ? 1 : 0)
                    .offset(y: avatarsAppeared ? 0 : 20)

                // Overlapping avatars (#53 - use real current user)
                overlappingAvatars
                    .padding(.vertical, DNSpace.md)

                // Matched user info
                VStack(spacing: DNSpace.xs) {
                    Text("\(viewModel.matchedUser.name), \(viewModel.matchedUser.age ?? 0)")
                        .dnH2()
                    if let bio = viewModel.matchedUser.bio {
                        Text(bio)
                            .dnCaption()
                            .multilineTextAlignment(.center)
                    }
                }
                .opacity(avatarsAppeared ? 1 : 0)

                // Shared interests
                if !viewModel.sharedInterests.isEmpty {
                    sharedInterestsSection
                }

                Spacer()

                // Action buttons
                VStack(spacing: DNSpace.md) {
                    DNButton("match_send_message".localized(), variant: .primary) {
                        showChat = true
                    }

                    DNButton("match_keep_swiping".localized(), variant: .secondary) {
                        onKeepSwiping()
                    }
                }
                .padding(.horizontal, DNSpace.lg)
                .padding(.bottom, DNSpace.xxl)
            }
        }
        .fullScreenCover(isPresented: $showChat) {
            NavigationStack {
                ConversationChatView(conversationId: UUID(), partner: viewModel.matchedUser)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                avatarsAppeared = true
            }
            withAnimation(.easeOut(duration: 1.0).delay(0.1)) {
                showConfetti = true
            }
        }
    }

    // MARK: - Confetti

    private var confettiSection: some View {
        ZStack {
            if showConfetti {
                ForEach(0 ..< 20, id: \.self) { index in
                    ConfettiPiece(index: index)
                }
            }
        }
        .frame(height: 60)
    }

    // MARK: - Overlapping Avatars

    private var overlappingAvatars: some View {
        HStack(spacing: -24) {
            // Current user avatar (#53)
            AvatarView(
                url: URL(string: currentUser?.avatarUrl ?? MockData.currentUser.avatar),
                size: 96
            )
            .overlay(
                Circle()
                    .stroke(Color.dnBackground, lineWidth: 4)
            )
            .zIndex(1)

            // Matched user avatar
            AvatarView(
                url: URL(string: viewModel.matchedUser.avatarUrl ?? ""),
                size: 96
            )
            .overlay(
                Circle()
                    .stroke(Color.dnBackground, lineWidth: 4)
            )
        }
        .scaleEffect(avatarsAppeared ? 1.0 : 0.5)
        .opacity(avatarsAppeared ? 1 : 0)
    }

    // MARK: - Shared Interests

    private var sharedInterestsSection: some View {
        VStack(spacing: DNSpace.sm) {
            Text("match_shared_interests".localized())
                .dnLabel()

            HStack(spacing: DNSpace.sm) {
                ForEach(viewModel.sharedInterests, id: \.self) { interest in
                    Text(interest.uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .tracking(0.2)
                        .foregroundColor(.dnPrimary)
                        .padding(.horizontal, DNSpace.md)
                        .padding(.vertical, DNSpace.sm)
                        .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.sm)
                }
            }
        }
        .opacity(avatarsAppeared ? 1 : 0)
    }
}

// MARK: - UserProfile -> MockUser bridge (temporary until chat is migrated)

extension UserProfile {
    func toMockUser() -> MockUser {
        MockUser(
            id: id.uuidString,
            name: name,
            age: age ?? 0,
            avatar: avatarUrl ?? "",
            photos: photos,
            bio: bio ?? "",
            interests: interests
        )
    }
}

// MARK: - Confetti Piece

private struct ConfettiPiece: View {
    let index: Int

    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var rotation: Double = 0

    private var color: Color {
        [Color.dnPrimary, .dnAccentPink, .dnSuccess, .dnWarning, .dnInfo][index % 5]
    }

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: CGFloat.random(in: 6 ... 10), height: CGFloat.random(in: 6 ... 10))
            .offset(x: offsetX, y: offsetY)
            .opacity(opacity)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                let randomX = CGFloat.random(in: -150 ... 150)
                let randomY = CGFloat.random(in: -200 ... -50)
                let duration = Double.random(in: 1.0 ... 2.0)

                withAnimation(.easeOut(duration: duration)) {
                    offsetX = randomX
                    offsetY = randomY + 300
                    opacity = 0
                    rotation = Double.random(in: -360 ... 360)
                }
            }
    }
}
