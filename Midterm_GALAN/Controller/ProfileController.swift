//
//  ProfileController.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import Foundation
import Supabase

// MARK: Profile / Account Controller
@MainActor
final class ProfileController: ObservableObject {
    @Published var profile: UserProfile? = nil

    //Account (edit) page fields
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var contactNumber: String = ""

    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    var firstName: String {
        profile?.firstName ?? ""
    }

    var displayUsername: String {
        let name = profile?.username ?? ""
        return name.isEmpty ? "N/A" : name
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

            //If the profile row is missing, make one from the logged in user
            profile = profiles.first ?? UserProfile(id: user.id, email: user.email)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Navigation
    //Profile > Account (edit page)
    func startEditing(router: AppRouter) {
        username = profile?.username ?? ""
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
            //Back to the Profile page
            router.pop()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
