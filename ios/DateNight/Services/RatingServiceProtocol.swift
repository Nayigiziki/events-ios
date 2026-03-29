import Foundation

struct Rating: Identifiable, Codable, Hashable {
    let id: UUID
    let raterId: UUID
    let ratedUserId: UUID
    let score: Int
    let comment: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case raterId = "rater_id"
        case ratedUserId = "rated_user_id"
        case score
        case comment
        case createdAt = "created_at"
    }
}

protocol RatingServiceProtocol: Sendable {
    func submitRating(ratedUserId: UUID, score: Int, comment: String?) async throws -> Rating
    func fetchRatingsForUser(userId: UUID) async throws -> [Rating]
    func fetchMyRatings() async throws -> [Rating]
    func currentUserId() async throws -> UUID
}
