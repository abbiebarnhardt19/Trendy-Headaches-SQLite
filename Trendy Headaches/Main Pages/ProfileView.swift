//
//  ProfileView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/31/25.
//
import SwiftUI

struct ProfileView: View {
    
    var userID: Int64
    var backgroundColor: String
    var accentColor: String
    
    @State private var name: String = "Abbie"
    @State private var isEditing = false
    @State private var symptoms: [String] = []
    @State private var hasLoadedSymptoms: Bool = false
    @State private var triggers: [String] = []
    @State private var prevMeds: [String] = []
    @State private var emergencyMeds: [String] = []
    
    @State private var securityQuestion: String = ""
    @State private var securityAnswer: String = ""
    @State private var themeName: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Color(hex: backgroundColor).ignoresSafeArea()
                
                if isEditing {
                    TextField("Name", text: $name)
                        .textFieldStyle(CustomTextField(background: backgroundColor, accent: accentColor, width: 160))
                }
                else {
                    CustomText(text: "Symptoms/Illnesses", color: accentColor)
                    if symptoms.isEmpty {
                        CustomList(items: ["No current symptoms or triggers entered"], color: accentColor)
                    } else {
                        CustomList(items: symptoms, color: accentColor)
                    }
                    
                    CustomText(text: "Triggers", color: accentColor)
                    
                    if triggers.isEmpty {
                        CustomList(items: ["No current triggers entered"], color: accentColor)
                    } else {
                        CustomList(items: triggers, color: accentColor)
                    }
                    
                    CustomText(text: "Preventative Meds", color: accentColor)
                    
                    if prevMeds.isEmpty {
                        CustomList(items: ["No current preventative meds entered"], color: accentColor)
                    } else {
                        CustomList(items: prevMeds, color: accentColor)
                    }
                    
                    CustomText(text: "Emergency Meds", color: accentColor)

                    if emergencyMeds.isEmpty {
                        CustomList(items: ["No current emergency meds entered"], color: accentColor)
                    } else {
                        CustomList(items: emergencyMeds, color: accentColor)
                    }
                    
                    CustomText(text: "Security Question", color: accentColor)
                    CustomList(items: [securityQuestion], color: accentColor)
                    
                    CustomText(text: "Theme", color: accentColor)
                    CustomList(items: [themeName], color: accentColor)
                    
                    if themeName == "Custom"{
                        CustomList(items: [backgroundColor, accentColor], color: accentColor)
                            .padding(.leading, 15)
                    }
                    
                }
                
                CustomButton(
                    text: isEditing ? "Save" : "Edit",
                    background: accentColor,
                    accent: backgroundColor
                ) {
                    isEditing.toggle()
                    // Optionally save the updated name to database here
                }
                
            }
            .onAppear {
                // Only load once to avoid duplicates
                guard !hasLoadedSymptoms else { return }
                hasLoadedSymptoms = true
                
                // Fetch symptoms from database
                symptoms = DatabaseManager.shared.getForeignKeyColumnValues(userId: userID, tableName: "symptoms", columnName: "symptom_name")
                symptoms = DatabaseManager.deleteListDuplicates(list: symptoms)
                
                triggers = DatabaseManager.shared.getForeignKeyColumnValues(userId: userID, tableName: "triggers", columnName: "trigger_name")
                triggers = DatabaseManager.deleteListDuplicates(list: triggers)
                
                prevMeds = DatabaseManager.shared.getMeds(forUserId: userID, medCategory: "preventative")
                prevMeds = DatabaseManager.deleteListDuplicates(list: prevMeds)
                
                emergencyMeds = DatabaseManager.shared.getMeds(forUserId: userID, medCategory: "emergency")
                emergencyMeds = DatabaseManager.deleteListDuplicates(list: emergencyMeds)
                securityQuestion = DatabaseManager.shared.getSingleColumnValue(userId: userID, columnName: "security_question") ?? "No security question set"
                
                themeName = DatabaseManager.getThemeName(selected_background: backgroundColor, selected_accent: accentColor)
            }
        }
        .padding()
        
    }
}

#Preview {
    ProfileView(userID: 0, backgroundColor: "#001d00", accentColor: "#b5c4b9")
}
