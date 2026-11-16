//
//  GalleryEntry.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import Foundation

// MARK: Gallery Entry Model
//One row of the "gallery_entries" table in Supabase
nonisolated struct GalleryEntry: Codable, Identifiable, Hashable {
    var id: UUID? = nil
    var userId: UUID? = nil
    var petId: UUID
    var entryDate: String
    var note: String
    var activity: String
    //Link of the gallery photo in Supabase Storage (nil = no photo yet)
    var photoUrl: String? = nil

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case petId = "pet_id"
        case entryDate = "entry_date"
        case note
        case activity
        case photoUrl = "photo_url"
    }
}
