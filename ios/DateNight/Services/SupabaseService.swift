import Foundation
import Supabase

final class SupabaseService: Sendable {
    static let shared = SupabaseService()

    let client: SupabaseClient

    private static var isRunningTests: Bool {
        NSClassFromString("XCTestCase") != nil
    }

    let isConfigured: Bool

    private init() {
        let url = SupabaseConfig.supabaseURL
        let key = SupabaseConfig.supabaseAnonKey
        let hasRealConfig = !url.absoluteString.contains("placeholder") && !key.contains("placeholder")

        if hasRealConfig {
            self.client = SupabaseClient(supabaseURL: url, supabaseKey: key)
            self.isConfigured = true
        } else {
            // Placeholder credentials — use a dummy client that won't crash.
            // Real Supabase calls will fail gracefully via service error handling.
            self.client = SupabaseClient(
                supabaseURL: URL(string: "https://localhost.supabase.co")!,
                supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBsYWNlaG9sZGVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDAwMDAwMDAsImV4cCI6MjAwMDAwMDAwMH0.placeholder"
            )
            self.isConfigured = false
        }
    }
}
