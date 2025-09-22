//
//  AnalyticsView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/31/25.
//

import SwiftUI

struct AnalyticsView: View {
    
    var userID: Int64
    @Binding var background: String
    @Binding var accent: String
    
    
    var body: some View {
        ZStack {
            // Background color
            Color(hex: background).ignoresSafeArea()
            
            // Decorative blobs
            SameAmplitudeBlob(waves: 12, amplitude: 20, accent: accent, x: 160, y: -340, rotation: -18)
            SameAmplitudeBlob(waves: 13, amplitude: 15, accent: accent, x: 0, y: -375, rotation: 155)
            
            VStack(spacing: 0) {
                CustomText(text:"Analytics View", color: accent, width:300, textAlignment: .center, multilineAlignment: .center, textSize:75)
            }
            
            .ignoresSafeArea(edges: .bottom)
            
            // Nav bar overlay at bottom
            VStack {
                Spacer()
                NavBarView(
                    userID: userID,
                    background: $background,
                    accent: $accent
                )
                .frame(height: 60)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}


#Preview {
    AnalyticsView(userID: 1, background: .constant("#001d00"), accent: .constant("#b5c4b9"))
}
