import SwiftUI

struct ChatListView: View {
    @StateObject private var viewModel = ChatListViewModel()

    var body: some View {
        NavigationStack {
            DNScreen {
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: DNSpace.md) {
                        Text("MENSAJES")
                            .font(.system(size: 28, weight: .black))
                            .tracking(-0.6)
                            .foregroundColor(.dnTextPrimary)
                            .textCase(.uppercase)

                        DNTextField(
                            placeholder: "Buscar conversaciones...",
                            text: $viewModel.searchText,
                            icon: "magnifyingglass"
                        )
                    }
                    .padding(.horizontal, DNSpace.lg)
                    .padding(.top, DNSpace.lg)
                    .padding(.bottom, DNSpace.md)

                    // Chat List
                    if viewModel.filteredConversations.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            LazyVStack(spacing: DNSpace.xs) {
                                ForEach(viewModel.filteredConversations) { conversation in
                                    NavigationLink(destination: ConversationChatView(partner: conversation.user)) {
                                        conversationRow(conversation)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, DNSpace.lg)
                            .padding(.bottom, DNSpace.xxl)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Conversation Row

    private func conversationRow(_ conversation: MockConversation) -> some View {
        HStack(spacing: DNSpace.md) {
            ConversationAvatarView(conversation: conversation)

            VStack(alignment: .leading, spacing: DNSpace.xs) {
                Text(conversation.isGroup ? (conversation.groupName ?? conversation.user.name) : conversation.user.name)
                    .font(.system(size: 18, weight: .bold))
                    .tracking(-0.6)
                    .foregroundColor(.dnTextPrimary)
                    .lineLimit(1)

                if conversation.isTyping {
                    TypingIndicator()
                } else {
                    Text(conversation.lastMessage)
                        .dnCaption()
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(conversation.timestamp.uppercased())
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.dnTextTertiary)
        }
        .padding(.vertical, DNSpace.md)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: DNSpace.lg) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: DNRadius.lg, style: .continuous)
                    .fill(Color.dnPrimary)
                    .frame(width: 80, height: 80)
                Image(systemName: "message.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }
            .dnNeuRaised()

            Text("No hay conversaciones aún")
                .dnH3()

            Text("Cuando hagas match con alguien, podrás chatear aquí")
                .dnCaption()
                .multilineTextAlignment(.center)
                .padding(.horizontal, DNSpace.xxl)

            Spacer()
        }
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var dotCount = 0

    var body: some View {
        HStack(spacing: 3) {
            Text("escribiendo")
                .dnCaption()
                .foregroundColor(.dnPrimary)
            ForEach(0 ..< 3, id: \.self) { index in
                Circle()
                    .fill(Color.dnPrimary)
                    .frame(width: 4, height: 4)
                    .opacity(dotCount > index ? 1.0 : 0.3)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever()) {
                dotCount = 3
            }
        }
    }
}

// MARK: - Conversation Avatar View

struct ConversationAvatarView: View {
    let conversation: MockConversation

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .bottomTrailing) {
                AvatarView(
                    url: URL(string: conversation.user.avatar),
                    size: 56
                )

                if conversation.isGroup {
                    ZStack {
                        Circle()
                            .fill(Color.dnPrimary)
                            .frame(width: 24, height: 24)
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .offset(x: 4, y: 4)
                }
            }

            if conversation.unread > 0 {
                ZStack {
                    Circle()
                        .fill(Color.dnAccentPink)
                        .frame(width: 24, height: 24)
                    Text("\(conversation.unread)")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.white)
                }
                .offset(x: 4, y: -4)
            }
        }
    }
}
