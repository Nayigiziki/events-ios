import Foundation

@MainActor
class EventAgreementViewModel: ObservableObject {
    @Published var availableEvents: [Event] = []
    @Published var proposedByMe: Event?
    @Published var proposedByThem: Event?
    @Published var agreedEvent: Event?
    @Published var showConfirmation = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: any EventAgreementServiceProtocol
    private var proposals: [EventProposal] = []
    var matchId: UUID?
    private var currentUserId: UUID?

    init(service: any EventAgreementServiceProtocol = SupabaseEventAgreementService(), matchId: UUID? = nil) {
        self.service = service
        self.matchId = matchId
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil
        do {
            availableEvents = try await service.fetchAvailableEvents()

            if let matchId {
                proposals = try await service.fetchProposals(matchId: matchId)
                updateProposalState()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func proposeEvent(_ event: Event) async {
        guard let matchId else { return }
        errorMessage = nil
        do {
            let proposal = try await service.proposeEvent(matchId: matchId, eventId: event.id)
            proposals.append(proposal)
            proposedByMe = event
            checkAgreement()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func acceptProposal() async {
        guard let theirProposal = proposals.first(where: { $0.proposerId != currentUserId && $0.status == .pending })
        else { return }
        errorMessage = nil
        do {
            try await service.acceptProposal(proposalId: theirProposal.id)
            agreedEvent = proposedByThem
            withAnimationTrigger()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func rejectProposal() async {
        guard let theirProposal = proposals.first(where: { $0.proposerId != currentUserId && $0.status == .pending })
        else { return }
        errorMessage = nil
        do {
            try await service.rejectProposal(proposalId: theirProposal.id)
            proposedByThem = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func confirmDate() {
        // Navigate or finalize the agreed event
    }

    // MARK: - Private

    private func updateProposalState() {
        for proposal in proposals where proposal.status == .pending {
            if proposal.proposerId == currentUserId {
                proposedByMe = availableEvents.first { $0.id == proposal.eventId }
            } else {
                proposedByThem = availableEvents.first { $0.id == proposal.eventId }
            }
        }

        // Check for accepted proposals
        if let accepted = proposals.first(where: { $0.status == .accepted }) {
            agreedEvent = availableEvents.first { $0.id == accepted.eventId }
        }
    }

    private func checkAgreement() {
        if let mine = proposedByMe, let theirs = proposedByThem, mine.id == theirs.id {
            agreedEvent = mine
            withAnimationTrigger()
        }
    }

    private func withAnimationTrigger() {
        showConfirmation = true
    }
}
