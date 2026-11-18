//
//  PetController.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import Foundation
import Supabase
import Combine

// MARK: Pet List Controller

@MainActor
final class PetController: ObservableObject {
    @Published var pets: [Pet] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    func fetchPets() async {
        isLoading = true
        defer { isLoading = false }

        do {
            pets = try await supabase
                .from("pets")
                .select()
                .order("created_at", ascending: true)
                .execute()
                .value
        } catch {
            print("Could not load pets: \(error.localizedDescription)")
        }
    }

    func addPet(_ pet: Pet) async throws -> Pet {
        let savedPet: Pet = try await supabase
            .from("pets")
            .insert(pet)
            .select()
            .single()
            .execute()
            .value

        pets.append(savedPet)
        return savedPet
    }

    func updatePet(_ pet: Pet) async -> Bool {
        guard let id = pet.id else { return false }

        do {
            try await supabase
                .from("pets")
                .update(pet)
                .eq("id", value: id.uuidString)
                .execute()

            if let index = pets.firstIndex(where: { $0.id == id }) {
                pets[index] = pet
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deletePet(_ pet: Pet) async -> Bool {
        guard let id = pet.id else { return false }

        do {
            try await supabase
                .from("pets")
                .delete()
                .eq("id", value: id.uuidString)
                .execute()

            pets.removeAll { $0.id == id }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func iconName(for breed: String) -> String {
        let text = breed.lowercased()
        let catWords = ["cat", "persian", "siamese", "puspin", "maine", "ragdoll", "bengal", "sphynx"]
        let birdWords = ["bird", "parrot", "lovebird", "cockatiel", "parakeet", "budgie", "finch"]
        let fishWords = ["fish", "goldfish", "betta", "koi", "guppy"]

        if catWords.contains(where: { text.contains($0) }) {
            return "cat.fill"
        } else if birdWords.contains(where: { text.contains($0) }) {
            return "bird.fill"
        } else if fishWords.contains(where: { text.contains($0) }) {
            return "fish.fill"
        } else if text.contains("rabbit") || text.contains("bunny") {
            return "hare.fill"
        } else {
            return "dog.fill"
        }
    }
}
