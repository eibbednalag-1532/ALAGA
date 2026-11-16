//
//  AppRouter.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import SwiftUI

// MARK: Navigation Controller
//Keeps track of the pages opened inside the Main Tab View so we can go back and forth
@MainActor
final class AppRouter: ObservableObject {
    @Published var path: [AppRoute] = []
    @Published var selectedTab: Int = 0

    //Opens a page
    func push(_ route: AppRoute) {
        path.append(route)
    }

    //Goes back one page
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    //Goes back to the tabs
    func popToRoot() {
        path.removeAll()
    }

    //Goes back to the tabs and opens a tab (0 Home, 1 Pets, 2 Reminder, 3 Settings)
    func goToTab(_ tab: Int) {
        popToRoot()
        selectedTab = tab
    }
}
