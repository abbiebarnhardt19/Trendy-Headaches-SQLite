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
    @State private var newSecurityQuestion: String = ""
    @State private var newSecurityAnswer: String = ""
    @State private var newThemeName: String = ""
    @State private var newBackground: String = ""
    @State private var newAccent: String = ""
    
    // Dropdown values
    let theme_options = ["Classic Light", "Light Pink", "Light Yellow", "Classic Dark", "Dark Green","Dark Blue", "Dark Purple", "Custom"]
    
    // Floating button names
    let buttonNames = ["Edit Profile", "Data Policy", "Sign Out", "Delete Account"]
    
    var body: some View {
        NavigationStack{
            ZStack {
                // Background color
                Color(hex: newBackground).ignoresSafeArea()
                
                // Decorative blobs
                SameAmplitudeBlob(waves: 12, amplitude: 20, accent: newAccent, x: 160, y: -340, rotation: -18)
                SameAmplitudeBlob(waves: 13, amplitude: 15, accent: newAccent, x: 0, y: -375, rotation: 155)
                
                // Scrollable content
                ScrollView {
                    //set the content based on editing or not
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
                    NavBarView(userID: userID, backgroundColor: $newBackground, accentColor: $newAccent)
                    .frame(height: 60)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .ignoresSafeArea(edges: .bottom)
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
                DatabaseManager.shared.loadData(userID: userID, symptoms: &symptoms, triggers: &triggers, prevMeds: &prevMeds, emergencyMeds: &emergencyMeds, securityQuestion: &securityQuestion, securityAnswer: &securityAnswer, newSecurityQuestion: &newSecurityQuestion, backgroundColor: &backgroundColor, accentColor: &accentColor, newBackground: &newBackground, newAccent: &newAccent, themeName: &themeName, newThemeName: &newThemeName)
            }
        }
    }
    
    @ViewBuilder
    private func editingView() -> some View {
        let editColumnWidth = UIScreen.main.bounds.width / 2

        HStack(alignment: .top) {
            Spacer()
            
            // Left column
            VStack(alignment: .center) {
                CustomText(text: "User Profile", color: newAccent, width: 150, textAlignment: .leading, textSize: 50)
                    .padding(.bottom, 10)
                    .padding(.top, 0)
                    .padding(.leading, 5)

                CustomText(text: "Symptoms", color: newAccent, width: editColumnWidth - 40, textAlignment: .center, multilineAlignment: .center, isBold: true)
                
                EditableList(
                    items: $symptoms,
                    title: "Symptoms",
                    backgroundColor: newBackground,
                    accentColor: newAccent,
                    onAdd: { newSymptom in
                        DatabaseManager.shared.insertItem(table: DatabaseManager.shared.symptoms,
                            userID: userID, nameColumn: DatabaseManager.shared.symptom_name,
                            name: newSymptom, startColumn: DatabaseManager.shared.symptom_start,
                            endColumn: DatabaseManager.shared.symptom_end)},
                    onEdit: { oldValue, newValue in
                        DatabaseManager.shared.updateItem(table: DatabaseManager.shared.symptoms, userID: userID,oldValue: oldValue, newValue: newValue,nameColumn: DatabaseManager.shared.symptom_name)},
                    onDelete: { value in
                        DatabaseManager.shared.endItem(table: DatabaseManager.shared.symptoms, userID: userID, name: value, nameColumn: DatabaseManager.shared.symptom_name, endColumn: DatabaseManager.shared.symptom_end)})
  
                CustomText(text: "Triggers", color: newAccent, width: editColumnWidth - 40, textAlignment: .center, multilineAlignment: .center, isBold: true)
                
                EditableList(
                    items: $triggers,
                    title: "Triggers",
                    backgroundColor: newBackground,
                    accentColor: newAccent,
                    onAdd: { newTrigger in
                        DatabaseManager.shared.insertItem(table: DatabaseManager.shared.triggers,
                            userID: userID, nameColumn: DatabaseManager.shared.trigger_name,
                            name: newTrigger, startColumn: DatabaseManager.shared.trigger_start,
                            endColumn: DatabaseManager.shared.trigger_end)},
                    onEdit: { oldValue, newValue in
                        DatabaseManager.shared.updateItem(table: DatabaseManager.shared.triggers, userID: userID, oldValue: oldValue, newValue: newValue,nameColumn: DatabaseManager.shared.trigger_name)},
                    onDelete: { value in
                        DatabaseManager.shared.endItem(table: DatabaseManager.shared.triggers, userID: userID, name: value, nameColumn: DatabaseManager.shared.trigger_name, endColumn: DatabaseManager.shared.trigger_end)})
                
                CustomText(text: "Preventative Medications", color: newAccent, width: editColumnWidth - 40, textAlignment: .center, multilineAlignment: .center, isBold: true)
                
                EditableList(
                    items: $prevMeds,
                    title: "Preventative Medications",
                    backgroundColor: newBackground,
                    accentColor: newAccent,
                    onAdd: { newPrevMed in
                        DatabaseManager.shared.insertItem(table: DatabaseManager.shared.medications,
                            userID: userID, nameColumn: DatabaseManager.shared.medication_name,
                            name: newPrevMed, startColumn: DatabaseManager.shared.medication_start,
                            endColumn: DatabaseManager.shared.medication_end, medicationCategory: "preventative")},
                    onEdit: { oldValue, newValue in
                        DatabaseManager.shared.updateItem(table: DatabaseManager.shared.medications, userID: userID, oldValue: oldValue, newValue: newValue,nameColumn: DatabaseManager.shared.medication_name, medicationCategory: "preventative")},
                    onDelete: { value in
                        DatabaseManager.shared.endItem(table: DatabaseManager.shared.medications, userID: userID, name: value, nameColumn: DatabaseManager.shared.medication_name, endColumn: DatabaseManager.shared.medication_end, medicationCategory: "preventative")})
            }
            .frame(maxWidth: editColumnWidth, alignment: .center)
            .padding(.bottom, 50)
            
            // Right column
            VStack {
                CustomText(text: "Emergency Medications", color: newAccent, width: editColumnWidth - 40, textAlignment: .center, multilineAlignment: .center, isBold: true)
                
                EditableList(
                    items: $emergencyMeds,
                    title: "Emergency Medications",
                    backgroundColor: newBackground,
                    accentColor: newAccent,
                    onAdd: { newPrevMed in
                        DatabaseManager.shared.insertItem(table: DatabaseManager.shared.medications,
                            userID: userID, nameColumn: DatabaseManager.shared.medication_name,
                            name: newPrevMed, startColumn: DatabaseManager.shared.medication_start,
                            endColumn: DatabaseManager.shared.medication_end, medicationCategory: "emergency")},
                    onEdit: { oldValue, newValue in
                        DatabaseManager.shared.updateItem(table: DatabaseManager.shared.medications, userID: userID, oldValue: oldValue, newValue: newValue,nameColumn: DatabaseManager.shared.medication_name, medicationCategory: "emergency")},
                    onDelete: { value in
                        DatabaseManager.shared.endItem(table: DatabaseManager.shared.medications, userID: userID, name: value, nameColumn: DatabaseManager.shared.medication_name, endColumn: DatabaseManager.shared.medication_end, medicationCategory: "emergency")})
                
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
                    CustomList(items: symptoms, color: newAccent)
                }
                
                VStack {
                    CustomText(text: "Triggers", color: newAccent, width: viewColumnWidth - 10, textAlignment: .center, multilineAlignment: .center, isBold: true)
                    CustomList(items: triggers, color: newAccent)
                }
                
                VStack {
                    CustomText(text: "Preventative Meds", color: newAccent, width: viewColumnWidth - 10, textAlignment: .center, multilineAlignment: .center, isBold: true)
                    CustomList(items: prevMeds, color: newAccent)
                }
            }
            .frame(maxWidth: viewColumnWidth)
            
            // Right column
            VStack(alignment: .center) {
                //placeholder
                
                VStack {
                    CustomText(text: "Emergency Meds", color: newAccent, width: viewColumnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                    CustomList(items: emergencyMeds, color: newAccent)
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
    }
}

#Preview {
    ProfileView(userID: 1, backgroundColor: .constant("#001d00"), accentColor: .constant("#b5c4b9"))
}
