import Foundation

@MainActor
class DateDetailViewModel: ObservableObject {
    @Published var dateRequest: DateRequest
    @Published var showChat = false

    init(dateRequest: DateRequest) {
        self.dateRequest = dateRequest
    }

    func confirm() {
        dateRequest.status = .confirmed
    }

    func cancel() {
        dateRequest.status = .cancelled
    }

    func openChat() {
        showChat = true
    }

    // MARK: - Display Helpers

    var statusDisplay: String {
        switch dateRequest.status {
        case .open: "Pending"
        case .full: "Pending"
        case .confirmed: "Confirmed"
        case .cancelled: "Cancelled"
        }
    }

    var isCompleted: Bool {
        // In a real app, check if the event date has passed
        false
    }

    // MARK: - Mock Data

    static let mockDateRequest: DateRequest = {
        let organizer = UserProfile(
            id: UUID(),
            name: "Emma",
            age: 26,
            bio: "Jazz enthusiast and foodie",
            avatarUrl: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop",
            interests: ["Music", "Food", "Wine"]
        )

        let attendees = [
            organizer,
            UserProfile(
                id: UUID(),
                name: "Alex",
                age: 27,
                avatarUrl: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop",
                interests: ["Music", "Outdoors"]
            ),
            UserProfile(
                id: UUID(),
                name: "Sarah",
                age: 29,
                avatarUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=400&fit=crop",
                interests: ["Art", "Comedy"]
            )
        ]

        let event = Event(
            title: "Jazz at Lincoln Center",
            category: "Music",
            imageUrl: "https://images.unsplash.com/photo-1511192336575-5a79af67a629?w=800&h=600&fit=crop",
            date: "April 5, 2026",
            time: "8:00 PM",
            venue: "Lincoln Center",
            location: "New York, NY",
            price: "$45",
            description: "An evening of world-class jazz performances",
            totalSpots: 6
        )

        return DateRequest(
            id: UUID(),
            eventId: event.id,
            organizerId: organizer.id,
            maxPeople: 6,
            description: "Looking for jazz lovers to enjoy a great night out!",
            dateType: .group,
            status: .confirmed,
            organizer: organizer,
            event: event,
            attendees: attendees
        )
    }()
}
