//
//  Pet.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import Foundation

// MARK: Pet Model
//One row of the "pets" table in Supabase
nonisolated struct Pet: Codable, Identifiable, Hashable {
    var id: UUID? = nil
    var userId: UUID? = nil
    var name: String
    var breed: String
    var age: String
    var birthdate: String
    var gender: String
    var weight: String
    var iconName: String
    //Link of the pet's photo in Supabase Storage (nil = no photo yet)
    var photoUrl: String? = nil

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case breed
        case age
        case birthdate
        case gender
        case weight
        case iconName = "icon_name"
        case photoUrl = "photo_url"
    }

    //Used by the previews only
    static let sample = Pet(name: "Niroshi", breed: "Persian", age: "4 Years Old", birthdate: "January 17, 2022", gender: "Male", weight: "1.5", iconName: "cat.fill")
}
