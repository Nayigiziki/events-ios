import Foundation
import Supabase

@MainActor
final class EventService {
    private var client: SupabaseClient { SupabaseService.shared.client }

    func fetchEvents(category: String? = nil) async throws -> [Event] {
        var query = client.from("events")
            .select("*, attendees:event_interests(user:profiles(*))")
            .eq("is_public", value: true)

        if let category, category.lowercased() != "all" {
            query = query.eq("category", value: category)
        }

        let events: [Event] = try await query
            .order("date", ascending: true)
            .execute()
            .value

        return events
    }

    func fetchEventDetail(id: UUID) async throws -> Event {
        let event: Event = try await client.from("events")
            .select("*, attendees:event_interests(user:profiles(*))")
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value

        return event
    }

    func likeEvent(eventId: UUID) async throws {
        let userId = try await client.auth.session.user.id

        try await client.from("event_interests")
            .insert([
                "user_id": userId.uuidString,
                "event_id": eventId.uuidString
            ])
            .execute()
    }

    func unlikeEvent(eventId: UUID) async throws {
        let userId = try await client.auth.session.user.id

        try await client.from("event_interests")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .eq("event_id", value: eventId.uuidString)
            .execute()
    }
}
