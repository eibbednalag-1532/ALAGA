//
//  AddActiveMed.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

struct AddActiveMed: View {
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

            VStack {
                ActiveMedGreetings()
                FillActiveMed()

                Spacer(minLength: 22)
                ActiveMedSaveButton()
            }


        }
        .errorAlert($addPetController.errorMessage)
    }
}
struct ActiveMedGreetings: View {
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text("Active Medication")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.top, 40)
    }
}
struct FillActiveMed: View {
    @EnvironmentObject var addPetController: AddPetController
    var body: some View {
        VStack(spacing: 6) {
            AddPetTextField(title: "Diagnosis", example: "N/A", text: $addPetController.diagnosis)

            AddPetTextField(title: "Date of Diagnosis", example: "N/A", text: $addPetController.diagnosisDate)

            AddPetTextField(title: "Medication", example: "N/A", text: $addPetController.medication)

            AddPetTextField(title: "Intake Frequency", example: "N/A", text: $addPetController.intakeFrequency)

            AddPetTextField(title: "Intake Duration", example: "N/A", text: $addPetController.intakeDuration)

            Spacer(minLength: 0)


        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
}
struct ActiveMedSaveButton: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var reminderController: ReminderController
    @EnvironmentObject var addPetController: AddPetController

    var body: some View {
        CustomSaveButton(title: "Save") {
            addPetController.goToAddEvent(reminderController: reminderController, router: router)
        }
        .padding(.vertical, 40)
    }
}

#Preview {
    NavigationStack {
        AddActiveMed()
    }
    .environmentObject(AppRouter())
    .environmentObject(ReminderController())
    .environmentObject(AddPetController())
}
