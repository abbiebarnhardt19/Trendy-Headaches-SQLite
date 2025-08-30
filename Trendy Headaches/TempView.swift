//
//  TempView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/24/25.
//

import SwiftUI
import SQLite

struct TempView: SwiftUI.View {
    let currentUserId: Int64   // 👈 Accept userId
    
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
            fetchUserInfo()
            fetchTriggers()
            fetchMedications()
            fetchSymptoms()
        }
    }
    
    // MARK: - User Info
    private func fetchUserInfo() {
        currentEmail = DatabaseManager.shared.getSingleColumnValue(userId: currentUserId, columnName: "email") ?? ""
        currentPassword = DatabaseManager.shared.getSingleColumnValue(userId: currentUserId, columnName: "password") ?? ""
        securityQuestion = DatabaseManager.shared.getSingleColumnValue(userId: currentUserId, columnName: "security_question") ?? ""
        securityAnswer = DatabaseManager.shared.getSingleColumnValue(userId: currentUserId, columnName: "security_answer") ?? ""
        colorScheme = DatabaseManager.shared.getSingleColumnValue(userId: currentUserId, columnName: "color_scheme") ?? ""
    }
    
    // MARK: - Triggers
    private func fetchTriggers() {
        triggers = DatabaseManager.shared.getForeignKeyColumnValues(
            userId: currentUserId,
            tableName: "triggers",
            columnName: "trigger_name"
        )
    }
    
    private func fetchMedications() {
        medications = DatabaseManager.shared.getForeignKeyColumnValues(
            userId: currentUserId,
            tableName: "medications",
            columnName: "med_name"
        )
    }
    
    private func fetchSymptoms() {
        symptoms = DatabaseManager.shared.getForeignKeyColumnValues(
            userId: currentUserId,
            tableName: "symptoms",
            columnName: "symptom_name"
        )
    }
}

#Preview {
    NavigationStack {
        TempView(currentUserId: 1)
    }
}
