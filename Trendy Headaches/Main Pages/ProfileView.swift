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
    
    var body: some View {
        VStack(spacing: 20) {
            
            CustomText(text: "Symptoms/Illnesses", color: accentColor)
            
            if isEditing {
                TextField("Name", text: $name)
                    .textFieldStyle(CustomTextField(background: backgroundColor, accent: accentColor))
            } else {
                if symptoms.isEmpty {
                    CustomText(text:"No symptoms or illnesses entered yet", color:accentColor)
                        .foregroundColor(.red)
                } else {
                    ForEach(symptoms, id: \.self) { symptom in
                        CustomList(text:"• \(symptom)", color: accentColor)
                    }
                }
            }
            
            CustomButton(
                text: isEditing ? "Save" : "Edit",
                background: accentColor,
                accent: backgroundColor
            ) {
                isEditing.toggle()
                // Optionally save the updated name to database here
            }
            
        }
        .padding()
        .CustomView(color: backgroundColor)
        .onAppear {
            // Only load once to avoid duplicates
            guard !hasLoadedSymptoms else { return }
            hasLoadedSymptoms = true
            
            // Fetch symptoms from database
            symptoms = DatabaseManager.shared.getSymptoms(forUserId: userID)
        }
    }
}

#Preview {
    ProfileView(userID: 1, backgroundColor: "#001d00", accentColor: "#b5c4b9")
}
