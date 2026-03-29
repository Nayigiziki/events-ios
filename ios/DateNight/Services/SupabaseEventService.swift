import Foundation
import Supabase

final class SupabaseEventService: EventServiceProtocol, @unchecked Sendable {
    private var client: SupabaseClient { SupabaseService.shared.client }

    func fetchEvents(category: String?, limit: Int, offset: Int) async throws -> [Event] {
        let client = client
        var query = client.from("events")
            .select("*, attendees:event_interests(user:profiles(*))")
            .eq("is_public", value: true)

        if let category, category.lowercased() != "all" {
            query = query.eq("category", value: category)
        }

        let events: [Event] = try await query
            .order("date", ascending: true)
            .range(from: offset, to: offset + limit - 1)
            .execute()
            .value
        return events
    }

    func fetchEventDetail(id: UUID) async throws -> Event {
        let client = client
        let event: Event = try await client.from("events")
            .select("*, attendees:event_interests(user:profiles(*))")
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value
        return event
    }

    func searchEvents(query: String, limit: Int, offset: Int) async throws -> [Event] {
        let client = client
        let events: [Event] = try await client.from("events")
            .select("*, attendees:event_interests(user:profiles(*))")
            .eq("is_public", value: true)
            .or("title.ilike.%\(query)%,venue.ilike.%\(query)%,location.ilike.%\(query)%")
            .order("date", ascending: true)
            .range(from: offset, to: offset + limit - 1)
            .execute()
            .value
        return events
    }

    func fetchLikedEventIds() async throws -> [UUID] {
        let client = client
        let userId = try await client.auth.session.user.id
        let rows: [[String: String]] = try await client.from("event_interests")
            .select("event_id")
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value
        return rows.compactMap { UUID(uuidString: $0["event_id"] ?? "") }
    }

    func likeEvent(_ eventId: UUID) async throws {
        let client = client
        let userId = try await client.auth.session.user.id
        try await client.from("event_interests")
            .insert(["user_id": userId.uuidString, "event_id": eventId.uuidString])
            .execute()
    }

    func unlikeEvent(_ eventId: UUID) async throws {
        let client = client
        let userId = try await client.auth.session.user.id
        try await client.from("event_interests")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .eq("event_id", value: eventId.uuidString)
            .execute()
    }

    func createEvent(_ request: EventCreateRequest) async throws -> Event {
        let client = client
        let userId = try await client.auth.session.user.id
        var data: [String: String] = [
            "title": request.title, "category": request.category,
            "date": request.date, "time": request.time,
            "venue": request.venue, "location": request.location,
            "price": request.price, "description": request.description,
            "total_spots": "\(request.totalSpots)", "is_public": "\(request.isPublic)",
            "created_by": userId.uuidString
        ]
        if let imageUrl = request.imageUrl { data["image_url"] = imageUrl }

        let event: Event = try await client.from("events")
            .insert(data)
            .select("*, attendees:event_interests(user:profiles(*))")
            .single()
            .execute()
            .value
        return event
    }

    func deleteEvent(_ eventId: UUID) async throws {
        let client = client
        try await client.from("events")
            .delete()
            .eq("id", value: eventId.uuidString)
            .execute()
    }

    func updateEvent(_ eventId: UUID, _ request: EventCreateRequest) async throws -> Event {
        let client = client
        var data: [String: String] = [
            "title": request.title, "category": request.category,
            "date": request.date, "time": request.time,
            "venue": request.venue, "location": request.location,
            "price": request.price, "description": request.description,
            "total_spots": "\(request.totalSpots)", "is_public": "\(request.isPublic)"
        ]
        if let imageUrl = request.imageUrl { data["image_url"] = imageUrl }

        let event: Event = try await client.from("events")
            .update(data)
            .eq("id", value: eventId.uuidString)
            .select("*, attendees:event_interests(user:profiles(*))")
            .single()
            .execute()
            .value
        return event
    }

    func fetchMyCreatedEvents() async throws -> [Event] {
        let client = client
        let userId = try await client.auth.session.user.id
        let events: [Event] = try await client.from("events")
            .select("*, attendees:event_interests(user:profiles(*))")
            .eq("created_by", value: userId.uuidString)
            .order("date", ascending: true)
            .execute()
            .value
        return events
    }

    func fetchMyAttendingEvents() async throws -> [Event] {
        let client = client
        let userId = try await client.auth.session.user.id
        let interestRows: [[String: String]] = try await client.from("event_interests")
            .select("event_id")
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value
        let eventIds = interestRows.compactMap { $0["event_id"] }
        guard !eventIds.isEmpty else { return [] }
        let events: [Event] = try await client.from("events")
            .select("*, attendees:event_interests(user:profiles(*))")
            .in("id", values: eventIds)
            .order("date", ascending: true)
            .execute()
            .value
        return events
    }

    func recordSwipe(_ action: EventSwipeAction) async throws {
        let client = client
        let userId = try await client.auth.session.user.id
        try await client.from("event_swipes")
            .insert([
                "user_id": userId.uuidString,
                "event_id": action.eventId.uuidString,
                "action": action.action.rawValue
            ])
            .execute()
    }

    func fetchSwipeableEvents(limit: Int, offset: Int) async throws -> [Event] {
        let client = client
        let userId = try await client.auth.session.user.id
        let events: [Event] = try await client.from("events")
            .select("*, attendees:event_interests(user:profiles(*))")
            .eq("is_public", value: true)
            .not(
                "id",
                operator: .in,
                value: "(select event_id from event_swipes where user_id = '\(userId.uuidString)')"
            )
            .order("date", ascending: true)
            .range(from: offset, to: offset + limit - 1)
            .execute()
            .value
        return events
    }

    func rsvpEvent(_ eventId: UUID) async throws { try await likeEvent(eventId) }
    func unrsvpEvent(_ eventId: UUID) async throws { try await unlikeEvent(eventId) }

    func fetchComments(eventId: UUID) async throws -> [EventComment] {
        struct CommentRow: Decodable {
            let id: UUID; let text: String; let createdAt: String
            let upvotes: Int; let downvotes: Int
            let userName: String; let avatarUrl: String?
            enum CodingKeys: String, CodingKey {
                case id, text, upvotes, downvotes
                case createdAt = "created_at"; case userName = "user_name"; case avatarUrl = "avatar_url"
            }
        }
        let client = client
        let rows: [CommentRow] = try await client.from("event_comments")
            .select("*").eq("event_id", value: eventId.uuidString)
            .order("created_at", ascending: false).execute().value
        return rows.map { EventComment(
            id: $0.id,
            userName: $0.userName,
            avatarUrl: $0.avatarUrl,
            text: $0.text,
            timestamp: $0.createdAt,
            upvotes: $0.upvotes,
            downvotes: $0.downvotes
        ) }
    }

    func addComment(_ request: EventCommentCreateRequest) async throws -> EventComment {
        struct Row: Decodable {
            let id: UUID; let text: String; let createdAt: String; let userName: String; let avatarUrl: String?
            enum CodingKeys: String, CodingKey {
                case id,
                     text; case createdAt = "created_at"; case userName = "user_name"; case avatarUrl = "avatar_url"
            }
        }
        let client = client
        let userId = try await client.auth.session.user.id
        let row: Row = try await client.from("event_comments")
            .insert(["event_id": request.eventId.uuidString, "user_id": userId.uuidString, "text": request.text])
            .select("*").single().execute().value
        return EventComment(
            id: row.id,
            userName: row.userName,
            avatarUrl: row.avatarUrl,
            text: row.text,
            timestamp: row.createdAt
        )
    }

    func deleteComment(_ commentId: UUID) async throws {
        let client = client
        try await client.from("event_comments").delete().eq("id", value: commentId.uuidString).execute()
    }

    func voteComment(_ request: CommentVoteRequest) async throws {
        let client = client
        let userId = try await client.auth.session.user.id
        try await client.from("comment_votes")
            .upsert([
                "comment_id": request.commentId.uuidString,
                "user_id": userId.uuidString,
                "direction": request.direction == .up ? "up" : "down"
            ])
            .execute()
    }

    func createDate(_ request: DateCreateRequest) async throws {
        let client = client
        let userId = try await client.auth.session.user.id
        try await client.from("dates")
            .insert([
                "event_id": request.eventId.uuidString,
                "created_by": userId.uuidString,
                "date_type": request.dateType,
                "group_size": "\(request.groupSize)",
                "description": request.description
            ])
            .execute()
    }

    func uploadEventImage(_ imageData: Data) async throws -> String {
        let client = client
        let fileName = "\(UUID().uuidString).jpg"
        let path = "events/\(fileName)"
        try await client.storage.from("event-images").upload(
            path,
            data: imageData,
            options: .init(contentType: "image/jpeg")
        )
        let publicUrl = try client.storage.from("event-images").getPublicURL(path: path)
        return publicUrl.absoluteString
    }
}
