//
//  ErrorAlert.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import SwiftUI

// MARK: Error Alert
//Shows the controller's error message as an alert, use it like .errorAlert($controller.errorMessage)
extension View {
    func errorAlert(_ message: Binding<String?>) -> some View {
        alert(
            "Oops!",
            isPresented: Binding(
                get: { message.wrappedValue != nil },
                set: { isShowing in
                    if !isShowing {
                        message.wrappedValue = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(message.wrappedValue ?? "")
        }
    }
}
