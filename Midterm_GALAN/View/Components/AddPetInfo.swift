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
        }
    }
}

struct PetInfoGreetings: View {
    var body: some View {
        VStack {
            Text("Pet Information")
                .font(.system(size: 35, weight: .semibold, design: .rounded))
        }
    }
}
#Preview {
    PetInfo()
}
