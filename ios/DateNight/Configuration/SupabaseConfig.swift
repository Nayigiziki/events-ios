import Foundation

enum SupabaseConfig {
    static var supabaseURL: URL {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              let url = URL(string: urlString)
        else {
            fatalError("SUPABASE_URL not found in Info.plist")
        }
        return url
    }

    static var supabaseAnonKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String, !key.isEmpty else {
            fatalError("SUPABASE_ANON_KEY not found in Info.plist")
        }
        return key
    }
}
