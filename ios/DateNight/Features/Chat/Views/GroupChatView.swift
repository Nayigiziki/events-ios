import SwiftUI

struct GroupChatView: View {
    @StateObject private var viewModel: GroupChatViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputFocused: Bool

    init(groupName: String = "Jazz Club Date") {
        _viewModel = StateObject(wrappedValue: GroupChatViewModel(groupName: groupName))
    }

    var body: some View {
        VStack(spacing: 0) {
            chatNavigationBar

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: DNSpace.md) {
                        ForEach(viewModel.messages) { message in
                            groupMessageBubble(message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, DNSpace.lg)
                    .padding(.vertical, DNSpace.md)
                }
                .onAppear {
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    withAnimation {
                        scrollToBottom(proxy: proxy)
                    }
                }
            }
            .background(Color.dnBackground)

            inputBar
        }
        .background(Color.dnBackground)
        .navigationBarHidden(true)
    }

    // MARK: - Navigation Bar

    private var chatNavigationBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: DNSpace.md) {
                // Back button
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.dnTextPrimary)
                        .frame(width: 36, height: 36)
                        .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
                }

                // Avatar stack
                HStack(spacing: -8) {
                    ForEach(viewModel.participants.prefix(3), id: \.id) { participant in
                        AvatarView(url: URL(string: participant.avatar), size: 28)
                    }
                }

                // Group info
                Button {
                    withAnimation(.dnTabSwitch) {
                        viewModel.showParticipants.toggle()
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.groupName)
                            .dnH4()

                        Text("\(viewModel.participants.count) participants")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.dnTextSecondary)
                    }
                }

                Spacer()

                // Invite button
                Button {} label: {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.dnPrimary)
                        .frame(width: 36, height: 36)
                        .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
                }
            }
            .padding(.horizontal, DNSpace.lg)
            .padding(.vertical, DNSpace.md)

            // Expandable participant list
            if viewModel.showParticipants {
                participantList
            }
        }
        .dnNeuRaised(intensity: .medium, cornerRadius: 0)
    }

    // MARK: - Participant List

    private var participantList: some View {
        VStack(spacing: DNSpace.sm) {
            ForEach(viewModel.participants, id: \.id) { participant in
                HStack(spacing: DNSpace.md) {
                    AvatarView(url: URL(string: participant.avatar), size: 32)

                    Text(participant.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.dnTextPrimary)

                    Spacer()

                    if participant.isOnline {
                        Circle()
                            .fill(Color.dnSuccess)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.horizontal, DNSpace.lg)
            }
        }
        .padding(.vertical, DNSpace.sm)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: - Group Message Bubble

    private func groupMessageBubble(_ message: GroupMessage) -> some View {
        HStack(alignment: .top) {
            if message.isSent {
                Spacer(minLength: UIScreen.main.bounds.width * 0.2)
            } else {
                AvatarView(url: URL(string: message.senderAvatar), size: 28)
            }

            VStack(alignment: message.isSent ? .trailing : .leading, spacing: DNSpace.xs) {
                if !message.isSent {
                    Text(message.senderName)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.dnPrimary)
                }

                Text(message.text)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(message.isSent ? .white : .dnTextPrimary)
                    .padding(.horizontal, DNSpace.lg)
                    .padding(.vertical, DNSpace.md)
                    .background(
                        Group {
                            if message.isSent {
                                RoundedRectangle(cornerRadius: DNRadius.lg, style: .continuous)
                                    .fill(Color.dnPrimary)
                                    .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.lg)
                            } else {
                                RoundedRectangle(cornerRadius: DNRadius.lg, style: .continuous)
                                    .fill(Color.dnBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DNRadius.lg, style: .continuous)
                                            .stroke(Color.dnShadowDark, lineWidth: 1)
                                    )
                                    .dnNeuPressed(intensity: .light, cornerRadius: DNRadius.lg)
                            }
                        }
                    )

                Text(message.timestamp)
                    .dnSmall()
                    .padding(.horizontal, DNSpace.xs)
            }

            if !message.isSent {
                Spacer(minLength: UIScreen.main.bounds.width * 0.2)
            }
        }
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: DNSpace.sm) {
            Button {} label: {
                Image(systemName: "face.smiling")
                    .font(.system(size: 20))
                    .foregroundColor(.dnTextSecondary)
            }

            TextField("Type a message...", text: $viewModel.messageText, axis: .vertical)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.dnTextPrimary)
                .lineLimit(1 ... 4)
                .focused($isInputFocused)
                .padding(.horizontal, DNSpace.md)
                .padding(.vertical, DNSpace.sm)
                .dnNeuPressed(intensity: .light, cornerRadius: DNRadius.md)

            Button {} label: {
                Image(systemName: "photo")
                    .font(.system(size: 20))
                    .foregroundColor(.dnTextSecondary)
            }

            if !viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Button {
                    viewModel.sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color.dnPrimary)
                        )
                        .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
                }
                .transition(.scale.combined(with: .opacity))
                .animation(.dnButtonPress, value: viewModel.messageText.isEmpty)
            }
        }
        .padding(.horizontal, DNSpace.lg)
        .padding(.vertical, DNSpace.md)
        .dnNeuRaised(intensity: .medium, cornerRadius: 0)
    }

    // MARK: - Helpers

    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = viewModel.messages.last {
            proxy.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
}
