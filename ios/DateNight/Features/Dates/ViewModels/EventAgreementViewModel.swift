import Foundation

@MainActor
class EventAgreementViewModel: ObservableObject {
    @Published var availableEvents: [Event] = []
    @Published var proposedByMe: Event?
    @Published var proposedByThem: Event?
    @Published var agreedEvent: Event?
    @Published var showConfirmation = false

    init() {
        loadMockData()
    }

    func proposeEvent(_ event: Event) {
        proposedByMe = event
        checkAgreement()
    }

    func acceptProposal() {
        guard let proposed = proposedByThem else { return }
        agreedEvent = proposed
        withAnimationTrigger()
    }

    func rejectProposal() {
        proposedByThem = nil
    }

    func confirmDate() {
        // Navigate or finalize the agreed event
    }

    // MARK: - Private

    private func checkAgreement() {
        if let mine = proposedByMe, let theirs = proposedByThem, mine.id == theirs.id {
            agreedEvent = mine
            withAnimationTrigger()
        }
    }

    private func withAnimationTrigger() {
        showConfirmation = true
    }

    private func loadMockData() {
        availableEvents = Self.mockAvailableEvents
        // Mock: the other person proposed the second event
        proposedByThem = availableEvents[1]
    }

    private static var mockAvailableEvents: [Event] {
        [
            Event(
                title: "Jazz at Lincoln Center",
                category: "Music",
                imageUrl: "https://images.unsplash.com/photo-1511192336575-5a79af67a629?w=800&h=600&fit=crop",
                date: "April 5, 2026",
                time: "8:00 PM",
                venue: "Lincoln Center",
                location: "New York, NY",
                price: "$45",
                description: "World-class jazz performances",
                totalSpots: 6
            ),
            Event(
                title: "Wine & Paint Night",
                category: "Art",
                imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=800&h=600&fit=crop",
                date: "April 8, 2026",
                time: "7:00 PM",
                venue: "Artisan Studio",
                location: "Brooklyn, NY",
                price: "$35",
                description: "Create art while enjoying fine wine",
                totalSpots: 4
            ),
            Event(
                title: "Rooftop Comedy Show",
                category: "Comedy",
                imageUrl: "https://images.unsplash.com/photo-1585699324551-f6c309eedeca?w=800&h=600&fit=crop",
                date: "April 10, 2026",
                time: "9:00 PM",
                venue: "SkyBar Lounge",
                location: "Manhattan, NY",
                price: "$25",
                description: "Stand-up comedy under the stars",
                totalSpots: 8
            ),
            Event(
                title: "Farm-to-Table Dinner",
                category: "Food",
                imageUrl: "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&h=600&fit=crop",
                date: "April 12, 2026",
                time: "6:30 PM",
                venue: "Green Table",
                location: "Chelsea, NY",
                price: "$65",
                description: "Seasonal tasting menu experience",
                totalSpots: 4
            )
        ]
    }
}
