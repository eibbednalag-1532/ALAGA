//
//  GoogleSignIn.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/18/26.
//
import SwiftUI

struct GoogleSignIn: View {
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
                AuthBackButton {
                    authController.goToSignIn()
                }

                Spacer()

                VStack(alignment: .leading, spacing: 0) {
                    SmallLogo()
                    GoogleSignInHeader()
                    GoogleEmailField()
                    GoogleSignInFooter()
                }
                .authCard()

                Spacer()
                Spacer()
            }
            .padding()
        }
        .errorAlert($authController.errorMessage)
    }
}

struct SmallLogo: View {
    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 22))
                .foregroundStyle(LinearGradient (colors:
                                                    [Color(red: 144/255,
                                                           green: 213/255,
                                                            blue: 255/255),
                                                     .blue],
                                                 startPoint: .top,
                                                 endPoint: .bottom))

            Text("Alaga")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(LinearGradient(colors:
                                                    [Color(red: 24/255, green: 104/255, blue: 174/255),
                                                     Color(red: 45/255, green: 160/255, blue: 140/255)],
                                                startPoint: .leading,
                                                endPoint: .trailing))
        }
        .padding(.bottom, 20)
    }
}

struct GoogleSignInHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sign in")
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(Color.black)

            Text("to continue to ALAGA")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color.black)
        }
        .padding(.bottom, 20)
    }
}

struct GoogleEmailField: View {
    @EnvironmentObject var authController: AuthController
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Email or phone", text: $authController.otpEmail)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundStyle(Color.black)
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                )
                .padding(.bottom, 14)

            Button(action: {

            }) {
                Text("Forgot email?")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.black)
            }
            .padding(.bottom, 30)

            Text("Not your computer? Use Guest mode to sign in privately. Learn more")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.black)
                .lineSpacing(4)
                .padding(.bottom, 30)
        }
    }
}

struct GoogleSignInFooter: View {
    @EnvironmentObject var authController: AuthController
    var body: some View {
        HStack {
            Button(action: {
                authController.goToSignUp()
            }) {
                Text("Create account")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.black)
            }

            Spacer()

            AuthBlueButton(title: authController.isLoading ? "Sending..." : "Next") {
                Task {
                    await authController.sendOTP()
                }
            }
            .disabled(authController.isLoading)
        }
    }
}

struct AuthBlueButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .frame(height: 44)
                .background(
                    Capsule()
                        .fill(Color(red: 11/255, green: 87/255, blue: 208/255))
                )
        }
    }
}

struct AuthBackButton: View {
    let action: () -> Void

    var body: some View {
        HStack {
            Button(action: action) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.black)
                    .padding(10)
            }
            Spacer()
        }
    }
}

extension View {
    func authCard() -> some View {
        self
            .padding(28)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white.opacity(0.3))
                    .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
            )
            .padding(.horizontal, 8)
    }
}

#Preview {
    GoogleSignIn()
        .environmentObject(AuthController())
}
