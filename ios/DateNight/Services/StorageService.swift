import Foundation
import Supabase

@MainActor
final class StorageService {
    private var client: SupabaseClient { SupabaseService.shared.client }
    private let bucketName = "photos"

    func uploadPhoto(data: Data, path: String) async throws -> String {
        try await client.storage.from(bucketName)
            .upload(path: path, file: data, options: FileOptions(contentType: "image/jpeg"))

        let url = try client.storage.from(bucketName)
            .getPublicURL(path: path)

        return url.absoluteString
    }

    func deletePhoto(path: String) async throws {
        try await client.storage.from(bucketName)
            .remove(paths: [path])
    }

    func getPhotoURL(path: String) throws -> URL {
        try client.storage.from(bucketName)
            .getPublicURL(path: path)
    }
}
