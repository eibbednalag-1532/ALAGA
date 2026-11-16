//
//  AddEvent.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

struct AddEvent: View {
    @EnvironmentObject var reminderController: ReminderController
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
    @EnvironmentObject var reminderController: ReminderController
    var body: some View {
        VStack {
            AddPetTextField(title: "Event Type", example: "e.g Check-Up", text: $reminderController.eventType)
            
            AddPetTextField(title: "Pet", example: "e.g Buddy", text: $reminderController.petName)
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
    
    var body: some View {
        //Saves the event to Supabase and goes back to the page that opened it
        CustomSaveButton(title: reminderController.isLoading ? "Saving..." : "Save") {
            Task {
                await reminderController.saveEvent(petController: petController, router: router)
            }
        }
        .disabled(reminderController.isLoading)
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
}
