import Foundation
import Supabase

final class SupabaseService: Sendable {
    static let shared = SupabaseService()

    let client: SupabaseClient

    private static var isRunningTests: Bool {
        NSClassFromString("XCTestCase") != nil
    }

    private init() {
        if Self.isRunningTests {
            // Use a valid but non-functional client for tests to prevent crashes.
            // All test code should use mock services injected via protocols.
            self.client = SupabaseClient(
                supabaseURL: URL(string: "https://test.supabase.co")!,
                supabaseKey: "test-key"
            )
        } else {
            self.client = SupabaseClient(
                supabaseURL: SupabaseConfig.supabaseURL,
                supabaseKey: SupabaseConfig.supabaseAnonKey
            )
        }
    }
}
