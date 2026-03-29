import Foundation

struct ProfileStats: Codable {
    var matches: Int
    var dates: Int
    var events: Int

    init(matches: Int = 0, dates: Int = 0, events: Int = 0) {
        self.matches = matches
        self.dates = dates
        self.events = events
    }
}

struct Activity: Codable, Identifiable {
    let id: String
    let icon: String
    let iconColor: String
    let title: String
    let subtitle: String
    let timeAgo: String
}

struct ProfileUpdateRequest: Codable {
    let name: String?
    let bio: String?
    let occupation: String?
    let height: Int?
    let photos: [String]?
    let interests: [String]?
    let readyToMingle: Bool?
    let availableFrom: Date?
    let availableUntil: Date?

    enum CodingKeys: String, CodingKey {
        case name, bio, occupation, height, photos, interests
        case readyToMingle = "ready_to_mingle"
        case availableFrom = "available_from"
        case availableUntil = "available_until"
    }
}

protocol ProfileServiceProtocol: Sendable {
    func fetchProfile(userId: UUID) async throws -> UserProfile
    func updateProfile(_ request: ProfileUpdateRequest, userId: UUID) async throws
    func fetchStats(userId: UUID) async throws -> ProfileStats
    func fetchActivity(userId: UUID) async throws -> [Activity]
    func uploadPhoto(data: Data, userId: UUID) async throws -> String
    func deleteAccount() async throws
}

protocol PreferencesServiceProtocol: Sendable {
    func fetchPreferences(userId: UUID) async throws -> MatchPreferences
    func savePreferences(_ prefs: MatchPreferences, userId: UUID) async throws
}

struct MatchPreferences: Codable {
    var ageMin: Int
    var ageMax: Int
    var distance: Int
    var relationshipTypes: [String]
    var interests: [String]
    var genderPreference: String?

    enum CodingKeys: String, CodingKey {
        case ageMin = "age_min"
        case ageMax = "age_max"
        case distance
        case relationshipTypes = "relationship_types"
        case interests
        case genderPreference = "gender_preference"
    }

    init(
        ageMin: Int = 18,
        ageMax: Int = 35,
        distance: Int = 25,
        relationshipTypes: [String] = [],
        interests: [String] = [],
        genderPreference: String? = nil
    ) {
        self.ageMin = ageMin
        self.ageMax = ageMax
        self.distance = distance
        self.relationshipTypes = relationshipTypes
        self.interests = interests
        self.genderPreference = genderPreference
    }
}
