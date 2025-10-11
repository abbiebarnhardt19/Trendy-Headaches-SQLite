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
    @Binding var bg: String
    @Binding var accent: String
    
    //  UI State
    @State private var isEditing = false
    @State private var logOut = false
    @State private var showPolicy = false
    @State private var showDelete = false
    
    //  User Data
    @State private var symps: [String] = []
    @State private var triggs: [String] = []
    @State private var prevMeds: [String] = []
    @State private var emergMeds: [String] = []
    @State private var sQ = ""
    @State private var sA = ""
    @State private var themeName = ""
    
    //  Editable Values
    @State private var newSQ = ""
    @State private var newSA = ""
    @State private var newTN = ""
    @State private var newBG = ""
    @State private var newAcc = ""
    
    //  Constants
    private let themeOptions = ["Classic Light", "Light Pink", "Light Yellow", "Classic Dark",  "Dark Green", "Dark Blue", "Dark Purple", "Custom"]
    private let buttonNames = ["Edit Profile", "Data Policy", "Sign Out", "Delete Account"]
    private let screenWidth = UIScreen.main.bounds.width
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                ProfileBGComps(bg: newBG, accent: newAcc)
                
                // Content
                ScrollView {
                    VStack{
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
                    NavBarView(userID: userID, bg: $newBG, accent: $newAcc, selected: .constant(3))
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(1)
            }
            //delete confirmation
            .alert("Are you sure you want to delete your account?", isPresented: $showDelete) {
                Button("Delete", role: .destructive) {
                    Database.shared.deleteUser(userID: userID)
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
                Database.shared.loadData(userID: userID,  symptoms: &symps, triggers: &triggs,  prevMeds: &prevMeds, emergencyMeds: &emergMeds,  securityQuestion: &sQ,  securityAnswer: &sA, newSecurityQuestion: &newSQ, backgroundColor: &bg, accentColor: &accent, newBackground: &newBG, newAccent: &newAcc, themeName: &themeName,  newThemeName: &newTN)}
        }
    }
    
    // Editing View
    @ViewBuilder
    private func editingView() -> some View {
        let colWidth = screenWidth / 2
        
        CustomText(text: "User Profile", color: newAcc, textAlign: .center, textSize: 45)
            .padding(.top, 30)
            .padding(.bottom, 10)
        
        HStack(alignment: .top) {
            VStack(alignment: .center) {
                //symptom editable list
                sectionTitle("Symptoms", width: colWidth)
                EditableList(items: $symps,  title: "Symptoms", backgroundColor: newBG, accentColor: newAcc,
                     onAdd: { newSymptom in Database.shared.insertItem( table: Database.shared.symptoms, userID: userID, nameColumn: Database.shared.symptom_name, name: newSymptom, startColumn: Database.shared.symptom_start, endColumn: Database.shared.symptom_end)},
                             
                    onEdit: { oldValue, newValue in Database.shared.updateItem( table: Database.shared.symptoms, userID: userID, oldValue: oldValue, newValue: newValue, nameColumn: Database.shared.symptom_name)},
                             
                    onDelete: { value in Database.shared.endItem( table: Database.shared.symptoms, userID: userID, name: value, nameColumn: Database.shared.symptom_name, endColumn: Database.shared.symptom_end)} )
                
                //prev meds editable list
                sectionTitle("Preventative Medications", width: colWidth)
                EditableList(items: $prevMeds, title: "Preventative Medications", backgroundColor: newBG, accentColor: newAcc,
                     onAdd: { newPrevMed in Database.shared.insertItem( table: Database.shared.medications, userID: userID, nameColumn: Database.shared.medication_name, name: newPrevMed, startColumn: Database.shared.medication_start, endColumn: Database.shared.medication_end, medicationCategory: "preventative" )},
                             
                    onEdit: { oldValue, newValue in Database.shared.updateItem( table: Database.shared.medications, userID: userID, oldValue: oldValue, newValue: newValue, nameColumn: Database.shared.medication_name, medicationCategory: "preventative")},
                             
                    onDelete: { value in Database.shared.endItem( table: Database.shared.medications, userID: userID, name: value, nameColumn: Database.shared.medication_name, endColumn: Database.shared.medication_end, medicationCategory: "preventative")})
                
                //non-editable list fields
                sectionTitle("Security Question", width: colWidth)
                CustomTextField(bg: newBG, accent: newAcc, placeholder: "",  text: $newSQ,  width: colWidth - 15, height: 50, corner: 8, textSize: 20,  multiline: true)
                
                sectionTitle("Color Theme", width: colWidth)
                CustomDropdown(color_theme: $newTN, background: $newBG, accent: $newAcc, options: themeOptions, width: colWidth - 15, height: 50,  cornerRadius: 8, fontSize: 20)
                
                //conditionally show hex code text boxes
                if newTN == "Custom" {
                    sectionTitle("Hex Codes", width: colWidth)
                    ColorPickerTextField(
                                accent: newAcc,
                                background: newBG,
                                var_to_change: $newBG,
                                placeholder: "Enter HEX color",
                                width: colWidth-10)
                    .padding(.vertical, 15)

                    ColorPickerTextField(
                                accent: newAcc,
                                background: newBG,
                                var_to_change: $newAcc,
                                placeholder: "Enter HEX color",
                                width: colWidth - 10)
                }
            }
            .frame(maxWidth: colWidth)
            .padding(.leading, 10)
            
            //second column
            VStack {
                //triggers editable list
                sectionTitle("Triggers", width: colWidth)
                EditableList(items: $triggs, title: "Triggers", backgroundColor: newBG, accentColor: newAcc,
                     onAdd: { newTrigger in Database.shared.insertItem( table: Database.shared.triggers, userID: userID, nameColumn: Database.shared.trigger_name, name: newTrigger, startColumn: Database.shared.trigger_start, endColumn: Database.shared.trigger_end)},
                             
                    onEdit: { oldValue, newValue in Database.shared.updateItem( table: Database.shared.triggers, userID: userID,  oldValue: oldValue, newValue: newValue, nameColumn: Database.shared.trigger_name)},
                             
                    onDelete: { value in Database.shared.endItem( table: Database.shared.triggers, userID: userID, name: value, nameColumn: Database.shared.trigger_name, endColumn: Database.shared.trigger_end)} )
                
                //emerg meds editable list
                sectionTitle("Emergency Medications", width: colWidth)
                EditableList( items: $emergMeds, title: "Emergency Medications", backgroundColor: newBG, accentColor: newAcc,
                    onAdd: { newEmergencyMed in Database.shared.insertItem( table: Database.shared.medications, userID: userID, nameColumn: Database.shared.medication_name, name: newEmergencyMed, startColumn: Database.shared.medication_start, endColumn: Database.shared.medication_end,  medicationCategory: "emergency")},
                              
                    onEdit: { oldValue, newValue in Database.shared.updateItem( table: Database.shared.medications, userID: userID, oldValue: oldValue, newValue: newValue, nameColumn: Database.shared.medication_name, medicationCategory: "emergency")},
                              
                    onDelete: { value in Database.shared.endItem( table: Database.shared.medications, userID: userID, name: value, nameColumn: Database.shared.medication_name, endColumn: Database.shared.medication_end, medicationCategory: "emergency")})
                
                //non-edtiable list text field
                sectionTitle("Security Answer", width: colWidth)
                CustomTextField(bg: newBG, accent: newAcc, placeholder: "", text: $newSA, width: colWidth - 15, height: 50, corner: 8, textSize: 16)
                
                //push the changes to the database
                CustomButton( text: "Save", bg: newBG, accent: newAcc, height: 50, width: colWidth - 25, corner: 36,  bold: true, textSize: 25, action: saveProfileChanges )
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
        let colWidth = screenWidth / 2
        
        CustomText(text: "User Profile", color: newAcc, textAlign: .center, textSize: 45)
            .padding(.vertical, 50)
        
        HStack(alignment: .top) {
            //column one
            VStack {
                //display the data in a non-editable list
                section(colTitle: "Symptoms", items: symps, width: colWidth)
                section(colTitle: "Preventative Meds", items: prevMeds, width: colWidth)
                section(colTitle: "Security Question", items: [newSQ], width: colWidth)
            }
            .frame(maxWidth: colWidth)
            
            //column two
            VStack {
                //display the data in a non-editable list
                section(colTitle: "Triggers", items: triggs, width: colWidth)
                section(colTitle: "Emergency Meds", items: emergMeds, width: colWidth)
                section(colTitle: "Color Theme", items: [themeName], width: colWidth)
                
                //options button
                HStack {
                    Spacer()
                    let buttonActions: [() -> Void] = [ { isEditing = true },  { showPolicy = true },  { logOut = true },  { showDelete = true } ]
                    
                    CustomFloatButton( accent: newAcc,  background: newBG,  options: buttonNames, actions: buttonActions)
                        .padding(.top, 20)
                    .fullScreenCover(isPresented: $showPolicy) {
                        PolicySheetView(policyFileName: "DataPolicy", showsAgreeButton: false)
                    }
                    .padding(.trailing, 10)
                }
            }
            .frame(maxWidth: colWidth)
        }
    }
    
    //Break repetive code into reusable sections
    private func sectionTitle(_ title: String, width: CGFloat) -> some View {
        CustomText(text: title, color: newAcc, width: width - 15, textAlign: .center, multiAlign: .center, bold: true)
    }
    
    private func section(colTitle: String, items: [String], width: CGFloat) -> some View {
            VStack {
                sectionTitle(colTitle, width: width)
                CustomList(items: items, color: newAcc)
            }
    }
    
    private func saveProfileChanges() {
        if sQ != newSQ {
            Database.shared.updateUser(userID: userID, newValue: newSQ, column: "security_question")
        }
        
        let normSA = Database.normalize(newSA)
        let hashedSA = Database.hashString(normSA)
        if hashedSA != sA {
            Database.shared.updateUser(userID: userID, newValue: hashedSA, column: "security_answer")
        }
        
        if bg != newBG {
            Database.shared.updateUser(userID: userID, newValue: newBG, column: "background_color")
            bg = newBG
            themeName = Database.getThemeName(background: newBG, accent: newAcc)
            newTN = themeName.contains("Custom") ? "Custom" : themeName
        }
        
        if accent != newAcc {
            Database.shared.updateUser(userID: userID, newValue: newAcc, column: "accent_color")
            accent = newAcc
        }
        isEditing = false
    }
}

#Preview {
    ProfileView(userID: 1, bg: .constant("#001d00"), accent: .constant("#b5c4b9"))
}
