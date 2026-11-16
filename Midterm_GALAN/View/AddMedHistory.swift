//
//  AddMedHistory.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

struct AddMedHistory: View {
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
                MedHistoryGreetings()
                FillMedHstory()
                
                Spacer(minLength: 22)
                MedHistorySaveButton()
            }
            
            
        }
    }
}
struct MedHistoryGreetings: View {
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text("Medical History")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            
            Text("Help Us Keep Track of Your Pet's Health")
                .font(.system(size: 16.5, weight: .regular))
                .foregroundStyle(Color.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 8)
        .offset(x: 30, y: 50)
    }
}
struct FillMedHstory: View {
    @EnvironmentObject var addPetController: AddPetController
    var body: some View {
        VStack(spacing: 6) {
            AddPetTextField(title: "Weight(kg)", example: "3.5", text: $addPetController.weight)
            
            AddPetTextField(title: "Current Illness(if applicable)", example: "N/A", text: $addPetController.currentIllness)
            
            AddPetTextField(title: "Date of Diagnosis", example: "N/A", text: $addPetController.currentIllnessDate)
            
            AddPetTextField(title: "Medicine Taken", example: "N/A", text: $addPetController.currentMedicine)
            
            AddPetTextField(title: "Post Illness(if applicable)", example: "Allergy", text: $addPetController.pastIllness)
            
            AddPetTextField(title: "Date of Diagnosis", example: "June 1, 2026", text: $addPetController.pastIllnessDate)
            
            AddPetTextField(title: "Medicine Taken", example: "Antihistamine", text: $addPetController.pastMedicine)
            
            Spacer(minLength: 0)
            
            
        }
        .padding(.horizontal)
        .offset(y: 65)
    }
}
struct MedHistorySaveButton: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var addPetController: AddPetController
    
    var body: some View {
        //Goes to Active Medication, the back button brings you back here
        CustomSaveButton(title: "Save") {
            addPetController.goToActiveMed(router: router)
        }
        .padding(.vertical, 70)
        .padding(.trailing, -10)
    }
}
#Preview {
    NavigationStack {
        AddMedHistory()
    }
    .environmentObject(AppRouter())
    .environmentObject(AddPetController())
}
