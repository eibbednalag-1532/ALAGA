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
        VStack {
            Text(detsName)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .offset(x: -30, y: 15)
                .padding()
            
            Rectangle()
                .frame(width: 300, height: 45, alignment: .center)
                .foregroundStyle(.white)
                .cornerRadius(10)
            
        }
        
    }
    
}


