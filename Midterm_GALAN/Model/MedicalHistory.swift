//
//  MedicalHistory.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import Foundation

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
    //Same parts as the Medical History page when adding a pet
    var currentIllness: String = ""
    var currentIllnessDate: String = ""
    var currentMedicine: String = ""
    var pastIllness: String = ""
    var pastIllnessDate: String = ""
    var pastMedicine: String = ""

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
        case currentIllness = "current_illness"
        case currentIllnessDate = "current_illness_date"
        case currentMedicine = "current_medicine"
        case pastIllness = "past_illness"
        case pastIllnessDate = "past_illness_date"
        case pastMedicine = "past_medicine"
    }
}
