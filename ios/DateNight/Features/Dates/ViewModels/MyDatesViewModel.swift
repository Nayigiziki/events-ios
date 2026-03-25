import Foundation

@MainActor
class MyDatesViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var upcoming: [DateRequest] = []
    @Published var past: [DateRequest] = []
    @Published var cancelled: [DateRequest] = []

    init() {
        loadMockData()
    }

    private func loadMockData() {
        let users = Self.mockUsers()
        upcoming = Self.mockUpcoming(users)
        past = Self.mockPast(users)
        cancelled = Self.mockCancelled(users)
    }
}

// MARK: - Mock Data

struct MockDateUsers {
    let emma: UserProfile
    let alex: UserProfile
    let sarah: UserProfile
    let michael: UserProfile
}

private extension MyDatesViewModel {
    static func mockUsers() -> MockDateUsers {
        let emma = UserProfile(
            id: UUID(), name: "Emma", age: 26, bio: "Jazz enthusiast and foodie",
            avatarUrl: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop",
            interests: ["Music", "Food"]
        )
        let alex = UserProfile(
            id: UUID(), name: "Alex", age: 27,
            avatarUrl: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop",
            interests: ["Music", "Outdoors"]
        )
        let sarah = UserProfile(
            id: UUID(), name: "Sarah", age: 29,
            avatarUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=400&fit=crop",
            interests: ["Art", "Comedy"]
        )
        let michael = UserProfile(
            id: UUID(), name: "Michael", age: 30,
            avatarUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop",
            interests: ["Wine", "Music"]
        )
        return MockDateUsers(emma: emma, alex: alex, sarah: sarah, michael: michael)
    }

    static func mockUpcoming(_ u: MockDateUsers) -> [DateRequest] {
        [
            DateRequest(
                id: UUID(), eventId: UUID(), organizerId: u.emma.id, maxPeople: 4,
                description: "Jazz night with friends!", dateType: .group, status: .confirmed,
                organizer: u.emma,
                event: Event(
                    title: "Jazz at Lincoln Center", category: "Music",
                    imageUrl: "https://images.unsplash.com/photo-1511192336575-5a79af67a629?w=800&h=600&fit=crop",
                    date: "April 5, 2026", time: "8:00 PM", venue: "Lincoln Center",
                    location: "New York, NY", price: "$45", description: "World-class jazz", totalSpots: 6
                ),
                attendees: [u.emma, u.alex]
            ),
            DateRequest(
                id: UUID(), eventId: UUID(), organizerId: u.sarah.id, maxPeople: 2,
                description: "Wine tasting for two", dateType: .solo, status: .open,
                organizer: u.sarah,
                event: Event(
                    title: "Wine & Paint Night", category: "Art",
                    imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=800&h=600&fit=crop",
                    date: "April 8, 2026", time: "7:00 PM", venue: "Artisan Studio",
                    location: "Brooklyn, NY", price: "$35", description: "Art and wine", totalSpots: 4
                ),
                attendees: [u.sarah]
            )
        ]
    }

    static func mockPast(_ u: MockDateUsers) -> [DateRequest] {
        [
            DateRequest(
                id: UUID(), eventId: UUID(), organizerId: u.alex.id, maxPeople: 4,
                description: "Comedy night was amazing!", dateType: .group, status: .confirmed,
                organizer: u.alex,
                event: Event(
                    title: "Rooftop Comedy Show", category: "Comedy",
                    imageUrl: "https://images.unsplash.com/photo-1585699324551-f6c309eedeca?w=800&h=600&fit=crop",
                    date: "March 15, 2026", time: "9:00 PM", venue: "SkyBar Lounge",
                    location: "Manhattan, NY", price: "$25", description: "Stand-up comedy", totalSpots: 8
                ),
                attendees: [u.alex, u.emma, u.michael]
            ),
            DateRequest(
                id: UUID(), eventId: UUID(), organizerId: u.emma.id, maxPeople: 2,
                description: "Lovely dinner experience", dateType: .solo, status: .confirmed,
                organizer: u.emma,
                event: Event(
                    title: "Farm-to-Table Dinner", category: "Food",
                    imageUrl: "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&h=600&fit=crop",
                    date: "March 10, 2026", time: "6:30 PM", venue: "Green Table",
                    location: "Chelsea, NY", price: "$65", description: "Seasonal menu", totalSpots: 4
                ),
                attendees: [u.emma]
            ),
            DateRequest(
                id: UUID(), eventId: UUID(), organizerId: u.michael.id, maxPeople: 6,
                description: "Art gallery opening", dateType: .group, status: .confirmed,
                organizer: u.michael,
                event: Event(
                    title: "Contemporary Art Exhibition", category: "Art",
                    imageUrl: "https://images.unsplash.com/photo-1531243269054-5ebf6f34081e?w=800&h=600&fit=crop",
                    date: "March 5, 2026", time: "5:00 PM", venue: "MOMA",
                    location: "Midtown, NY", price: "$20", description: "Modern art showcase", totalSpots: 6
                ),
                attendees: [u.michael, u.sarah, u.alex]
            )
        ]
    }

    static func mockCancelled(_ u: MockDateUsers) -> [DateRequest] {
        [
            DateRequest(
                id: UUID(), eventId: UUID(), organizerId: u.sarah.id, maxPeople: 4,
                description: "Had to cancel due to weather", dateType: .group, status: .cancelled,
                organizer: u.sarah,
                event: Event(
                    title: "Outdoor Film Festival", category: "Film",
                    imageUrl: "https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800&h=600&fit=crop",
                    date: "March 20, 2026", time: "7:30 PM", venue: "Central Park",
                    location: "New York, NY", price: "Free", description: "Cinema under the stars", totalSpots: 10
                ),
                attendees: [u.sarah, u.emma]
            )
        ]
    }
}
