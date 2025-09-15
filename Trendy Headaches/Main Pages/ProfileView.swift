//
//  ProfileView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/31/25.
//
import SwiftUI

struct ProfileView: View {
    //passed in values
    var userID: Int64
    @Binding var backgroundColor: String
    @Binding var accentColor: String
    
    //booleans
    @State private var isEditing = false
    @State private var hasLoadedSymptoms: Bool = false
    @State private var logOut = false
    @State private var showPolicy = false
    @State private var showDeleteConfirmation = false
    
    //user data from database
    @State private var symptoms: [String] = []
    @State private var triggers: [String] = []
    @State private var prevMeds: [String] = []
    @State private var emergencyMeds: [String] = []
    @State private var securityQuestion: String = ""
    @State private var securityAnswer: String = ""
    @State private var themeName: String = ""

    //editing values
    @State private var newSymptoms: [String] = []
    @State private var newTriggers: [String] = []
    @State private var newPrevMeds: [String] = []
    @State private var newEmergencyMeds: [String] = []
    @State private var newSecurityQuestion: String = ""
    @State private var newSecurityAnswer: String = ""
    @State private var newThemeName: String = ""
    @State private var newBackground: String = ""
    @State private var newAccent: String = ""
    
    
    let theme_options = ["Classic Light", "Light Pink", "Light Yellow", "Classic Dark", "Dark Green","Dark Blue", "Dark Purple", "Custom"]
    
    let buttonNames = ["Edit Profile", "Data Policy", "Sign Out", "Delete Account"]
    
    var body: some View {
        //get screen size to get column widths
        let columnWidth = UIScreen.main.bounds.width / 2 - 10
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
                                            CustomText(text: "User Profile", color: newAccent, width: 150, textAlignment: .center, textSize: 50)
                                            
                                            CustomText(text: "Symptoms", color: newAccent, width: columnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                            
                                            EditableList(items: $newSymptoms, title: "Symptoms", backgroundColor: newBackground, accentColor: newAccent)
                                            
                                            CustomText(text: "Triggers", color: newAccent, width: columnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                            
                                            EditableList(items: $newTriggers, title: "Triggers", backgroundColor: newBackground, accentColor: newAccent)
                                            
                                            CustomText(text: "Preventative Medications", color: newAccent, width: columnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                            
                                            EditableList(items: $newPrevMeds, title: "Preventative Medications", backgroundColor: newBackground, accentColor: newAccent)
                                        }
                                        //right column
                                        VStack {
                                            CustomText(text: "Emergency Medications", color: newAccent, width: columnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                            
                                            EditableList(items: $newEmergencyMeds, title: "Emergency Medications", backgroundColor: newBackground, accentColor: newAccent)
                                            
                                            CustomText(text: "Security Question", color: newAccent, width: columnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                            
                                            CustomTextField(background: newBackground, accent: newAccent, placeholder: "", text: $newSecurityQuestion, width: columnWidth - 30, height: 55, cornerRadius: 8, textSize: 16,  isMultiline: true)

                                            CustomText(text: "Security Answer", color: newAccent, width: columnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                            
                                            CustomTextField(background: newBackground, accent: newAccent, placeholder: "", text: $newSecurityAnswer, width: columnWidth - 30, height: 34, cornerRadius: 8, textSize: 16, isSecure: true)
                                            
                                            CustomText(text: "Color Theme", color: newAccent, width: columnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                            
                                            CustomDropdown(color_theme: $newThemeName, background: $newBackground, accent: $newAccent, options: theme_options, width: columnWidth-13, height: 38, cornerRadius: 8, fontSize: 16)
                                            
                                            if newThemeName == "Custom"{
                                                CustomText(text: "Hex Codes", color: newAccent, width: columnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                                
                                                CustomTextField(background: newBackground, accent: newAccent, placeholder: "", text: $newBackground, width: columnWidth - 30, height: 38, cornerRadius: 8, textSize: 16)
                                                
                                                CustomTextField(background: newBackground, accent: newAccent, placeholder: "", text: $newAccent, width: columnWidth - 30, height: 38, cornerRadius: 8, textSize: 16)
                                            }
                                            
                                            CustomButton(text: "Save", background: newBackground, accent: newAccent) {
                                                isEditing = false
                                            }
                                        }
                                    }
                                }
                                //not editing
                                else {
                                    CustomText(text: "User Profile", color: accentColor, width: 150, textAlignment: .leading, textSize: 50)
                                        .padding(.trailing, 170)
                                        .padding(.bottom, 30)
                                    
                                    HStack(alignment: .top) {
                                        //left column
                                        VStack {
                                            VStack {
                                                CustomText(text: "Symptoms", color: accentColor, width: columnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                                if symptoms.isEmpty {
                                                    CustomList(items: ["No current symptoms or triggers entered"], color: accentColor)
                                                } else {
                                                    CustomList(items: symptoms, color: accentColor)
                                                }
                                            }
                                            
                                            VStack {
                                                CustomText(text: "Triggers", color: accentColor, width: columnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                                if triggers.isEmpty {
                                                    CustomList(items: ["No current triggers entered"], color: accentColor)
                                                } else {
                                                    CustomList(items: triggers, color: accentColor)
                                                }
                                            }
                                            
                                            VStack {
                                                CustomText(text: "Preventative Meds", color: accentColor, width: columnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
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
                                                CustomText(text: "Emergency Meds", color: accentColor, width: columnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                                if emergencyMeds.isEmpty {
                                                    CustomList(items: ["No current emergency meds entered"], color: accentColor)
                                                } else {
                                                    CustomList(items: emergencyMeds, color: accentColor)
                                                }
                                            }
                                            
                                            VStack {
                                                CustomText(text: "Security Question", color: accentColor, width: columnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                                CustomList(items: [securityQuestion], color: accentColor)
                                            }
                                            
                                            VStack {
                                                CustomText(text: "Color Theme", color: accentColor, width: columnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
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
                        
                        // dictionary mapping variable references to their database parameters
                        let fetchLists: [(tableName: String, columnName: String, filterColumn: String?, filterValue: String?, assign: ([String]) -> Void)] = [
                            ("symptoms", "symptom_name", nil, nil, { symptoms = $0 }),
                            ("triggers", "trigger_name", nil, nil, { triggers = $0 }),
                            ("medications", "medication_name", nil, nil,  { prevMeds = $0 }),
                            ("medications", "medication_name", "medication_category", "emergency", { emergencyMeds = $0 })
                        ]

                        fetchLists.forEach { param in
                            var list = DatabaseManager.shared.getForeignKeyColumnValues(
                                userId: userID,
                                tableName: param.tableName,
                                columnName: param.columnName,
                                filterColumn: param.filterColumn,
                                filterValue: param.filterValue
                            )
                            
                            list = DatabaseManager.deleteListDuplicates(list: list)
                            if list.isEmpty { list.append("None entered") }
                            
                            param.assign(list)
                        }
                        
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
                        
                        newSecurityQuestion = securityQuestion
                        
                        newAccent = accentColor
                        newBackground = backgroundColor
                }
                

    }
}

#Preview {
    ProfileView(userID: 1, backgroundColor: .constant("#001d00"), accentColor: .constant("#b5c4b9"))
}
