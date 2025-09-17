//
//  ProfileView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/31/25.
//
import SwiftUI

struct ProfileView: View {
    // Passed in values
    var userID: Int64
    @Binding var backgroundColor: String
    @Binding var accentColor: String
    
    
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
    @State private var newBackground: String = ""
    @State private var newAccent: String = ""
    
    // Dropdown values
    let theme_options = ["Classic Light", "Light Pink", "Light Yellow", "Classic Dark", "Dark Green","Dark Blue", "Dark Purple", "Custom"]
    
    // Floating button names
    let buttonNames = ["Edit Profile", "Data Policy", "Sign Out", "Delete Account"]
    
    func refreshUserData(refreshColors: Bool) {
        // Fetch all user values from database
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
            if list.isEmpty {
                list.append("None entered")
            }
            param.assign(list)
            param.newAssign(list)
        }
        
        securityQuestion = DatabaseManager.shared.getSingleColumnValue(userId: userID, columnName: "security_question") ?? "None set"
        securityAnswer = DatabaseManager.shared.getSingleColumnValue(userId: userID, columnName: "security_answer") ?? "None set"
        newSecurityQuestion = securityQuestion
        
        if refreshColors {
            backgroundColor = DatabaseManager.shared.getSingleColumnValue(userId: userID, columnName: "background_color") ?? "None set"
            accentColor = DatabaseManager.shared.getSingleColumnValue(userId: userID, columnName: "accent_color") ?? "None set"
            newAccent = accentColor
            newBackground = backgroundColor
            themeName = DatabaseManager.getThemeName(selected_background: newBackground, selected_accent: newAccent)
            newThemeName = themeName.contains("Custom") ? "Custom" : themeName
        }
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                // Background color
                Color(hex: newBackground).ignoresSafeArea()
                
                // Decorative blobs
                SameAmplitudeBlob(waves: 12, amplitude: 20, accent: newAccent, x: 160, y: -340, rotation: -18)
                SameAmplitudeBlob(waves: 13, amplitude: 15, accent: newAccent, x: 0, y: -375, rotation: 155)
                
                GeometryReader { geo in
                    // Scrollable content
                    ScrollView {
                        VStack(spacing: 0) {
                            if isEditing {
                                editingView()
                            } else {
                                viewingView()
                            }
                        }
                    }
                    
                    .ignoresSafeArea(edges: .bottom)
                    
                    // Nav bar overlay at bottom
                    VStack {
                        Spacer()
                        NavBarView(
                            userID: userID,
                            backgroundColor: $newBackground,
                            accentColor: $newAccent,
                            width: UIScreen.main.bounds.width
                        )
                        .frame(height: 60)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .ignoresSafeArea(edges: .bottom)
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
    
    @ViewBuilder
    private func editingView() -> some View {
        let editColumnWidth = UIScreen.main.bounds.width / 2
//        let buttonActions = [{ isEditing = true }, { showPolicy = true },
//                             { logOut = true }, { showDeleteConfirmation = true}]

        HStack(alignment: .top) {
            Spacer()
            
            // Left column
            VStack(alignment: .center) {
                CustomText(text: "User Profile", color: newAccent, width: 150, textAlignment: .leading, textSize: 50)
                    .padding(.bottom, 10)
                    .padding(.top, 0)
                    .padding(.leading, 5)

                
                CustomText(text: "Symptoms", color: newAccent, width: editColumnWidth - 40, textAlignment: .center, multilineAlignment: .center, isBold: true)
                EditableList(items: $newSymptoms, title: "Symptoms", backgroundColor: newBackground, accentColor: newAccent)
                
                CustomText(text: "Triggers", color: newAccent, width: editColumnWidth - 40, textAlignment: .center, multilineAlignment: .center, isBold: true)
                EditableList(items: $newTriggers, title: "Triggers", backgroundColor: newBackground, accentColor: newAccent)
                
                CustomText(text: "Preventative Medications", color: newAccent, width: editColumnWidth - 40, textAlignment: .center, multilineAlignment: .center, isBold: true)
                EditableList(items: $newPrevMeds, title: "Preventative Medications", backgroundColor: newBackground, accentColor: newAccent)
            }
            .frame(maxWidth: editColumnWidth, alignment: .center)
            .padding(.bottom, 50)
            
            // Right column
            VStack {
                CustomText(text: "Emergency Medications", color: newAccent, width: editColumnWidth - 40, textAlignment: .center, multilineAlignment: .center, isBold: true)
                EditableList(items: $newEmergencyMeds, title: "Emergency Medications", backgroundColor: newBackground, accentColor: newAccent)
                
                CustomText(text: "Security Question", color: newAccent, width: editColumnWidth - 40, textAlignment: .center, multilineAlignment: .center, isBold: true)
                CustomTextField(background: newBackground, accent: newAccent, placeholder: "", text: $newSecurityQuestion, width: editColumnWidth - 40, height: 55, cornerRadius: 8, textSize: 16, isMultiline: true)
                    .padding(.bottom, 10)

                CustomText(text: "Security Answer", color: newAccent, width: editColumnWidth - 40, textAlignment: .center, multilineAlignment: .center, isBold: true)
                CustomTextField(background: newBackground, accent: newAccent, placeholder: "", text: $newSecurityAnswer, width: editColumnWidth - 40, height: 34, cornerRadius: 8, textSize: 16, isSecure: true)
                    .padding(.bottom, 10)
                
                CustomText(text: "Color Theme", color: newAccent, width: editColumnWidth - 40, textAlignment: .center, multilineAlignment: .center, isBold: true)
                CustomDropdown(color_theme: $newThemeName, background: $newBackground, accent: $newAccent, options: theme_options, width: editColumnWidth-40, height: 38, cornerRadius: 8, fontSize: 16)
                
                if newThemeName == "Custom" {
                    CustomText(text: "Hex Codes", color: newAccent, width: editColumnWidth - 40, textAlignment: .center, multilineAlignment: .center, isBold: true)
                    CustomTextField(background: newBackground, accent: newAccent, placeholder: "", text: $newBackground, width: editColumnWidth - 50, height: 38, cornerRadius: 8, textSize: 16)
                    CustomTextField(background: newBackground, accent: newAccent, placeholder: "", text: $newAccent, width: editColumnWidth - 50, height: 38, cornerRadius: 8, textSize: 16)
                }
                
                CustomButton(text: "Save", background: newBackground, accent: newAccent) {
                    saveProfileChanges()
                }
            }
            .padding(.top, 80)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func viewingView() -> some View {
        let viewColumnWidth = UIScreen.main.bounds.width / 2

        
        HStack(alignment: .top) {
            // Left column
            Spacer()
            VStack {
                CustomText(text: "User Profile", color: newAccent, width: 150, textAlignment: .leading, textSize: 50)
                    .padding(.bottom, 30)
                    .padding(.top, 0)
                    .padding(.leading, 5)

                VStack {
                    CustomText(text: "Symptoms", color: newAccent, width: viewColumnWidth - 10, textAlignment: .center, multilineAlignment: .center, isBold: true)
                    CustomList(items: newSymptoms, color: newAccent)
                }
                
                VStack {
                    CustomText(text: "Triggers", color: newAccent, width: viewColumnWidth - 10, textAlignment: .center, multilineAlignment: .center, isBold: true)
                    CustomList(items: newTriggers, color: newAccent)
                }
                
                VStack {
                    CustomText(text: "Preventative Meds", color: newAccent, width: viewColumnWidth - 10, textAlignment: .center, multilineAlignment: .center, isBold: true)
                    CustomList(items: newPrevMeds, color: newAccent)
                }
            }
            .frame(maxWidth: viewColumnWidth)
            
            // Right column
            VStack(alignment: .center) {
                //placeholder
                
                VStack {
                    CustomText(text: "Emergency Meds", color: newAccent, width: viewColumnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                    CustomList(items: newEmergencyMeds, color: newAccent)
                }
                
                VStack {
                    CustomText(text: "Security Question", color: newAccent, width: viewColumnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                    CustomList(items: [newSecurityQuestion], color: newAccent)
                }
                
                VStack {
                    CustomText(text: "Color Theme", color: newAccent, width: viewColumnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                    CustomList(items: [themeName], color: newAccent)
                }
                
                // Floating button
                let buttonActions = [{ isEditing = true }, { showPolicy = true },
                                     { logOut = true }, { showDeleteConfirmation = true}]
                
                CustomFloatButton(accent: newAccent, background: newBackground, options: buttonNames, actions: buttonActions)
                    .fullScreenCover(isPresented: $showPolicy) {
                        PolicySheetView(policyFileName: "DataPolicy", showsAgreeButton: false)
                    }
            }
            .frame(maxWidth: viewColumnWidth, alignment: .center)
            .padding(.top, 160)
            Spacer()
        }
    }
    
    private func saveProfileChanges() {
        if securityQuestion != newSecurityQuestion {
            DatabaseManager.shared.updateUser(userID: userID, newValue: newSecurityQuestion, column: "security_question")
        }
        
        let normalizedSecurityAnswer = DatabaseManager.normalizedValue(newSecurityAnswer)
        let hashedSecurityAnswer = DatabaseManager.hashString(normalizedSecurityAnswer)
        if hashedSecurityAnswer != securityAnswer {
            DatabaseManager.shared.updateUser(userID: userID, newValue: hashedSecurityAnswer, column: "security_answer")
        }
        
        if backgroundColor != newBackground {
            DatabaseManager.shared.updateUser(userID: userID, newValue: newBackground, column: "background_color")
            backgroundColor = newBackground
            themeName = DatabaseManager.getThemeName(selected_background: newBackground, selected_accent: newAccent)
            newThemeName = themeName.contains("Custom") ? "Custom" : themeName
        }
        
        if accentColor != newAccent {
            DatabaseManager.shared.updateUser(userID: userID, newValue: newAccent, column: "accent_color")
            accentColor = newAccent
        }
        
        isEditing = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            refreshUserData(refreshColors: false)
        }
    }
}

#Preview {
    ProfileView(userID: 1, backgroundColor: .constant("#001d00"), accentColor: .constant("#b5c4b9"))
}
