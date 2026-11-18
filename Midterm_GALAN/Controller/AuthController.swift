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

    //Sign in fields
    @Published var loginEmail: String = ""
    @Published var loginPassword: String = ""

    //Sign up fields
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var contactNumber: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""

    //Google sign in fields (email + 6-digit code)
    @Published var otpEmail: String = ""
    @Published var otpCode: String = ""

    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var infoMessage: String? = nil

    // MARK: Navigation
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

    // MARK: Keeps the user logged in when the app opens again
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
            loginPassword = ""
            currentScreen = .home
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

            if response.session != nil {
                //Email confirmation is off, go straight to the app
                clearSignUpFields()
                currentScreen = .home
            } else {
                //Email confirmation is on, the user has to confirm first
                loginEmail = cleanEmail
                clearSignUpFields()
                currentScreen = .signin
                infoMessage = "Account created! Check your email to confirm it, then sign in."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Send OTP
    //Sends a 6-digit code to the email, then opens the Enter OTP page
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
            otpEmail = cleanEmail
            otpCode = ""
            currentScreen = .otp
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
            try await supabase.auth.signInWithOTP(email: otpEmail)
            otpCode = ""
            infoMessage = "A new code was sent to \(otpEmail)."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Verify OTP
    //Checks the 6-digit code, then opens the app
    func verifyOTP() async {
        clearMessages()

        guard otpCode.count == 6 else {
            errorMessage = "Please enter the 6-digit code."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await supabase.auth.verifyOTP(email: otpEmail, token: otpCode, type: .email)
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

    // MARK: Helpers
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
