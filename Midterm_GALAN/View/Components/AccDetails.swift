//
//  AccDetails.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 10/22/26.
//

import SwiftUI

struct AccDetails: View {
    let detsName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            HStack {
                Text(detsName)
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .padding(.top, 20)
                    .offset(y: 18)
                    
                
                Spacer()
            }
            
            
            Rectangle()
                .frame(width: 300, height: 45, alignment: .center)
                .foregroundStyle(.white)
                .cornerRadius(10)
            
        }
        .padding(.leading, 30)
    
        
    }
    
}


