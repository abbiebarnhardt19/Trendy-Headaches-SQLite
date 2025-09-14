//
//  ProfileView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/31/25.
//
import SwiftUI

struct ProfileView: View {
    
    var userID: Int64
    @Binding var backgroundColor: String
    @Binding var accentColor: String
    
    @State private var name: String = "Abbie"
    @State private var isEditing = true
    @State private var symptoms: [String] = []
    @State private var hasLoadedSymptoms: Bool = false
    @State private var triggers: [String] = []
    @State private var prevMeds: [String] = []
    @State private var emergencyMeds: [String] = []
    
    @State private var securityQuestion: String = ""
    @State private var securityAnswer: String = ""
    @State private var themeName: String = ""
    @State private var logOut = false
    @State private var showPolicy = false
    @State private var showDeleteConfirmation = false
    
    @State private var newSymptoms: [String] = []
    @State private var newTriggers: [String] = []
    @State private var newPrevMeds: [String] = []
    @State private var newEmergencyMeds: [String] = []
    @State private var newSecurityQuestion: String = ""
    @State private var newSecurityAnswer: String = ""
    @State private var newThemeName: String = ""
    @State private var newBackground: String = ""
    @State private var newAccent: String = ""
    
    @State private var tempSecurityQuestion: String = ""
    
    
    let options = ["Classic Light", "Light Pink", "Light Yellow", "Classic Dark", "Dark Green","Dark Blue", "Dark Purple", "Custom"]
    
    let buttonNames = ["Edit Profile", "Data Policy", "Sign Out", "Delete Account"]
    
    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let columnWidth = screenWidth / 2 - 10
                    ZStack {
                        Color(hex: newBackground).ignoresSafeArea()
                        
                        // Decorative blobs
                        SameAmplitudeBlob(waves: 12, amplitude: 20, accent: accentColor, x: 160, y: -270, rotation: -10)
                            .zIndex(isEditing ? 1 : 0)
                        SameAmplitudeBlob(waves: 12, amplitude: 20, accent: accentColor, x: 100, y: -270, rotation: 170)
                            .zIndex(isEditing ? 1 : 0)
                        
                        ScrollView {
                            VStack {
                                if isEditing {
                                    HStack(alignment: .top) {
                                        // Left column
                                        VStack {
                                            CustomWelcome(text: "User Profile", color: accentColor, textAlignment: .leading, width: 150)
                                            
                                            EditableList(items: $newSymptoms, title: "Symptoms", backgroundColor: newBackground, accentColor: newAccent)
                                            
                                            EditableList(items: $newTriggers, title: "Triggers", backgroundColor: newBackground, accentColor: newAccent)
                                            
                                            EditableList(items: $newPrevMeds, title: "Preventative Medications", backgroundColor: newBackground, accentColor: newAccent)
                                        }
                                        VStack {
                                            EditableList(items: $newEmergencyMeds, title: "Emergency Medications", backgroundColor: newBackground, accentColor: newAccent)
                                            
                                            CustomListHeader(text: "Security Question", color: accentColor)
                                            
                                            TextField("", text: $newSecurityQuestion, axis: .vertical)
                                                .lineLimit(1...2)
                                                .frame(width: columnWidth - 30)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal,10)
                                                .background(Color(hex: newAccent))
                                                .foregroundColor(Color(hex: newAccent))
                                                .cornerRadius(8)
                                                .font(.system(size: 16, design: .serif))
                                            .padding(.bottom, 10)
                                            
                                            CustomListHeader(text: "Security Answer", color: accentColor)
                                            
                                            
                                            TextField("", text: $newSecurityAnswer)
                                                .frame(width: columnWidth - 30)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal,10)
                                                .background(Color(hex: accentColor))
                                                .foregroundColor(Color(hex: backgroundColor))
                                                .cornerRadius(8)
                                                .font(.system(size: 16, design: .serif))
                                            .padding(.bottom, 10)
                                            
                                            CustomListHeader(text: "Color Theme", color: accentColor)
                                            
                                            CustomDropdown(color_theme: $newThemeName, background: $backgroundColor, accent: $accentColor, options: options, width: columnWidth-13, height: 38, cornerRadius: 8, fontSize: 16)
                                            
                                            if newThemeName == "Custom"{
                                                //custom instructions
                                                CustomListHeader(text: "Hex Codes", color: accentColor)
                                                
                                                TextField("", text: $newBackground)
                                                    .frame(width: columnWidth - 30)
                                                    .padding(.vertical, 8)
                                                    .padding(.horizontal,10)
                                                    .background(Color(hex: accentColor))
                                                    .foregroundColor(Color(hex: backgroundColor))
                                                    .cornerRadius(8)
                                                    .font(.system(size: 16, design: .serif))
                                                .padding(.bottom, 10)
                                                    
                                                TextField("", text: $newAccent)
                                                    .frame(width: columnWidth - 30)
                                                    .padding(.vertical, 8)
                                                    .padding(.horizontal,10)
                                                    .background(Color(hex: accentColor))
                                                    .foregroundColor(Color(hex: backgroundColor))
                                                    .cornerRadius(8)
                                                    .font(.system(size: 16, design: .serif))
                                                .padding(.bottom, 10)
                                            }
                                            
                                            CustomButton(text: "Save", background: backgroundColor, accent: accentColor) {
                                                isEditing = false
                                            }
                                        }
                                    }
                                } else {
                                    CustomWelcome(text: "User Profile", color: accentColor, textAlignment: .leading, width: 150)
                                        .padding(.trailing, 170)
                                        .padding(.bottom, 30)

                                    
                                    HStack(alignment: .top) {
                                        
                                        VStack {
                                            
                                            
                                            VStack {
                                                CustomListHeader(text: "Symptoms", color: accentColor)
                                                if symptoms.isEmpty {
                                                    CustomList(items: ["No current symptoms or triggers entered"], color: accentColor)
                                                } else {
                                                    CustomList(items: symptoms, color: accentColor)
                                                }
                                            }
                                            
                                            VStack {
                                                CustomListHeader(text: "Triggers", color: accentColor)
                                                if triggers.isEmpty {
                                                    CustomList(items: ["No current triggers entered"], color: accentColor)
                                                } else {
                                                    CustomList(items: triggers, color: accentColor)
                                                }
                                            }
                                            
                                            VStack {
                                                CustomListHeader(text: "Preventative Meds", color: accentColor)
                                                if prevMeds.isEmpty {
                                                    CustomList(items: ["No current preventative meds entered"], color: accentColor)
                                                } else {
                                                    CustomList(items: prevMeds, color: accentColor)
                                                }
                                            }
                                        }
                                        .frame(maxWidth: columnWidth)
                                        
                                        // Right column
                                        VStack(alignment: .center) {
                                            VStack {
                                                CustomListHeader(text: "Emergency Meds", color: accentColor)
                                                if emergencyMeds.isEmpty {
                                                    CustomList(items: ["No current emergency meds entered"], color: accentColor)
                                                } else {
                                                    CustomList(items: emergencyMeds, color: accentColor)
                                                }
                                            }
                                            
                                            VStack {
                                                CustomListHeader(text: "Security Question", color: accentColor)
                                                CustomList(items: [securityQuestion], color: accentColor)
                                            }
                                            
                                            VStack {
                                                CustomListHeader(text: "Theme", color: accentColor)
                                                CustomList(items: [themeName], color: accentColor)
                                            }
                                            
                                            // Floating button
                                            CustomFloatButton(
                                                accent: accentColor,
                                                background: backgroundColor,
                                                options: buttonNames,
                                                actions: [
                                                    { isEditing = true },
                                                    { showPolicy = true },
                                                    { logOut = true },
                                                    {showDeleteConfirmation = true}
                                                ]
                                            )
                                            .fullScreenCover(isPresented: $showPolicy) {
                                                PolicySheetView(
                                                    policyFileName: "DataPolicy",
                                                    showsAgreeButton: false
                                                )
                                            }

                                        }
                                        .frame(maxWidth: columnWidth, alignment: .center)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    .alert("Are you sure you want to delete your account?", isPresented: $showDeleteConfirmation) {
                        Button("Delete", role: .destructive) {
                            DatabaseManager.shared.deleteUser(userID: userID)
                            logOut = true
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                    .fullScreenCover(isPresented: $logOut) {
                        LoginView()
                    }
                    .onAppear {
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
                        
                        securityAnswer = DatabaseManager.shared.getSingleColumnValue(userId: userID, columnName: "security_answer") ?? "No security answer set"
                        
                        themeName = DatabaseManager.getThemeName(selected_background: backgroundColor, selected_accent: accentColor)
                        
                        if themeName.contains("Custom")
                        {
                            newThemeName = "Custom"
                        }
                        else{
                            newThemeName = themeName
                        }
            
                        
                        newSymptoms = symptoms
                        newTriggers = triggers
                        newPrevMeds = prevMeds
                        newEmergencyMeds = emergencyMeds
                        
                        tempSecurityQuestion = securityQuestion
                        newSecurityQuestion = securityQuestion
                        
                        newAccent = accentColor
                        newBackground = backgroundColor
                }
                

    }
}

#Preview {
    ProfileView(userID: 10, backgroundColor: .constant("#001d00"), accentColor: .constant("#b5c4b9"))
}
