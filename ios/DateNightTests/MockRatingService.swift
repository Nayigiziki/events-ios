@testable import DateNight
import Foundation

final class MockRatingService: RatingServiceProtocol, @unchecked Sendable {
    // MARK: - Result Stubs

    var currentUserIdResult: Result<UUID, Error> = .success(UUID())
    var submitRatingResult: Result<Rating, Error> = .success(
        Rating(id: UUID(), raterId: UUID(), ratedUserId: UUID(), score: 5, comment: nil, createdAt: nil)
    )
    var fetchRatingsForUserResult: Result<[Rating], Error> = .success([])
    var fetchMyRatingsResult: Result<[Rating], Error> = .success([])

    // MARK: - Call Tracking

    var submitRatingCallCount = 0
    var fetchRatingsForUserCallCount = 0
    var fetchMyRatingsCallCount = 0

    var lastSubmittedRatedUserId: UUID?
    var lastSubmittedScore: Int?
    var lastSubmittedComment: String?
    var lastFetchedUserId: UUID?

    // MARK: - Protocol Implementation

    func currentUserId() async throws -> UUID {
        try currentUserIdResult.get()
    }

    func submitRating(ratedUserId: UUID, score: Int, comment: String?) async throws -> Rating {
        submitRatingCallCount += 1
        lastSubmittedRatedUserId = ratedUserId
        lastSubmittedScore = score
        lastSubmittedComment = comment
        return try submitRatingResult.get()
    }

    func fetchRatingsForUser(userId: UUID) async throws -> [Rating] {
        fetchRatingsForUserCallCount += 1
        lastFetchedUserId = userId
        return try fetchRatingsForUserResult.get()
    }

    func fetchMyRatings() async throws -> [Rating] {
        fetchMyRatingsCallCount += 1
        return try fetchMyRatingsResult.get()
    }
}
