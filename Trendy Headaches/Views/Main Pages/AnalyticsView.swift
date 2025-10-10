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
    
    @State var logs: [UnifiedLog] = []
    
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
    
    
    var body: some View {
        NavigationStack{
            ZStack {
                // Background color
                Color(hex: background).ignoresSafeArea()
                
                // Decorative blobs
                SameAmplitudeBlob(waves: 12, amplitude: 20, accent: accent, x: 160, y: -340, rotation: -18)
                SameAmplitudeBlob(waves: 13, amplitude: 15, accent: accent, x: 0, y: -375, rotation: 155)
                
                VStack(spacing: 0) {
                    HStack{
                        CalendarView(logs: logs, background: background, accent: accent, width:screenWidth-120)
                            .frame(height: 350)
                            .padding(.horizontal, 10)
                        SeverityKeyBar(accent: accent, width: 20, height:screenWidth-100)
                        
                    }
                }
                
                // Nav bar overlay at bottom
                VStack {
                    Spacer()
                    NavBarView(userID: userID, background: $background,  accent: $accent)
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(10)
                .onAppear{
                    logs = DatabaseManager.shared.getLogList(userID: userID)
                }
            }
        }
    }
}


#Preview {
    AnalyticsView(userID: 1, background: .constant("#001d00"), accent: .constant("#b5c4b9"))
}
