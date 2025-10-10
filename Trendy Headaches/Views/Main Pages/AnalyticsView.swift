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
    
    // List of icons to cycle through
    let availableIcons = [
        "circle.fill", "square.fill", "triangle.fill", "star.fill", "diamond.fill",
        "hexagon.fill", "heart.fill", "bolt.fill", "leaf.fill", "flame.fill"
    ]
    let unknownIcon = "questionmark.square.fill"

    // Keep a mapping from symptom name -> icon
    @State private var symptomToIcon: [String: String] = [:]

    func icon(for symptom: String?) -> String {
        guard let name = symptom, !name.isEmpty else {
            return unknownIcon
        }

        if let assignedIcon = symptomToIcon[name] {
            return assignedIcon
        } else {
            // Assign next available icon in a cycle
            let nextIcon = availableIcons[symptomToIcon.count % availableIcons.count]
            symptomToIcon[name] = nextIcon
            return nextIcon
        }
    }
    
    
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
                        CalendarView(logs: logs, background: background, accent: accent, width:screenWidth-120, symptomToIcon: symptomToIcon)
                            .frame(height: 350)
                            .padding(.horizontal, 10)
                        SeverityKeyBar(accent: accent, width: 20, height:screenWidth-100)
                        
                    }
                    SymptomKey(symptomToIcon: symptomToIcon, accent: accent, width: screenWidth-20)
                        .padding()

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
                    var mapping: [String: String] = [:]
                    for (index, symptom) in Set(logs.compactMap { $0.symptom_name }).sorted().enumerated() {
                        mapping[symptom] = availableIcons[index % availableIcons.count]
                    }
                    symptomToIcon = mapping
                }
            }
        }
    }
}


#Preview {
    AnalyticsView(userID: 1, background: .constant("#001d00"), accent: .constant("#b5c4b9"))
}
