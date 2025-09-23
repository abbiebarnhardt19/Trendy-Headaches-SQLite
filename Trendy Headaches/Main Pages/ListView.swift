//
//  ListView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 9/19/25.
//

import SwiftUI

struct ListView: View {
    
    var userID: Int64
    @State var background: String
    @State var accent: String
    @State var logID: Int64
    
    @State private var log: DatabaseManager.Log? = nil // Correct: use DatabaseManager.Log
    
    var body: some View {
        ZStack {
            Color(hex: background).ignoresSafeArea()
            
            SameAmplitudeBlob(waves: 12, amplitude: 20, accent: accent, x: 160, y: -340, rotation: -18)
            SameAmplitudeBlob(waves: 13, amplitude: 15, accent: accent, x: 0, y: -375, rotation: 155)
            
            VStack(spacing: 0) {
                CustomText(
                    text: "List View",
                    color: accent,
                    width: 300,
                    textAlignment: .center,
                    multilineAlignment: .center,
                    textSize: 75
                )

                if let log = log {
                    CustomText(text:"Symptom Onset: \(log.symptomOnset)", color: accent, width: 300)
                    CustomText(text:"Severity: \(log.severity)", color: accent, width: 300)
                    CustomText(text:"Notes: \(log.notes)", color: accent, width: 300)
                    CustomText(text:"Log Date: \(log.date)", color: accent, width: 300)
                    CustomText(text:"Submit Date: \(log.submit)", color: accent, width: 300)
                    CustomText(text:"Triggers: \(log.triggerIDs.map { String($0) }.joined(separator: ", "))", color: accent, width: 300)
                } else {
                    Text("Loading log...")
                }
            }
            .ignoresSafeArea(edges: .bottom)
            
            VStack {
                Spacer()
                NavBarView(
                    userID: userID,
                    background: $background,
                    accent: $accent
                )
                .frame(height: 60)
                .frame(maxWidth: .infinity)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .onAppear {
            log = DatabaseManager.shared.getLog(byID: logID) // Make sure this method is inside DatabaseManager
        }
    }
}


#Preview {
    ListView(userID: 2, background: "#001d00", accent: "#b5c4b9", logID: 1)
}
