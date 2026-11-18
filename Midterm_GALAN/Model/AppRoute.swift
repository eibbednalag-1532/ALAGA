//
//  AppRoute.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import Foundation

// MARK: Screens before signing in
nonisolated enum AppScreen {
    case signin
    case signup
    case googleSignIn
    case otp
    case home
}

// MARK: Pages that can be pushed inside the Main Tab View
//Every page you can go to (and come back from) is listed here
nonisolated enum AppRoute: Hashable {
    case petDetails(Pet)
    case addPetInfo
    case addMedHistory
    case addActiveMed
    case addEvent
    case clinics
    case faq
    case profile
    case account
}
