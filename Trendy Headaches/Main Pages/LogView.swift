//
//  LogView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/31/25.
//

import SwiftUI
import Foundation

struct LogView: View {
    //  Inputs
    var userID: Int64
    @Binding var background: String
    @Binding var accent: String
    
    // Layout
    private let leadingPadding: CGFloat = 40
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
    
    // Shared State
    @State private var hasSubmitted: Bool = false
    @State private var symptomLogViewShown = true
    @State private var logID: Int64?
    
    //  Symptom Log variables
    @State private var stringDate: String = ""
    @State private var dateCheckTask: Task<Void, Never>? = nil
    @State private var dateFormatCorrect = true
    @State private var onset: String?
    @State private var onsetOptions: [String] = ["From Wake", "Morning", "Afternoon", "Evening"]
    @State private var symptom: String?
    @State private var symptomOptions: [String] = []
    @State private var severity: Int64 = 0
    @State private var medTaken: Bool = false
    @State private var medTakenName: String?
    @State private var symptomDesc: String = ""
    @State private var notes: String = ""
    @State private var triggerOptions: [String] = []
    @State private var selectedTriggers: [String] = []
    @State private var symptomID: Int64 = 0
    @State private var triggerIDs: [Int64] = []
    @State private var emergencyMedID: Int64 = 0
    
    //  Side Effect Log variables
    @State private var sideEffectDate: String = ""
    @State private var sideEffectName: String = ""
    @State private var sideEffectSeverity: Int64 = 0
    @State private var medicationOptions: [String] = []
    @State private var selectedMedication: String?
    @State private var medicationID: Int64 = 0
    
    @State private var date: Date = Date()
    @State private var medWorked: String? = " "
    @State private var medWorkedOptions: [String] = ["Yes", "No"]
    @State private var oldSymptomName: String = ""
    @State private var oldLogDate: Date = Date()
    @State private var showEmergencyPopup: Bool = false
    
    // Date Formatter
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()
    
    private var formValid: Bool {
        if symptomLogViewShown {
            // Base condition for symptom log
            var isValid = symptom != nil && severity > 0
            
            // Extra check: if medTaken is true, require medTakenName
            if medTaken {
                isValid = isValid && !(medTakenName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
            }
            
            return isValid
        } else {
            // Side effect log condition
            return !sideEffectName.isEmpty && sideEffectSeverity > 0 && selectedMedication != nil
        }
    }


    
    // Date Formatting Function
//    private func isDateInValidFormat(_ input: String) -> Bool {
//        let pattern = #"^\d{1,2}[-/]\d{1,2}[-/](\d{2}|\d{4})$"#
//        return input.range(of: pattern, options: .regularExpression) != nil
//    }
    
    //  Body
    var body: some View {
        
        NavigationStack {
            ZStack {
                Color(hex: background).ignoresSafeArea()
                
                if showEmergencyPopup{
                    EmergencyMedPopup(selectedAnswer: $medWorked, options: $medWorkedOptions, isPresented: $showEmergencyPopup, date: oldLogDate, symptom: oldSymptomName, background: background, accent: accent)
                        .zIndex(5)
                }
                
                
                if hasSubmitted {
                    ListView(userID: userID, background: $background, accent: $accent, logID: logID ?? 0)
                } else {
                    backgroundWaves
                    ScrollView {
                        headerSection
                            .padding(.top, 30)
                            .frame(width: screenWidth)
                        
                        if symptomLogViewShown {
                            symptomLogView
                        } else {
                            sideEffectLogView
                        }
                    }
                    .padding(.leading, leadingPadding)
                    
                    VStack { Spacer(); NavBarView(userID: userID, background: $background, accent: $accent) }
                        .zIndex(1)
                        .ignoresSafeArea(edges: .bottom)
                }
            }
        }
        .onAppear {
            setupData()
            let results = DatabaseManager.shared.emergencyMedPopup(userID: userID)
            if let first = results.first {
                oldLogDate = first.0
                oldSymptomName = first.1
                showEmergencyPopup = true
            }
        }
    }
    
    //  Subviews
    
    //waves
    private var backgroundWaves: some View {
        Group {
            WavyTopBottomRectangle(waves: 10, amplitude: 6, accent: accent, x: 0, y: -580, width: screenWidth, height: 400)
                .zIndex(1)
            WavyTopBottomRectangle(waves: 10, amplitude: 6, accent: accent, x: 0, y: 515, width: screenWidth, height: 400)
                .zIndex(1)
        }
    }
    
    //header and toggle
    private var headerSection: some View {
        HStack {
            CustomText(text: symptomLogViewShown ? "Symptom Log" : "Side Effect Log",
                       color: accent,
                       textAlignment: .center,
                       textSize: 43)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.trailing, 10)
            
            CustomToggle(color: accent, feature: $symptomLogViewShown)
                .padding(.trailing, leadingPadding)
                .padding(.top, 7)
        }
    }
    
    //symptom log view
    private var symptomLogView: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 16) {
                dateField(label: "Date:", text: $stringDate)
                
                CustomText(text: "Symptom*", color: accent, isBold: true, textSize: 24)
                MultipleChoiceButtonGroup(options: $symptomOptions, selected: $symptom, accent: accent)
                
                CustomText(text: "Symptom Severity*", color: accent, isBold: true, textSize: 24)
                StepSlider(value: $severity, range: 1...10, step: 1, accentColor: accent, width: screenWidth - 50)

                CustomText(text: "Symptom Onset", color: accent, isBold: true, textSize: 24)
                MultipleChoiceButtonGroup(options: $onsetOptions, selected: $onset, accent: accent)
                

                
                CustomSingleCheckbox(text: "Emergency Med Taken?", color: accent, isOn: $medTaken)
                
                if medTaken{
                    CustomText(text: "Emergency Med Name*", color: accent, isBold: true, textSize: 24)
                    MultipleChoiceButtonGroup(options: $medicationOptions, selected: $medTakenName, accent: accent)
                }
                
                CustomText(text: "Triggers Present", color: accent, isBold: true, textSize: 24)
                MultipleChoiceCheckboxGroup(options: $triggerOptions, selected: $selectedTriggers, accent: accent, background: background)
                
                textFieldSection(title: "Symptom Description", text: $symptomDesc)
                textFieldSection(title: "Notes", text: $notes)
                
                submitButton {
                    submitSymptomLog()
                }
                .disabled(!formValid)
            }
            .padding(.bottom, 100)
        }
    }

    
    //side effect log
    private var sideEffectLogView: some View {
        VStack(alignment: .leading, spacing: 16) {
            dateField(label: "Date:", text: $sideEffectDate)
            
            textFieldSection(title: "Side Effect*", text: $sideEffectName)
            
            CustomText(text: "Side Effect Severity*", color: accent, isBold: true, textSize: 24)
            StepSlider(value: $sideEffectSeverity, range: 1...10, step: 1, accentColor: accent, width: screenWidth - 50)
            
            CustomText(text: "Medication*", color: accent, isBold: true, textSize: 24)
            MultipleChoiceButtonGroup(options: $medicationOptions, selected: $selectedMedication, accent: accent)
            
            submitButton {
                submitSideEffectLog()
            }
            .disabled(!formValid)
        }
    }
    
    // Components
    
    //date field, which is reused for both views
    private func dateField(label: String, text: Binding<String>) -> some View {
        HStack {
            DatePickerTextFieldDropdown(selectedDate: $date,  textFieldValue: $stringDate, background: $background, accent: $accent)
        }
    }
    
    //text field, which is reused in both views
    private func textFieldSection(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            CustomText(text: title, color: accent, isBold: true, textSize: 24)
            CustomTextField(background: background, accent: accent, placeholder: "", text: text, width: screenWidth - 50, height: 45, textSize: 20, isMultiline: true)
                .padding(.trailing, leadingPadding + 20)
        }
    }
    
    private func submitButton(action: @escaping () -> Void) -> some View {
        HStack{
            Spacer()
            CustomButton(text: "Submit", background: background, accent: accent, action: action)
                .padding(.top, 10)
                .padding(.trailing, leadingPadding)
            Spacer()
        }
    }
    
    //Functions
    
    //get profile data to fill mutliple choice options
    private func setupData() {
        //get the current date
        stringDate = formatter.string(from: Date())
        sideEffectDate = stringDate
        
        //get data from database
        symptomOptions = DatabaseManager.shared.getForeignKeyColumnValues(userId: userID, tableName: "symptoms", columnName: "symptom_name")
        triggerOptions = DatabaseManager.deleteListDuplicates(list: DatabaseManager.shared.getForeignKeyColumnValues(userId: userID, tableName: "triggers", columnName: "trigger_name"))
        medicationOptions = DatabaseManager.shared.getForeignKeyColumnValues(userId: userID, tableName: "medications", columnName: "medication_name")
    }
    
    //function to add the log to the database
    private func submitSymptomLog() {
        //get the symptoms and triggers from the names
        symptomID = DatabaseManager.shared.getIDFromName(tableName: "symptoms", names: [symptom ?? ""], userID: userID).first ?? 0
        
        triggerIDs = DatabaseManager.shared.getIDFromName(tableName: "triggers", names: selectedTriggers, userID: userID)
        
        emergencyMedID = DatabaseManager.shared.getIDFromName(tableName: "medications", names: [medTakenName ?? ""], userID: userID).first ?? 0
        
        //convert the date from string format
        let enteredDate = formatter.date(from: stringDate) ?? Date()
        
        //add log to database
        logID = DatabaseManager.shared.createLog(userID: userID,  date: enteredDate, symptom_onset: onset ?? "", symptom: symptomID, severity: severity, med_taken: medTaken, med_taken_id: emergencyMedID, symptom_desc: symptomDesc, notes: notes, submit: Date(), triggerIDs: triggerIDs)
        
        //change value to change to list view
        hasSubmitted = true
    }
    
    //function to add the side effect to the database
    private func submitSideEffectLog() {
        //get the medication ID from the name
        medicationID = DatabaseManager.shared.getIDFromName(tableName: "medication", names: [selectedMedication ?? ""], userID: userID).first ?? 0
       
        //convert the date from a string
        let enteredDate = formatter.date(from: sideEffectDate) ?? Date()
        
        //add it to the database
        logID = DatabaseManager.shared.createSideEffectLog(userID: userID, date: enteredDate, side_effect: sideEffectName, side_effect_severity: sideEffectSeverity, medication_id: medicationID)
        
        //change value to navigate to the list page
        hasSubmitted = true
    }
}

#Preview {
    LogView(userID: 1, background: .constant("#001d00"), accent: .constant("#b5c4b9"))
}
