//
//  AddPetInfo.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

struct PetInfo: View {
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
                PetInfoGreetings()
            }
        }
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
#Preview {
    PetInfo()
}
