import SwiftUI

struct ConversationChatView: View {
    @StateObject private var viewModel: ConversationChatViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputFocused: Bool

    init(partner: MockUser) {
        _viewModel = StateObject(wrappedValue: ConversationChatViewModel(partner: partner))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            chatNavigationBar

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: DNSpace.md) {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(message: message)
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

            // Input Bar
            inputBar
        }
        .background(Color.dnBackground)
        .navigationBarHidden(true)
    }

    // MARK: - Navigation Bar

    private var chatNavigationBar: some View {
        HStack(spacing: DNSpace.md) {
            // Back button
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.dnTextPrimary)
                    .frame(width: 36, height: 36)
                    .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
            }

            // User info
            AvatarView(
                url: URL(string: viewModel.conversationPartner.avatar),
                size: 32
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.conversationPartner.name)
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.dnTextPrimary)

                HStack(spacing: 4) {
                    if viewModel.conversationPartner.isOnline {
                        Circle()
                            .fill(Color.dnSuccess)
                            .frame(width: 8, height: 8)
                        Text("Online")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.dnSuccess)
                    } else {
                        Text("Offline")
                            .dnSmall()
                    }
                }
            }

            Spacer()

            // Action buttons
            Button {} label: {
                Image(systemName: "phone.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.dnPrimary)
                    .frame(width: 36, height: 36)
                    .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
            }

            Button {} label: {
                Image(systemName: "video.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.dnPrimary)
                    .frame(width: 36, height: 36)
                    .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
            }
        }
        .padding(.horizontal, DNSpace.lg)
        .padding(.vertical, DNSpace.md)
        .dnNeuRaised(intensity: .medium, cornerRadius: 0)
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
