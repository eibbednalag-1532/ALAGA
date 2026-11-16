//
//  Midterm_GALANApp.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 9/1/26.
//

import SwiftUI

@main
struct Midterm_GALANApp: App {
    @StateObject private var authController = AuthController()
    var body: some Scene {
        WindowGroup {
            Group {
                if authController.currentScreen == .signin {
                    SignIn()
                } else if authController.currentScreen == .signup {
                    Signup()
                } else if authController.currentScreen == .home {
                    MainTabView()
                }
            }
            .animation(.easeInOut, value: authController.currentScreen)
            .environmentObject(authController)
            .task {
                await authController.restoreSession()
            }
            
        }
    }
}
