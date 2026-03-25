import Foundation

struct DateRequest: Codable, Identifiable, Hashable {
    let id: UUID
    var eventId: UUID
    var organizerId: UUID
    var maxPeople: Int
    var description: String
    var dateType: DateType
    var status: DateRequestStatus
    var createdAt: Date?
    var organizer: UserProfile?
    var event: Event?
    var attendees: [UserProfile]?

    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case organizerId = "organizer_id"
        case maxPeople = "max_people"
        case description
        case dateType = "date_type"
        case status
        case createdAt = "created_at"
        case organizer
        case event
        case attendees
    }
}

enum DateType: String, Codable, Hashable {
    case solo
    case group
}

enum DateRequestStatus: String, Codable, Hashable {
    case open
    case full
    case confirmed
    case cancelled
}
