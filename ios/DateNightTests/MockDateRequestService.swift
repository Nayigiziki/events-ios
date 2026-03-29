@testable import DateNight
import Foundation

final class MockDateRequestService: DateRequestServiceProtocol, @unchecked Sendable {
    // MARK: - Stubs

    var stubbedAvailableDates: [DateRequest] = []
    var stubbedMyDates: [DateRequest] = []
    var stubbedError: Error?

    // MARK: - Call tracking

    var fetchAvailableDatesCalled = false
    var fetchMyDatesCalls: [DateRequestStatus?] = []
    var joinDateCalls: [UUID] = []
    var leaveDateCalls: [UUID] = []
    var confirmDateCalls: [UUID] = []
    var cancelDateCalls: [UUID] = []
    // swiftlint:disable:next large_tuple
    var createDateRequestCalls: [(eventId: UUID, maxPeople: Int, description: String, dateType: DateType)] = []

    // MARK: - DateRequestServiceProtocol

    func fetchAvailableDates() async throws -> [DateRequest] {
        if let error = stubbedError { throw error }
        fetchAvailableDatesCalled = true
        return stubbedAvailableDates
    }

    func fetchMyDates(status: DateRequestStatus?) async throws -> [DateRequest] {
        if let error = stubbedError { throw error }
        fetchMyDatesCalls.append(status)
        return stubbedMyDates
    }

    func joinDate(requestId: UUID) async throws {
        if let error = stubbedError { throw error }
        joinDateCalls.append(requestId)
    }

    func leaveDate(requestId: UUID) async throws {
        if let error = stubbedError { throw error }
        leaveDateCalls.append(requestId)
    }

    func confirmDate(requestId: UUID) async throws {
        if let error = stubbedError { throw error }
        confirmDateCalls.append(requestId)
    }

    func cancelDate(requestId: UUID) async throws {
        if let error = stubbedError { throw error }
        cancelDateCalls.append(requestId)
    }

    func createDateRequest(eventId: UUID, maxPeople: Int, description: String, dateType: DateType) async throws {
        if let error = stubbedError { throw error }
        createDateRequestCalls.append((eventId, maxPeople, description, dateType))
    }
}
