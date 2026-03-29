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
                                    conversationRow(conversation)
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
            .task {
                await viewModel.loadConversations()
            }
        }
    }

    // MARK: - Conversation Row

    private func conversationRow(_ conversation: ConversationListItem) -> some View {
        HStack(spacing: DNSpace.md) {
            ConversationAvatarView(conversation: conversation)

            VStack(alignment: .leading, spacing: DNSpace.xs) {
                Text(conversationDisplayName(conversation))
                    .font(.system(size: 18, weight: .bold))
                    .tracking(-0.6)
                    .foregroundColor(.dnTextPrimary)
                    .lineLimit(1)

                if conversation.isTyping {
                    TypingIndicator()
                } else {
                    Text(conversation.lastMessageText ?? "")
                        .dnCaption()
                        .lineLimit(1)
                }
            }

            Spacer()

            if let date = conversation.lastMessageDate {
                Text(date.formatted(.relative(presentation: .named)))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.dnTextTertiary)
            }
        }
        .padding(.vertical, DNSpace.md)
    }

    private func conversationDisplayName(_ conversation: ConversationListItem) -> String {
        if conversation.isGroup {
            return conversation.groupName ?? conversation.participants.first?.name ?? ""
        }
        return conversation.participants.first?.name ?? ""
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

            Text("No hay conversaciones aun")
                .dnH3()

            Text("Cuando hagas match con alguien, podras chatear aqui")
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
    let conversation: ConversationListItem

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .bottomTrailing) {
                AvatarView(
                    url: URL(string: conversation.participants.first?.avatarUrl ?? ""),
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

            if conversation.unreadCount > 0 {
                ZStack {
                    Circle()
                        .fill(Color.dnAccentPink)
                        .frame(width: 24, height: 24)
                    Text("\(conversation.unreadCount)")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.white)
                }
                .offset(x: 4, y: -4)
            }
        }
    }
}
