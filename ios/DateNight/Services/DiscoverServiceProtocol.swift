import Foundation

struct DiscoverFilters: Equatable {
    var minAge: Int = 18
    var maxAge: Int = 60
    var maxDistance: Int = 25
    var interests: Set<String> = []
    var genderPreference: String?
}

enum SwipeResult: Equatable {
    case recorded
    case matched(Match)
}

protocol DiscoverServiceProtocol: Sendable {
    func fetchNearbyUsers(filters: DiscoverFilters) async throws -> [UserProfile]
    func recordSwipe(userId: UUID, direction: SwipeDirection) async throws -> SwipeResult
    func checkMutualMatch(userId: UUID) async throws -> Bool
}
