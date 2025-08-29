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
    
    // Single-row values (from Users table)
    @State private var currentEmail: String = ""
    @State private var currentPassword: String = ""
    @State private var securityQuestion: String = ""
    @State private var securityAnswer: String = ""
    @State private var colorScheme: String = ""
    
    // Multi-row values (from related tables)
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
        do {
            if let email = try DatabaseManager.shared.getSingleColumnValue(
                userId: currentUserId,
                columnName: "email"
            ) {
                currentEmail = email
            }
            if let password = try DatabaseManager.shared.getSingleColumnValue(
                userId: currentUserId,
                columnName: "password"
            ) {
                currentPassword = password
            }
            if let question = try DatabaseManager.shared.getSingleColumnValue(
                userId: currentUserId,
                columnName: "security_question"
            ) {
                securityQuestion = question
            }
            if let answer = try DatabaseManager.shared.getSingleColumnValue(
                userId: currentUserId,
                columnName: "security_answer"
            ) {
                securityAnswer = answer
            }
            
            if let color = try DatabaseManager.shared.getSingleColumnValue(
                userId: currentUserId,
                columnName: "color_scheme"
            ) {
                colorScheme = color
            }
        } catch {
            print("Error fetching user info: \(error)")
        }
    }
    
    // MARK: - Triggers
    private func fetchTriggers() {
        do {
            let triggers = try DatabaseManager.shared.getForeignKeyColumnValues(
                userId: currentUserId,
                tableName: "triggers",
                columnName: "trigger_name"
            )
            print("Triggers:", triggers)
        } catch {
            print("Error fetching triggers:", error)
        }
    }
    
    private func fetchMedications() {
        do {
            let meds = try DatabaseManager.shared.getForeignKeyColumnValues(
                userId: currentUserId,
                tableName: "medications",
                columnName: "med_name"
            )
            print("Medications:", meds)
        } catch {
            print("Error fetching medications:", error)
        }
    }
    
    private func fetchSymptoms() {
        do {
            let symptoms = try DatabaseManager.shared.getForeignKeyColumnValues(
                userId: currentUserId,
                tableName: "symptoms",
                columnName: "symptom_name"
            )
            print("Symptoms:", symptoms)
        } catch {
            print("Error fetching symptoms:", error)
        }
    }
}

