//
//  ProfileController.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import Foundation
import Supabase
import Combine

// MARK: Profile / Account Controller
@MainActor
final class ProfileController: ObservableObject {
    @Published var profile: UserProfile? = nil
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var contactNumber: String = ""

    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    var firstName: String {
        profile?.firstName ?? ""
    }

    var displayUsername: String {
        let name = (profile?.username ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let fullName = "\(profile?.firstName ?? "") \(profile?.lastName ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)

        if !name.isEmpty {
            return name
        } else if !fullName.isEmpty {
            return fullName
        } else {
            return "N/A"
        }
    }

    var displayEmail: String {
        let text = profile?.email ?? ""
        return text.isEmpty ? "N/A" : text
    }

    var displayContactNumber: String {
        let text = profile?.contactNumber ?? ""
        return text.isEmpty ? "N/A" : text
    }

    func fetchProfile() async {
        do {
            let user = try await supabase.auth.session.user

            let profiles: [UserProfile] = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: user.id.uuidString)
                .execute()
                .value

            profile = profiles.first ?? UserProfile(id: user.id, email: user.email)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Navigation
  
    func startEditing(router: AppRouter) {
        username = displayUsername == "N/A" ? "" : displayUsername
        email = profile?.email ?? ""
        contactNumber = profile?.contactNumber ?? ""
        router.push(.account)
    }

    func saveProfile(router: AppRouter) async {
        guard var updatedProfile = profile else { return }

        updatedProfile.username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedProfile.contactNumber = contactNumber.trimmingCharacters(in: .whitespacesAndNewlines)

        isLoading = true
        defer { isLoading = false }

        do {
            try await supabase
                .from("profiles")
                .upsert(updatedProfile)
                .execute()

            profile = updatedProfile
            router.pop()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
