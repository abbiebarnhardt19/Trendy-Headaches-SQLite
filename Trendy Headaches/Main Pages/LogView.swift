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
    @Binding var backgroundColor: String
    @Binding var accentColor: String
    
    let leading_padding = CGFloat(70)
    @State private var string_date: String = ""
    @State private var date_date: Date = Date()
    @State private var dateCheckTask: Task<Void, Never>? = nil
    @State private var dateFormatCorrect: Bool = true
    @State private var dateValid: Bool = true
    
    @State var onset: String?
    @State var onsetOptions: [String] = ["From Wake", "Morning", "Afternoon", "Evening"]
    
    @State var symptom: String?
    @State var symptomOptions: [String] = []
    
    @State var medTaken: String?
    @State var medTakenOptions: [String] = ["Yes", "No"]
    
    @State private var sliderValue: Double = 0.0
    
    @State private var symptom_desc: String = ""
    @State private var notes: String = ""
    
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
    
    @State private var symptomLogViewShown = true
    @State private var toggleText = ""
    
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
        ZStack {
            // Background color
            Color(hex: backgroundColor).ignoresSafeArea()
            
            WavyTopBottomRectangle(waves: 10, amplitude:8, accent:accentColor, x:0, y:-615, width:screenWidth, height: 400)
                .zIndex(0)
            WavyTopBottomRectangle(waves: 10, amplitude:8, accent:accentColor, x:0, y:525, width:screenWidth, height: 400)
                .zIndex(0)
            
            CustomButton(text: "test", background: backgroundColor, accent: accentColor){
                symptomLogViewShown.toggle()
            }
            .zIndex(1)
            
            if symptomLogViewShown{
                symptomLogView()
            }
            else{
                sideEffectLogView()
            }

            // Nav bar overlay at bottom
            VStack {
                Spacer()
                NavBarView(userID: userID, backgroundColor: $backgroundColor, accentColor: $accentColor)
                    .frame(height: 60)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .zIndex(1)
            .ignoresSafeArea(edges: .bottom)
        }
        .onAppear{
            string_date = formatter.string(from: Date())
            date_date = formatter.date(from: string_date) ?? Date()
            
            symptomOptions = DatabaseManager.shared.getForeignKeyColumnValues(userId: userID, tableName: "symptoms", columnName: "symptom_name")
        }
    }
    @ViewBuilder
    private func symptomLogView() -> some View {
        ScrollView{
            VStack {
                HStack{
                    CustomText(text:"Log Symptom", color: accentColor,  width: screenWidth, textAlignment: .center, multilineAlignment: .center, textSize:50)
                        .padding(.bottom, 20)
                        .padding(.leading, 20)
                    Spacer()
                }
                
                VStack{
                    HStack(alignment: .top) {
                        VStack(alignment: .center){
                            CustomText(text: "Date:", color: accentColor, textSize: 28)
                                .frame(width: 70)
                        }
                        .frame(height:50)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            CustomTextField(background: backgroundColor,
                                            accent: accentColor,
                                            placeholder: "",
                                            text: $string_date,
                                            width: 140,
                                            height: 50,
                                            textSize: 22)
                            .onChange(of: string_date) {
                                dateCheckTask?.cancel()
                                dateCheckTask = Task {
                                    try? await Task.sleep(nanoseconds: 500_000_000)
                                    if !Task.isCancelled {
                                        dateFormatCorrect = isDateInValidFormat(string_date)
                                    }
                                }
                            }
                            
                            if !dateFormatCorrect {
                                CustomWarningText(text: "Invalid date format")
                            } else {
                                CustomWarningText(text: " ")
                            }
                        }
                        .frame(width: screenWidth - 40, alignment: .leading)
                    }
                    
                    CustomText(text: "Symptom Onset", color: accentColor, textSize: 28)
                    
                    MultipleChoiceButtonGroup(options: $onsetOptions, selectedOption: $onset, accentColor: accentColor)
                    
                    CustomText(text: "Symptom", color: accentColor, textSize: 28)
                    
                    MultipleChoiceButtonGroup(options: $symptomOptions, selectedOption: $symptom, accentColor: accentColor)
                    
                    CustomText(text: "Symptom Severity", color: accentColor, textSize: 28)
                    StepSlider(value: $sliderValue, range: 1...10, step: 1, accentColor: accentColor, width: screenWidth - 50)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomText(text: " Emergency Med Taken?", color: accentColor, textSize: 28)
                    MultipleChoiceButtonGroup(options: $medTakenOptions, selectedOption: $medTaken, accentColor: accentColor, columns: 2)
                    
                    CustomText(text: "Symptom Description", color: accentColor, textSize: 28)
                    CustomTextField(background: backgroundColor, accent:accentColor, placeholder: "", text: $symptom_desc, width: screenWidth-50, height: 50, textSize: 20, isMultiline: true)
                        .padding(.bottom, 10)
                        .padding(.trailing, leading_padding + 20)
                    
                    CustomText(text: " Notes", color: accentColor, textSize: 28)
                    CustomTextField(background: backgroundColor, accent:accentColor, placeholder: "", text: $notes, width: screenWidth-50, height: 50, textSize: 20, isMultiline: true)
                        .padding(.bottom, 10)
                        .padding(.trailing, leading_padding + 20)
                }
                .padding(.leading, leading_padding)
                .padding(.bottom, 150)
            }
            
        }
    }
    @ViewBuilder
    private func sideEffectLogView() -> some View {
        CustomText(text: "test", color: accentColor)
    }
}



#Preview {
    LogView(userID: 2, backgroundColor: .constant("#001d00"), accentColor: .constant("#b5c4b9"))
}
