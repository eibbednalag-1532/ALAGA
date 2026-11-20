//
//  PetTab.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 9/11/26.
//

import SwiftUI

struct PetTab: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var addPetController: AddPetController
    @EnvironmentObject var reminderController: ReminderController
    @EnvironmentObject var documentationController: DocumentationController
    @EnvironmentObject var petController: PetController
    @State private var showChooseAction = false
    
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
            VStack(alignment: .leading, spacing: 10) {
                PetGreeting()
                
                
                Color.clear.frame(height: 15)
                Spacer()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 15){
                        PetList()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 90)
                }
                .refreshable {
                    await petController.fetchPets()
                }
            }
            
            AddButton {
                showChooseAction = true
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding(.trailing, 25)
            .padding(.bottom, 20)
            
            if showChooseAction {
                ChooseActionSheet(
                    isPresented: $showChooseAction,
                    onAddPet: { addPetController.startNewPet(router: router) },
                    onAddEvent: { reminderController.startNewEvent(router: router) },
                    onAddDocumentation: { documentationController.startDocumentation(petController: petController, addPetController: addPetController, router: router) },
                    onAddMedHistory: { documentationController.startMedicalHistory(petController: petController, addPetController: addPetController, router: router) }
                )
            }

            if router.selectedTab == 1 {
                DocumentationOverlay()
            }
        }
        .errorAlert($petController.errorMessage)
    }
}
struct PetGreeting: View {
    var body: some View {
        HStack {
            VStack {
                
                Text("Your Pets!")
                    .font(.system(size: 45, weight: .bold, design: .rounded))
                
            }
            Image(systemName: "pawprint.fill")
                .frame(width: 10)
                .foregroundStyle(Color.blue)
                .rotationEffect(.degrees(-20))
                .offset(y: -5)
            
            Image(systemName: "pawprint.fill")
                .frame(width: 10)
                .foregroundStyle(Color.blue)
                .rotationEffect(.degrees(-20))
                .offset(x: -5, y: 10)
        }
        .padding()
    }
}

struct AddButton: View {
    var action: () -> Void = {}
    
    var body: some View {
        VStack {
            Button(action: action) {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.white)
                }
            }
        }
    }
}
struct PetList: View {
    @EnvironmentObject var petController: PetController
    var body: some View {
        VStack(spacing: 15) {
            if petController.isLoading && petController.pets.isEmpty {
                ProgressView()
                    .padding(.top, 40)
            } else if petController.pets.isEmpty {
                Text("No pets yet. Tap the + button to add your first pet!")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
            }
            
            ForEach(petController.pets) { pet in
                PetLink(pet: pet)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
struct PetLink: View {
    let pet: Pet
    
    var body: some View {
        NavigationLink(value: AppRoute.petDetails(pet)) {
            PetsCard(petName: pet.name, breed: pet.breed, age: pet.age, iconName: pet.iconName, photoUrl: pet.photoUrl)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        PetTab()
    }
    .environmentObject(AppRouter())
    .environmentObject(PetController())
    .environmentObject(AddPetController())
    .environmentObject(ReminderController())
    .environmentObject(DocumentationController())
}
