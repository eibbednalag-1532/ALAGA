//
//  EnterOTP.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/18/26.
//
import SwiftUI

struct EnterOTP: View {
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
                //Goes back to the Google Sign In page to change the email
                AuthBackButton {
                    authController.goToGoogleSignIn()
                }

                Spacer()

                VStack(alignment: .leading, spacing: 0) {
                    SmallLogo()
                    OTPHeader()
                    OTPBoxes()
                    OTPFooter()
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

struct OTPHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Enter OTP")
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(Color.black)

            Text("We've sent a 6-digit code to your email address. Please enter it below to verify your account.")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color.black)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 24)
    }
}

// MARK: 6 code boxes
//One hidden text field holds the code, the boxes just show each number
struct OTPBoxes: View {
    @EnvironmentObject var authController: AuthController
    @FocusState private var isTyping: Bool

    var body: some View {
        ZStack {
            TextField("", text: $authController.otpCode)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isTyping)
                .opacity(0.01)

            HStack(spacing: 8) {
                ForEach(0..<6, id: \.self) { index in
                    Text(digit(at: index))
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isCurrentBox(index) ? Color.blue : Color.gray.opacity(0.6), lineWidth: 1)
                        )
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isTyping = true
            }
        }
        .padding(.bottom, 20)
        //Numbers only, 6 digits max
        .onChange(of: authController.otpCode) {
            let cleanCode = String(authController.otpCode.filter { $0.isNumber }.prefix(6))
            if cleanCode != authController.otpCode {
                authController.otpCode = cleanCode
            }
        }
        .onAppear {
            isTyping = true
        }
    }

    private func digit(at index: Int) -> String {
        let code = Array(authController.otpCode)
        return index < code.count ? String(code[index]) : ""
    }

    private func isCurrentBox(_ index: Int) -> Bool {
        isTyping && index == min(authController.otpCode.count, 5)
    }
}

struct OTPFooter: View {
    @EnvironmentObject var authController: AuthController
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                Task {
                    await authController.resendOTP()
                }
            }) {
                Text("Resend code")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.black)
            }
            .disabled(authController.isLoading)
            .padding(.bottom, 8)

            //Shows "A new code was sent to ..." after resending
            if let info = authController.infoMessage {
                Text(info)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.green)
            }

            HStack {
                Spacer()

                //Checks the code then opens the app
                AuthBlueButton(title: authController.isLoading ? "Verifying..." : "Verify") {
                    Task {
                        await authController.verifyOTP()
                    }
                }
                .disabled(authController.isLoading)
            }
            .padding(.top, 22)
        }
    }
}

#Preview {
    EnterOTP()
        .environmentObject(AuthController())
}
