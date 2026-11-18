//
//  AddPetController.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import Foundation
import Supabase
import Combine

// MARK: Add Pet Controller
//Holds the 4 Add Pet pages (Pet Information > Medical History > Active Medication > Add Event) and saves them together
@MainActor
final class AddPetController: ObservableObject {
    //Pet Information page
    @Published var petName: String = ""
    @Published var breed: String = ""
    @Published var age: String = ""
    @Published var birthdate: String = ""
    @Published var gender: String = ""

    //Medical History page
    @Published var weight: String = ""
    @Published var currentIllness: String = ""
    @Published var currentIllnessDate: String = ""
    @Published var currentMedicine: String = ""
    @Published var pastIllness: String = ""
    @Published var pastIllnessDate: String = ""
    @Published var pastMedicine: String = ""

    //Active Medication page
    @Published var diagnosis: String = ""
    @Published var diagnosisDate: String = ""
    @Published var medication: String = ""
    @Published var intakeFrequency: String = ""
    @Published var intakeDuration: String = ""

    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    // MARK: Navigation
    //Called by the "Add Pet" button in the Choose Action sheet
    func startNewPet(router: AppRouter) {
        reset()
        router.push(.addPetInfo)
    }

    //Pet Information > Medical History
    func goToMedHistory(router: AppRouter) {
        guard !clean(petName).isEmpty else {
            errorMessage = "Please enter your pet's name."
            return
        }
        router.push(.addMedHistory)
    }

    //Medical History > Active Medication
    func goToActiveMed(router: AppRouter) {
        router.push(.addActiveMed)
    }

    //Active Medication > Add Event (the pet field is filled with the new pet's name)
    func goToAddEvent(reminderController: ReminderController, router: AppRouter) {
        reminderController.eventType = ""
        reminderController.petName = clean(petName)
        reminderController.eventDate = Date()
        reminderController.errorMessage = nil
        router.push(.addEvent)
    }

    // MARK: Save everything to Supabase
    //Called by the Save button in Add Event, the last Add Pet page
    func savePet(petController: PetController, reminderController: ReminderController, router: AppRouter) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let newPet = Pet(
                name: clean(petName),
                breed: clean(breed),
                age: clean(age),
                birthdate: clean(birthdate),
                gender: clean(gender),
                weight: clean(weight),
                iconName: petController.iconName(for: breed)
            )

            let savedPet = try await petController.addPet(newPet)
            guard let petId = savedPet.id else { return }

            //Current and past illness become medical history records
            var histories: [MedicalHistory] = []

            if !clean(currentIllness).isEmpty {
                histories.append(MedicalHistory(
                    petId: petId,
                    recordDate: clean(currentIllnessDate),
                    diagnosis: clean(currentIllness),
                    activity: "",
                    age: clean(age),
                    weight: clean(weight),
                    medicine: clean(currentMedicine)
                ))
            }

            if !clean(pastIllness).isEmpty {
                histories.append(MedicalHistory(
                    petId: petId,
                    recordDate: clean(pastIllnessDate),
                    diagnosis: clean(pastIllness),
                    activity: "",
                    age: clean(age),
                    weight: clean(weight),
                    medicine: clean(pastMedicine)
                ))
            }

            if !histories.isEmpty {
                try await supabase
                    .from("medical_histories")
                    .insert(histories)
                    .execute()
            }

            if !clean(diagnosis).isEmpty || !clean(medication).isEmpty {
                let activeMed = ActiveMedication(
                    petId: petId,
                    diagnosis: clean(diagnosis),
                    diagnosisDate: clean(diagnosisDate),
                    medicine: clean(medication),
                    intakeFrequency: clean(intakeFrequency),
                    intakeDuration: clean(intakeDuration)
                )

                try await supabase
                    .from("active_medications")
                    .insert(activeMed)
                    .execute()
            }

            //The event is saved only if an event type was typed
            let cleanEventType = clean(reminderController.eventType)
            if !cleanEventType.isEmpty {
                let reminder = Reminder(
                    petId: petId,
                    petName: savedPet.name,
                    eventType: cleanEventType,
                    eventDate: reminderController.eventDate
                )
                try await reminderController.addReminder(reminder)
            }

            reset()
            //Back to the Pets Tab
            router.goToTab(1)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Helpers
    func reset() {
        petName = ""
        breed = ""
        age = ""
        birthdate = ""
        gender = ""
        weight = ""
        currentIllness = ""
        currentIllnessDate = ""
        currentMedicine = ""
        pastIllness = ""
        pastIllnessDate = ""
        pastMedicine = ""
        diagnosis = ""
        diagnosisDate = ""
        medication = ""
        intakeFrequency = ""
        intakeDuration = ""
        errorMessage = nil
    }

    //Removes extra spaces, and "N/A" (not applicable) is saved as empty
    private func clean(_ text: String) -> String {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let notApplicable = ["n/a", "na", "n.a.", "none"]
        return notApplicable.contains(cleanText.lowercased()) ? "" : cleanText
    }
}
