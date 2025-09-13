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
    @State private var themeName: String = ""
    @State private var logOut = false
    @State private var showPolicy = false
    @State private var showDeleteConfirmation = false
    
    
    let buttonNames = ["Edit Profile", "View Data Policy", "Sign Out", "Delete Account"]
    
    var body: some View {
                    ZStack {
                        Color(hex: backgroundColor).ignoresSafeArea()
                        
                        // Decorative blobs
                        SameAmplitudeBlob(waves: 10, amplitude: 20, accent: accentColor, x: 160, y: -270, rotation: -10)
                        SameAmplitudeBlob(waves: 10, amplitude: 20, accent: accentColor, x: 170, y: -180, rotation: 175)
                        
                        ScrollView {
                            VStack {
                                if isEditing {
                                    TextField("Name", text: $name)
                                        .textFieldStyle(CustomTextField(background: backgroundColor, accent: accentColor, width: 160))
                                    CustomButton(text: "Save", background: backgroundColor, accent: accentColor) {
                                        isEditing = false
                                    }
                                } else {
                                    let screenWidth = UIScreen.main.bounds.width
                                    let columnWidth = screenWidth / 2 - 10
                                    
                                    HStack(alignment: .top) {
                                        // Left column
                                        VStack {
                                            CustomWelcome(text: "User Profile", color: accentColor, textAlignment: .leading, width: 150)
                                            
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
                                            .sheet(isPresented: $showPolicy) {
                                                PolicySheetView(
                                                    policyFileName: "DataPolicy",
                                                    showsAgreeButton: false // Or true if you want "Agree"
                                                )
                                            }
                                        }
                                        .frame(maxWidth: columnWidth, alignment: .center)
                                        .padding(.top, 95)
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
                        
                        themeName = DatabaseManager.getThemeName(selected_background: backgroundColor, selected_accent: accentColor)
                }
                

    }
}

#Preview {
    ProfileView(userID: 3, backgroundColor: "#001d00", accentColor: "#b5c4b9")
}
