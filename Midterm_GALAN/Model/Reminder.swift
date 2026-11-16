//
//  Reminder.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import Foundation

// MARK: Reminder Model
//One row of the "reminders" table in Supabase (made from the Add Event page)
nonisolated struct Reminder: Codable, Identifiable, Hashable {
    var id: UUID? = nil
    var userId: UUID? = nil
    var petId: UUID? = nil
    var petName: String
    var eventType: String
    var eventDate: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case petId = "pet_id"
        case petName = "pet_name"
        case eventType = "event_type"
        case eventDate = "event_date"
    }
}
