//
//  DocumentationController.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/18/26.
//

import Foundation
import Supabase
import Combine
import PhotosUI
import SwiftUI
import UIKit

enum PetAction {
    case documentation
    case medicalHistory
}

// MARK: Documentation Controller

@MainActor
final class DocumentationController: ObservableObject {
    @Published var pendingAction: PetAction = .documentation
    @Published var selectedPet: Pet? = nil

    // MARK: Alert Sheets
    @Published var showChoosePet = false
    @Published var showPhotoOptions = false
    @Published var showDocumentationSheet = false

    // MARK: Photos
    @Published var showPhotoLibrary = false
    @Published var showCamera = false
    @Published var selectedPhotoItem: PhotosPickerItem? = nil
    @Published var cropImage: UIImage? = nil
    @Published var documentImage: UIImage? = nil

    //MARK: Add Documentation fields
    @Published var incidentDescription: String = ""
    @Published var incidentDate = Date()

    @Published var isSaving = false
    @Published var errorMessage: String? = nil

    func startDocumentation(petController: PetController, addPetController: AddPetController, router: AppRouter) {
        choosePet(for: .documentation, petController: petController, addPetController: addPetController, router: router)
    }

    func startMedicalHistory(petController: PetController, addPetController: AddPetController, router: AppRouter) {
        choosePet(for: .medicalHistory, petController: petController, addPetController: addPetController, router: router)
    }

    private func choosePet(for action: PetAction, petController: PetController, addPetController: AddPetController, router: AppRouter) {
        pendingAction = action

        if petController.pets.isEmpty {
            errorMessage = "Please add a pet first."
        } else if petController.pets.count == 1 {
            petChosen(petController.pets[0], addPetController: addPetController, router: router)
        } else {
            showChoosePet = true
        }
    }

    func petChosen(_ pet: Pet, addPetController: AddPetController, router: AppRouter) {
        showChoosePet = false

        if pendingAction == .medicalHistory {
            addPetController.startMedHistory(for: pet, router: router)
        } else {
            selectedPet = pet
            incidentDescription = ""
            incidentDate = Date()
            documentImage = nil
            showPhotoOptions = true
        }
    }

    // MARK: Photos

    func takePhoto() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            errorMessage = "The camera is not available on this device. Try Pick Photo in Gallery instead."
            return
        }
        showCamera = true
    }

    func choosePhoto() {
        showPhotoLibrary = true
    }

    func handlePickedItem() async {
        guard let item = selectedPhotoItem else { return }
        selectedPhotoItem = nil

        do {
            if let data = try await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                cropImage = image
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func handleCameraImage(_ image: UIImage) {
        cropImage = image
    }

    func photoCropped(_ image: UIImage) {
        cropImage = nil
        documentImage = image
        showDocumentationSheet = true
    }

    func cancel() {
        cropImage = nil
        documentImage = nil
        showDocumentationSheet = false
    }

    // MARK: Save to Supabase

    func saveDocumentation() async {
        guard let petId = selectedPet?.id, let image = documentImage else { return }

        let cleanDescription = incidentDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanDescription.isEmpty else {
            errorMessage = "Please enter a description."
            return
        }
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            let photoUrl = try await PhotoStorage.upload(imageData)

            let entry = GalleryEntry(
                petId: petId,
                entryDate: formattedDate(incidentDate),
                note: cleanDescription,
                activity: "",
                photoUrl: photoUrl
            )

            try await supabase
                .from("gallery_entries")
                .insert(entry)
                .execute()

            showDocumentationSheet = false
            documentImage = nil
            selectedPet = nil
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
}
