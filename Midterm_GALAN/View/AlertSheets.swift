//
//  AlertSheets.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/12/26.
//

import SwiftUI

// MARK: Reusable Alert Sheet Container
//Gray card that floats on top of the screen, every alert sheet uses this
struct CustomAlertContainer<Content: View>: View {
    @Binding var isPresented: Bool
    let title: String
    var showsBackButton: Bool = true
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            //Dims the screen behind the alert sheet, tap outside to close
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
                        //Keeps the title in the center
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

// MARK: Alert Sheet Parts
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

// MARK: Reusable Edit Sheet (fields + Save / Delete)
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

    var body: some View {
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

                    //Shows after a photo is picked, it uploads when Save is pressed
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

                    SheetButton(title: "Delete", backgroundColor: .red) {
                        onDelete()
                        isPresented = false
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
                SheetFieldItem(placeholder: "May 15, 2023", text: $controller.historyDate),
                SheetFieldItem(placeholder: "Dwarfism", text: $controller.historyDiagnosis),
                SheetFieldItem(placeholder: "Swimming", text: $controller.historyActivity),
                SheetFieldItem(placeholder: "1.5", text: $controller.historyWeight, unit: "Kg")
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

// MARK: Choose Action (green button in Pet Tab and Reminder Tab)
struct ChooseActionSheet: View {
    @Binding var isPresented: Bool
    var onAddPet: () -> Void = {}
    var onAddEvent: () -> Void = {}

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
