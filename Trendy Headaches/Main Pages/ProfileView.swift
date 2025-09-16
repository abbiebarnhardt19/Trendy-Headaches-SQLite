//
//  ProfileView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/31/25.
//

import SwiftUI

struct ProfileView: View {
    var userID: Int64
    @EnvironmentObject var themeManager: ThemeManager
    
    // Booleans
    @State private var isEditing = true
    @State private var logOut = false
    @State private var showPolicy = false
    @State private var showDeleteConfirmation = false
    
    // User data from database
    @State private var symptoms: [String] = []
    @State private var triggers: [String] = []
    @State private var prevMeds: [String] = []
    @State private var emergencyMeds: [String] = []
    @State private var securityQuestion: String = ""
    @State private var securityAnswer: String = ""
    @State private var themeName: String = ""

    // Editing values
    @State private var newSymptoms: [String] = []
    @State private var newTriggers: [String] = []
    @State private var newPrevMeds: [String] = []
    @State private var newEmergencyMeds: [String] = []
    @State private var newSecurityQuestion: String = ""
    @State private var newSecurityAnswer: String = ""
    @State private var newThemeName: String = ""
    
    // Dropdown values
    let themeOptions = ["Classic Light", "Light Pink", "Light Yellow", "Classic Dark", "Dark Green","Dark Blue", "Dark Purple", "Custom"]
    
    // Floating button names
    let buttonNames = ["Edit Profile", "Data Policy", "Sign Out", "Delete Account"]
    
    func refreshUserData(refreshColors: Bool) {
        // Get all user values from database
        let fetchForeignLists: [(table: String, column: String, filterCol: String?, filterVal: String?, assign: ([String]) -> Void, newAssign: ([String]) -> Void)] =
        [("symptoms", "symptom_name", nil, nil, {symptoms=$0}, {newSymptoms=$0}),
         ("triggers", "trigger_name", nil, nil, {triggers=$0}, {newTriggers=$0}),
         ("medications", "medication_name", "medication_category", "preventative", {prevMeds=$0}, {newPrevMeds=$0}),
         ("medications", "medication_name", "medication_category", "emergency", {emergencyMeds=$0}, {newEmergencyMeds=$0})]
        
        fetchForeignLists.forEach { param in
            var list = DatabaseManager.shared.getForeignKeyColumnValues(
                userId: userID,
                tableName: param.table,
                columnName: param.column,
                filterColumn: param.filterCol,
                filterValue: param.filterVal
            )
            
            list = DatabaseManager.deleteListDuplicates(list: list)
            if list.isEmpty { list.append("None entered") }
            param.assign(list)
            param.newAssign(list)
        }
        
        securityQuestion = DatabaseManager.shared.getSingleColumnValue(userId: userID, columnName: "security_question") ?? "None set"
        securityAnswer = DatabaseManager.shared.getSingleColumnValue(userId: userID, columnName: "security_answer") ?? "None set"
        newSecurityQuestion = securityQuestion
        
        if refreshColors {
            themeManager.backgroundColor = DatabaseManager.shared.getSingleColumnValue(userId: userID, columnName: "background_color") ?? themeManager.backgroundColor
            themeManager.accentColor = DatabaseManager.shared.getSingleColumnValue(userId: userID, columnName: "accent_color") ?? themeManager.accentColor
            
            themeName = DatabaseManager.getThemeName(selected_background: themeManager.backgroundColor, selected_accent: themeManager.accentColor)
            newThemeName = themeName.contains("Custom") ? "Custom" : themeName
        }
    }
    
    var body: some View {
        let editColumnWidth = UIScreen.main.bounds.width / 2 - 18
        let viewColumnWidth = UIScreen.main.bounds.width / 2
        let buttonActions = [{ isEditing = true }, { showPolicy = true }, { logOut = true }, { showDeleteConfirmation = true }]
        
        ZStack {
            Color(hex: themeManager.backgroundColor).ignoresSafeArea()
            
            // Decorative blobs
            SameAmplitudeBlob(waves: 12, amplitude: 20, accent: themeManager.accentColor, x: 160, y: -270, rotation: -10)
                .zIndex(isEditing ? 1 : 0)
            SameAmplitudeBlob(waves: 13, amplitude: 20, accent: themeManager.accentColor, x: 100, y: -320, rotation: 165)
                .zIndex(isEditing ? 1 : 0)
            
            ScrollView {
                VStack {
                    if isEditing {
                        HStack(alignment: .top) {
                            // Left column
                            Spacer()
                            VStack(alignment: .center) {
                                CustomText(text: "User Profile", color: themeManager.accentColor, width: 150, textAlignment: .center, textSize: 47)
                                    .padding(.top, 20)
                                    .padding(.bottom, 10)
                                
                                CustomText(text: "Symptoms", color: themeManager.accentColor, width: editColumnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                EditableList(items: $newSymptoms, title: "Symptoms", backgroundColor: themeManager.backgroundColor, accentColor: themeManager.accentColor)
                                
                                CustomText(text: "Triggers", color: themeManager.accentColor, width: editColumnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                EditableList(items: $newTriggers, title: "Triggers", backgroundColor: themeManager.backgroundColor, accentColor: themeManager.accentColor)
                                
                                CustomText(text: "Preventative Medications", color: themeManager.accentColor, width: editColumnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                EditableList(items: $newPrevMeds, title: "Preventative Medications", backgroundColor: themeManager.backgroundColor, accentColor: themeManager.accentColor)
                            }
                            .frame(maxWidth: editColumnWidth, alignment: .center)
                            
                            // Right column
                            VStack {
                                CustomText(text: "Emergency Medications", color: themeManager.accentColor, width: editColumnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                EditableList(items: $newEmergencyMeds, title: "Emergency Medications", backgroundColor: themeManager.backgroundColor, accentColor: themeManager.accentColor)
                                
                                CustomText(text: "Security Question", color: themeManager.accentColor, width: editColumnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                CustomTextField(background: themeManager.backgroundColor, accent: themeManager.accentColor, placeholder: "", text: $newSecurityQuestion, width: editColumnWidth - 20, height: 55, cornerRadius: 8, textSize: 16, isMultiline: true)
                                    .padding(.bottom, 10)
                                
                                CustomText(text: "Security Answer", color: themeManager.accentColor, width: editColumnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                CustomTextField(background: themeManager.backgroundColor, accent: themeManager.accentColor, placeholder: "", text: $newSecurityAnswer, width: editColumnWidth - 20, height: 34, cornerRadius: 8, textSize: 16, isSecure: true)
                                    .padding(.bottom, 10)
                                
                                CustomText(text: "Color Theme", color: themeManager.accentColor, width: editColumnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                CustomDropdown(color_theme: $newThemeName, background: $themeManager.backgroundColor, accent: $themeManager.accentColor, options: themeOptions, width: editColumnWidth - 20, height: 38, cornerRadius: 8, fontSize: 16)
                                
                                if newThemeName == "Custom" {
                                    CustomText(text: "Hex Codes", color: themeManager.accentColor, width: editColumnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                    
                                    CustomTextField(background: themeManager.backgroundColor, accent: themeManager.accentColor, placeholder: "", text: $themeManager.backgroundColor, width: editColumnWidth - 30, height: 38, cornerRadius: 8, textSize: 16)
                                    
                                    CustomTextField(background: themeManager.backgroundColor, accent: themeManager.accentColor, placeholder: "", text: $themeManager.accentColor, width: editColumnWidth - 30, height: 38, cornerRadius: 8, textSize: 16)
                                }
                                
                                CustomButton(text: "Save", background: themeManager.backgroundColor, accent: themeManager.accentColor) {
                                    // Update database first
                                    DatabaseManager.shared.updateUser(userID: userID, newValue: newSecurityQuestion, column: "security_question")
                                    let hashedAnswer = DatabaseManager.hashString(DatabaseManager.normalizedValue(newSecurityAnswer))
                                    DatabaseManager.shared.updateUser(userID: userID, newValue: hashedAnswer, column: "security_answer")

                                    // Update colors in ThemeManager
                                    themeManager.backgroundColor = newThemeName == "Custom" ? themeManager.backgroundColor : DatabaseManager.shared.getSingleColumnValue(userId: userID, columnName: "background_color") ?? themeManager.backgroundColor
                                    themeManager.accentColor = newThemeName == "Custom" ? themeManager.accentColor : DatabaseManager.shared.getSingleColumnValue(userId: userID, columnName: "accent_color") ?? themeManager.accentColor

                                    // Refresh local view
                                    refreshUserData(refreshColors: true)
                                    isEditing = false
                                }


                            }
                            .padding(.top, 100)
                            Spacer()
                        }
                        .padding(.bottom, 60)
                    } else {
                        // View mode
                        CustomText(text: "User Profile", color: themeManager.accentColor, width: 150, textAlignment: .leading, textSize: 50)
                            .padding(.trailing, 170)
                            .padding(.bottom, 30)
                            .padding(.top, 20)
                        
                        HStack(alignment: .top) {
                            VStack {
                                CustomText(text: "Symptoms", color: themeManager.accentColor, width: viewColumnWidth - 10, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                CustomList(items: newSymptoms, color: themeManager.accentColor)
                                
                                CustomText(text: "Triggers", color: themeManager.accentColor, width: viewColumnWidth - 10, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                CustomList(items: newTriggers, color: themeManager.accentColor)
                                
                                CustomText(text: "Preventative Meds", color: themeManager.accentColor, width: viewColumnWidth - 10, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                CustomList(items: newPrevMeds, color: themeManager.accentColor)
                            }
                            .frame(maxWidth: viewColumnWidth)
                            
                            VStack(alignment: .center) {
                                CustomText(text: "Emergency Meds", color: themeManager.accentColor, width: viewColumnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                CustomList(items: newEmergencyMeds, color: themeManager.accentColor)
                                
                                CustomText(text: "Security Question", color: themeManager.accentColor, width: viewColumnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                CustomList(items: [newSecurityQuestion], color: themeManager.accentColor)
                                
                                CustomText(text: "Color Theme", color: themeManager.accentColor, width: viewColumnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                                CustomList(items: [themeName], color: themeManager.accentColor)
                                
                                CustomFloatButton(accent: themeManager.accentColor, background: themeManager.backgroundColor, options: buttonNames, actions: buttonActions)
                                    .fullScreenCover(isPresented: $showPolicy) {
                                        PolicySheetView(policyFileName: "DataPolicy", showsAgreeButton: false)
                                    }
                            }
                            .frame(maxWidth: viewColumnWidth, alignment: .center)
                        }
                    }
                }
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
            refreshUserData(refreshColors: true)
        }
    }
}

#Preview {
    ProfileView(userID: 1)
        .environmentObject(ThemeManager())
}
