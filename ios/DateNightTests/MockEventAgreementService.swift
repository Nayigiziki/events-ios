@testable import DateNight
import Foundation

final class MockEventAgreementService: EventAgreementServiceProtocol, @unchecked Sendable {
    var stubbedEvents: [Event] = []
    var stubbedProposals: [EventProposal] = []
    var stubbedProposalResult: EventProposal?
    var stubbedError: Error?

    var fetchAvailableEventsCalled = false
    var fetchProposalsCalls: [UUID] = []
    var proposeEventCalls: [(matchId: UUID, eventId: UUID)] = []
    var acceptProposalCalls: [UUID] = []
    var rejectProposalCalls: [UUID] = []

    func fetchAvailableEvents() async throws -> [Event] {
        if let error = stubbedError { throw error }
        fetchAvailableEventsCalled = true
        return stubbedEvents
    }

    func fetchProposals(matchId: UUID) async throws -> [EventProposal] {
        if let error = stubbedError { throw error }
        fetchProposalsCalls.append(matchId)
        return stubbedProposals
    }

    func proposeEvent(matchId: UUID, eventId: UUID) async throws -> EventProposal {
        if let error = stubbedError { throw error }
        proposeEventCalls.append((matchId, eventId))
        return stubbedProposalResult ?? EventProposal(
            id: UUID(),
            matchId: matchId,
            proposerId: UUID(),
            eventId: eventId,
            status: .pending
        )
    }

    func acceptProposal(proposalId: UUID) async throws {
        if let error = stubbedError { throw error }
        acceptProposalCalls.append(proposalId)
    }

    func rejectProposal(proposalId: UUID) async throws {
        if let error = stubbedError { throw error }
        rejectProposalCalls.append(proposalId)
    }
}
