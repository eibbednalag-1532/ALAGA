//
//  ReminderController.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import Foundation
import Supabase
import Combine

@MainActor
final class ReminderController: ObservableObject {
    @Published var reminders: [Reminder] = []
    @Published var selectedTab: Int = 0

   
    @Published var eventType: String = ""
    @Published var petName: String = ""
    @Published var eventDate = Date()

   
    @Published var showDeleteReminder = false
    @Published var reminderToDelete: Reminder? = nil

    
    @Published var showEditReminder = false
    @Published var editingReminder: Reminder? = nil
    @Published var editEventType: String = ""
    @Published var editPetName: String = ""

    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    
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

   
    func remindersOn(_ date: Date) -> [Reminder] {
        reminders
            .filter { Calendar.current.isDate($0.eventDate, inSameDayAs: date) }
            .sorted { $0.eventDate < $1.eventDate }
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
            print("Could not load reminders: \(error.localizedDescription)")
        }
    }

    // MARK: Add Event

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

        let matchedPet = petController.pets.first { $0.name.lowercased() == cleanPet.lowercased() }

        let reminder = Reminder(
            petId: matchedPet?.id,
            petName: matchedPet?.name ?? cleanPet,
            eventType: cleanType,
            eventDate: eventDate
        )

        do {
            try await addReminder(reminder)
            router.pop()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addReminder(_ reminder: Reminder) async throws {
        let savedReminder: Reminder = try await supabase
            .from("reminders")
            .insert(reminder)
            .select()
            .single()
            .execute()
            .value

        reminders.append(savedReminder)
    }

    func askDeleteReminder(_ reminder: Reminder) {
        reminderToDelete = reminder
        showDeleteReminder = true
    }

    func deleteChosenReminder() async {
        if let reminder = reminderToDelete {
            await deleteReminder(reminder)
        }
        reminderToDelete = nil
    }

    func beginEditReminder(_ reminder: Reminder) {
        editingReminder = reminder
        editEventType = reminder.eventType
        editPetName = reminder.petName
        showEditReminder = true
    }

    func saveEditedReminder(petController: PetController) async {
        guard var reminder = editingReminder, let id = reminder.id else { return }

        let cleanPet = editPetName.trimmingCharacters(in: .whitespacesAndNewlines)
        let matchedPet = petController.pets.first { $0.name.lowercased() == cleanPet.lowercased() }

        reminder.eventType = editEventType.trimmingCharacters(in: .whitespacesAndNewlines)
        reminder.petName = matchedPet?.name ?? cleanPet
        reminder.petId = matchedPet?.id

        do {
            try await supabase
                .from("reminders")
                .update(reminder)
                .eq("id", value: id.uuidString)
                .execute()

            if let index = reminders.firstIndex(where: { $0.id == id }) {
                reminders[index] = reminder
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        editingReminder = nil
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
