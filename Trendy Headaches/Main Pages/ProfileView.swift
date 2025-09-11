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
                ZStack {
                    //full width blob
                    //color symetrical slight wave blobs
                    SameAmplitudeBlob(waves: 10, amplitude: 20, accent:accentColor, x:140, y: -280, rotation: 0)
                    SameAmplitudeBlob(waves: 10, amplitude:20, accent:accentColor, x:200, y: -250, rotation: 170)
                    
                    ScrollView{
                        
                        VStack {
                            
                            CustomWelcome(text: "User Profile", color: accentColor, textAlignment: .leading, width: 150)
                                .padding(.trailing, 160)
                                .padding(.top, 20)
                                .padding(.bottom, 10)
                            
                            if isEditing {
                                TextField("Name", text: $name)
                                    .textFieldStyle(CustomTextField(background: backgroundColor, accent: accentColor, width: 160))
                            } else {
                                HStack(alignment: .top) {
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
                                }
                                .frame(maxWidth: 375, alignment: .center)
                                .padding(.bottom, 20)
                                
                                HStack(alignment: .top) {
                                    VStack {
                                        CustomListHeader(text: "Preventative Meds", color: accentColor)
                                        if prevMeds.isEmpty {
                                            CustomList(items: ["No current preventative meds entered"], color: accentColor)
                                        } else {
                                            CustomList(items: prevMeds, color: accentColor)
                                        }
                                    }
                                    VStack {
                                        CustomListHeader(text: "Emergency Meds", color: accentColor)
                                        if emergencyMeds.isEmpty {
                                            CustomList(items: ["No current emergency meds entered"], color: accentColor)
                                        } else {
                                            CustomList(items: emergencyMeds, color: accentColor)
                                        }
                                    }
                                }
                                .frame(maxWidth: 375, alignment: .center)
                                .padding(.bottom, 20)
                                
                                HStack(alignment: .top) {
                                    VStack {
                                        CustomListHeader(text: "Security Question", color: accentColor)
                                        CustomList(items: [securityQuestion], color: accentColor)
                                    }
                                    VStack {
                                        CustomListHeader(text: "Theme", color: accentColor)
                                            .padding(.bottom, 15)
                                            .padding(.top, 15)
                                        CustomList(items: [themeName], color: accentColor)
                                    }
                                }
                                .frame(maxWidth: 375, alignment: .center)
                                .padding(.bottom, 30)
                                
                                CustomFloatButton(accent: accentColor, background: backgroundColor)
                                    .padding(.leading, 150)
                                    .padding(.top, 25)
                            }
                        }
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

#Preview {
    ProfileView(userID: 2, backgroundColor: "#001d00", accentColor: "#b5c4b9")
}
