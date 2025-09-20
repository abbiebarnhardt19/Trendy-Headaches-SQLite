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
    
    let leading_padding = CGFloat(30)
    @State private var string_date: String = ""
    @State private var date_date: Date = Date()
    @State private var dateCheckTask: Task<Void, Never>? = nil
    @State private var dateFormatCorrect: Bool = true
    @State private var dateValid: Bool = true
    
    @State var onset: String?
    @State var onsetOptions: [String] = ["From Wake", "Morning", "Afternoon", "Evening"]
    
    @State private var sliderValue: Double = 0.0
    
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        return f
    }()
    
    func isDateInValidFormat(_ input: String) -> Bool {
        // Matches:
        //  - 1–2 digits, separator, 1–2 digits, separator, 2 OR 4 digits
        //  - separator can be "-" or "/"
        let pattern = #"^\d{1,2}[-/]\d{1,2}[-/](\d{2}|\d{4})$"#
        return input.range(of: pattern, options: .regularExpression) != nil
    }



    var body: some View {
        
        
        ZStack {
            // Background color
            Color(hex: backgroundColor).ignoresSafeArea()
            
            // Decorative blobs
            RandomBlob(points: 85, width:350, height:350, x:270, y:340, rotation:60, accent:accentColor)
            RandomBlob(points: 85, width:350, height:270, x:280, y:350, rotation:240, accent:accentColor)
            
            VStack {
                HStack{
                    CustomText(text:"Log Symptom", color: accentColor,  width: 250, textAlignment: .leading, multilineAlignment: .leading, textSize:50)
                        .padding(.leading, leading_padding)
                        .padding(.top, 30)
                    Spacer()
                }
                Spacer()
            }
            .ignoresSafeArea(edges: .bottom)
            
            VStack(alignment: .leading){
                CustomText(text: "Date", color: accentColor, textSize: 28)
                    .padding(.leading, 10)
                    
                CustomTextField(background: backgroundColor, accent: accentColor, placeholder: "", text: $string_date, width: 150, height: 45, textSize: 20)
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
                }
                else{
                    CustomWarningText(text: "                                 ")
                }
                
                CustomText(text: "Symptom Onset", color: accentColor, textSize: 28)
                    
                MultipleChoiceButtonGroup(options: $onsetOptions, selectedOption: $onset, accentColor: accentColor)
                
                CustomText(text: "Symptom Severity", color: accentColor, textSize: 28)
                StepSlider(
                    value: $sliderValue,
                    range: 1...10,
                    step: 1,
                    accentColor: accentColor
                )         
            }
            .padding(.leading, leading_padding)
            
            
            
            // Nav bar overlay at bottom
            VStack {
                Spacer()
                NavBarView(userID: userID, backgroundColor: $backgroundColor, accentColor: $accentColor)
                .frame(height: 60)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .ignoresSafeArea(edges: .bottom)
            .zIndex(10)
        }
        .onAppear{
           string_date = formatter.string(from: Date())
            date_date = formatter.date(from: string_date) ?? Date()
        }
    }
}

#Preview {
    LogView(userID: 1, backgroundColor: .constant("#001d00"), accentColor: .constant("#b5c4b9"))
}
