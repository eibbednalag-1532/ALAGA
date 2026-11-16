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
//Holds the 3 Add Pet pages (Pet Information > Medical History > Active Medication) and saves them together
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

    // MARK: Save everything to Supabase
    func savePet(petController: PetController, router: AppRouter) async {
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

    private func clean(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
