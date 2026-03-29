import Foundation

protocol DateRequestServiceProtocol: Sendable {
    func fetchAvailableDates() async throws -> [DateRequest]
    func fetchMyDates(status: DateRequestStatus?) async throws -> [DateRequest]
    func joinDate(requestId: UUID) async throws
    func leaveDate(requestId: UUID) async throws
    func confirmDate(requestId: UUID) async throws
    func cancelDate(requestId: UUID) async throws
    func createDateRequest(eventId: UUID, maxPeople: Int, description: String, dateType: DateType) async throws
}
