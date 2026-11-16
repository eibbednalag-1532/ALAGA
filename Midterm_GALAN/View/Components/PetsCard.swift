//
//  PetsCard.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 9/15/26.
//
import SwiftUI

struct PetsCard: View {
    let petName: String
    let breed: String
    let age: String
    let iconName: String
    var photoUrl: String? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            //Pet photo, shows the icon when there is no photo yet
            Group {
                if let photoUrl = photoUrl, let url = URL(string: photoUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Image(systemName: iconName)
                        .font(.system(size: 45))
                        .foregroundStyle(Color.gray)
                }
            }
                .frame(width: 100, height: 85)
                .background(Color.gray.opacity(0.2))
                .clipped()
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 8) {
                Text(petName)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.black)

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)

                    Text(breed)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.gray)
                }

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 10, height: 10)

                    Text(age)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.gray)
                }
            }

            Spacer()

            VStack {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .foregroundStyle(Color.gray)

                Spacer()

                Image(systemName: "info.circle")
                    .foregroundStyle(Color.blue)
            }
            .padding(.vertical, 5)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .frame(height: 110)
        .background(Color.white)
        .cornerRadius(15)
    }
}

#Preview {
    PetsCard(petName: "Niroshi", breed: "Persian", age: "4 Years Old", iconName: "cat.fill")
        .padding()
        .background(Color.gray.opacity(0.3))
}
