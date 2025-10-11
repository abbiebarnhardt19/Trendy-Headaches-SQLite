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
    var existingLogID: Int64? = nil
    var existingLogTable: String? = nil
    @Binding var background: String
    @Binding var accent: String
    
    // Layout
    private let leadingPadding: CGFloat = 40
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
    
    // Shared State
    @State private var symptomLogViewShown = true
    @State private var logID: Int64 = 0
    @State private var showEmergencyPopup: Bool = false
    @State private var date: Date = Date()
    
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
    @State private var emergencyMedOptions: [String] = []
    @State private var medTakenName: String?
    @State private var symptomDesc: String = ""
    @State private var notes: String = ""
    @State private var triggerOptions: [String] = []
    @State private var selectedTriggers: [String] = []
    @State private var symptomID: Int64 = 0
    @State private var triggerIDs: [Int64] = []
    @State private var emergencyMedID: Int64? = nil
    
    //  Side Effect Log variables
    @State private var sideEffectDate: String = ""
    @State private var sideEffectName: String = ""
    @State private var sideEffectSeverity: Int64 = 0
    @State private var medicationOptions: [String] = []
    @State private var selectedMedication: String?
    @State private var medicationID: Int64 = 0
    
    //for med popup
    @State private var medWorked: Bool? = nil
    @State private var oldLogIDs: [Int64] = [0]
    
    //for log editing
    @State private var medEffective: Bool = false
    
    @State private var goToListView = false
    
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

    
    //  Body
    var body: some View {
        
        NavigationStack {
            ZStack {
                LogBGComps(background: background, accent: accent)
                
                if showEmergencyPopup, !oldLogIDs.isEmpty {
                    EmergencyMedPopup(selectedAnswer: $medWorked, isPresented: $showEmergencyPopup,  oldLogID: oldLogIDs[0],  background: background, accent: accent)
                    .zIndex(5)
                    .onDisappear {
                        // When the popup closes, remove the first ID
                        if !oldLogIDs.isEmpty {
                            medWorked = nil
                            oldLogIDs.removeFirst()
                            
                            // If there are more, show the next one
                            if !oldLogIDs.isEmpty {
                                showEmergencyPopup = true
                            }
                        }
                    }
                }
                
                
                ScrollView {
                    headerSection
                        .padding(.top, 20)
                        .frame(width: screenWidth)
                    
                    if symptomLogViewShown {
                        symptomLogView
                    } else {
                        sideEffectLogView
                    }
                }
                .padding(.leading, leadingPadding)
                
                VStack { Spacer(); NavBarView(userID: userID, background: $background, accent: $accent, selectedIndex: .constant(0)) }
                    .zIndex(1)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .onAppear {
            setupData()
            let results = Database.shared.emergencyMedPopup(userID: userID)
            if !results.isEmpty {
                oldLogIDs = results
                showEmergencyPopup = true
            }
        }
    }
    
    //  Subviews
    
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
                    MultipleChoiceButtonGroup(options: $emergencyMedOptions, selected: $medTakenName, accent: accent)
                        
                    
                    if existingLogID != nil{
                        CustomSingleCheckbox(text: "Emergency Med Effective?", color: accent, isOn: $medEffective )
                    }
                }
                
                CustomText(text: "Triggers Present", color: accent, isBold: true, textSize: 24)
                MultipleChoiceCheckboxGroup(options: $triggerOptions, selected: $selectedTriggers, accent: accent, background: background, width: screenWidth-100)
                    .padding(.leading, 5)
                
                textFieldSection(title: "Symptom Description", text: $symptomDesc)
                textFieldSection(title: "Notes", text: $notes)
                
                // Inside your symptom log view
                HStack{
                    Spacer()
                    
                    let buttonText = existingLogID != nil ? "Submit" : "Save"

                    CustomButton(
                        text: buttonText,
                        background: background,
                        accent: accent,
                        height: 50,
                        width: 150
                    ) {
                        if existingLogID == nil{
                            submitSymptomLog()
                        }
                        else{
                             if medTakenName != nil && medTakenName != ""{
                                emergencyMedID = Database.shared.getIDFromName(tableName: "medications", names: [medTakenName ?? ""], userID: userID).first
                            }
                            else{
                                emergencyMedID=nil
                            }
                            
                            Database.shared.updateSymptomLog(logID: existingLogID ?? 0, userID: userID, date: date, onsetTime: onset, severity: severity, symptomID: symptomID, medTaken: medTaken, medicationID: emergencyMedID, medWorked: medEffective, symptomDescription: symptomDesc, notes: notes, triggerIDs: triggerIDs)
                        }// call your function first
                        goToListView = true  // then trigger navigation
                    }
                    .disabled(!formValid)
                    .padding(.trailing, 40)
                    // Navigation destination
                    .navigationDestination(isPresented: $goToListView) {
                        ListView(userID: userID, background: $background, accent: $accent)
                    }
                    Spacer()
                }
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
            
            HStack{
                Spacer()
                
                let buttonText = existingLogID != nil ? "Submit" : "Save"

                CustomButton(
                    text: buttonText,
                    background: background,
                    accent: accent,
                    height: 50,
                    width: 150
                ) {
                    if existingLogID == nil{
                        submitSideEffectLog()
                    }
                    else{
                        Database.shared.updateSideEffectLog(logID: existingLogID ?? 0, userID: userID, date: date, sideEffectName: sideEffectName, sideEffectSeverity: sideEffectSeverity, medicationID: medicationID)
                    }// call your function first
                    goToListView = true  // then trigger navigation
                }
                .disabled(!formValid)
                .padding(.trailing, 40)
                // Navigation destination
                .navigationDestination(isPresented: $goToListView) {
                    ListView(userID: userID, background: $background, accent: $accent)
                }
                Spacer()
            }
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
    
    
    //Functions
    
    //get profile data to fill mutliple choice options
    private func setupData() {
        //get the current date
        stringDate = formatter.string(from: Date())
        sideEffectDate = formatter.string(from: Date())
        
        //get data from database
        symptomOptions = Database.shared.getForeignKeyColumnValues(userId: userID, tableName: "symptoms", columnName: "symptom_name")
        triggerOptions = Database.deleteListDuplicates(list: Database.shared.getForeignKeyColumnValues(userId: userID, tableName: "triggers", columnName: "trigger_name"))
        medicationOptions = Database.shared.getForeignKeyColumnValues(userId: userID, tableName: "medications", columnName: "medication_name")
        
        emergencyMedOptions = Database.shared.getForeignKeyColumnValues(userId: userID, tableName: "medications", columnName: "medication_name", filterColumn: "medication_category", filterValue: "emergency")
        
        if let existingLogID = existingLogID {
            if let log = Database.shared.getUnifiedLog(by: existingLogID, logType: existingLogTable ?? "") {
                
                if log.log_type == "Symptom" {
                    severity = log.severity
                    symptomDesc = log.symptom_description ?? ""
                    notes = log.notes ?? ""
                    onset = log.onset_time ?? ""
                    medTaken = log.med_taken ?? false
                    date = log.date
                    stringDate = formatter.string(from: date)
                    symptom = log.symptom_name
                    symptomID = log.symptom_id ?? 0
                    medTakenName = log.medication_name ?? ""
                    emergencyMedID = log.medication_id ?? 0
                    selectedTriggers = log.trigger_names ?? []
                    triggerIDs = log.trigger_ids ?? []
                    medEffective = log.med_worked ?? false
                    symptomLogViewShown = true

                } else if log.log_type == "SideEffect" {
                    sideEffectDate = formatter.string(from: log.date)
                    sideEffectName = log.side_effect_med ?? ""
                    sideEffectSeverity = log.severity
                    selectedMedication = log.medication_name ?? ""
                    medicationID = log.medication_id ?? 0

                    symptomLogViewShown = false
                }

            } else {
                notes = "test"
            }
        }

    }
    
    //function to add the log to the database
    private func submitSymptomLog(){
            //get the symptoms and triggers from the names
            symptomID = Database.shared.getIDFromName(tableName: "symptoms", names: [symptom ?? ""], userID: userID).first ?? 0
            
            triggerIDs = Database.shared.getIDFromName(tableName: "triggers", names: selectedTriggers, userID: userID)
            
        if medTakenName != ""{
            emergencyMedID = Database.shared.getIDFromName(tableName: "medications", names: [medTakenName ?? ""], userID: userID).first
        }
            
            //convert the date from string format
            let enteredDate = formatter.date(from: stringDate) ?? Date()
            
            //add log to database
            logID = Database.shared.createLog(userID: userID,  date: enteredDate, symptom_onset: onset ?? "", symptom: symptomID, severity: severity, med_taken: medTaken, med_taken_id: emergencyMedID, symptom_desc: symptomDesc, notes: notes, submit: Date(), triggerIDs: triggerIDs) ?? 0
    }
    
    //function to add the side effect to the database
    private func submitSideEffectLog() {
        //get the medication ID from the name
        medicationID = Database.shared.getIDFromName(tableName: "medications", names: [selectedMedication ?? ""], userID: userID).first ?? 0
       
        //convert the date from a string
        let enteredDate = formatter.date(from: sideEffectDate) ?? Date()
        
        //add it to the database
        logID = Database.shared.createSideEffectLog(userID: userID, date: enteredDate, submit_time: Date(), side_effect: sideEffectName, side_effect_severity: sideEffectSeverity, medication_id: medicationID) ?? 0 
    }
}

#Preview {
    LogView(userID: 1, background: .constant("#001d00"), accent: .constant("#b5c4b9"))
}
