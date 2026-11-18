//
//  AddEvent.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

struct AddEvent: View {
    @EnvironmentObject var reminderController: ReminderController
    @EnvironmentObject var addPetController: AddPetController
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
            
            ScrollView {
                VStack {
                    EventHeader()
                    EventDetails()
                    AddDateTime()
                    EventSaveButton()
                }
            }
            //Shows errors while saving a new pet
            .errorAlert($addPetController.errorMessage)
            
            
        }
        .errorAlert($reminderController.errorMessage)
    }
}
struct EventHeader: View {
    var body: some View {
        VStack(spacing: 35){
            Text("Add Event")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.70)
            
            
            Text("Event Details")
                .font(.system(size: 30, weight: .regular))
                .offset(x: -85)
        }
        .padding(100)
        .padding(.vertical, -30)
    }
}
struct EventDetails: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var reminderController: ReminderController
    var body: some View {
        VStack {
            AddPetTextField(title: "Event Type", example: "e.g Check-Up", text: $reminderController.eventType)
            
            //When adding a new pet, the event is for that pet so it can't be changed
            if router.path.contains(.addActiveMed) {
                AddPetTextField(title: "Pet", example: reminderController.petName)
            } else {
                AddPetTextField(title: "Pet", example: "e.g Buddy", text: $reminderController.petName)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 35)
        .padding(.vertical, -45)
    }
}
struct AddDateTime: View {
    @EnvironmentObject var reminderController: ReminderController
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date And Time")
                .font(.system(size: 22, weight: .regular))
                .foregroundColor(.primary)
            
            DatePicker(
                "Selected Date and Time", selection: $reminderController.eventDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.graphical)
            .tint(Color.blue)
            .padding(10)
            .background(Color.white)
            .cornerRadius(15)
            .frame(width: 320)
        }
        .padding(.top, 65)
    }
}
struct EventSaveButton: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var petController: PetController
    @EnvironmentObject var reminderController: ReminderController
    @EnvironmentObject var addPetController: AddPetController
    
    var body: some View {
        let isSaving = reminderController.isLoading || addPetController.isLoading
        
        CustomSaveButton(title: isSaving ? "Saving..." : "Save") {
            Task {
                if router.path.contains(.addActiveMed) {
                    //Last Add Pet page: saves the pet, medical history, medication and event, then opens the Pets Tab
                    await addPetController.savePet(petController: petController, reminderController: reminderController, router: router)
                } else {
                    //Saves the event to Supabase and goes back to the page that opened it
                    await reminderController.saveEvent(petController: petController, router: router)
                }
            }
        }
        .disabled(isSaving)
        .padding(.vertical, 30)
    }
}


#Preview {
    NavigationStack {
        AddEvent()
    }
    .environmentObject(AppRouter())
    .environmentObject(PetController())
    .environmentObject(ReminderController())
    .environmentObject(AddPetController())
}
