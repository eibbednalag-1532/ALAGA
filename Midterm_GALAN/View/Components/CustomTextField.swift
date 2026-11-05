//
//  CustomTextField.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/5/26.
//

import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var iconName: String? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = iconName {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .font(.system(size: 18))
            }
            
            TextField("", text: $text, prompt:
            Text(placeholder)
                .foregroundColor(.gray.opacity(0.7))
                .font(.system(.body, design: .rounded))
            )
            .font(.system(.body, design: .rounded))
            .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}
