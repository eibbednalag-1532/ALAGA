//
//  CustomSaveButton.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/5/26.
//

import SwiftUI

struct CustomSaveButton: View {
    let title: String
    var backgroundColor: Color = .green.opacity(0.7)
    var foregroundColor: Color = .white
    let action: () -> Void
    
    var body: some View {
        Button(action:action) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(foregroundColor)
                .frame(width: 250)
                .frame(height: 50)
                .background(backgroundColor)
                .cornerRadius(12)
                .shadow(color: backgroundColor.opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }
}


