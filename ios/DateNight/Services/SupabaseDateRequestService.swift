import Foundation
import Supabase

final class SupabaseDateRequestService: DateRequestServiceProtocol, @unchecked Sendable {
    private var client: SupabaseClient { SupabaseService.shared.client }

    private let selectQuery = "*, organizer:profiles!organizer_id(*), event:events(*), attendees:date_request_attendees(user:profiles(*))"

    func fetchAvailableDates() async throws -> [DateRequest] {
        let dates: [DateRequest] = try await client.from("date_requests")
            .select(selectQuery)
            .eq("status", value: DateRequestStatus.open.rawValue)
            .order("created_at", ascending: false)
            .execute()
            .value
        return dates
    }

    func fetchMyDates(status: DateRequestStatus?) async throws -> [DateRequest] {
        let userId = try await client.auth.session.user.id

        var query = client.from("date_requests")
            .select(selectQuery)
            .eq("organizer_id", value: userId.uuidString)

        if let status {
            query = query.eq("status", value: status.rawValue)
        }

        let dates: [DateRequest] = try await query
            .order("created_at", ascending: false)
            .execute()
            .value
        return dates
    }

    func joinDate(requestId: UUID) async throws {
        let userId = try await client.auth.session.user.id

        try await client.from("date_request_attendees")
            .insert([
                "date_request_id": requestId.uuidString,
                "user_id": userId.uuidString
            ])
            .execute()
    }

    func leaveDate(requestId: UUID) async throws {
        let userId = try await client.auth.session.user.id

        try await client.from("date_request_attendees")
            .delete()
            .eq("date_request_id", value: requestId.uuidString)
            .eq("user_id", value: userId.uuidString)
            .execute()
    }

    func confirmDate(requestId: UUID) async throws {
        try await client.from("date_requests")
            .update(["status": DateRequestStatus.confirmed.rawValue])
            .eq("id", value: requestId.uuidString)
            .execute()
    }

    func cancelDate(requestId: UUID) async throws {
        try await client.from("date_requests")
            .update(["status": DateRequestStatus.cancelled.rawValue])
            .eq("id", value: requestId.uuidString)
            .execute()
    }

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
}
