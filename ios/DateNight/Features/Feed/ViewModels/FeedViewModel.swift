import Foundation
import SwiftUI

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var selectedCategory: String = "All"
    @Published var likedEventIds: Set<UUID> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var hasMorePages = true

    let categories = ["All", "Music", "Art", "Comedy", "Food", "Wellness", "Wine", "Social"]

    private let eventService: any EventServiceProtocol
    private let pageSize = 20

    var filteredEvents: [Event] {
        if selectedCategory == "All" {
            return events
        }
        return events.filter { $0.category == selectedCategory }
    }

    var isEmpty: Bool {
        !isLoading && events.isEmpty
    }

    // Legacy computed property for views still using string-based liked check
    var likedEvents: Set<String> {
        Set(likedEventIds.map(\.uuidString))
    }

    init(eventService: any EventServiceProtocol = SupabaseEventService()) {
        self.eventService = eventService
    }

    func loadEvents() async {
        isLoading = true
        errorMessage = nil
        do {
            let category = selectedCategory == "All" ? nil : selectedCategory
            let fetched = try await eventService.fetchEvents(
                category: category,
                limit: pageSize,
                offset: 0
            )
            events = fetched
            hasMorePages = fetched.count >= pageSize
        } catch {
            errorMessage = error.localizedDescription
        }

        // Load liked state separately so event fetch failure doesn't block likes
        do {
            let ids = try await eventService.fetchLikedEventIds()
            likedEventIds = Set(ids)
        } catch {
            // Silently fail — liked state is non-critical
        }

        isLoading = false
    }

    func loadMore() async {
        guard hasMorePages, !isLoading else { return }
        isLoading = true
        do {
            let category = selectedCategory == "All" ? nil : selectedCategory
            let fetched = try await eventService.fetchEvents(
                category: category,
                limit: pageSize,
                offset: events.count
            )
            events.append(contentsOf: fetched)
            hasMorePages = fetched.count >= pageSize
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func searchEvents() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            await loadEvents()
            return
        }

        isLoading = true
        errorMessage = nil
        do {
            events = try await eventService.searchEvents(query: query, limit: pageSize, offset: 0)
            hasMorePages = events.count >= pageSize
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func toggleLike(eventId: UUID) async {
        let wasLiked = likedEventIds.contains(eventId)

        // Optimistic update
        if wasLiked {
            likedEventIds.remove(eventId)
        } else {
            likedEventIds.insert(eventId)
        }

        do {
            if wasLiked {
                try await eventService.unlikeEvent(eventId)
            } else {
                try await eventService.likeEvent(eventId)
            }
        } catch {
            // Revert on failure
            if wasLiked {
                likedEventIds.insert(eventId)
            } else {
                likedEventIds.remove(eventId)
            }
        }
    }

    // Legacy string-based toggle for views not yet migrated
    func toggleLike(eventId: String) {
        guard let uuid = UUID(uuidString: eventId) else { return }
        Task { await toggleLike(eventId: uuid) }
    }

    func refresh() async {
        await loadEvents()
    }
}
