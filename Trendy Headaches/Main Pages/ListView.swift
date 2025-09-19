//
//  ListView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 9/19/25.
//

import SwiftUI

struct ListView: View {
    
    var userID: Int64
    @Binding var backgroundColor: String
    @Binding var accentColor: String
    
    
    var body: some View {
        ZStack {
            // Background color
            Color(hex: backgroundColor).ignoresSafeArea()
            
            // Decorative blobs
            SameAmplitudeBlob(waves: 12, amplitude: 20, accent: accentColor, x: 160, y: -340, rotation: -18)
            SameAmplitudeBlob(waves: 13, amplitude: 15, accent: accentColor, x: 0, y: -375, rotation: 155)
            
            VStack(spacing: 0) {
                CustomText(text:"List View", color: accentColor, width:300, textAlignment: .center, multilineAlignment: .center, textSize:75)
            }
            
            .ignoresSafeArea(edges: .bottom)
            
            // Nav bar overlay at bottom
            VStack {
                Spacer()
                NavBarView(
                    userID: userID,
                    backgroundColor: $backgroundColor,
                    accentColor: $accentColor
                )
                .frame(height: 60)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}


#Preview {
    ListView(userID: 1, backgroundColor: .constant("#001d00"), accentColor: .constant("#b5c4b9"))
}
