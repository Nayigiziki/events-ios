@testable import DateNight
import Foundation

final class MockInviteService: InviteServiceProtocol, @unchecked Sendable {
    var stubbedMatches: [UserProfile] = []
    var stubbedFriends: [UserProfile] = []
    var stubbedError: Error?

    var fetchMatchesCalled = false
    var fetchFriendsCalled = false
    var sendInvitationsCalls: [(dateRequestId: UUID, userIds: [UUID])] = []

    func fetchMatches() async throws -> [UserProfile] {
        if let error = stubbedError { throw error }
        fetchMatchesCalled = true
        return stubbedMatches
    }

    func fetchFriends() async throws -> [UserProfile] {
        if let error = stubbedError { throw error }
        fetchFriendsCalled = true
        return stubbedFriends
    }

    func sendInvitations(dateRequestId: UUID, userIds: [UUID]) async throws {
        if let error = stubbedError { throw error }
        sendInvitationsCalls.append((dateRequestId, userIds))
    }
}
