//
//  AddPetTextField.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/5/26.
//

import SwiftUI

struct AddPetTextField: View {
    var title: String
    var example : String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 22, weight: .regular))
                .foregroundColor(.primary)
            
            CustomTextField(
                placeholder: example,
                text: .constant(""),
                isReadOnly: true
            )
            .frame(width: 300)
            
        }
        
    }
}
