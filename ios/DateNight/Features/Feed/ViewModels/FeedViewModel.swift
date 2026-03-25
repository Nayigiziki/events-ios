import Foundation
import SwiftUI

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var selectedCategory: String = "All"
    @Published var likedEvents: Set<String> = []
    @Published var isLoading = false

    let categories = ["All", "Music", "Art", "Comedy", "Food", "Wellness", "Wine", "Social"]

    var filteredEvents: [Event] {
        if selectedCategory == "All" {
            return events
        }
        return events.filter { $0.category == selectedCategory }
    }

    init() {
        loadMockData()
    }

    func toggleLike(eventId: String) {
        if likedEvents.contains(eventId) {
            likedEvents.remove(eventId)
        } else {
            likedEvents.insert(eventId)
        }
    }

    func refresh() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 500_000_000)
        loadMockData()
        isLoading = false
    }

    // MARK: - Mock Data

    private static let mockUsers: [UserProfile] = [
        UserProfile(
            name: "Emma",
            age: 26,
            bio: "Jazz enthusiast and foodie",
            avatarUrl: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop",
            interests: ["Music", "Food", "Wine"]
        ),
        UserProfile(
            name: "Sarah",
            age: 29,
            bio: "Art lover, comedy fan",
            avatarUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=400&fit=crop",
            interests: ["Art", "Comedy", "Music"]
        ),
        UserProfile(
            name: "Alex",
            age: 27,
            bio: "Concert junkie and outdoor enthusiast",
            avatarUrl: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop",
            interests: ["Music", "Outdoors", "Food"]
        ),
        UserProfile(
            name: "Michael",
            age: 30,
            bio: "Wine connoisseur, live music fan",
            avatarUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop",
            interests: ["Wine", "Music", "Art"]
        ),
        UserProfile(
            name: "Jessica",
            age: 25,
            bio: "Yoga instructor who loves comedy shows",
            avatarUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop",
            interests: ["Wellness", "Comedy", "Food"]
        ),
        UserProfile(
            name: "David",
            age: 31,
            bio: "Food festival explorer",
            avatarUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop",
            interests: ["Food", "Music", "Art"]
        )
    ]

    private func loadMockData() {
        let users = Self.mockUsers
        events = Self.makeMockEvents(users: users)
    }

    // swiftlint:disable:next function_body_length
    private static func makeMockEvents(users: [UserProfile]) -> [Event] {
        [
            Event(
                title: "Indie Rock Night",
                category: "Music",
                imageUrl: "https://images.unsplash.com/photo-1604364260242-1156640c0dfb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
                date: "March 28, 2026",
                time: "8:00 PM",
                venue: "The Electric Ballroom",
                location: "Downtown",
                price: "$25",
                description: "Experience an unforgettable night with local indie bands. Great vibes, amazing music, and the perfect atmosphere for meeting new people.",
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
                description: "Explore contemporary masterpieces and engage in meaningful conversations about art. Wine and cheese included.",
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
                description: "Laugh the night away with up-and-coming comedians. Two-drink minimum, unlimited laughs guaranteed.",
                totalSpots: 100,
                attendees: [users[1], users[4]]
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
                description: "Sample cuisines from around the world in a vibrant outdoor setting. Live music and entertainment all day.",
                totalSpots: 500,
                attendees: [users[0], users[5]]
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
                description: "Unwind with a relaxing yoga session as the sun sets. All levels welcome. Stay for refreshments after.",
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
                description: "Sample a curated selection of wines from around the world paired with artisanal cheeses and charcuterie.",
                totalSpots: 25,
                attendees: [users[0], users[3]]
            ),
            Event(
                title: "Jazz Night Live",
                category: "Music",
                imageUrl: "https://images.unsplash.com/photo-1757439160077-dd5d62a4d851?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
                date: "April 1, 2026",
                time: "9:00 PM",
                venue: "Blue Note Club",
                location: "Jazz Quarter",
                price: "$30",
                description: "Smooth jazz performances in an intimate club setting. Perfect date night atmosphere with craft cocktails.",
                totalSpots: 60,
                attendees: [users[0], users[3]]
            ),
            Event(
                title: "Rooftop Summer Kickoff",
                category: "Social",
                imageUrl: "https://images.unsplash.com/photo-1644589075956-a2526d00fd31?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
                date: "April 8, 2026",
                time: "5:00 PM",
                venue: "Sky Lounge",
                location: "Downtown",
                price: "$35",
                description: "Celebrate the season with stunning city views, DJ sets, and premium cocktails. Dress to impress!",
                totalSpots: 150,
                attendees: [users[1], users[2], users[5]]
            )
        ]
    }
}
