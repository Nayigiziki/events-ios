import Foundation

struct EventProposal: Codable, Identifiable, Hashable {
    let id: UUID
    var matchId: UUID
    var proposerId: UUID
    var eventId: UUID
    var status: ProposalStatus
    var createdAt: Date?
    var event: Event?

    enum CodingKeys: String, CodingKey {
        case id
        case matchId = "match_id"
        case proposerId = "proposer_id"
        case eventId = "event_id"
        case status
        case createdAt = "created_at"
        case event
    }
}

enum ProposalStatus: String, Codable, Hashable {
    case pending
    case accepted
    case rejected
}

protocol EventAgreementServiceProtocol: Sendable {
    func fetchProposals(matchId: UUID) async throws -> [EventProposal]
    func proposeEvent(matchId: UUID, eventId: UUID) async throws -> EventProposal
    func acceptProposal(proposalId: UUID) async throws
    func rejectProposal(proposalId: UUID) async throws
    func fetchAvailableEvents() async throws -> [Event]
}
