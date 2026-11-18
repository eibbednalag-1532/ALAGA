//
//  MainTabView.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 9/11/26.
//
import SwiftUI

struct MainTabView: View {
    @StateObject private var router = AppRouter()
    @StateObject private var homeController = HomeController()
    @StateObject private var petController = PetController()
    @StateObject private var addPetController = AddPetController()
    @StateObject private var reminderController = ReminderController()
    @StateObject private var profileController = ProfileController()
    @StateObject private var documentationController = DocumentationController()
    
    var body: some View {
        
        NavigationStack(path: $router.path) {
            TabView(selection: $router.selectedTab) {
                
                HomeTab()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                
                PetTab()
                    .tabItem {
                        Label("Pets", systemImage: "pawprint.fill")
                    }
                    .tag(1)
                
                ReminderTab()
                    .tabItem {
                        Label("Reminder", systemImage: "bell.fill")
                    }
                    .tag(2)
                
                SettingsTab()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(3)
            }
            .tint(Color.green)
            .navigationBarBackButtonHidden(true)
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .petDetails(let pet):
                    PetDetails(pet: pet)
                case .addPetInfo:
                    PetInfo()
                case .addMedHistory:
                    AddMedHistory()
                case .addActiveMed:
                    AddActiveMed()
                case .addEvent:
                    AddEvent()
                case .clinics:
                    ClinicsInfo()
                case .faq:
                    FAQ()
                case .profile:
                    Profile()
                case .account:
                    Acc()
                }
            }
        }
        .environmentObject(router)
        .environmentObject(homeController)
        .environmentObject(petController)
        .environmentObject(addPetController)
        .environmentObject(reminderController)
        .environmentObject(profileController)
        .environmentObject(documentationController)
        .task {
            await petController.fetchPets()
            await reminderController.fetchReminders()
            await profileController.fetchProfile()
        }
    }
}


#Preview {
    MainTabView()
        .environmentObject(AuthController())
}
