//
//  AddPetInfo.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

struct PetInfo: View {
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
            VStack(spacing: -40) {
                PetInfoGreetings()
                FillPetInfo()
                SaveButton()
            }
        }
        .errorAlert($addPetController.errorMessage)
    }
}

struct PetInfoGreetings: View {
    var body: some View {
        VStack {
            Text("Pet Information")
                .font(.system(size: 43.5, weight: .bold, design: .rounded))
                .padding(.vertical, 90)
                .padding(.leading, 45)
            
            Text("Tell Us More About Your Pet")
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(Color.gray)
                .offset(x: 15, y: -80)
        }
    }
}

struct FillPetInfo: View {
    @EnvironmentObject var addPetController: AddPetController
    var body: some View {
        VStack {
            AddPetTextField(title: "Pet Name", example: "Buddy", text: $addPetController.petName)
            
            AddPetTextField(title: "Breed", example: "Golden Retiever", text: $addPetController.breed)
            
            AddPetTextField(title: "Age", example: "1", text: $addPetController.age)
            
            AddPetTextField(title: "Birthdate", example: "December 5, 2025", text: $addPetController.birthdate)
            
            AddPetTextField(title: "Gender", example: "Male", text: $addPetController.gender)
            
            
        }
    }
}

struct SaveButton: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var addPetController: AddPetController
    
    var body: some View {
        CustomSaveButton(title: "Save") {
            addPetController.goToMedHistory(router: router)
        }
        .padding(.vertical, 70)
        .padding(.trailing, -10)
    }
}
#Preview {
    NavigationStack {
        PetInfo()
    }
    .environmentObject(AppRouter())
    .environmentObject(AddPetController())
}
