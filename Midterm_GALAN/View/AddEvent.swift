//
//  AddEvent.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

struct AddEvent: View {
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
                EventHeader()
                EventDetails()
            }
            
            
        }
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
    var body: some View {
        VStack {
            AddPetTextField(title: "Event Type", example: "e.g Check-Up")
            
            AddPetTextField(title: "Pet", example: "e.g Buddy")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 35)
        .padding(.vertical, -45)
    }
}
struct AddDateTime: View {
    var body: some View {
        
    }
}


#Preview {
    AddEvent()
}
