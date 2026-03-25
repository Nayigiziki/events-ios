import Foundation

// MARK: - Mock Data

enum DiscoverMockData {
    static let users: [UserProfile] = [
        UserProfile(
            name: "Emma",
            age: 26,
            bio: "Jazz enthusiast and foodie. Always down for a spontaneous night out.",
            avatarUrl: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop",
            photos: [
                "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=800&h=800&fit=crop",
                "https://images.unsplash.com/photo-1675663351050-89949e051c38?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMGNvZmZlZSUyMGxpZmVzdHlsZXxlbnwxfHx8fDE3NzQzMTQ0MDJ8MA&ixlib=rb-4.1.0&q=80&w=1080"
            ],
            interests: ["Music", "Food", "Wine", "Jazz"]
        ),
        UserProfile(
            name: "Sarah",
            age: 29,
            bio: "Art lover and comedy fan. Looking for someone to explore galleries with.",
            avatarUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=400&fit=crop",
            photos: [
                "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&h=800&fit=crop",
                "https://images.unsplash.com/photo-1652375186211-805106e54556?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMGFydCUyMG11c2V1bXxlbnwxfHx8fDE3NzQzMTQ0MDJ8MA&ixlib=rb-4.1.0&q=80&w=1080"
            ],
            interests: ["Art", "Comedy", "Music", "Theater"]
        ),
        UserProfile(
            name: "Alex",
            age: 27,
            bio: "Concert junkie and outdoor enthusiast. Let's catch a show together!",
            avatarUrl: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop",
            photos: [
                "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800&h=800&fit=crop",
                "https://images.unsplash.com/photo-1650965238931-8f642566fb57?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBoaWtpbmclMjBtb3VudGFpbnN8ZW58MXx8fHwxNzc0MjYxNjIyfDA&ixlib=rb-4.1.0&q=80&w=1080"
            ],
            interests: ["Music", "Outdoors", "Food", "Sports"]
        ),
        UserProfile(
            name: "Michael",
            age: 30,
            bio: "Wine connoisseur and live music fan. Appreciate the finer things.",
            avatarUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop",
            photos: [
                "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800&h=800&fit=crop",
                "https://images.unsplash.com/photo-1765175095011-7c31690b4e48?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBwb3J0cmFpdCUyMGNvbmZpZGVudHxlbnwxfHx8fDE3NzQyODMyOTJ8MA&ixlib=rb-4.1.0&q=80&w=1080"
            ],
            interests: ["Wine", "Music", "Art", "Dining"]
        ),
        UserProfile(
            name: "Jessica",
            age: 25,
            bio: "Yoga instructor who loves comedy shows. Good vibes only!",
            avatarUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop",
            photos: [
                "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800&h=800&fit=crop",
                "https://images.unsplash.com/photo-1727206842092-f4a602899f91?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMG91dGRvb3IlMjBhZHZlbnR1cmV8ZW58MXx8fHwxNzc0MjkwNDA4fDA&ixlib=rb-4.1.0&q=80&w=1080"
            ],
            interests: ["Wellness", "Comedy", "Food", "Yoga"]
        ),
        UserProfile(
            name: "David",
            age: 31,
            bio: "Food festival explorer. Always searching for the next great bite.",
            avatarUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop",
            photos: [
                "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=800&fit=crop",
                "https://images.unsplash.com/photo-1632226390535-2f02c1a93541?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBjaXR5JTIwc3R5bGV8ZW58MXx8fHwxNzc0MzE0NDAzfDA&ixlib=rb-4.1.0&q=80&w=1080"
            ],
            interests: ["Food", "Music", "Art", "Travel"]
        )
    ]

    static let events: [Event] = [
        Event(
            title: "Indie Rock Night",
            category: "Music",
            imageUrl: "https://images.unsplash.com/photo-1604364260242-1156640c0dfb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxsaXZlJTIwbXVzaWMlMjBjb25jZXJ0JTIwY3Jvd2R8ZW58MXx8fHwxNzc0MjcxNDAzfDA&ixlib=rb-4.1.0&q=80&w=1080",
            date: "March 28, 2026",
            time: "8:00 PM",
            venue: "The Electric Ballroom",
            location: "Downtown",
            price: "$25",
            description: "Experience an unforgettable night with local indie bands.",
            totalSpots: 200
        ),
        Event(
            title: "Contemporary Art Exhibition",
            category: "Art",
            imageUrl: "https://images.unsplash.com/photo-1713779490284-a81ff6a8ffae?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhcnQlMjBnYWxsZXJ5JTIwZXhoaWJpdGlvbnxlbnwxfHx8fDE3NzQzMTI4NDh8MA&ixlib=rb-4.1.0&q=80&w=1080",
            date: "March 30, 2026",
            time: "6:00 PM",
            venue: "Modern Art Gallery",
            location: "Arts District",
            price: "$15",
            description: "Explore contemporary masterpieces. Wine and cheese included.",
            totalSpots: 50
        ),
        Event(
            title: "Jazz Night Live",
            category: "Music",
            imageUrl: "https://images.unsplash.com/photo-1757439160077-dd5d62a4d851?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxqYXp6JTIwY2x1YiUyMHBlcmZvcm1hbmNlfGVufDF8fHx8MTc3NDMxMjg1MHww&ixlib=rb-4.1.0&q=80&w=1080",
            date: "April 1, 2026",
            time: "9:00 PM",
            venue: "Blue Note Club",
            location: "Jazz Quarter",
            price: "$30",
            description: "Smooth jazz in an intimate club setting. Craft cocktails available.",
            totalSpots: 60
        ),
        Event(
            title: "Street Food Festival",
            category: "Food",
            imageUrl: "https://images.unsplash.com/photo-1551883738-19ffa3dc4c43?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmb29kJTIwZmVzdGl2YWwlMjBzdHJlZXR8ZW58MXx8fHwxNzc0MjcyNjAxfDA&ixlib=rb-4.1.0&q=80&w=1080",
            date: "April 2, 2026",
            time: "12:00 PM",
            venue: "Central Park",
            location: "Central Park",
            price: "Free Entry",
            description: "Sample cuisines from around the world in a vibrant outdoor setting.",
            totalSpots: 500
        )
    ]

    static let dateRequests: [DateRequest] = [
        DateRequest(
            id: UUID(),
            eventId: events[0].id,
            organizerId: users[0].id,
            maxPeople: 4,
            description: "Looking for 2 more music lovers to join us for this show!",
            dateType: .group,
            status: .open,
            organizer: users[0],
            event: events[0],
            attendees: [users[0], users[2]]
        ),
        DateRequest(
            id: UUID(),
            eventId: events[1].id,
            organizerId: users[1].id,
            maxPeople: 2,
            description: "Art gallery date — would love to meet someone who appreciates contemporary art.",
            dateType: .solo,
            status: .open,
            organizer: users[1],
            event: events[1],
            attendees: [users[1]]
        ),
        DateRequest(
            id: UUID(),
            eventId: events[2].id,
            organizerId: users[3].id,
            maxPeople: 2,
            description: "Intimate jazz night for two. Love smooth jazz and good conversation.",
            dateType: .solo,
            status: .full,
            organizer: users[3],
            event: events[2],
            attendees: [users[3], users[0]]
        ),
        DateRequest(
            id: UUID(),
            eventId: events[3].id,
            organizerId: users[5].id,
            maxPeople: 6,
            description: "Group food crawl! Let's explore every stall together.",
            dateType: .group,
            status: .confirmed,
            organizer: users[5],
            event: events[3],
            attendees: [users[5], users[2], users[4]]
        )
    ]
}

// MARK: - DiscoverViewModel

@MainActor
class DiscoverViewModel: ObservableObject {
    @Published var users: [UserProfile] = DiscoverMockData.users
    @Published var currentIndex: Int = 0
    @Published var showFilters: Bool = false
    @Published var showMatchDetail: Bool = false
    @Published var matchedUser: UserProfile?

    var currentUser: UserProfile? {
        guard currentIndex < users.count else { return nil }
        return users[currentIndex]
    }

    var nextUser: UserProfile? {
        guard currentIndex + 1 < users.count else { return nil }
        return users[currentIndex + 1]
    }

    func swipeRight(userId: UUID) {
        let liked = currentUser
        print("Liked: \(liked?.name ?? "unknown")")

        // Mock: 30% chance of mutual match
        let isMutualMatch = Double.random(in: 0 ... 1) < 0.3
        if isMutualMatch, let liked {
            matchedUser = liked
            advanceIndex()
            showMatchDetail = true
        } else {
            advanceIndex()
        }
    }

    func swipeLeft(userId: UUID) {
        print("Passed: \(currentUser?.name ?? "unknown")")
        advanceIndex()
    }

    func dismissMatch() {
        showMatchDetail = false
        matchedUser = nil
    }

    private func advanceIndex() {
        if currentIndex < users.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
    }
}
