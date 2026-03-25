import Foundation
import Supabase

@MainActor
final class SupabaseService {
    static let shared = SupabaseService()

    let client: SupabaseClient

    private init() {
        self.client = SupabaseClient(
            supabaseURL: SupabaseConfig.supabaseURL,
            supabaseKey: SupabaseConfig.supabaseAnonKey
        )
    }
}
