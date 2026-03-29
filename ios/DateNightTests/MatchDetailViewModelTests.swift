@testable import DateNight
import XCTest

@MainActor
final class MatchDetailViewModelTests: XCTestCase {
    // MARK: - Init

    func testInit_setsMatchedUser() {
        let user = UserProfile(name: "Alice", photos: [], interests: ["Music", "Art"])
        let sut = MatchDetailViewModel(matchedUser: user)

        XCTAssertEqual(sut.matchedUser.name, "Alice")
    }

    func testInit_calculatesSharedInterests_withOverlap() {
        let user = UserProfile(name: "Alice", interests: ["Music", "Art", "Travel"])
        let sut = MatchDetailViewModel(matchedUser: user, currentUserInterests: ["Music", "Art", "Food", "Comedy"])

        XCTAssertEqual(Set(sut.sharedInterests), Set(["Music", "Art"]))
    }

    func testInit_calculatesSharedInterests_noOverlap() {
        let user = UserProfile(name: "Bob", interests: ["Gaming", "Travel"])
        let sut = MatchDetailViewModel(matchedUser: user, currentUserInterests: ["Music", "Art", "Food", "Comedy"])

        XCTAssertTrue(sut.sharedInterests.isEmpty)
    }

    func testInit_calculatesSharedInterests_emptyUserInterests() {
        let user = UserProfile(name: "Charlie", interests: [])
        let sut = MatchDetailViewModel(matchedUser: user, currentUserInterests: ["Music", "Art"])

        XCTAssertTrue(sut.sharedInterests.isEmpty)
    }
}
