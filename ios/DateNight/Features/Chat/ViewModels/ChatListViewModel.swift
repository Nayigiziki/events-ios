import Foundation

@MainActor
class ChatListViewModel: ObservableObject {
    @Published var conversations: [ConversationListItem] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let chatService: any ChatServiceProtocol

    var filteredConversations: [ConversationListItem] {
        if searchText.isEmpty {
            return conversations
        }
        let query = searchText.lowercased()
        return conversations.filter { conversation in
            let name: String = if conversation.isGroup {
                conversation.groupName ?? conversation.participants.first?.name ?? ""
            } else {
                conversation.participants.first?.name ?? ""
            }
            return name.lowercased().contains(query)
                || (conversation.lastMessageText ?? "").lowercased().contains(query)
        }
    }

    init(chatService: any ChatServiceProtocol = SupabaseChatService()) {
        self.chatService = chatService
    }

    func loadConversations() async {
        isLoading = true
        errorMessage = nil
        do {
            conversations = try await chatService.fetchConversations()
            await chatService.subscribeToConversationUpdates { [weak self] updated in
                Task { @MainActor in
                    self?.handleConversationUpdate(updated)
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func handleConversationUpdate(_ updated: ConversationListItem) {
        if let index = conversations.firstIndex(where: { $0.id == updated.id }) {
            conversations[index] = updated
        } else {
            conversations.insert(updated, at: 0)
        }
    }
}
