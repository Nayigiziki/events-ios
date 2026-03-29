import Foundation

struct DateReview: Codable, Identifiable {
    let id: UUID
    let reviewerId: UUID
    let reviewedUserId: UUID
    let stars: Int
    let comment: String?
    let createdAt: Date?
    var reviewer: UserProfile?

    enum CodingKeys: String, CodingKey {
        case id
        case reviewerId = "reviewer_id"
        case reviewedUserId = "reviewed_user_id"
        case stars
        case comment
        case createdAt = "created_at"
        case reviewer
    }
}

protocol ReviewServiceProtocol: Sendable {
    func fetchReviews(forUserId: UUID) async throws -> [DateReview]
}
