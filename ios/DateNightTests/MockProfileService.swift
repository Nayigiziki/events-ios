@testable import DateNight
import Foundation

final class MockProfileService: ProfileServiceProtocol, @unchecked Sendable {
    var fetchProfileResult: Result<UserProfile, Error> = .success(
        UserProfile(
            id: UUID(),
            name: "Test User",
            age: 25,
            bio: "Test bio",
            photos: ["photo1.jpg"],
            interests: ["Music"]
        )
    )
    var updateProfileError: Error?
    var fetchStatsResult: Result<ProfileStats, Error> = .success(ProfileStats(matches: 5, dates: 3, events: 10))
    var fetchActivityResult: Result<[Activity], Error> = .success([
        Activity(id: "1", icon: "heart.fill", iconColor: "pink", title: "Matched", subtitle: "Test", timeAgo: "2d")
    ])
    var uploadPhotoResult: Result<String, Error> = .success("https://example.com/photo.jpg")
    var deleteAccountError: Error?

    var fetchProfileCallCount = 0
    var updateProfileCallCount = 0
    var fetchStatsCallCount = 0
    var fetchActivityCallCount = 0
    var uploadPhotoCallCount = 0
    var deleteAccountCallCount = 0

    var lastUpdateRequest: ProfileUpdateRequest?

    func fetchProfile(userId: UUID) async throws -> UserProfile {
        fetchProfileCallCount += 1
        return try fetchProfileResult.get()
    }

    func updateProfile(_ request: ProfileUpdateRequest, userId: UUID) async throws {
        updateProfileCallCount += 1
        lastUpdateRequest = request
        if let error = updateProfileError { throw error }
    }

    func fetchStats(userId: UUID) async throws -> ProfileStats {
        fetchStatsCallCount += 1
        return try fetchStatsResult.get()
    }

    func fetchActivity(userId: UUID) async throws -> [Activity] {
        fetchActivityCallCount += 1
        return try fetchActivityResult.get()
    }

    func uploadPhoto(data: Data, userId: UUID) async throws -> String {
        uploadPhotoCallCount += 1
        return try uploadPhotoResult.get()
    }

    func deleteAccount() async throws {
        deleteAccountCallCount += 1
        if let error = deleteAccountError { throw error }
    }
}

final class MockPreferencesService: PreferencesServiceProtocol, @unchecked Sendable {
    var fetchPreferencesResult: Result<MatchPreferences, Error> = .success(MatchPreferences())
    var savePreferencesError: Error?

    var fetchCallCount = 0
    var saveCallCount = 0
    var lastSavedPreferences: MatchPreferences?

    func fetchPreferences(userId: UUID) async throws -> MatchPreferences {
        fetchCallCount += 1
        return try fetchPreferencesResult.get()
    }

    func savePreferences(_ prefs: MatchPreferences, userId: UUID) async throws {
        saveCallCount += 1
        lastSavedPreferences = prefs
        if let error = savePreferencesError { throw error }
    }
}
