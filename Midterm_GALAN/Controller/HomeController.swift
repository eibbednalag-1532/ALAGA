//
//  HomeController.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import Foundation
import Combine


@MainActor
final class HomeController: ObservableObject {
    @Published var selectedDateTime = Date()

    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())

        if hour < 12 {
            return "Good morning."
        } else if hour < 18 {
            return "Good afternoon."
        } else {
            return "Good evening."
        }
    }

    //Shows the user's name, or "Pet Parent!" if there is none yet
    func parentName(from profileController: ProfileController) -> String {
        let name = profileController.firstName
        return name.isEmpty ? "Pet Parent!" : "\(name)!"
    }

    //Only the next 3 reminders are shown on the Home Tab
    func homeReminders(from reminderController: ReminderController) -> [Reminder] {
        Array(reminderController.upcomingReminders.prefix(3))
    }
}
