//
//  ReminderController.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import Foundation
import Supabase

// MARK: Reminder / Add Event Controller
@MainActor
final class ReminderController: ObservableObject {
    @Published var reminders: [Reminder] = []
    @Published var selectedTab: Int = 0

    //Add Event fields
    @Published var eventType: String = ""
    @Published var petName: String = ""
    @Published var eventDate = Date()

    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    // MARK: Lists
    var upcomingReminders: [Reminder] {
        reminders
            .filter { $0.eventDate >= Date() }
            .sorted { $0.eventDate < $1.eventDate }
    }

    var pastReminders: [Reminder] {
        reminders
            .filter { $0.eventDate < Date() }
            .sorted { $0.eventDate > $1.eventDate }
    }

    func fetchReminders() async {
        do {
            reminders = try await supabase
                .from("reminders")
                .select()
                .order("event_date", ascending: true)
                .execute()
                .value
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Add Event
    //Called by the "Add Event" button in the Choose Action sheet
    func startNewEvent(router: AppRouter) {
        eventType = ""
        petName = ""
        eventDate = Date()
        errorMessage = nil
        router.push(.addEvent)
    }

    func saveEvent(petController: PetController, router: AppRouter) async {
        let cleanType = eventType.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPet = petName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanType.isEmpty, !cleanPet.isEmpty else {
            errorMessage = "Please enter the event type and your pet's name."
            return
        }

        isLoading = true
        defer { isLoading = false }

        //Links the event to the pet if the name matches one of the user's pets
        let matchedPet = petController.pets.first { $0.name.lowercased() == cleanPet.lowercased() }

        let reminder = Reminder(
            petId: matchedPet?.id,
            petName: matchedPet?.name ?? cleanPet,
            eventType: cleanType,
            eventDate: eventDate
        )

        do {
            let savedReminder: Reminder = try await supabase
                .from("reminders")
                .insert(reminder)
                .select()
                .single()
                .execute()
                .value

            reminders.append(savedReminder)
            //Back to the page that opened Add Event
            router.pop()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteReminder(_ reminder: Reminder) async {
        guard let id = reminder.id else { return }

        do {
            try await supabase
                .from("reminders")
                .delete()
                .eq("id", value: id.uuidString)
                .execute()

            reminders.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Display Helpers
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy - h:mm a"
        return formatter.string(from: date)
    }

    func iconName(for eventType: String) -> String {
        let text = eventType.lowercased()

        if text.contains("vacc") {
            return "syringe.fill"
        } else if text.contains("check") {
            return "stethoscope"
        } else if text.contains("groom") {
            return "scissors"
        } else if text.contains("lab") || text.contains("test") {
            return "list.clipboard.fill"
        } else {
            return "calendar"
        }
    }
}
