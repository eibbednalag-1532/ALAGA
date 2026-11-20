//
//  UserProfile.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import Foundation

nonisolated struct UserProfile: Codable, Identifiable, Hashable {
    var id: UUID
    var username: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var email: String? = nil
    var contactNumber: String? = nil

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case contactNumber = "contact_number"
    }
}
