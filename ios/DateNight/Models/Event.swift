import Foundation

struct Event: Codable, Identifiable, Hashable {
    let id: UUID
    var title: String
    var category: String
    var imageUrl: String?
    var date: String
    var time: String
    var venue: String
    var location: String
    var price: String
    var description: String
    var totalSpots: Int
    var isPublic: Bool
    var createdBy: UUID?
    var createdAt: Date?
    var attendees: [UserProfile]?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case category
        case imageUrl = "image_url"
        case date
        case time
        case venue
        case location
        case price
        case description
        case totalSpots = "total_spots"
        case isPublic = "is_public"
        case createdBy = "created_by"
        case createdAt = "created_at"
        case attendees
    }

    init(
        id: UUID = UUID(),
        title: String,
        category: String,
        imageUrl: String? = nil,
        date: String,
        time: String,
        venue: String,
        location: String,
        price: String,
        description: String,
        totalSpots: Int,
        isPublic: Bool = true,
        createdBy: UUID? = nil,
        createdAt: Date? = nil,
        attendees: [UserProfile]? = nil
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.imageUrl = imageUrl
        self.date = date
        self.time = time
        self.venue = venue
        self.location = location
        self.price = price
        self.description = description
        self.totalSpots = totalSpots
        self.isPublic = isPublic
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.attendees = attendees
    }
}
