//
//  PetDetails.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/12/26.
//

import SwiftUI
import PhotosUI

struct PetDetails: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var petController: PetController
    @StateObject private var controller: PetDetailsController

    @Environment(\.dismiss) private var dismiss

    init(pet: Pet) {
        _controller = StateObject(wrappedValue: PetDetailsController(pet: pet))
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            AngularGradient(
                stops: [Gradient.Stop(color: Color(.sRGB, red: 156/255, green: 229/255, blue: 174/255), location: 0.36),
                        Gradient.Stop(color: Color(.sRGB, red: 160/255, green: 192/255, blue: 233/255), location: 0.89)
                       ],
                center: .center,
                startAngle: .degrees(90),
                endAngle: .degrees(360)
            )
            .ignoresSafeArea()

            VStack(spacing: 10) {
                PetDetailsHeader(
                    petName: controller.pet.name,
                    breed: controller.pet.breed,
                    age: controller.pet.age,
                    iconName: controller.pet.iconName,
                    photoUrl: controller.pet.photoUrl,
                    isUploading: controller.isUploading,
                    onBack: { dismiss() },
                    onChangePhoto: { controller.beginChangePetPhoto() },
                    onAddHistory: { controller.beginEditHistory(nil) },
                    onAddGallery: { controller.beginEditGallery(nil) },
                    onDeletePet: {
                        Task {
                            await controller.deletePet(petController: petController, router: router)
                        }
                    }
                )

                UnderlineTabBar(tabs: ["Overview", "Medical History", "Gallery"], selectedTab: $controller.selectedTab)

                ScrollView {
                    VStack(spacing: 15) {
                        if controller.selectedTab == 0 {
                            PetOverview(
                                controller: controller,
                                onEditPetInfo: { controller.beginEditPetInfo() },
                                onEditActiveMed: { controller.beginEditActiveMed() }
                            )
                        } else if controller.selectedTab == 1 {
                            PetMedicalHistory(controller: controller)
                        } else {
                            PetGallery(controller: controller)
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 10)
                }
            }

            // MARK: Alert Sheets
            if controller.showEditPetInfo {
                EditPetInfoSheet(
                    isPresented: $controller.showEditPetInfo,
                    controller: controller,
                    onSave: { Task { await controller.savePetInfo(petController: petController) } },
                    onDelete: { Task { await controller.deletePet(petController: petController, router: router) } }
                )
            }

            if controller.showEditActiveMed {
                EditActiveMedSheet(
                    isPresented: $controller.showEditActiveMed,
                    controller: controller,
                    onSave: { Task { await controller.saveActiveMed() } },
                    onDelete: { Task { await controller.deleteActiveMed() } }
                )
            }

            if controller.showEditMedHistory {
                EditMedHistorySheet(
                    isPresented: $controller.showEditMedHistory,
                    controller: controller,
                    onSave: { Task { await controller.saveHistory() } },
                    onDelete: { Task { await controller.deleteHistory() } }
                )
            }

            if controller.showEditGallery {
                EditGallerySheet(
                    isPresented: $controller.showEditGallery,
                    controller: controller,
                    onSave: { Task { await controller.saveGallery() } },
                    onDelete: { Task { await controller.deleteGallery() } }
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .errorAlert($controller.errorMessage)
        // MARK: Photos
        //Camera icon > choose where the photo comes from
        .confirmationDialog("Pet Photo", isPresented: $controller.showPhotoOptions, titleVisibility: .visible) {
            Button("Take Photo") {
                controller.takePhoto(for: .pet)
            }

            Button("Choose from Photos") {
                controller.choosePhoto(for: .pet)
            }

            Button("Cancel", role: .cancel) {}
        }
        .photosPicker(isPresented: $controller.showPhotoLibrary, selection: $controller.selectedPhotoItem, matching: .images)
        .onChange(of: controller.selectedPhotoItem) {
            Task {
                await controller.handlePickedItem(petController: petController)
            }
        }
        .fullScreenCover(isPresented: $controller.showCamera) {
            CameraPicker { image in
                Task {
                    await controller.handleCameraImage(image, petController: petController)
                }
            }
            .ignoresSafeArea()
        }
        //Loads Medical History, Active Medication and Gallery from Supabase
        .task {
            await controller.loadDetails()
        }
    }
}
struct PetDetailsHeader: View {
    let petName: String
    let breed: String
    let age: String
    let iconName: String
    var photoUrl: String? = nil
    var isUploading: Bool = false
    let onBack: () -> Void
    var onChangePhoto: () -> Void = {}
    var onAddHistory: () -> Void = {}
    var onAddGallery: () -> Void = {}
    var onDeletePet: () -> Void = {}

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.black)
                }

                Spacer()

                //More options for this pet
                Menu {
                    Button(action: onAddHistory) {
                        Label("Add Medical History", systemImage: "cross.case")
                    }

                    Button(action: onAddGallery) {
                        Label("Add Gallery Entry", systemImage: "photo")
                    }

                    Button(role: .destructive, action: onDeletePet) {
                        Label("Delete Pet", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(Color.black)
                }
            }
            .padding(.horizontal)

            ZStack(alignment: .bottomTrailing) {
                //Pet photo, shows the icon when there is no photo yet
                Group {
                    if let photoUrl = photoUrl, let url = URL(string: photoUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundStyle(Color.gray)
                    }
                }
                    .frame(width: 120, height: 120)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.5))
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.blue, lineWidth: 2)
                    )
                    .overlay {
                        if isUploading {
                            ProgressView()
                        }
                    }

                Button(action: onChangePhoto) {
                    Image(systemName: "camera")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.black)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(Color.white)
                        )
                }
            }

            Text(petName)
                .font(.system(size: 30, weight: .bold, design: .rounded))

            Text("\(breed)  .  \(age)")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.gray)
        }
    }
}

// MARK: Overview
struct PetOverview: View {
    @ObservedObject var controller: PetDetailsController
    let onEditPetInfo: () -> Void
    let onEditActiveMed: () -> Void

    var body: some View {
        VStack(spacing: 15) {
            DetailsCard(
                title: "Pet Information",
                rows: controller.petInfoRows,
                onEdit: onEditPetInfo
            )

            DetailsCard(
                title: "Active Medication",
                rows: controller.activeMedRows,
                onEdit: onEditActiveMed
            )
        }
    }
}

// MARK: Medical History
struct PetMedicalHistory: View {
    @ObservedObject var controller: PetDetailsController

    var body: some View {
        VStack(spacing: 15) {
            if controller.medicalHistories.isEmpty {
                EmptyDetailsText(text: "No medical history yet. Tap the ... button to add one.")
            }

            ForEach(controller.medicalHistories) { record in
                DetailsCard(
                    title: controller.display(record.recordDate),
                    rows: controller.historyRows(record),
                    onEdit: { controller.beginEditHistory(record) }
                )
            }
        }
    }
}

// MARK: Gallery
struct PetGallery: View {
    @ObservedObject var controller: PetDetailsController

    var body: some View {
        VStack(spacing: 15) {
            if controller.galleryEntries.isEmpty {
                EmptyDetailsText(text: "No gallery entries yet. Tap the ... button to add one.")
            }

            ForEach(controller.galleryEntries) { entry in
                GalleryCard(
                    date: controller.display(entry.entryDate),
                    note: controller.display(entry.note),
                    photoUrl: entry.photoUrl,
                    onEdit: { controller.beginEditGallery(entry) }
                )
            }
        }
    }
}

struct EmptyDetailsText: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 15, weight: .regular))
            .foregroundStyle(Color.gray)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 30)
    }
}

// MARK: Cards
struct DetailsCard: View {
    let title: String
    let rows: [(String, String)]
    let onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))

                Spacer()

                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundStyle(Color.black)
                }
            }

            ForEach(rows.indices, id: \.self) { index in
                VStack(spacing: 4) {
                    HStack {
                        Text(rows[index].0)

                        Spacer()

                        Text(rows[index].1)
                    }
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.gray)

                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color.gray.opacity(0.3))
                }
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .top)
        .background(Color.white)
        .cornerRadius(15)
    }
}
struct GalleryCard: View {
    let date: String
    let note: String
    var photoUrl: String? = nil
    let onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(date)
                    .font(.system(size: 15, weight: .bold, design: .rounded))

                Spacer()

                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundStyle(Color.black)
                }
            }

            HStack(alignment: .top, spacing: 12) {
                //Gallery photo, gray box when there is no photo yet
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray.opacity(0.3))
                    .overlay {
                        if let photoUrl = photoUrl, let url = URL(string: photoUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .frame(width: 90, height: 65)

                Text(note)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.gray)

                Spacer()
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .top)
        .background(Color.white)
        .cornerRadius(15)
    }
}

#Preview {
    NavigationStack {
        PetDetails(pet: Pet.sample)
    }
    .environmentObject(AppRouter())
    .environmentObject(PetController())
}
