import Foundation
import Supabase

final class SupabaseEventAgreementService: EventAgreementServiceProtocol, @unchecked Sendable {
    private var client: SupabaseClient { SupabaseService.shared.client }

    func fetchProposals(matchId: UUID) async throws -> [EventProposal] {
        let proposals: [EventProposal] = try await client.from("event_proposals")
            .select("*, event:events(*)")
            .eq("match_id", value: matchId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
        return proposals
    }

    func proposeEvent(matchId: UUID, eventId: UUID) async throws -> EventProposal {
        let userId = try await client.auth.session.user.id
        let proposalId = UUID()

        let values: [String: String] = [
            "id": proposalId.uuidString,
            "match_id": matchId.uuidString,
            "proposer_id": userId.uuidString,
            "event_id": eventId.uuidString,
            "status": ProposalStatus.pending.rawValue
        ]

        try await client.from("event_proposals")
            .insert(values)
            .execute()

        return EventProposal(
            id: proposalId,
            matchId: matchId,
            proposerId: userId,
            eventId: eventId,
            status: .pending
        )
    }

    func acceptProposal(proposalId: UUID) async throws {
        try await client.from("event_proposals")
            .update(["status": ProposalStatus.accepted.rawValue])
            .eq("id", value: proposalId.uuidString)
            .execute()
    }

    func rejectProposal(proposalId: UUID) async throws {
        try await client.from("event_proposals")
            .update(["status": ProposalStatus.rejected.rawValue])
            .eq("id", value: proposalId.uuidString)
            .execute()
    }

    func fetchAvailableEvents() async throws -> [Event] {
        let events: [Event] = try await client.from("events")
            .select()
            .eq("is_public", value: true)
            .order("date", ascending: true)
            .limit(20)
            .execute()
            .value
        return events
    }
}
