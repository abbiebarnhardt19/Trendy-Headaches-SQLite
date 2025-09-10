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
    
    let leading_padding = CGFloat(300)
    
    var body: some View {
        ZStack{
            Color(hex: backgroundColor).ignoresSafeArea()
            ScrollView {
                ZStack {
                    
                    //full width blob
                    WavyTopBottomRectangle(waves: 20, amplitude:10, accent:accentColor, x:300, y:-580, width:1000, height: 400)
                    WavyTopBottomRectangle(waves: 20, amplitude:10, accent:accentColor, x:300, y:590, width:1000, height: 400)
                    
                    VStack(spacing:17){
                        CustomWelcome(text: "User Profile", color: accentColor, textAlignment: .center, width: 350)
                            .padding(.top, 5)
                        
                        if isEditing {
                            TextField("Name", text: $name)
                                .textFieldStyle(CustomTextField(background: backgroundColor, accent: accentColor, width: 160))
                        }
                        else {
                            CustomText(text: "Symptoms/Illnesses", color: accentColor)
                                .padding(.leading, leading_padding)
                            
                            if symptoms.isEmpty {
                                CustomList(items: ["No current symptoms or triggers entered"], color: accentColor)
                            } else {
                                CustomList(items: symptoms, color: accentColor)
                            }
                            
                            CustomText(text: "Triggers", color: accentColor)
                                .padding(.leading, leading_padding)
                            
                            if triggers.isEmpty {
                                CustomList(items: ["No current triggers entered"], color: accentColor)
                            } else {
                                CustomList(items: triggers, color: accentColor)
                            }
                            
                            CustomText(text: "Preventative Meds", color: accentColor)
                                .padding(.leading, leading_padding)
                            
                            if prevMeds.isEmpty {
                                CustomList(items: ["No current preventative meds entered"], color: accentColor)
                            } else {
                                CustomList(items: prevMeds, color: accentColor)
                            }
                            
                            CustomText(text: "Emergency Meds", color: accentColor)
                                .padding(.leading, leading_padding)
                            
                            if emergencyMeds.isEmpty {
                                CustomList(items: ["No current emergency meds entered"], color: accentColor)
                            } else {
                                CustomList(items: emergencyMeds, color: accentColor)
                            }
                            
                            CustomText(text: "Security Question", color: accentColor)
                                .padding(.leading, leading_padding)
                            CustomList(items: [securityQuestion], color: accentColor)
                            
                            CustomText(text: "Theme", color: accentColor)
                                .padding(.leading, leading_padding)
                            CustomList(items: [themeName], color: accentColor)
                            
                            if themeName == "Custom"{
                                CustomList(items: [backgroundColor, accentColor], color: accentColor)
                                    .padding(.leading, leading_padding+40)
                            }
                        }
                        
                        CustomButton(
                            text: isEditing ? "Save" : "Edit",
                            background: backgroundColor,
                            accent: accentColor
                        ) {
                            isEditing.toggle()
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
            }
        }
    }
}

#Preview {
    ProfileView(userID: 0, backgroundColor: "#001d00", accentColor: "#b5c4b9")
}
