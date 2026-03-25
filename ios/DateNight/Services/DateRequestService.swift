import Foundation
import Supabase

@MainActor
final class DateRequestService {
    private var client: SupabaseClient { SupabaseService.shared.client }

    func createDateRequest(eventId: UUID, maxPeople: Int, description: String, dateType: DateType) async throws {
        let userId = try await client.auth.session.user.id

        try await client.from("date_requests")
            .insert([
                "event_id": eventId.uuidString,
                "organizer_id": userId.uuidString,
                "max_people": "\(maxPeople)",
                "description": description,
                "date_type": dateType.rawValue,
                "status": DateRequestStatus.open.rawValue
            ])
            .execute()
    }

    func fetchAvailableDates() async throws -> [DateRequest] {
        let dates: [DateRequest] = try await client.from("date_requests")
            .select(
                "*, organizer:profiles!organizer_id(*), event:events(*), attendees:date_request_attendees(user:profiles(*))"
            )
            .eq("status", value: DateRequestStatus.open.rawValue)
            .order("created_at", ascending: false)
            .execute()
            .value

        return dates
    }

    func fetchMyDates() async throws -> [DateRequest] {
        let userId = try await client.auth.session.user.id

        let dates: [DateRequest] = try await client.from("date_requests")
            .select(
                "*, organizer:profiles!organizer_id(*), event:events(*), attendees:date_request_attendees(user:profiles(*))"
            )
            .eq("organizer_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value

        return dates
    }

    func joinDateRequest(requestId: UUID) async throws {
        let userId = try await client.auth.session.user.id

        try await client.from("date_request_attendees")
            .insert([
                "date_request_id": requestId.uuidString,
                "user_id": userId.uuidString
            ])
            .execute()
    }

    func leaveDateRequest(requestId: UUID) async throws {
        let userId = try await client.auth.session.user.id

        try await client.from("date_request_attendees")
            .delete()
            .eq("date_request_id", value: requestId.uuidString)
            .eq("user_id", value: userId.uuidString)
            .execute()
    }
}
