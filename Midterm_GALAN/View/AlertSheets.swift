//
//  AlertSheets.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/12/26.
//

import SwiftUI
import PhotosUI

struct CustomAlertContainer<Content: View>: View {
    @Binding var isPresented: Bool
    let title: String
    var showsBackButton: Bool = true
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            Color.black.opacity(0.15)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    if showsBackButton {
                        Button(action: {
                            isPresented = false
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.black)
                        }
                    }

                    Text(title)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: showsBackButton ? .center : .leading)

                    if showsBackButton {
                        Color.clear.frame(width: 18, height: 18)
                    }
                }

                content
            }
            .padding(20)
            .frame(width: 300)
            .background(Color(.sRGB, red: 200/255, green: 200/255, blue: 200/255).opacity(0.95))
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
}

struct SheetFieldItem {
    let placeholder: String
    let text: Binding<String>
    var unit: String? = nil
}

struct SheetTextField: View {
    let placeholder: String
    @Binding var text: String
    var unit: String? = nil

    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .font(.system(size: 17, weight: .regular, design: .rounded))

            if let unit = unit {
                Text(unit)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.gray)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white)
        .cornerRadius(20)
    }
}

struct SheetButton: View {
    let title: String
    var backgroundColor: Color = .green
    var foregroundColor: Color = .white
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(backgroundColor)
                .cornerRadius(16)
        }
    }
}

struct CustomEditSheet: View {
    @Binding var isPresented: Bool
    let title: String
    let fields: [SheetFieldItem]
    var showsPhotoButtons: Bool = false
    var photoAdded: Bool = false
    var onTakePhoto: () -> Void = {}
    var onChoosePhoto: () -> Void = {}
    var onSave: () -> Void = {}
    var onDelete: () -> Void = {}
    var showsDeleteButton: Bool = true

    @State private var showConfirmDelete = false

    var body: some View {
        ZStack {
            CustomAlertContainer(isPresented: $isPresented, title: title) {
                VStack(spacing: 8) {
                    ForEach(fields.indices, id: \.self) { index in
                        SheetTextField(
                            placeholder: fields[index].placeholder,
                            text: fields[index].text,
                            unit: fields[index].unit
                        )
                    }

                    if showsPhotoButtons {
                        HStack(spacing: 15) {
                            SheetButton(title: "Take Photo", action: onTakePhoto)

                            SheetButton(title: "Photos", action: onChoosePhoto)
                        }
                        .padding(.top, 4)

                        if photoAdded {
                            Text("Photo added, press Save to upload it")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(Color.green)
                        }
                    }

                    HStack(spacing: 15) {
                        SheetButton(title: "Save") {
                            onSave()
                            isPresented = false
                        }

                        if showsDeleteButton {
                            SheetButton(title: "Delete", backgroundColor: .red) {
                                showConfirmDelete = true
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            }

            if showConfirmDelete {
                ConfirmDeleteSheet(isPresented: $showConfirmDelete) {
                    onDelete()
                    isPresented = false
                }
            }
        }
    }
}

struct ConfirmDeleteSheet: View {
    @Binding var isPresented: Bool
    var message: String = "This will be permanently deleted. Do you want to continue?"
    var onConfirm: () -> Void = {}

    var body: some View {
        CustomAlertContainer(isPresented: $isPresented, title: "Confirm Delete", showsBackButton: false) {
            VStack(spacing: 10) {
                Text(message)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                HStack(spacing: 15) {
                    SheetButton(title: "Cancel", backgroundColor: Color.gray.opacity(0.4), foregroundColor: .black) {
                        isPresented = false
                    }

                    SheetButton(title: "Delete", backgroundColor: .red) {
                        isPresented = false
                        onConfirm()
                    }
                }
                .padding(.top, 4)
            }
        }
    }
}

// MARK: Edit Pet Information

struct EditPetInfoSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var controller: PetDetailsController
    var onSave: () -> Void = {}
    var onDelete: () -> Void = {}

    var body: some View {
        CustomEditSheet(
            isPresented: $isPresented,
            title: "Pet Information",
            fields: [
                SheetFieldItem(placeholder: "Name", text: $controller.editName),
                SheetFieldItem(placeholder: "Breed", text: $controller.editBreed),
                SheetFieldItem(placeholder: "Age", text: $controller.editAge),
                SheetFieldItem(placeholder: "Birthdate", text: $controller.editBirthdate),
                SheetFieldItem(placeholder: "Gender", text: $controller.editGender),
                SheetFieldItem(placeholder: "Weight", text: $controller.editWeight, unit: "Kg")
            ],
            onSave: onSave,
            onDelete: onDelete
        )
    }
}

// MARK: Edit Medical History

struct EditMedHistorySheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var controller: PetDetailsController
    var onSave: () -> Void = {}
    var onDelete: () -> Void = {}

    var body: some View {
        CustomEditSheet(
            isPresented: $isPresented,
            title: "Medical History",
            fields: [
                SheetFieldItem(placeholder: "Weight", text: $controller.historyWeight, unit: "Kg"),
                SheetFieldItem(placeholder: "Current Illness", text: $controller.historyCurrentIllness),
                SheetFieldItem(placeholder: "Date of Diagnosis", text: $controller.historyCurrentDate),
                SheetFieldItem(placeholder: "Medicine Taken", text: $controller.historyCurrentMedicine),
                SheetFieldItem(placeholder: "Post Illness", text: $controller.historyPastIllness),
                SheetFieldItem(placeholder: "Date of Diagnosis", text: $controller.historyPastDate),
                SheetFieldItem(placeholder: "Medicine Taken", text: $controller.historyPastMedicine)
            ],
            onSave: onSave,
            onDelete: onDelete
        )
    }
}

// MARK: Edit Gallery Details

struct EditGallerySheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var controller: PetDetailsController
    var onSave: () -> Void = {}
    var onDelete: () -> Void = {}

    var body: some View {
        CustomEditSheet(
            isPresented: $isPresented,
            title: "Gallery",
            fields: [
                SheetFieldItem(placeholder: "May 14, 2023", text: $controller.galleryDate),
                SheetFieldItem(placeholder: "No Progress In Growth", text: $controller.galleryNote),
                SheetFieldItem(placeholder: "Swimming", text: $controller.galleryActivity)
            ],
            showsPhotoButtons: true,
            photoAdded: controller.galleryImageData != nil,
            onTakePhoto: { controller.takePhoto(for: .gallery) },
            onChoosePhoto: { controller.choosePhoto(for: .gallery) },
            onSave: onSave,
            onDelete: onDelete
        )
    }
}

// MARK: Edit Active Medication

struct EditActiveMedSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var controller: PetDetailsController
    var onSave: () -> Void = {}
    var onDelete: () -> Void = {}

    var body: some View {
        CustomEditSheet(
            isPresented: $isPresented,
            title: "Active Medication",
            fields: [
                SheetFieldItem(placeholder: "Diagnosis", text: $controller.medDiagnosis),
                SheetFieldItem(placeholder: "Medicine", text: $controller.medMedicine),
                SheetFieldItem(placeholder: "Intake Frequency", text: $controller.medIntakeFrequency),
                SheetFieldItem(placeholder: "Intake Duration", text: $controller.medIntakeDuration)
            ],
            onSave: onSave,
            onDelete: onDelete
        )
    }
}

// MARK: Edit Reminder

struct EditReminderSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var controller: ReminderController
    var onSave: () -> Void = {}

    var body: some View {
        CustomEditSheet(
            isPresented: $isPresented,
            title: "Reminder",
            fields: [
                SheetFieldItem(placeholder: "Event Type", text: $controller.editEventType),
                SheetFieldItem(placeholder: "Pet", text: $controller.editPetName)
            ],
            onSave: onSave,
            showsDeleteButton: false
        )
    }
}

// MARK: Pet Photo

struct PhotoOptionsSheet: View {
    @Binding var isPresented: Bool
    var onTakePhoto: () -> Void = {}
    var onChoosePhoto: () -> Void = {}

    var body: some View {
        CustomAlertContainer(isPresented: $isPresented, title: "Pet Photo", showsBackButton: false) {
            VStack(spacing: 10) {
                SheetButton(title: "Take a Photo") {
                    isPresented = false
                    onTakePhoto()
                }

                SheetButton(title: "Pick Photo in Gallery") {
                    isPresented = false
                    onChoosePhoto()
                }

                SheetButton(title: "Cancel", backgroundColor: Color.gray.opacity(0.4), foregroundColor: .red) {
                    isPresented = false
                }
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
        }
    }
}

// MARK: Choose Pet

struct ChoosePetSheet: View {
    @Binding var isPresented: Bool
    let pets: [Pet]
    var onChoose: (Pet) -> Void = { _ in }

    var body: some View {
        CustomAlertContainer(isPresented: $isPresented, title: "Choose Pet", showsBackButton: false) {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(pets) { pet in
                        SheetButton(title: pet.name) {
                            onChoose(pet)
                        }
                    }
                }
            }
            .frame(maxHeight: 250)
            .padding(.horizontal, 10)
            .padding(.top, 10)

            SheetButton(title: "Cancel", backgroundColor: Color.gray.opacity(0.4), foregroundColor: .red) {
                isPresented = false
            }
            .padding(.horizontal, 10)
        }
    }
}

// MARK: Add Documentation

struct AddDocumentationSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var controller: DocumentationController
    var onSave: () -> Void = {}

    var body: some View {
        CustomAlertContainer(isPresented: $isPresented, title: "Add Documentation") {
            VStack(spacing: 10) {
                if let image = controller.documentImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                if let pet = controller.selectedPet {
                    Text("For \(pet.name)")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.gray)
                }

                SheetTextField(placeholder: "e.g Vomiting", text: $controller.incidentDescription)

                DatePicker(
                    "Date and Time", selection: $controller.incidentDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .tint(Color.blue)

                SheetButton(title: controller.isSaving ? "Saving..." : "Save", action: onSave)
                    .disabled(controller.isSaving)
                    .padding(.top, 4)
            }
        }
    }
}

struct DocumentationOverlay: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var petController: PetController
    @EnvironmentObject var addPetController: AddPetController
    @EnvironmentObject var documentationController: DocumentationController

    var body: some View {
        ZStack {
            Color.clear
                .frame(width: 0, height: 0)

            if documentationController.showChoosePet {
                ChoosePetSheet(isPresented: $documentationController.showChoosePet, pets: petController.pets) { pet in
                    documentationController.petChosen(pet, addPetController: addPetController, router: router)
                }
            }

            if documentationController.showPhotoOptions {
                PhotoOptionsSheet(
                    isPresented: $documentationController.showPhotoOptions,
                    onTakePhoto: { documentationController.takePhoto() },
                    onChoosePhoto: { documentationController.choosePhoto() }
                )
            }

            if let image = documentationController.cropImage {
                PhotoCropper(
                    image: image,
                    isSquare: true,
                    onCancel: { documentationController.cancel() },
                    onSave: { croppedImage in
                        documentationController.photoCropped(croppedImage)
                    }
                )
            }

            if documentationController.showDocumentationSheet {
                AddDocumentationSheet(
                    isPresented: $documentationController.showDocumentationSheet,
                    controller: documentationController,
                    onSave: { Task { await documentationController.saveDocumentation() } }
                )
            }
        }
        .errorAlert($documentationController.errorMessage)
        .photosPicker(isPresented: $documentationController.showPhotoLibrary, selection: $documentationController.selectedPhotoItem, matching: .images)
        .onChange(of: documentationController.selectedPhotoItem) {
            Task {
                await documentationController.handlePickedItem()
            }
        }
        .fullScreenCover(isPresented: $documentationController.showCamera) {
            CameraPicker { image in
                documentationController.handleCameraImage(image)
            }
            .ignoresSafeArea()
        }
    }
}

struct ChooseActionSheet: View {
    @Binding var isPresented: Bool
    var onAddPet: () -> Void = {}
    var onAddEvent: () -> Void = {}
    var onAddDocumentation: () -> Void = {}
    var onAddMedHistory: () -> Void = {}

    var body: some View {
        CustomAlertContainer(isPresented: $isPresented, title: "Choose Action", showsBackButton: false) {
            VStack(spacing: 10) {
                SheetButton(title: "Add Pet") {
                    isPresented = false
                    onAddPet()
                }

                SheetButton(title: "Add Event") {
                    isPresented = false
                    onAddEvent()
                }

                SheetButton(title: "Add Documentation") {
                    isPresented = false
                    onAddDocumentation()
                }

                SheetButton(title: "Add Medical History") {
                    isPresented = false
                    onAddMedHistory()
                }

                SheetButton(title: "Cancel", backgroundColor: Color.gray.opacity(0.4), foregroundColor: .red) {
                    isPresented = false
                }
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
        }
    }
}

#Preview {
    ZStack {
        Color.green.opacity(0.3)
            .ignoresSafeArea()
        EditGallerySheet(isPresented: .constant(true), controller: PetDetailsController(pet: Pet.sample))
    }
}
