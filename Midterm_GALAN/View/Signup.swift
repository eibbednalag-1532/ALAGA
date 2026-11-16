//
//  Signuo.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 9/8/26.
//
import SwiftUI

struct Signup: View {
    @EnvironmentObject var authController: AuthController
    var body: some View {
        ZStack {
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
                CreateAcc()
                InfoFields()
                SignupButton()
                OrDesign()
                GoogleButton()
                SignupText()
            }
        }
        .errorAlert($authController.errorMessage)
    }
}
struct CreateAcc: View {
    var body: some View {
        VStack {
            Text("Create Account")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .offset(y: -25)
            
                .padding(.vertical,10)
            
            Text("Let's create your account")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.gray)
                .offset(y: -25)
        }
        .padding(.vertical,20)
    }
}

struct InfoFields: View {
    @EnvironmentObject var authController: AuthController
    var body: some View {
        VStack {
            TextField("First Name", text: $authController.firstName)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 300, maxHeight: 35)
                .padding(.bottom,8)
            
            TextField("Last Name", text: $authController.lastName)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 300, maxHeight: 35)
                .padding(.bottom,8)
            
            TextField("Email Address", text: $authController.email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .frame(maxWidth: 300, maxHeight: 35)
                .padding(.bottom,8)
            
            SecureField("Password", text: $authController.password)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 300, maxHeight: 35)
                .padding(.bottom,8)
            
            SecureField("Confirm Password", text: $authController.confirmPassword)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 300, maxHeight: 35)
                .padding(.bottom,8)
            
        }
    }
}
struct SignupButton: View {
    @EnvironmentObject var authController: AuthController
    var body: some View {
        Button(action: {
            Task {
                await authController.signUp()
            }
            
        }) {
            Text(authController.isLoading ? "Creating account..." : "Sign up")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 275, height: 30)
        }
        .buttonStyle(.borderedProminent)
        .tint(.green)
        .padding(.vertical,40)
        .disabled(authController.isLoading)
        
    }
}

//Goes back to the Sign In page
struct SignupText: View {
    @EnvironmentObject var authController: AuthController
    var body: some View {
        HStack {
            Text("Already have an account?")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.gray)
            
            Button(action: {
                authController.goToSignIn()
            }) {
                Text("Sign in")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.green)
            }
        }
        .offset(y: 35)
    }
}

#Preview {
    Signup()
        .environmentObject(AuthController())
}
