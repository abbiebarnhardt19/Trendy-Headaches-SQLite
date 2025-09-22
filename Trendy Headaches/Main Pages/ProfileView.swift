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
    @State private var isEditing = false
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
    
    let screen_width = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationStack{
            ZStack {
                // Background color
                Color(hex: newBackground).ignoresSafeArea()
                
                // Decorative blobs
                SameAmplitudeBlob(waves: 15, amplitude: 15, accent: newAccent, x: 100, y: -375, rotation: -35)
                    .zIndex(1)
                SameAmplitudeBlob(waves: 15, amplitude: 15, accent: newAccent, x: 265, y: -180, rotation: 145)
                    .zIndex(1)
                
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
                .zIndex(1)
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
        
        CustomText(text: "User Profile", color: newAccent, textAlignment: .center, textSize: 50)
            .padding(.bottom, 20)
            .padding(.top, 50)

        HStack(alignment: .top) {
            // Left column
            VStack(alignment: .center) {

                CustomText(text: "Symptoms", color: newAccent, width: UIScreen.main.bounds.width / 2 - 15, textAlignment: .center, multilineAlignment: .center, isBold: true)
                
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
  

                CustomText(text: "Preventative Medications", color: newAccent, width: UIScreen.main.bounds.width / 2 - 15, textAlignment: .center, multilineAlignment: .center, isBold: true)
                
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
                
                CustomText(text: "Security Question", color: newAccent, width: UIScreen.main.bounds.width / 2 - 15, textAlignment: .center, multilineAlignment: .center, isBold: true)
                CustomTextField(background: newBackground, accent: newAccent, placeholder: "", text: $newSecurityQuestion, width: UIScreen.main.bounds.width / 2 - 15, height: 50, cornerRadius: 8, textSize: 20, isMultiline: true)
                    .padding(.bottom, 10)
                
                CustomText(text: "Color Theme", color: newAccent, width: UIScreen.main.bounds.width / 2 - 15, textAlignment: .center, multilineAlignment: .center, isBold: true)
                CustomDropdown(color_theme: $newThemeName, background: $newBackground, accent: $newAccent, options: theme_options, width: UIScreen.main.bounds.width / 2 - 15, height: 50, cornerRadius: 8, fontSize: 20)
                
                if newThemeName == "Custom" {
                    CustomText(text: "Hex Codes", color: newAccent, textAlignment: .center, multilineAlignment: .center, isBold: true)
                    CustomTextField(background: newBackground, accent: newAccent, placeholder: "", text: $newBackground, width: editColumnWidth - 20, height: 50, cornerRadius: 8, textSize: 20)
                    CustomTextField(background: newBackground, accent: newAccent, placeholder: "", text: $newAccent, width: editColumnWidth - 20, height: 50, cornerRadius: 8, textSize: 20)
                }
            }
            .frame(maxWidth: editColumnWidth, alignment: .center)
            .padding(.leading, 10)
            
            // Right column
            VStack {
                CustomText(text: "Triggers", color: newAccent, width: UIScreen.main.bounds.width / 2 - 15, textAlignment: .center, multilineAlignment: .center, isBold: true)
                
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
                CustomText(text: "Emergency Medications", color: newAccent, width: UIScreen.main.bounds.width / 2 - 15, textAlignment: .center, multilineAlignment: .center, isBold: true)
                
                EditableList(
                    items: $emergencyMeds,
                    title: "Emergency Medications",
                    backgroundColor: newBackground,
                    accentColor: newAccent,
                    onAdd: { newEmergencyMed in
                        DatabaseManager.shared.insertItem(table: DatabaseManager.shared.medications,
                            userID: userID, nameColumn: DatabaseManager.shared.medication_name,
                            name: newEmergencyMed, startColumn: DatabaseManager.shared.medication_start,
                            endColumn: DatabaseManager.shared.medication_end, medicationCategory: "emergency")},
                    onEdit: { oldValue, newValue in
                        DatabaseManager.shared.updateItem(table: DatabaseManager.shared.medications, userID: userID, oldValue: oldValue, newValue: newValue,nameColumn: DatabaseManager.shared.medication_name, medicationCategory: "emergency")},
                    onDelete: { value in
                        DatabaseManager.shared.endItem(table: DatabaseManager.shared.medications, userID: userID, name: value, nameColumn: DatabaseManager.shared.medication_name, endColumn: DatabaseManager.shared.medication_end, medicationCategory: "emergency")})
                


                CustomText(text: "Security Answer", color: newAccent, width: 100, textAlignment: .center, multilineAlignment: .center, isBold: true)
                CustomTextField(background: newBackground, accent: newAccent, placeholder: "", text: $newSecurityAnswer, width: UIScreen.main.bounds.width / 2 - 15, height: 50, cornerRadius: 8, textSize: 16, isSecure: true)
                    .padding(.bottom, 10)
                
                CustomButton(text: "Save", background: newBackground, accent: newAccent,  height: 50, width:UIScreen.main.bounds.width / 2 - 25, cornerRadius: 36, isBold: true, textSize: 25) {
                    saveProfileChanges()
                }
                .padding(.top, 10)
                
            }
            .padding(.trailing, 10)
            
        }
        .frame(width: UIScreen.main.bounds.width, alignment: .center)
        .padding(.bottom, 120)
    }
    
    @ViewBuilder
    private func viewingView() -> some View {
        let viewColumnWidth = UIScreen.main.bounds.width / 2
        CustomText(text: "User Profile", color: newAccent, textAlignment: .center, textSize: 50)
            .padding(.bottom, 40)
            .padding(.top, 50)
        
        HStack(alignment: .top) {
            // Left column
            VStack {
                VStack {
                    CustomText(text: "Symptoms", color: newAccent, width: viewColumnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                    CustomList(items: symptoms, color: newAccent)
                }
                VStack {
                    CustomText(text: "Preventative Meds", color: newAccent, width: viewColumnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                    CustomList(items: prevMeds, color: newAccent)
                }
                VStack {
                    CustomText(text: "Security Question", color: newAccent, width: viewColumnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                    CustomList(items: [newSecurityQuestion], color: newAccent)
                }
            }
            .frame(maxWidth: viewColumnWidth)
            
            // Right column
            VStack{
                VStack{
                    CustomText(text: "Triggers", color: newAccent, width: viewColumnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                    CustomList(items: triggers, color: newAccent)
                }
                
                VStack {
                    CustomText(text: "Emergency Meds", color: newAccent, width: viewColumnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                    CustomList(items: emergencyMeds, color: newAccent)
                }
                
                VStack {
                    CustomText(text: "Color Theme", color: newAccent, width: viewColumnWidth - 20, textAlignment: .center, multilineAlignment: .center, isBold: true)
                    CustomList(items: [themeName], color: newAccent)
                }
            }
            .frame(maxWidth: viewColumnWidth)
        }
        // Floating button
        HStack{
            Spacer()
            let buttonActions = [{ isEditing = true }, { showPolicy = true },
                                 { logOut = true }, { showDeleteConfirmation = true}]
            
            CustomFloatButton(accent: newAccent, background: newBackground, options: buttonNames, actions: buttonActions)
                .fullScreenCover(isPresented: $showPolicy) {
                    PolicySheetView(policyFileName: "DataPolicy", showsAgreeButton: false)
                }
                .padding(.trailing, 10)
        }
        .frame(width: viewColumnWidth*2)
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
    ProfileView(userID:3, backgroundColor: .constant("#001d00"), accentColor: .constant("#b5c4b9"))
}
