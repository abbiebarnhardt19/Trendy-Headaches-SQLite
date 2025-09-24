//
//  LogView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/31/25.
//

import SwiftUI
import Foundation

struct LogView: View {
    var userID: Int64
    @Binding var background: String
    @Binding var accent: String
    
    let leading_padding = CGFloat(40)
    @State private var string_date: String = ""
    @State private var date_date: Date = Date()
    @State private var dateCheckTask: Task<Void, Never>? = nil
    @State private var dateFormatCorrect: Bool = true
    @State private var dateValid: Bool = true
    @State var onset: String?
    @State var onsetOptions: [String] = ["From Wake", "Morning", "Afternoon", "Evening"]
    @State var symptom: String?
    @State var symptomOptions: [String] = []
    @State var medTaken: Bool = false
    @State var medTakenOptions: [String] = ["Yes", "No"]
    @State private var severity: Int64 = 0
    @State private var symptom_desc: String = ""
    @State private var notes: String = ""
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
    @State private var toggleText = ""
    @State private var triggerOptions : [String] = []
    @State private var selectedTriggers: [String] = []
    @State private var symptomLogViewShown = true
    
    @State private var triggerIDs: [Int64] = []
    @State private var symptomID: Int64 = 0
    
    @State private var logID: Int64? = 0
    
    @State private var hasSubmitted: Bool = false
    
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        return f
    }()
    
    func isDateInValidFormat(_ input: String) -> Bool {
        let pattern = #"^\d{1,2}[-/]\d{1,2}[-/](\d{2}|\d{4})$"#
        return input.range(of: pattern, options: .regularExpression) != nil
    }
    
    var body: some View {
        var header: String {
            symptomLogViewShown ?  "Symptom Log":"Side Effect Log"
        }
        NavigationStack{
            ZStack {
                // Background color
                Color(hex: background).ignoresSafeArea()
                if hasSubmitted {
                    // Show your list view here
                    ListView(userID: userID, background: $background, accent: $accent, logID: logID ?? 0)
                }
                else{
                    
                    WavyTopBottomRectangle(waves: 10, amplitude:6, accent:accent, x:0, y:-580, width:screenWidth, height: 400)
                        .zIndex(1)
                    WavyTopBottomRectangle(waves:10, amplitude:6, accent:accent, x:0, y:525, width:screenWidth, height: 400)
                        .zIndex(1)
                    
                    ScrollView{
                        HStack {
                            CustomText( text: header, color: accent, textAlignment: .center,  textSize: 43)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.trailing, 10)
                            
                            CustomToggle(color: accent, feature: $symptomLogViewShown)
                                .padding(.trailing, leading_padding)
                                .padding(.top, 7)
                        }
                        .frame(width: screenWidth)
                        .padding(.top, 20)
                        
                        if symptomLogViewShown{
                            symptomLogView()
                        }
                        else{
                            sideEffectLogView()
                        }
                    }
                    .padding(.leading, leading_padding)
                    
                    // Nav bar overlay at bottom
                    VStack {
                        Spacer()
                        NavBarView(userID: userID, background: $background, accent: $accent)
                    }
                    .zIndex(1)
                    .ignoresSafeArea(edges: .bottom)
                }
            }
        }
        .onAppear{
            string_date = formatter.string(from: Date())
            date_date = formatter.date(from: string_date) ?? Date()
            
            symptomOptions = DatabaseManager.shared.getForeignKeyColumnValues(userId: userID, tableName: "symptoms", columnName: "symptom_name")
            
            triggerOptions = DatabaseManager.shared.getForeignKeyColumnValues(userId: userID, tableName: "triggers", columnName: "trigger_name")
            
            triggerOptions = DatabaseManager.deleteListDuplicates(list: triggerOptions)
        }
    }
    @ViewBuilder
    private func symptomLogView() -> some View {
        VStack{
            HStack{
                VStack {
                    CustomText(text: "Date:", color: accent, isBold: true, textSize: 24)
                        .frame(width: 70, height: 45, alignment: .center)
                }
                
                VStack(alignment: .center) {
                    CustomTextField(background: background, accent: accent, placeholder: "", text: $string_date, width: 140, height: 45,  textSize: 22)
                        .onChange(of: string_date) {
                            dateCheckTask?.cancel()
                            dateCheckTask = Task {
                                try? await Task.sleep(nanoseconds: 500_000_000)
                                if !Task.isCancelled {
                                    dateFormatCorrect = isDateInValidFormat(string_date)
                                }
                            }
                        }
                    }
                
                    VStack{
                        CustomWarningText(text: dateFormatCorrect ? " " : "Invalid format")
                            .frame(width:40, height: 50, alignment: .center)
                            .padding(.leading, 40)
                    }
                    Spacer()
                }
                
                CustomText(text: "Symptom Onset", color: accent, isBold: true, textSize: 24)
                MultipleChoiceButtonGroup(options: $onsetOptions, selected: $onset, accent: accent)
                
                CustomText(text: "Symptom", color: accent, isBold: true, textSize: 24)
                MultipleChoiceButtonGroup(options: $symptomOptions, selected: $symptom, accent: accent)
                
                CustomText(text: "Symptom Severity", color: accent, isBold: true, textSize: 24)
                StepSlider(value: $severity, range: 1...10, step: 1, accentColor: accent, width: screenWidth - 50)
                .padding(.trailing, leading_padding)
                
                CustomSingleCheckbox(text: "Emergency Med Taken?", color: accent, isOn: $medTaken)
                    .padding(.trailing, leading_padding)
                
                CustomText(text: "Triggers Present", color: accent, isBold: true, textSize: 24)
                MultipleChoiceCheckboxGroup(options: $triggerOptions, selected: $selectedTriggers, accent: accent, background : background)
                
                CustomText(text: "Symptom Description", color: accent, isBold: true, textSize: 24)
                CustomTextField(background: background, accent:accent, placeholder: "", text: $symptom_desc, width: screenWidth-50, height: 45, textSize: 20, isMultiline: true)
                    .padding(.trailing, leading_padding + 20)
                
                CustomText(text: " Notes", color: accent, isBold: true, textSize: 24)
                CustomTextField(background: background, accent:accent, placeholder: "", text: $notes, width: screenWidth-50, height: 45, textSize: 20, isMultiline: true)
                    .padding(.trailing, leading_padding + 20)
            
            CustomButton(text: "Submit", background: background, accent: accent, action: {
                    print("Submit Log")
                symptomID = DatabaseManager.shared
                    .getIDFromName(tableName: "symptoms", names: [symptom ?? ""], userID: userID)
                    .first ?? 0

                    triggerIDs = DatabaseManager.shared.getIDFromName(tableName: "triggers", names: selectedTriggers , userID: userID)
                
                let enteredDate = formatter.date(from: string_date) ?? Date()

                // Use current date/time for submit
                let currentDateTime = Date()

                // Create log
                logID = DatabaseManager.shared.createLog(
                    userID: userID,
                    date: enteredDate,
                    symptom_onset: onset ?? "",
                    symptom: symptomID,
                    severity: severity,
                    med_taken: medTaken,
                    symptom_desc: symptom_desc,
                    notes: notes,
                    submit: currentDateTime,  // <-- current timestamp
                    triggerIDs: triggerIDs
                )
                
                hasSubmitted = true
            })

            .padding(.trailing, leading_padding)
            .padding(.top, 10)
            }
            .padding(.bottom, 100)
    }
    
    @ViewBuilder
    private func sideEffectLogView() -> some View {
        CustomText(text: "test", color: accent)
    }
}

#Preview {
    LogView(userID: 1, background: .constant("#001d00"), accent: .constant("#b5c4b9"))
}
