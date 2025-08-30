//
//  TempView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/24/25.
//

import SwiftUI
import SQLite

struct TempView: SwiftUI.View {
    let currentUserId: Int64 
    
    // Single-row values
    @State private var currentEmail: String = ""
    @State private var currentPassword: String = ""
    @State private var securityQuestion: String = ""
    @State private var securityAnswer: String = ""
    @State private var colorScheme: String = ""
    
    // Multi-row values
    @State private var triggers: [String] = []
    @State private var medications: [String] = []
    @State private var symptoms: [String] = []
    
    var body: some SwiftUI.View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Account Info")
                    .font(.title2)
                    .bold()
                
                Text("Email: \(currentEmail)")
                Text("Password: \(currentPassword)")
                Text("Security Q: \(securityQuestion)")
                Text("Security A: \(securityAnswer)")
                Text("Color: \(colorScheme)")
                
                Divider()
                
                Text("Triggers")
                    .font(.headline)
                ForEach(triggers, id: \.self) { trigger in
                    Text("• \(trigger)")
                }
                
                Text("Medications")
                    .font(.headline)
                ForEach(medications, id: \.self) { med in
                    Text("• \(med)")
                }
                
                Text("Symptoms")
                    .font(.headline)
                ForEach(symptoms, id: \.self) { sym in
                    Text("• \(sym)")
                }
            }
            .padding()
        }
        .onAppear {
            let userInfo = DatabaseManager.shared.getUserInfo(userId: currentUserId)
            currentEmail = userInfo.email
            currentPassword = userInfo.password
            securityQuestion = userInfo.securityQuestion
            securityAnswer = userInfo.securityAnswer
            colorScheme = userInfo.colorScheme

            triggers = DatabaseManager.shared.getTriggers(forUserId: currentUserId)
            medications = DatabaseManager.shared.getMedications(forUserId: currentUserId)
            symptoms = DatabaseManager.shared.getSymptoms(forUserId: currentUserId)
        }
    }
}

#Preview {
    NavigationStack {
        TempView(currentUserId: 1)
    }
}
