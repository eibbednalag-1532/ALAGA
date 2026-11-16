//
//  ReminderTab.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 9/11/26.
//
import SwiftUI

struct ReminderTab: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var addPetController: AddPetController
    @EnvironmentObject var reminderController: ReminderController
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
            VStack(alignment: .center, spacing: 5) {

                Title()
                    .padding(.horizontal)
                    .padding(.top, 10)

                UnderlineTabBar(tabs: ["Upcoming", "Past"], selectedTab: $reminderController.selectedTab)

                Color.clear.frame(height: 15)
                Spacer()

                ScrollView {
                    VStack(alignment: .leading, spacing: 10){
                        if reminderController.selectedTab == 0 {
                            UpcomingReminders()
                        } else {
                            PastReminders()
                        }

                    }
                    .padding(.horizontal)
                    .padding(.bottom, 90)
                }
                .refreshable {
                    await reminderController.fetchReminders()
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
                    onAddEvent: { reminderController.startNewEvent(router: router) }
                )
            }

        }
        .errorAlert($reminderController.errorMessage)
    }
}
struct Title: View {
    var body: some View {
        Text("Reminders")
            .font(.system(size: 45, weight: .bold, design: .rounded))
    }

}
struct UpcomingReminders: View {
    @EnvironmentObject var reminderController: ReminderController
    var body: some View {
        ReminderList(reminders: reminderController.upcomingReminders, emptyText: "No upcoming reminders. Tap the + button to add an event!")
    }
}
struct PastReminders: View {
    @EnvironmentObject var reminderController: ReminderController
    var body: some View {
        ReminderList(reminders: reminderController.pastReminders, emptyText: "No past reminders yet")
    }
}
struct ReminderList: View {
    @EnvironmentObject var reminderController: ReminderController
    let reminders: [Reminder]
    let emptyText: String

    var body: some View {
        VStack(spacing: 10) {
            if reminders.isEmpty {
                Text(emptyText)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            }

            ForEach(reminders) { reminder in
                ReminderListCard(
                    eventName: reminder.eventType,
                    dateTime: reminderController.formattedDate(reminder.eventDate),
                    petName: reminder.petName,
                    iconName: reminderController.iconName(for: reminder.eventType)
                )
                //Press and hold a card to delete it
                .contextMenu {
                    Button(role: .destructive) {
                        Task {
                            await reminderController.deleteReminder(reminder)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
}
struct ReminderListCard: View {
    let eventName: String
    let dateTime: String
    let petName: String
    let iconName: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(eventName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))

                Text(dateTime)
                    .font(.system(size: 14, weight: .regular))

                Text(petName)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.gray)
            }

            Spacer()

            Image(systemName: iconName)
                .font(.system(size: 32))
                .foregroundStyle(Color.blue)
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(15)
    }
}

#Preview {
    NavigationStack {
        ReminderTab()
    }
    .environmentObject(AppRouter())
    .environmentObject(AddPetController())
    .environmentObject(ReminderController())
}
