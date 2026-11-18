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

@MainActor
final class AddPetController: ObservableObject {
    //MARK: Pet Information page
    @Published var petName: String = ""
    @Published var breed: String = ""
    @Published var age: String = ""
    @Published var birthdate: String = ""
    @Published var gender: String = ""

    //MARK: Medical History page
    @Published var weight: String = ""
    @Published var currentIllness: String = ""
    @Published var currentIllnessDate: String = ""
    @Published var currentMedicine: String = ""
    @Published var pastIllness: String = ""
    @Published var pastIllnessDate: String = ""
    @Published var pastMedicine: String = ""

    //MARK: Active Medication page
    @Published var diagnosis: String = ""
    @Published var diagnosisDate: String = ""
    @Published var medication: String = ""
    @Published var intakeFrequency: String = ""
    @Published var intakeDuration: String = ""

    @Published var historyPet: Pet? = nil

    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    func startNewPet(router: AppRouter) {
        reset()
        router.push(.addPetInfo)
    }

    func goToMedHistory(router: AppRouter) {
        guard !clean(petName).isEmpty else {
            errorMessage = "Please enter your pet's name."
            return
        }
        router.push(.addMedHistory)
    }

    func startMedHistory(for pet: Pet, router: AppRouter) {
        reset()
        historyPet = pet
        weight = pet.weight
        router.push(.addMedHistory)
    }

    func goToActiveMed(router: AppRouter) {
        router.push(.addActiveMed)
    }

    func goToAddEvent(reminderController: ReminderController, router: AppRouter) {
        reminderController.eventType = ""
        reminderController.petName = clean(petName)
        reminderController.eventDate = Date()
        reminderController.errorMessage = nil
        router.push(.addEvent)
    }

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

            if let history = newHistory(petId: petId, petAge: clean(age)) {
                try await supabase
                    .from("medical_histories")
                    .insert(history)
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
            router.goToTab(1)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveMedHistory(router: AppRouter) async {
        guard let pet = historyPet, let petId = pet.id else { return }

        guard let history = newHistory(petId: petId, petAge: pet.age) else {
            errorMessage = "Please fill in at least one field."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await supabase
                .from("medical_histories")
                .insert(history)
                .execute()

            reset()
            router.pop()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func newHistory(petId: UUID, petAge: String) -> MedicalHistory? {
        let parts = [weight, currentIllness, currentIllnessDate, currentMedicine, pastIllness, pastIllnessDate, pastMedicine]
        guard parts.contains(where: { !clean($0).isEmpty }) else { return nil }

        return MedicalHistory(
            petId: petId,
            recordDate: Date().formatted(date: .long, time: .omitted),
            diagnosis: clean(currentIllness),
            activity: "",
            age: petAge,
            weight: clean(weight),
            medicine: clean(currentMedicine),
            currentIllness: clean(currentIllness),
            currentIllnessDate: clean(currentIllnessDate),
            currentMedicine: clean(currentMedicine),
            pastIllness: clean(pastIllness),
            pastIllnessDate: clean(pastIllnessDate),
            pastMedicine: clean(pastMedicine)
        )
    }

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
        historyPet = nil
        errorMessage = nil
    }

    private func clean(_ text: String) -> String {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let notApplicable = ["n/a", "na", "n.a.", "none"]
        return notApplicable.contains(cleanText.lowercased()) ? "" : cleanText
    }
}
