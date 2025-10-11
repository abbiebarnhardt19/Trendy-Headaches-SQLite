//
//  ProfileView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/31/25.
//

import SwiftUI

struct ProfileView: View {
    // Passed-in Values
    var userID: Int64
    @Binding var background: String
    @Binding var accent: String
    
    //  UI State
    @State private var isEditing = true
    @State private var logOut = false
    @State private var showPolicy = false
    @State private var showDeleteConfirmation = false
    
    //  User Data
    @State private var symptoms: [String] = []
    @State private var triggers: [String] = []
    @State private var prevMeds: [String] = []
    @State private var emergencyMeds: [String] = []
    @State private var securityQuestion = ""
    @State private var securityAnswer = ""
    @State private var themeName = ""
    
    //  Editable Values
    @State private var newSecurityQuestion = ""
    @State private var newSecurityAnswer = ""
    @State private var newThemeName = ""
    @State private var newBackground = ""
    @State private var newAccent = ""
    
    //  Constants
    private let themeOptions = ["Classic Light", "Light Pink", "Light Yellow", "Classic Dark",  "Dark Green", "Dark Blue", "Dark Purple", "Custom"]
    private let buttonNames = ["Edit Profile", "Data Policy", "Sign Out", "Delete Account"]
    private let screenWidth = UIScreen.main.bounds.width
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                ProfileBackgroundComponents(background: newBackground, accent: newAccent)
                
                // Content
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
                
                // Bottom Nav Bar
                VStack {
                    Spacer()
                    NavBarView(userID: userID, background: $newBackground, accent: $newAccent, selectedIndex: .constant(3))
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(1)
            }
            //delete confirmation
            .alert("Are you sure you want to delete your account?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    DatabaseManager.shared.deleteUser(userID: userID)
                    logOut = true
                }
                Button("Cancel", role: .cancel) {}
            }
            //go to login if cancel account
            .fullScreenCover(isPresented: $logOut) {
                InitialView()
            }
            //get data on load
            .onAppear {
                DatabaseManager.shared.loadData(userID: userID,  symptoms: &symptoms, triggers: &triggers,  prevMeds: &prevMeds, emergencyMeds: &emergencyMeds,  securityQuestion: &securityQuestion,  securityAnswer: &securityAnswer, newSecurityQuestion: &newSecurityQuestion, backgroundColor: &background, accentColor: &accent, newBackground: &newBackground, newAccent: &newAccent, themeName: &themeName,  newThemeName: &newThemeName)}
        }
    }
    
    // Editing View
    @ViewBuilder
    private func editingView() -> some View {
        let columnWidth = screenWidth / 2
        
        CustomText(text: "User Profile", color: newAccent, textAlignment: .center, textSize: 45)
            .padding(.top, 30)
            .padding(.bottom, 10)
        
        HStack(alignment: .top) {
            VStack(alignment: .center) {
                
                sectionTitle("Symptoms", width: columnWidth)
                EditableList(items: $symptoms,  title: "Symptoms", backgroundColor: newBackground, accentColor: newAccent,
                     onAdd: { newSymptom in DatabaseManager.shared.insertItem( table: DatabaseManager.shared.symptoms, userID: userID, nameColumn: DatabaseManager.shared.symptom_name, name: newSymptom, startColumn: DatabaseManager.shared.symptom_start, endColumn: DatabaseManager.shared.symptom_end)},
                    onEdit: { oldValue, newValue in DatabaseManager.shared.updateItem( table: DatabaseManager.shared.symptoms, userID: userID, oldValue: oldValue, newValue: newValue, nameColumn: DatabaseManager.shared.symptom_name)},
                    onDelete: { value in DatabaseManager.shared.endItem( table: DatabaseManager.shared.symptoms, userID: userID, name: value, nameColumn: DatabaseManager.shared.symptom_name, endColumn: DatabaseManager.shared.symptom_end)} )
                
                sectionTitle("Preventative Medications", width: columnWidth)
                EditableList(items: $prevMeds, title: "Preventative Medications", backgroundColor: newBackground, accentColor: newAccent,
                     onAdd: { newPrevMed in DatabaseManager.shared.insertItem( table: DatabaseManager.shared.medications, userID: userID, nameColumn: DatabaseManager.shared.medication_name, name: newPrevMed, startColumn: DatabaseManager.shared.medication_start, endColumn: DatabaseManager.shared.medication_end, medicationCategory: "preventative" )},
                    onEdit: { oldValue, newValue in DatabaseManager.shared.updateItem( table: DatabaseManager.shared.medications, userID: userID, oldValue: oldValue, newValue: newValue, nameColumn: DatabaseManager.shared.medication_name, medicationCategory: "preventative")},
                    onDelete: { value in DatabaseManager.shared.endItem( table: DatabaseManager.shared.medications, userID: userID, name: value, nameColumn: DatabaseManager.shared.medication_name, endColumn: DatabaseManager.shared.medication_end, medicationCategory: "preventative")})
                
                sectionTitle("Security Question", width: columnWidth)
                CustomTextField(background: newBackground, accent: newAccent, placeholder: "",  text: $newSecurityQuestion,  width: columnWidth - 15, height: 50, cornerRadius: 8, textSize: 20,  isMultiline: true)
                
                sectionTitle("Color Theme", width: columnWidth)
                CustomDropdown(color_theme: $newThemeName, background: $newBackground, accent: $newAccent, options: themeOptions, width: columnWidth - 15, height: 50,  cornerRadius: 8, fontSize: 20)
                
                if newThemeName == "Custom" {
                    sectionTitle("Hex Codes", width: columnWidth)
                    ColorPickerTextField(
                                accent: newAccent,
                                background: newBackground,
                                var_to_change: $newBackground,
                                placeholder: "Enter HEX color",
                                width: columnWidth-10)
                    .padding(.vertical, 15)

                    
                    ColorPickerTextField(
                                accent: newAccent,
                                background: newBackground,
                                var_to_change: $newAccent,
                                placeholder: "Enter HEX color",
                                width: columnWidth - 10)
                }
            }
            .frame(maxWidth: columnWidth)
            .padding(.leading, 10)
            
            VStack {
                sectionTitle("Triggers", width: columnWidth)
                EditableList(items: $triggers, title: "Triggers", backgroundColor: newBackground, accentColor: newAccent,
                     onAdd: { newTrigger in DatabaseManager.shared.insertItem( table: DatabaseManager.shared.triggers, userID: userID, nameColumn: DatabaseManager.shared.trigger_name, name: newTrigger, startColumn: DatabaseManager.shared.trigger_start, endColumn: DatabaseManager.shared.trigger_end)},
                    onEdit: { oldValue, newValue in DatabaseManager.shared.updateItem( table: DatabaseManager.shared.triggers, userID: userID,  oldValue: oldValue, newValue: newValue, nameColumn: DatabaseManager.shared.trigger_name)},
                    onDelete: { value in DatabaseManager.shared.endItem( table: DatabaseManager.shared.triggers, userID: userID, name: value, nameColumn: DatabaseManager.shared.trigger_name, endColumn: DatabaseManager.shared.trigger_end)} )
                
                sectionTitle("Emergency Medications", width: columnWidth)
                EditableList( items: $emergencyMeds, title: "Emergency Medications", backgroundColor: newBackground, accentColor: newAccent,
                    onAdd: { newEmergencyMed in DatabaseManager.shared.insertItem( table: DatabaseManager.shared.medications, userID: userID, nameColumn: DatabaseManager.shared.medication_name, name: newEmergencyMed, startColumn: DatabaseManager.shared.medication_start, endColumn: DatabaseManager.shared.medication_end,  medicationCategory: "emergency")},
                    onEdit: { oldValue, newValue in DatabaseManager.shared.updateItem( table: DatabaseManager.shared.medications, userID: userID, oldValue: oldValue, newValue: newValue, nameColumn: DatabaseManager.shared.medication_name, medicationCategory: "emergency")},
                    onDelete: { value in DatabaseManager.shared.endItem( table: DatabaseManager.shared.medications, userID: userID, name: value, nameColumn: DatabaseManager.shared.medication_name, endColumn: DatabaseManager.shared.medication_end, medicationCategory: "emergency")})
                
                sectionTitle("Security Answer", width: columnWidth)
                CustomTextField(background: newBackground, accent: newAccent, placeholder: "", text: $newSecurityAnswer, width: columnWidth - 15, height: 50, cornerRadius: 8, textSize: 16, isSecure: true)
                
                CustomButton( text: "Save", background: newBackground, accent: newAccent, height: 50, width: columnWidth - 25, cornerRadius: 36,  isBold: true, textSize: 25, action: saveProfileChanges )
                .padding(.top, 10)
            }
            .padding(.trailing, 10)
        }
        .frame(width: screenWidth)
        .padding(.bottom, 120)
    }
    
    //  Viewing View
    @ViewBuilder
    private func viewingView() -> some View {
        let columnWidth = screenWidth / 2
        
        CustomText(text: "User Profile", color: newAccent, textAlignment: .center, textSize: 45)
            .padding(.vertical, 50)
        
        HStack(alignment: .top) {
            VStack {
                section(columnTitle: "Symptoms", items: symptoms, width: columnWidth)
                section(columnTitle: "Preventative Meds", items: prevMeds, width: columnWidth)
                section(columnTitle: "Security Question", items: [newSecurityQuestion], width: columnWidth)
            }
            .frame(maxWidth: columnWidth)
            
            VStack {
                section(columnTitle: "Triggers", items: triggers, width: columnWidth)
                section(columnTitle: "Emergency Meds", items: emergencyMeds, width: columnWidth)
                section(columnTitle: "Color Theme", items: [themeName], width: columnWidth)
            }
            .frame(maxWidth: columnWidth)
        }
        
        // Floating Button
        HStack {
            Spacer()
            let buttonActions: [() -> Void] = [ { isEditing = true },  { showPolicy = true },  { logOut = true },  { showDeleteConfirmation = true } ]
            
            CustomFloatButton( accent: newAccent,  background: newBackground,  options: buttonNames, actions: buttonActions)
            .fullScreenCover(isPresented: $showPolicy) {
                PolicySheetView(policyFileName: "DataPolicy", showsAgreeButton: false)
            }
            .padding(.trailing, 10)
        }
        .frame(width: columnWidth * 2)
    }
    
    // Helpers
    private func sectionTitle(_ title: String, width: CGFloat) -> some View {
        CustomText(text: title, color: newAccent, width: width - 15, textAlignment: .center, multilineAlignment: .center, isBold: true)
    }
    
    private func section(columnTitle: String, items: [String], width: CGFloat) -> some View {
            VStack {
                sectionTitle(columnTitle, width: width)
                CustomList(items: items, color: newAccent)
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
        
        if background != newBackground {
            DatabaseManager.shared.updateUser(userID: userID, newValue: newBackground, column: "background_color")
            background = newBackground
            themeName = DatabaseManager.getThemeName(selected_background: newBackground, selected_accent: newAccent)
            newThemeName = themeName.contains("Custom") ? "Custom" : themeName
        }
        
        if accent != newAccent {
            DatabaseManager.shared.updateUser(userID: userID, newValue: newAccent, column: "accent_color")
            accent = newAccent
        }
        isEditing = false
    }
}

#Preview {
    ProfileView(userID: 1, background: .constant("#001d00"), accent: .constant("#b5c4b9"))
}
