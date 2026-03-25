import Foundation

struct UserProfile: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var age: Int?
    var bio: String?
    var avatarUrl: String?
    var photos: [String]
    var interests: [String]
    var location: String?
    var occupation: String?
    var height: Int?
    var gender: String?
    var birthdate: Date?
    var readyToMingle: Bool
    var availableFrom: Date?
    var availableUntil: Date?
    var createdAt: Date?
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case age
        case bio
        case avatarUrl = "avatar_url"
        case photos
        case interests
        case location
        case occupation
        case height
        case gender
        case birthdate
        case readyToMingle = "ready_to_mingle"
        case availableFrom = "available_from"
        case availableUntil = "available_until"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(
        id: UUID = UUID(),
        name: String,
        age: Int? = nil,
        bio: String? = nil,
        avatarUrl: String? = nil,
        photos: [String] = [],
        interests: [String] = [],
        location: String? = nil,
        occupation: String? = nil,
        height: Int? = nil,
        gender: String? = nil,
        birthdate: Date? = nil,
        readyToMingle: Bool = true,
        availableFrom: Date? = nil,
        availableUntil: Date? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.bio = bio
        self.avatarUrl = avatarUrl
        self.photos = photos
        self.interests = interests
        self.location = location
        self.occupation = occupation
        self.height = height
        self.gender = gender
        self.birthdate = birthdate
        self.readyToMingle = readyToMingle
        self.availableFrom = availableFrom
        self.availableUntil = availableUntil
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
