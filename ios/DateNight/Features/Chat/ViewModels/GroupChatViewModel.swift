import Foundation

struct GroupMessage: Identifiable, Hashable {
    let id: String
    let senderId: String
    let senderName: String
    let senderAvatar: String
    let isSent: Bool
    let text: String
    let timestamp: String
}

@MainActor
class GroupChatViewModel: ObservableObject {
    @Published var messages: [GroupMessage] = []
    @Published var participants: [MockUser] = []
    @Published var groupName: String
    @Published var messageText: String = ""
    @Published var showParticipants = false

    init(groupName: String = "Jazz Club Date") {
        self.groupName = groupName
        loadMockData()
    }

    func sendMessage() {
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timestamp = formatter.string(from: Date())

        let newMessage = GroupMessage(
            id: UUID().uuidString,
            senderId: MockData.currentUser.id,
            senderName: MockData.currentUser.name,
            senderAvatar: MockData.currentUser.avatar,
            isSent: true,
            text: trimmed,
            timestamp: timestamp
        )
        messages.append(newMessage)
        messageText = ""
    }

    func addParticipant(_ user: MockUser) {
        guard !participants.contains(where: { $0.id == user.id }) else { return }
        participants.append(user)
    }

    // MARK: - Mock Data

    // swiftlint:disable:next function_body_length
    private func loadMockData() {
        let emma = MockData.users[0]
        let sarah = MockData.users[1]
        let alex = MockData.users[2]
        participants = [emma, sarah, alex]

        messages = [
            GroupMessage(
                id: "g1",
                senderId: emma.id,
                senderName: emma.name,
                senderAvatar: emma.avatar,
                isSent: false,
                text: "Hey everyone! Excited for the jazz night!",
                timestamp: "14:00"
            ),
            GroupMessage(
                id: "g2",
                senderId: "current-user",
                senderName: "You",
                senderAvatar: MockData.currentUser.avatar,
                isSent: true,
                text: "Me too! I've been looking forward to this all week",
                timestamp: "14:02"
            ),
            GroupMessage(
                id: "g3",
                senderId: sarah.id,
                senderName: sarah.name,
                senderAvatar: sarah.avatar,
                isSent: false,
                text: "Should we grab dinner before the show?",
                timestamp: "14:05"
            ),
            GroupMessage(
                id: "g4",
                senderId: alex.id,
                senderName: alex.name,
                senderAvatar: alex.avatar,
                isSent: false,
                text: "Great idea! I know a place nearby",
                timestamp: "14:06"
            ),
            GroupMessage(
                id: "g5",
                senderId: "current-user",
                senderName: "You",
                senderAvatar: MockData.currentUser.avatar,
                isSent: true,
                text: "That sounds perfect! What time should we meet?",
                timestamp: "14:08"
            ),
            GroupMessage(
                id: "g6",
                senderId: emma.id,
                senderName: emma.name,
                senderAvatar: emma.avatar,
                isSent: false,
                text: "How about 6:30? That gives us plenty of time",
                timestamp: "14:10"
            ),
            GroupMessage(
                id: "g7",
                senderId: sarah.id,
                senderName: sarah.name,
                senderAvatar: sarah.avatar,
                isSent: false,
                text: "6:30 works for me!",
                timestamp: "14:11"
            ),
            GroupMessage(
                id: "g8",
                senderId: alex.id,
                senderName: alex.name,
                senderAvatar: alex.avatar,
                isSent: false,
                text: "Perfect, see you all there!",
                timestamp: "14:12"
            )
        ]
    }
}
