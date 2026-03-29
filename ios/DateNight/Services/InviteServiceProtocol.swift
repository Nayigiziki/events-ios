import Foundation

protocol InviteServiceProtocol: Sendable {
    func fetchMatches() async throws -> [UserProfile]
    func fetchFriends() async throws -> [UserProfile]
    func sendInvitations(dateRequestId: UUID, userIds: [UUID]) async throws
}
