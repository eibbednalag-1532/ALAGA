//
//  FAQ.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

struct FAQ: View {
    @Environment(\.dismiss) private var dismiss

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

            VStack(spacing: 10) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.black)
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.6))
                            )
                    }

                    Spacer()
                }
                .padding(.horizontal)

                FAQHeader()

                Color.clear.frame(height: 30)

                ScrollView {
                    VStack(spacing: 12) {
                        FAQRow(
                            question: "Why is Alaga created?",
                            answer: "Alaga is created to help pet parents keep track of their pets' health, medical history, medications and upcoming events in one place."
                        )

                        FAQRow(
                            question: "How to add a pet?",
                            answer: "Go to the Pets tab and press the green + button, then choose Add Pet and fill in your pet's information, medical history and active medication."
                        )

                        FAQRow(
                            question: "What is the purpose of near vet clinic?",
                            answer: "Near Vet Clinics shows the veterinary clinics close to you, their schedule and services, so you can quickly find help for your pet."
                        )

                        FAQRow(
                            question: "How to delete an event?",
                            answer: "Go to the Reminder tab, slide the event card to the left and tap the trash can. Press Delete to confirm, and the event is also removed from the Home tab."
                        )

                        FAQRow(
                            question: "How to edit an event?",
                            answer: "Go to the Reminder tab and tap the event card. Change the event type or pet, then press Save."
                        )

                        FAQRow(
                            question: "How to add a pet photo?",
                            answer: "Open your pet from the Pets tab and tap the camera icon near the profile picture. Choose Take a Photo or Pick Photo in Gallery, move and resize the photo inside the circle, then press Save."
                        )

                        FAQRow(
                            question: "How to see the pet's details?",
                            answer: "Go to the Pets tab and tap a pet card. The Overview shows the pet information and active medication, Medical History shows the health records, and Gallery shows the documented photos."
                        )
                    }
                    .padding(.horizontal, 25)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
struct FAQHeader: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 45))

                Text("FAQ")
                    .font(.system(size: 50, weight: .bold, design: .rounded))
            }

            Text("Find Answer To Commonly\nAsked Question")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.gray)
                .multilineTextAlignment(.center)
        }
    }
}
struct FAQRow: View {
    let question: String
    let answer: String
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(question)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color.black)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .foregroundStyle(Color.gray)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
            }

            if isExpanded {
                Text(answer)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(15)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isExpanded ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    NavigationStack {
        FAQ()
    }
}
