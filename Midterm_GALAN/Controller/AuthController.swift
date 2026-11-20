//
//  AuthController.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import Foundation
import Supabase
import Combine

// MARK: Sign In / Sign Up Controller
@MainActor
final class AuthController: ObservableObject {
    @Published var currentScreen: AppScreen = .signin

    //MARK: Sign in fields
    @Published var loginEmail: String = ""
    @Published var loginPassword: String = ""

    //MARK: Sign up fields
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var contactNumber: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""

    //MARK: Google sign in fields
    @Published var otpEmail: String = ""
    @Published var otpCode: String = ""
    @Published var otpType: EmailOTPType = .email
    @Published var otpBackScreen: AppScreen = .googleSignIn

    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var infoMessage: String? = nil

    func goToSignUp() {
        clearMessages()
        currentScreen = .signup
    }

    func goToSignIn() {
        clearMessages()
        currentScreen = .signin
    }

    func goToGoogleSignIn() {
        clearMessages()
        otpCode = ""
        currentScreen = .googleSignIn
    }

    func goBackFromOTP() {
        clearMessages()
        otpCode = ""
        currentScreen = otpBackScreen
    }

    private func openOTP(email: String, type: EmailOTPType, backScreen: AppScreen) {
        otpEmail = email
        otpCode = ""
        otpType = type
        otpBackScreen = backScreen
        currentScreen = .otp
    }

    func restoreSession() async {
        guard SupabaseConfig.isConfigured else { return }

        if (try? await supabase.auth.session) != nil {
            currentScreen = .home
        }
    }

    // MARK: Sign In
    func signIn() async {
        clearMessages()
        let cleanEmail = loginEmail.trimmingCharacters(in: .whitespacesAndNewlines)

        guard SupabaseConfig.isConfigured else {
            errorMessage = "Supabase is not set up yet. Add your URL and anon key in SupabaseConfig.swift."
            return
        }
        guard !cleanEmail.isEmpty, !loginPassword.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await supabase.auth.signIn(email: cleanEmail, password: loginPassword)

            try? await supabase.auth.signOut()
            try await supabase.auth.signInWithOTP(email: cleanEmail, shouldCreateUser: false)
            loginPassword = ""
            openOTP(email: cleanEmail, type: .email, backScreen: .signin)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Sign Up
    func signUp() async {
        clearMessages()
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard SupabaseConfig.isConfigured else {
            errorMessage = "Supabase is not set up yet. Add your URL and anon key in SupabaseConfig.swift."
            return
        }
        guard !firstName.isEmpty, !lastName.isEmpty, !cleanEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all the fields."
            return
        }
        guard cleanEmail.contains("@") else {
            errorMessage = "Please enter a valid email address."
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await supabase.auth.signUp(
                email: cleanEmail,
                password: password,
                data: [
                    "first_name": .string(firstName),
                    "last_name": .string(lastName),
                    "contact_number": .string(contactNumber.trimmingCharacters(in: .whitespacesAndNewlines))
                ]
            )

            if response.user.identities?.isEmpty ?? false {
                try await supabase.auth.signInWithOTP(email: cleanEmail, shouldCreateUser: false)
                clearSignUpFields()
                openOTP(email: cleanEmail, type: .email, backScreen: .signup)
                infoMessage = "This email already has an account. We sent a code to sign you in."
            } else if response.session != nil {
                try? await supabase.auth.signOut()
                try await supabase.auth.signInWithOTP(email: cleanEmail, shouldCreateUser: false)
                clearSignUpFields()
                openOTP(email: cleanEmail, type: .email, backScreen: .signup)
            } else {
                clearSignUpFields()
                openOTP(email: cleanEmail, type: .signup, backScreen: .signup)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Send OTP
    
    func sendOTP() async {
        clearMessages()
        let cleanEmail = otpEmail.trimmingCharacters(in: .whitespacesAndNewlines)

        guard SupabaseConfig.isConfigured else {
            errorMessage = "Supabase is not set up yet. Add your URL and anon key in SupabaseConfig.swift."
            return
        }
        guard !cleanEmail.isEmpty else {
            errorMessage = "Please enter your email."
            return
        }
        guard cleanEmail.contains("@") else {
            errorMessage = "Please enter a valid email address."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await supabase.auth.signInWithOTP(email: cleanEmail)
            openOTP(email: cleanEmail, type: .email, backScreen: .googleSignIn)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Resend OTP
    
    func resendOTP() async {
        clearMessages()
        isLoading = true
        defer { isLoading = false }

        do {
            if otpType == .signup {
                try await supabase.auth.resend(email: otpEmail, type: .signup)
            } else {
                try await supabase.auth.signInWithOTP(email: otpEmail, shouldCreateUser: false)
            }
            otpCode = ""
            infoMessage = "A new code was sent to \(otpEmail)."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Verify OTP
  
    func verifyOTP() async {
        clearMessages()

        guard otpCode.count == 6 else {
            errorMessage = "Please enter the 6-digit code."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await supabase.auth.verifyOTP(email: otpEmail, token: otpCode, type: otpType)
            otpCode = ""
            currentScreen = .home
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Log Out
    
    func signOut() async {
        try? await supabase.auth.signOut()
        loginEmail = ""
        loginPassword = ""
        otpEmail = ""
        otpCode = ""
        clearMessages()
        currentScreen = .signin
    }

    func clearMessages() {
        errorMessage = nil
        infoMessage = nil
    }

    private func clearSignUpFields() {
        firstName = ""
        lastName = ""
        email = ""
        contactNumber = ""
        password = ""
        confirmPassword = ""
    }
}
