@testable import DateNight
import Foundation

final class MockReviewService: ReviewServiceProtocol, @unchecked Sendable {
    var fetchCallCount = 0
    var shouldFail = false
    var stubbedReviews: [DateReview] = []

    func fetchReviews(forUserId: UUID) async throws -> [DateReview] {
        fetchCallCount += 1
        if shouldFail {
            throw NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Fetch failed"])
        }
        return stubbedReviews
    }
}
