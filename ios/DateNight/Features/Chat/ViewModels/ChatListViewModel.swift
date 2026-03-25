import Foundation

@MainActor
class ChatListViewModel: ObservableObject {
    @Published var conversations: [MockConversation] = MockData.conversations
    @Published var searchText: String = ""

    var filteredConversations: [MockConversation] {
        if searchText.isEmpty {
            return conversations
        }
        let query = searchText.lowercased()
        return conversations.filter { conversation in
            let name = conversation.isGroup
                ? (conversation.groupName ?? conversation.user.name)
                : conversation.user.name
            return name.lowercased().contains(query)
                || conversation.lastMessage.lowercased().contains(query)
        }
    }
}
