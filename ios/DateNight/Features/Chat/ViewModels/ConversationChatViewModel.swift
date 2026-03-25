import Foundation

@MainActor
class ConversationChatViewModel: ObservableObject {
    @Published var messages: [MockMessage] = MockData.chatMessages
    @Published var messageText: String = ""
    @Published var conversationPartner: MockUser

    init(partner: MockUser) {
        self.conversationPartner = partner
    }

    func sendMessage() {
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timestamp = formatter.string(from: Date())

        let newMessage = MockMessage(
            id: UUID().uuidString,
            isSent: true,
            text: trimmed,
            timestamp: timestamp
        )
        messages.append(newMessage)
        messageText = ""
    }
}
