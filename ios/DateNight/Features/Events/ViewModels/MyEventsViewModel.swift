import Foundation
import SwiftUI

@MainActor
final class MyEventsViewModel: ObservableObject {
    enum Tab: String, CaseIterable {
        case created = "Created"
        case attending = "Attending"

        var localizedTitle: String {
            switch self {
            case .created: "my_events_tab_created".localized()
            case .attending: "my_events_tab_attending".localized()
            }
        }
    }

    @Published var selectedTab: Tab = .created
    @Published var createdEvents: [Event] = []
    @Published var attendingEvents: [Event] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let eventService: any EventServiceProtocol

    init(eventService: any EventServiceProtocol = SupabaseEventService()) {
        self.eventService = eventService
    }

    func loadEvents() async {
        isLoading = true
        errorMessage = nil

        do {
            async let created = eventService.fetchMyCreatedEvents()
            async let attending = eventService.fetchMyAttendingEvents()
            createdEvents = try await created
            attendingEvents = try await attending
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func deleteEvent(_ event: Event) async {
        do {
            try await eventService.deleteEvent(event.id)
            createdEvents.removeAll { $0.id == event.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func editEvent(_: Event) {
        // Will navigate to edit screen — handled by view
    }
}
