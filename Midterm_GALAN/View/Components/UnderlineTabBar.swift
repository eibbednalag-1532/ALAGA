//
//  UnderlineTabBar.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/12/26.
//

import SwiftUI

struct UnderlineTabBar: View {
    let tabs: [String]
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                Button(action: {
                    selectedTab = index
                }) {
                    VStack(spacing: 6) {
                        Text(tabs[index])
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(selectedTab == index ? Color.green : Color.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Rectangle()
                            .frame(height: 2)
                            .foregroundStyle(selectedTab == index ? Color.green : Color.gray.opacity(0.4))
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }
}
