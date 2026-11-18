//
//  AppRouter.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import SwiftUI
import Combine

@MainActor
final class AppRouter: ObservableObject {
    @Published var path: [AppRoute] = []
    @Published var selectedTab: Int = 0

   
    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func popToRoot() {
        path.removeAll()
    }

    func goToTab(_ tab: Int) {
        popToRoot()
        selectedTab = tab
    }
}
