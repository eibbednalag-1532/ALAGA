//
//  PetDetailsController.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import Foundation
import Supabase
import Combine
import PhotosUI
import SwiftUI
import UIKit

enum PhotoTarget {
    case pet
    case gallery
}

// MARK: Pet Details Controller

@MainActor
final class PetDetailsController: ObservableObject {
    @Published var pet: Pet
    @Published var selectedTab: Int = 0

    @Published var medicalHistories: [MedicalHistory] = []
    @Published var activeMedication: ActiveMedication? = nil
    @Published var galleryEntries: [GalleryEntry] = []

    @Published var errorMessage: String? = nil

    // MARK: Alert Sheets
    @Published var showEditPetInfo = false
    @Published var showEditActiveMed = false
    @Published var showEditMedHistory = false
    @Published var showEditGallery = false
    @Published var showDeletePetConfirm = false

    //MARK: Edit Pet Information fields
    @Published var editName: String = ""
    @Published var editBreed: String = ""
    @Published var editAge: String = ""
    @Published var editBirthdate: String = ""
    @Published var editGender: String = ""
    @Published var editWeight: String = ""

    //MARK: Edit Active Medication fields
    @Published var medDiagnosis: String = ""
    @Published var medMedicine: String = ""
    @Published var medIntakeFrequency: String = ""
    @Published var medIntakeDuration: String = ""

    //MARK: Edit Medical History fields
    @Published var editingHistory: MedicalHistory? = nil
    @Published var historyWeight: String = ""
    @Published var historyCurrentIllness: String = ""
    @Published var historyCurrentDate: String = ""
    @Published var historyCurrentMedicine: String = ""
    @Published var historyPastIllness: String = ""
    @Published var historyPastDate: String = ""
    @Published var historyPastMedicine: String = ""

    //MARK: Edit Gallery fields
    @Published var editingGallery: GalleryEntry? = nil
    @Published var galleryDate: String = ""
    @Published var galleryNote: String = ""
    @Published var galleryActivity: String = ""

    // MARK: Photos
    @Published var photoTarget: PhotoTarget = .pet
    @Published var showPhotoOptions = false
    @Published var showPhotoLibrary = false
    @Published var showCamera = false
    @Published var selectedPhotoItem: PhotosPickerItem? = nil
    @Published var isUploading = false
    @Published var galleryImageData: Data? = nil
    @Published var cropImage: UIImage? = nil

    init(pet: Pet) {
        self.pet = pet
    }

    func display(_ text: String) -> String {
        text.isEmpty ? "N/A" : text
    }

    var petInfoRows: [(String, String)] {
        [
            ("Name", display(pet.name)),
            ("Breed", display(pet.breed)),
            ("Age", display(pet.age)),
            ("Birthdate", display(pet.birthdate)),
            ("Gender", display(pet.gender)),
            ("Weight", pet.weight.isEmpty ? "N/A" : "\(pet.weight) Kg")
        ]
    }

    var activeMedRows: [(String, String)] {
        [
            ("Diagnosis", display(activeMedication?.diagnosis ?? "")),
            ("Medicine", display(activeMedication?.medicine ?? "")),
            ("Intake Frequency", display(activeMedication?.intakeFrequency ?? "")),
            ("Intake Duration", display(activeMedication?.intakeDuration ?? ""))
        ]
    }

    func historyRows(_ record: MedicalHistory) -> [(String, String)] {
        [
            ("Weight", record.weight.isEmpty ? "N/A" : "\(record.weight) Kg"),
            ("Current Illness", display(record.currentIllness)),
            ("Date of Diagnosis", display(record.currentIllnessDate)),
            ("Medicine Taken", display(record.currentMedicine)),
            ("Post Illness", display(record.pastIllness)),
            ("Date of Diagnosis", display(record.pastIllnessDate)),
            ("Medicine Taken", display(record.pastMedicine))
        ]
    }

    func loadDetails() async {
        guard let petId = pet.id?.uuidString else { return }

        do {
            medicalHistories = try await supabase
                .from("medical_histories")
                .select()
                .eq("pet_id", value: petId)
                .order("created_at", ascending: true)
                .execute()
                .value

            let medications: [ActiveMedication] = try await supabase
                .from("active_medications")
                .select()
                .eq("pet_id", value: petId)
                .order("created_at", ascending: false)
                .limit(1)
                .execute()
                .value
            activeMedication = medications.first

            galleryEntries = try await supabase
                .from("gallery_entries")
                .select()
                .eq("pet_id", value: petId)
                .order("created_at", ascending: true)
                .execute()
                .value
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Pet Information
    func beginEditPetInfo() {
        editName = pet.name
        editBreed = pet.breed
        editAge = pet.age
        editBirthdate = pet.birthdate
        editGender = pet.gender
        editWeight = pet.weight
        showEditPetInfo = true
    }

    func savePetInfo(petController: PetController) async {
        var updatedPet = pet
        updatedPet.name = editName
        updatedPet.breed = editBreed
        updatedPet.age = editAge
        updatedPet.birthdate = editBirthdate
        updatedPet.gender = editGender
        updatedPet.weight = editWeight
        updatedPet.iconName = petController.iconName(for: editBreed)

        if await petController.updatePet(updatedPet) {
            pet = updatedPet
        } else {
            errorMessage = petController.errorMessage
        }
    }

    func deletePet(petController: PetController, router: AppRouter) async {
        if await petController.deletePet(pet) {
            router.goToTab(1)
        } else {
            errorMessage = petController.errorMessage
        }
    }

    // MARK: Active Medication
    func beginEditActiveMed() {
        medDiagnosis = activeMedication?.diagnosis ?? ""
        medMedicine = activeMedication?.medicine ?? ""
        medIntakeFrequency = activeMedication?.intakeFrequency ?? ""
        medIntakeDuration = activeMedication?.intakeDuration ?? ""
        showEditActiveMed = true
    }

    func saveActiveMed() async {
        guard let petId = pet.id else { return }

        var medication = activeMedication ?? ActiveMedication(petId: petId, diagnosis: "", diagnosisDate: "", medicine: "", intakeFrequency: "", intakeDuration: "")
        medication.diagnosis = medDiagnosis
        medication.medicine = medMedicine
        medication.intakeFrequency = medIntakeFrequency
        medication.intakeDuration = medIntakeDuration

        do {
            if let id = medication.id {
                try await supabase
                    .from("active_medications")
                    .update(medication)
                    .eq("id", value: id.uuidString)
                    .execute()
                activeMedication = medication
            } else {
                let savedMedication: ActiveMedication = try await supabase
                    .from("active_medications")
                    .insert(medication)
                    .select()
                    .single()
                    .execute()
                    .value
                activeMedication = savedMedication
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteActiveMed() async {
        guard let id = activeMedication?.id else { return }

        do {
            try await supabase
                .from("active_medications")
                .delete()
                .eq("id", value: id.uuidString)
                .execute()
            activeMedication = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Medical History
    
    func beginEditHistory(_ record: MedicalHistory?) {
        editingHistory = record
        historyWeight = record?.weight ?? pet.weight
        historyCurrentIllness = record?.currentIllness ?? ""
        historyCurrentDate = record?.currentIllnessDate ?? ""
        historyCurrentMedicine = record?.currentMedicine ?? ""
        historyPastIllness = record?.pastIllness ?? ""
        historyPastDate = record?.pastIllnessDate ?? ""
        historyPastMedicine = record?.pastMedicine ?? ""
        selectedTab = 1
        showEditMedHistory = true
    }

    func saveHistory() async {
        guard let petId = pet.id else { return }

        var record = editingHistory ?? MedicalHistory(petId: petId, recordDate: Date().formatted(date: .long, time: .omitted), diagnosis: "", activity: "", age: pet.age, weight: "", medicine: "")
        record.weight = historyWeight
        record.currentIllness = historyCurrentIllness
        record.currentIllnessDate = historyCurrentDate
        record.currentMedicine = historyCurrentMedicine
        record.pastIllness = historyPastIllness
        record.pastIllnessDate = historyPastDate
        record.pastMedicine = historyPastMedicine
        record.diagnosis = historyCurrentIllness
        record.medicine = historyCurrentMedicine

        do {
            if let id = record.id {
                try await supabase
                    .from("medical_histories")
                    .update(record)
                    .eq("id", value: id.uuidString)
                    .execute()

                if let index = medicalHistories.firstIndex(where: { $0.id == id }) {
                    medicalHistories[index] = record
                }
            } else {
                let savedRecord: MedicalHistory = try await supabase
                    .from("medical_histories")
                    .insert(record)
                    .select()
                    .single()
                    .execute()
                    .value
                medicalHistories.append(savedRecord)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        editingHistory = nil
    }

    func deleteHistory() async {
        guard let id = editingHistory?.id else { return }

        do {
            try await supabase
                .from("medical_histories")
                .delete()
                .eq("id", value: id.uuidString)
                .execute()
            medicalHistories.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
        editingHistory = nil
    }

    // MARK: Gallery

    func beginEditGallery(_ entry: GalleryEntry?) {
        editingGallery = entry
        galleryDate = entry?.entryDate ?? ""
        galleryNote = entry?.note ?? ""
        galleryActivity = entry?.activity ?? ""
        galleryImageData = nil
        selectedTab = 2
        showEditGallery = true
    }

    func saveGallery() async {
        guard let petId = pet.id else { return }

        var entry = editingGallery ?? GalleryEntry(petId: petId, entryDate: "", note: "", activity: "")
        entry.entryDate = galleryDate
        entry.note = galleryNote
        entry.activity = galleryActivity

        do {
            if let imageData = galleryImageData {
                isUploading = true
                defer { isUploading = false }
                entry.photoUrl = try await PhotoStorage.upload(imageData)
            }

            if let id = entry.id {
                try await supabase
                    .from("gallery_entries")
                    .update(entry)
                    .eq("id", value: id.uuidString)
                    .execute()

                if let index = galleryEntries.firstIndex(where: { $0.id == id }) {
                    galleryEntries[index] = entry
                }
            } else {
                let savedEntry: GalleryEntry = try await supabase
                    .from("gallery_entries")
                    .insert(entry)
                    .select()
                    .single()
                    .execute()
                    .value
                galleryEntries.append(savedEntry)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        editingGallery = nil
        galleryImageData = nil
    }

    func deleteGallery() async {
        guard let id = editingGallery?.id else { return }

        do {
            try await supabase
                .from("gallery_entries")
                .delete()
                .eq("id", value: id.uuidString)
                .execute()
            galleryEntries.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
        editingGallery = nil
    }

    // MARK: Photos
    
    func beginChangePetPhoto() {
        photoTarget = .pet
        showPhotoOptions = true
    }
   
    func takePhoto(for target: PhotoTarget) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            errorMessage = "The camera is not available on this device. Try Photos instead."
            return
        }
        photoTarget = target
        showCamera = true
    }

    func choosePhoto(for target: PhotoTarget) {
        photoTarget = target
        showPhotoLibrary = true
    }

    func handlePickedItem(petController: PetController) async {
        guard let item = selectedPhotoItem else { return }
        selectedPhotoItem = nil

        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                if photoTarget == .pet, let image = UIImage(data: data) {
                    cropImage = image
                    return
                }

                let imageData = UIImage(data: data)?.jpegData(compressionQuality: 0.7) ?? data
                await usePhoto(imageData, petController: petController)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func handleCameraImage(_ image: UIImage, petController: PetController) async {
        if photoTarget == .pet {
            cropImage = image
            return
        }

        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return }
        await usePhoto(imageData, petController: petController)
    }

    func savePetPhoto(_ image: UIImage, petController: PetController) async {
        cropImage = nil
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return }
        await usePhoto(imageData, petController: petController)
    }

    private func usePhoto(_ imageData: Data, petController: PetController) async {
        if photoTarget == .gallery {
            
            galleryImageData = imageData
            return
        }

        isUploading = true
        defer { isUploading = false }

        do {
            var updatedPet = pet
            updatedPet.photoUrl = try await PhotoStorage.upload(imageData)

            if await petController.updatePet(updatedPet) {
                pet = updatedPet
            } else {
                errorMessage = petController.errorMessage
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
