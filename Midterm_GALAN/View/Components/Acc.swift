//
//  Acc.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 9/15/26.
//

import SwiftUI


struct Acc: View {
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
                
            VStack(alignment: .center, spacing: -10){
                    
                    ProfileCrcle()
                    UserNameDisplay()
                    EmailDisplay()
                    ContactNumberDisplay()
                    
                    
                    
            }
                .padding(40)
        }
    }
}
struct ProfileCrcle : View {
    var body: some View {
            HStack {
            Image(systemName: "person.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.black)
                .padding(26)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.5))
                )
                .overlay(
                    Circle()
                        .stroke(Color(red: 71/255,
                                      green: 255/255,
                                      blue: 111/255).opacity(0.8), lineWidth: 5)
                    
                )
                
                
                Text("Profile")
                    .font(.system(size: 45, weight: .semibold, design: .rounded))
                    .padding()
        }
            .offset(y: 30)
            .padding(.vertical, 65)
        
    }
   
}

// MARK: User Name

struct UserNameDisplay: View {
    var body: some View {
        VStack {
            Text("Username")
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .offset(x: -70, y: 10)
                .padding()
            
            Rectangle()
                .frame(width: 300, height: 45, alignment: .center)
                .foregroundStyle(.white)
                .cornerRadius(10)
            
        }
    }
}

// MARK: Email Name

struct EmailDisplay: View {
    var body: some View {
        VStack {
            Text("Email")
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .offset(x: -100, y: 15)
                .padding()
            
            Rectangle()
                .frame(width: 300, height: 45, alignment: .center)
                .foregroundStyle(.white)
                .cornerRadius(10)
            
        }
    }
}

// MARK: Contact Number

struct ContactNumberDisplay: View {
    var body: some View {
        VStack {
            Text("Contact Number")
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .offset(x: -30, y: 15)
                .padding()
            
            Rectangle()
                .frame(width: 300, height: 45, alignment: .center)
                .foregroundStyle(.white)
                .cornerRadius(10)
            
        }
    }
}

#Preview {
    Acc()
}


