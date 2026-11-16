//
//  MedicalHistory.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import Foundation

// MARK: Medical History Model
//One row of the "medical_histories" table in Supabase
nonisolated struct MedicalHistory: Codable, Identifiable, Hashable {
    var id: UUID? = nil
    var userId: UUID? = nil
    var petId: UUID
    var recordDate: String
    var diagnosis: String
    var activity: String
    var age: String
    var weight: String
    var medicine: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case petId = "pet_id"
        case recordDate = "record_date"
        case diagnosis
        case activity
        case age
        case weight
        case medicine
    }
}
