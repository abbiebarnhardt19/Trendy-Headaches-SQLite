//
//  ListView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 9/19/25.
//

import SwiftUI

struct ListView: View {
    
    var userID: Int64
    @Binding var background: String // ✅ use Binding instead of State
    @Binding var accent: String
    @State var logID: Int64
    
    @State private var log: DatabaseManager.Log? = nil
    
    var body: some View {
        NavigationStack { // ✅ wrap in NavigationStack for consistent navigation
            ZStack {
                Color(hex: background).ignoresSafeArea()
                
                    SameAmplitudeBlob(waves: 12, amplitude: 20, accent: accent, x: 160, y: -340, rotation: -18)
                    SameAmplitudeBlob(waves: 13, amplitude: 15, accent: accent, x: 0, y: -375, rotation: 155)
                    
                    VStack(spacing: 10) {
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
                            CustomText(text:"EmergencyMedTaken: \(log.medTaken)", color: accent, width: 300)
                            CustomText(text:"EmergencyMedTakenID: \(log.medTakenID)", color: accent, width: 300)
                            CustomText(text:"EmergencyMedWorked: \(log.medWorked)", color: accent, width: 300)
                        } else {
                            Text("Loading log...")
                                .foregroundColor(Color(hex: accent))
                    }
                
                }
                
                // ✅ Nav bar overlay at bottom, just like ProfileView
                VStack {
                    Spacer()
                    NavBarView(
                        userID: userID,
                        background: $background,
                        accent: $accent
                    )
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(1) // ✅ force it on top
            }
            .onAppear {
                log = DatabaseManager.shared.getLog(byID: logID)
            }
        }
    }
}

#Preview {
    ListView(userID: 2, background: .constant("#001d00"), accent: .constant("#b5c4b9"), logID: 1)
}

