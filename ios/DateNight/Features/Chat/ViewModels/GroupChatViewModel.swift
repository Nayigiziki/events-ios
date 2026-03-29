import Foundation

@MainActor
class GroupChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var participants: [UserProfile] = []
    @Published var groupName: String
    @Published var messageText: String = ""
    @Published var showParticipants = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published private(set) var currentUserId: UUID?

    let conversationId: UUID
    private let chatService: any ChatServiceProtocol

    init(
        conversationId: UUID,
        groupName: String = "Group Chat",
        chatService: any ChatServiceProtocol = SupabaseChatService()
    ) {
        self.conversationId = conversationId
        self.groupName = groupName
        self.chatService = chatService
    }

    func loadMessages() async {
        isLoading = true
        errorMessage = nil
        do {
            currentUserId = try await chatService.currentUserId()
            messages = try await chatService.fetchMessages(conversationId: conversationId)
            await chatService.subscribeToMessages(conversationId: conversationId) { [weak self] message in
                Task { @MainActor in
                    self?.handleIncomingMessage(message)
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func sendMessage() async {
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        messageText = ""
        do {
            let sent = try await chatService.sendMessage(
                conversationId: conversationId,
                content: trimmed,
                messageType: .text
            )
            if !messages.contains(where: { $0.id == sent.id }) {
                messages.append(sent)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func cleanup() {
        Task {
            await chatService.unsubscribe()
        }
    }

    private func handleIncomingMessage(_ message: Message) {
        guard !messages.contains(where: { $0.id == message.id }) else { return }
        messages.append(message)
    }
}
