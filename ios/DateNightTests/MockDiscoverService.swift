@testable import DateNight
import Foundation

final class MockDiscoverService: DiscoverServiceProtocol, @unchecked Sendable {
    // MARK: - Stubs

    var stubbedUsers: [UserProfile] = []
    var stubbedSwipeResult: SwipeResult = .recorded
    var stubbedMutualMatch: Bool = false
    var stubbedError: Error?

    // MARK: - Call tracking

    var fetchNearbyUsersCalls: [DiscoverFilters] = []
    var recordSwipeCalls: [(userId: UUID, direction: SwipeDirection)] = []
    var checkMutualMatchCalls: [UUID] = []

    // MARK: - DiscoverServiceProtocol

    func fetchNearbyUsers(filters: DiscoverFilters) async throws -> [UserProfile] {
        if let error = stubbedError { throw error }
        fetchNearbyUsersCalls.append(filters)
        return stubbedUsers
    }

    func recordSwipe(userId: UUID, direction: SwipeDirection) async throws -> SwipeResult {
        if let error = stubbedError { throw error }
        recordSwipeCalls.append((userId, direction))
        return stubbedSwipeResult
    }

    func checkMutualMatch(userId: UUID) async throws -> Bool {
        if let error = stubbedError { throw error }
        checkMutualMatchCalls.append(userId)
        return stubbedMutualMatch
    }
}
