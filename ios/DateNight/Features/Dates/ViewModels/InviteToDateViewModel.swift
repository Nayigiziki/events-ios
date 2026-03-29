import Foundation

@MainActor
class InviteToDateViewModel: ObservableObject {
    @Published var matches: [UserProfile] = []
    @Published var friends: [UserProfile] = []
    @Published var selectedInvitees: [UserProfile] = []
    @Published var isLoading: Bool = false
    @Published var isSending: Bool = false
    @Published var errorMessage: String?
    @Published var invitationsSent: Bool = false

    private let inviteService: any InviteServiceProtocol
    var dateRequestId: UUID?

    init(inviteService: any InviteServiceProtocol = SupabaseInviteService(), dateRequestId: UUID? = nil) {
        self.inviteService = inviteService
        self.dateRequestId = dateRequestId
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil
        do {
            async let matchesResult = inviteService.fetchMatches()
            async let friendsResult = inviteService.fetchFriends()
            let (m, f) = try await (matchesResult, friendsResult)
            matches = m
            friends = f
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func toggleInvitee(_ user: UserProfile) {
        if let index = selectedInvitees.firstIndex(where: { $0.id == user.id }) {
            selectedInvitees.remove(at: index)
        } else {
            selectedInvitees.append(user)
        }
    }

    func isSelected(_ user: UserProfile) -> Bool {
        selectedInvitees.contains(where: { $0.id == user.id })
    }

    func sendInvitations() async {
        guard let dateRequestId, !selectedInvitees.isEmpty else { return }
        isSending = true
        errorMessage = nil
        do {
            try await inviteService.sendInvitations(
                dateRequestId: dateRequestId,
                userIds: selectedInvitees.map(\.id)
            )
            invitationsSent = true
            selectedInvitees.removeAll()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSending = false
    }
}
