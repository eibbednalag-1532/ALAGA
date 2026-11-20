//
//  ErrorAlert.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import SwiftUI

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
