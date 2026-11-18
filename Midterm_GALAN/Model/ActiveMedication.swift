//
//  ActiveMedication.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import Foundation

nonisolated struct ActiveMedication: Codable, Identifiable, Hashable {
    var id: UUID? = nil
    var userId: UUID? = nil
    var petId: UUID
    var diagnosis: String
    var diagnosisDate: String
    var medicine: String
    var intakeFrequency: String
    var intakeDuration: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case petId = "pet_id"
        case diagnosis
        case diagnosisDate = "diagnosis_date"
        case medicine
        case intakeFrequency = "intake_frequency"
        case intakeDuration = "intake_duration"
    }
}
