import Foundation
import SwiftUI

@MainActor
final class EventSwipeViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var currentIndex = 0

    var currentEvent: Event? {
        guard currentIndex < events.count else { return nil }
        return events[currentIndex]
    }

    var nextEvent: Event? {
        guard currentIndex + 1 < events.count else { return nil }
        return events[currentIndex + 1]
    }

    private static let mockUsers: [UserProfile] = [
        UserProfile(
            name: "Emma",
            age: 26,
            avatarUrl: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop",
            interests: ["Music", "Food", "Wine"]
        ),
        UserProfile(
            name: "Sarah",
            age: 29,
            avatarUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=400&fit=crop",
            interests: ["Art", "Comedy", "Music"]
        ),
        UserProfile(
            name: "Alex",
            age: 27,
            avatarUrl: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop",
            interests: ["Music", "Outdoors", "Food"]
        ),
        UserProfile(
            name: "Michael",
            age: 30,
            avatarUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop",
            interests: ["Wine", "Music", "Art"]
        ),
        UserProfile(
            name: "Jessica",
            age: 25,
            avatarUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop",
            interests: ["Wellness", "Comedy", "Food"]
        )
    ]

    init() {
        loadMockData()
    }

    func swipeRight() {
        guard currentIndex < events.count else { return }
        currentIndex += 1
    }

    func swipeLeft() {
        guard currentIndex < events.count else { return }
        currentIndex += 1
    }

    private func loadMockData() {
        events = Self.mockEventSet1 + Self.mockEventSet2
    }

    private static var mockEventSet1: [Event] {
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
                attendees: [users[0], users[2], users[3]]
            ),
            Event(
                title: "Contemporary Art Exhibition",
                category: "Art",
                imageUrl: "https://images.unsplash.com/photo-1713779490284-a81ff6a8ffae?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
                date: "March 30, 2026",
                time: "6:00 PM",
                venue: "Modern Art Gallery",
                location: "Arts District",
                price: "$15",
                description: "Explore contemporary masterpieces and engage in meaningful conversations.",
                totalSpots: 50,
                attendees: [users[1], users[3]]
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
                attendees: [users[1], users[4]]
            )
        ]
    }

    private static var mockEventSet2: [Event] {
        let users = mockUsers
        return [
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
                attendees: [users[0], users[4]]
            ),
            Event(
                title: "Sunset Yoga Session",
                category: "Wellness",
                imageUrl: "https://images.unsplash.com/photo-1608405059861-b21a68ae76a2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
                date: "March 29, 2026",
                time: "6:30 PM",
                venue: "Beachfront Park",
                location: "Beachside",
                price: "$10",
                description: "Unwind with a relaxing yoga session as the sun sets.",
                totalSpots: 30,
                attendees: [users[4]]
            ),
            Event(
                title: "Wine Tasting Evening",
                category: "Wine",
                imageUrl: "https://images.unsplash.com/photo-1762455129210-c886b9295056?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
                date: "April 5, 2026",
                time: "7:00 PM",
                venue: "Vintage Wine Bar",
                location: "Wine District",
                price: "$45",
                description: "Sample a curated selection of wines paired with artisanal cheeses.",
                totalSpots: 25,
                attendees: [users[0], users[3]]
            )
        ]
    }
}
