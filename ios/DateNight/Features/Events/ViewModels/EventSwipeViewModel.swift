import Foundation
import SwiftUI

@MainActor
final class EventSwipeViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var currentIndex = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var canUndo = false

    private let eventService: any EventServiceProtocol
    private let pageSize = 20

    var currentEvent: Event? {
        guard currentIndex < events.count else { return nil }
        return events[currentIndex]
    }

    var nextEvent: Event? {
        guard currentIndex + 1 < events.count else { return nil }
        return events[currentIndex + 1]
    }

    init(eventService: any EventServiceProtocol = SupabaseEventService()) {
        self.eventService = eventService
    }

    func loadEvents() async {
        isLoading = true
        errorMessage = nil
        do {
            events = try await eventService.fetchSwipeableEvents(limit: pageSize, offset: 0)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func swipeRight() async {
        guard let event = currentEvent else { return }
        currentIndex += 1
        canUndo = true

        // Persist interested swipe in background
        do {
            try await eventService.recordSwipe(EventSwipeAction(eventId: event.id, action: .interested))
        } catch {
            // Swipe is optimistic — don't revert UI
        }
    }

    func swipeLeft() async {
        guard let event = currentEvent else { return }
        currentIndex += 1
        canUndo = true

        // Persist skip swipe in background
        do {
            try await eventService.recordSwipe(EventSwipeAction(eventId: event.id, action: .skip))
        } catch {
            // Swipe is optimistic — don't revert UI
        }
    }

    func undoLastSwipe() {
        guard canUndo, currentIndex > 0 else { return }
        currentIndex -= 1
        canUndo = false
    }
}
