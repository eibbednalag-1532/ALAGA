//
//  SupabaseManager.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import Foundation
import Supabase

// MARK: Shared Supabase Client
//Every controller uses this one client to talk to the cloud database
let supabase = SupabaseClient(
    supabaseURL: URL(string: SupabaseConfig.url)!,
    supabaseKey: SupabaseConfig.anonKey
)

// MARK: Photo Storage
//Uploads pet and gallery photos to the "pet-photos" bucket in Supabase Storage
enum PhotoStorage {
    static let bucket = "pet-photos"

    //Saves the photo inside the user's own folder and gives back its link
    static func upload(_ imageData: Data) async throws -> String {
        let userId = try await supabase.auth.session.user.id
        let path = "\(userId.uuidString.lowercased())/\(UUID().uuidString).jpg"

        _ = try await supabase.storage
            .from(bucket)
            .upload(path, data: imageData, options: FileOptions(contentType: "image/jpeg"))

        let url = try supabase.storage
            .from(bucket)
            .getPublicURL(path: path)

        return url.absoluteString
    }
}
