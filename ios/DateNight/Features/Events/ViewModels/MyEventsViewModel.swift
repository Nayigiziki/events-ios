import Foundation
import SwiftUI

@MainActor
final class MyEventsViewModel: ObservableObject {
    enum Tab: String, CaseIterable {
        case created = "Created"
        case attending = "Attending"
    }

    @Published var selectedTab: Tab = .created
    @Published var createdEvents: [Event] = []
    @Published var attendingEvents: [Event] = []

    private static let mockUsers: [UserProfile] = [
        UserProfile(
            name: "Emma",
            age: 26,
            avatarUrl: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop",
            interests: ["Music", "Food"]
        ),
        UserProfile(
            name: "Alex",
            age: 27,
            avatarUrl: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop",
            interests: ["Music", "Outdoors"]
        ),
        UserProfile(
            name: "Sarah",
            age: 29,
            avatarUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=400&fit=crop",
            interests: ["Art", "Comedy"]
        )
    ]

    init() {
        loadMockData()
    }

    func deleteEvent(_ event: Event) {
        createdEvents.removeAll { $0.id == event.id }
    }

    func editEvent(_: Event) {
        // Mock — will navigate to edit screen later
    }

    private func loadMockData() {
        createdEvents = Self.mockCreatedEvents
        attendingEvents = Self.mockAttendingEvents
    }

    private static var mockCreatedEvents: [Event] {
        let users = mockUsers
        return [
            Event(
                title: "Rooftop Jazz Night",
                category: "Music",
                imageUrl: "https://images.unsplash.com/photo-1757439160077-dd5d62a4d851?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
                date: "April 10, 2026",
                time: "8:00 PM",
                venue: "Sky Lounge",
                location: "Downtown",
                price: "$30",
                description: "An intimate rooftop jazz session under the stars.",
                totalSpots: 40,
                attendees: [users[0], users[1]]
            ),
            Event(
                title: "Wine & Paint Social",
                category: "Art",
                imageUrl: "https://images.unsplash.com/photo-1713779490284-a81ff6a8ffae?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
                date: "April 15, 2026",
                time: "6:30 PM",
                venue: "Creative Studio",
                location: "Arts District",
                price: "$25",
                description: "Paint, sip, and mingle at this creative social evening.",
                totalSpots: 20,
                attendees: [users[2]]
            )
        ]
    }

    private static var mockAttendingEvents: [Event] {
        let users = mockUsers
        return [
            Event(
                title: "Indie Rock Night",
                category: "Music",
                imageUrl: "https://images.unsplash.com/photo-1604364260242-1156640c0dfb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
                date: "March 28, 2026",
                time: "8:00 PM",
                venue: "The Electric Ballroom",
                location: "Downtown",
                price: "$25",
                description: "Experience an unforgettable night with local indie bands.",
                totalSpots: 200,
                attendees: [users[0], users[1], users[2]]
            ),
            Event(
                title: "Comedy Open Mic",
                category: "Comedy",
                imageUrl: "https://images.unsplash.com/photo-1648237409808-aa4649c07ec8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
                date: "March 26, 2026",
                time: "7:30 PM",
                venue: "Laugh Factory",
                location: "Midtown",
                price: "$20",
                description: "Laugh the night away with up-and-coming comedians.",
                totalSpots: 100,
                attendees: [users[2]]
            ),
            Event(
                title: "Street Food Festival",
                category: "Food",
                imageUrl: "https://images.unsplash.com/photo-1551883738-19ffa3dc4c43?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
                date: "April 2, 2026",
                time: "12:00 PM",
                venue: "Central Park",
                location: "Central Park",
                price: "Free Entry",
                description: "Sample cuisines from around the world in a vibrant outdoor setting.",
                totalSpots: 500,
                attendees: [users[0]]
            )
        ]
    }
}
