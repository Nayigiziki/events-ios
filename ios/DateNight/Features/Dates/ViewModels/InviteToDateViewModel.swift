import Foundation

@MainActor
class InviteToDateViewModel: ObservableObject {
    @Published var matches: [MockUser] = []
    @Published var friends: [MockUser] = []
    @Published var selectedInvitees: [MockUser] = []

    init() {
        loadMockData()
    }

    func toggleInvitee(_ user: MockUser) {
        if let index = selectedInvitees.firstIndex(where: { $0.id == user.id }) {
            selectedInvitees.remove(at: index)
        } else {
            selectedInvitees.append(user)
        }
    }

    func isSelected(_ user: MockUser) -> Bool {
        selectedInvitees.contains(where: { $0.id == user.id })
    }

    func sendInvitations() {
        // In a real app, send invitations via service
        selectedInvitees.removeAll()
    }

    private func loadMockData() {
        matches = Array(MockData.users.prefix(3))
        friends = Array(MockData.users.suffix(2))
    }
}
