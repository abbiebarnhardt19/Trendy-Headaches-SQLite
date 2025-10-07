//
//  Table Styles.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SwiftUI

struct FilterDropDown: View {
    @State var background: String
    @State var accent: String
    @Binding var showPopUp: Bool
    
    var body: some View {
        Button(action: { showPopUp.toggle() }) {
            Image(systemName: "line.horizontal.3.decrease.circle")
                .font(.system(size: 65))
                .foregroundColor(Color(hex: accent))
                .frame(width: 65, height: 25)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.trailing, 30)
        .padding(.bottom, 10)
    }
}

struct filterPopUp: View {
    @State var accent: String
    @State var background: String
    @State var columnOptions: [String]
    @Binding var selectedColumns: [String]
    @Binding var logType: [String]
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var stringStartDate: String
    @Binding var stringEndDate: String
    @Binding var sevStart: Int64
    @Binding var sevEnd: Int64
    
    @State var showColumnList: Bool = false
    @State var showLogTypeOptions: Bool = false
    @State var showDateOptions: Bool = false
    @State var showSeverityOptions: Bool = false
    
    
    

    
    var body: some View {
        @State var boolList = [showColumnList, showLogTypeOptions, showDateOptions, showSeverityOptions]
        
        VStack(spacing:10){
            VStack{
                HStack{
                    CustomText(text:"Columns", color: background, width:100, textAlignment: .leading, isBold: true)
                        .padding(.horizontal, 10)
                    Button(action: { showColumnList.toggle() }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: background))
                            .frame(width: 10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 30)
                    if boolList.contains(true){
                        Spacer()
                    }
                }
                if showColumnList{
                    MultipleChoiceCheckboxGroup(options: $columnOptions, selected: $selectedColumns, accent: background, background: accent)
                }
                
            }
            VStack{
                HStack{
                    CustomText(text:"Log Type", color: background, width:100, textAlignment: .leading, isBold: true)
                        .padding(.horizontal, 10)
                    Button(action: { showLogTypeOptions.toggle() }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: background))
                            .frame(width: 10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 30)
                    if boolList.contains(true){
                        Spacer()
                    }
                }
                if showLogTypeOptions{
                    MultipleChoiceCheckboxGroup(options: .constant(["Symptom", "Side Effect"]), selected: $logType, accent: background, background: accent)
                }
            }
            VStack{
                HStack{
                    CustomText(text:"Date", color: background, width:100, textAlignment: .leading, isBold: true)
                        .padding(.horizontal, 10)
                    Button(action: { showDateOptions.toggle() }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: background))
                            .frame(width: 10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 30)
                    if boolList.contains(true){
                        Spacer()
                    }
                }
                if showDateOptions{
                    DatePickerTextFieldDropdown(
                        selectedDate: $startDate,
                        textFieldValue: $stringStartDate,
                        background: $accent,
                        accent: $background,
                        textFieldWidth: 190,
                        arrowSpecialCase: true,
                        labelText: "Start:"
                    )

                    DatePickerTextFieldDropdown(
                        selectedDate: $endDate,
                        textFieldValue: $stringEndDate,
                        background: $accent,
                        accent: $background,
                        textFieldWidth: 190,
                        arrowSpecialCase: true,
                        labelText: "End:"
                    )
                    if endDate<startDate{
                        CustomWarningText(text: "*Start must be before end.")
                    }

                }
                VStack{
                    HStack{
                        CustomText(text:"Severity", color: background, width:100, textAlignment: .leading, isBold: true)
                            .padding(.horizontal, 10)
                        Button(action: { showSeverityOptions.toggle() }) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: background))
                                .frame(width: 10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, 30)
                        if boolList.contains(true){
                            Spacer()
                        }
                    }
                    if showSeverityOptions{
                        HStack{
                            CustomTextField(background: accent, accent: background, placeholder: "", text: Binding(
                                get: { String(sevStart) },
                                set: { sevStart = Int64($0) ?? 0 }
                            ), width: 65, alignment: .center)
                            
                            CustomText(text: " to ", color: background, width: 30)
                            
                            CustomTextField(background: accent, accent: background, placeholder: "", text: Binding(
                                get: { String(sevEnd) },
                                set: { sevEnd = Int64($0) ?? 0 }
                            ), width: 65, alignment: .center)
                        }
                    }
                    
                }
                
            }
        }
        
        .padding(10)
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(hex: background), lineWidth: 3))
        .background(Color(hex:accent))
        .cornerRadius(20)
        .padding(.bottom, 40)

    }
}
import SwiftUI

struct ScrollableLogTable: View {
    var userID: Int64
    var logList: [UnifiedLog]
    var selectedColumns: [String]
    @State var background: String
    @State var accent: String
    @State var height: CGFloat
    @State var width: CGFloat
    
    var onLogTap: ((Int64, String) -> Void)? = nil
    
    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .short
        return f
    }
    
    // Add this property to your table
    var columnMaxWidths: [String: CGFloat] = ["Log Type": 115, "Emerg. Med. Taken?": 130, "Emerg. Med. Name": 130, "Emerg. Med. Worked?": 130, "Sev." : 62]
    
    var columnMinWidths: [String: CGFloat] = ["Log Type":115, "Date": 65, "Symptom": 120, "Sev.":62]

    // Updated width helper
    private func width(for column: String) -> CGFloat {
        let charWidth: CGFloat = 10
        let padding: CGFloat = 5
        
        let headerCount = column.count
        let maxRowCount = logList.map { value(for: column, in: $0).count }.max() ?? 0
        let maxCount = max(headerCount, maxRowCount)
        
        let rawWidth = CGFloat(maxCount) * charWidth + padding
        
        // get custom limits if they exist
        let maxWidth = columnMaxWidths[column] ?? .infinity
        let minWidth = columnMinWidths[column] ?? 0
        
        // clamp between min and max
        return min(max(rawWidth, minWidth), maxWidth)
    }


    
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: true) {
                HStack {
                    ScrollView(.horizontal, showsIndicators: true) {
                        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                            Section(header: tableHeader) {
                                ForEach(logList, id: \.id) { log in
                                    row(for: log)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            onLogTap?(log.log_id, log.log_type)
                                        }
                                    if log.id != logList.last?.id {
                                        Divider()
                                            .frame(height: 1)
                                            .background(Color(hex: background).opacity(0.5))
                                    }
                                }
                            }
                        }
                        .background(Color(hex: accent))
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(width: width)
                    .clipped()
                }
                .frame(width: width)
            }
            .frame(maxHeight: height)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color(hex: background).opacity(0.5), lineWidth: 1)
            )
        }

    }
    
    // MARK: - Header
    private var tableHeader: some View {
        VStack(spacing: 0) { // VStack allows horizontal divider at bottom
            HStack(spacing: 0) {
                ForEach(selectedColumns, id: \.self) { column in
                    CustomText(
                        text: column,
                        color: background,
                        textAlignment: .center,
                        multilineAlignment: .center,
                        isBold: true,
                        textSize: 18
                    )
                    .padding(.vertical, 5)
                    .padding(.horizontal, 8)
                    .frame(width: width(for: column))
                    
                    if column != selectedColumns.last {
                        Divider()
                            .frame(width: 1) // vertical divider
                            .background(Color(hex: background).opacity(0.5))
                    }
                }
            }
            .background(Color(hex: accent))
            
            // Horizontal divider under header
            Divider()
                .frame(height: 1)
                .background(Color(hex: background).opacity(0.5))
        }
    }

    
    // MARK: - Row
    private func row(for log: UnifiedLog) -> some View {
        HStack(spacing: 0) {
            ForEach(selectedColumns, id: \.self) { column in
                CustomText(
                    text: value(for: column, in: log),
                    color: background,
                    textAlignment: .center,
                    textSize: 16
                )
                .padding(.vertical, 5)
                .padding(.horizontal, 8)
                .frame(width: width(for: column))
                
                if column != selectedColumns.last {
                    Divider()
                        .frame(width: 1)
                        .background(Color(hex: background).opacity(0.5))
                }
            }
        }
        .background(Color(hex: accent))
    }
    
    // MARK: - Helpers
    private func value(for column: String, in log: UnifiedLog) -> String {
        switch column {
        case "Log Type": return log.log_type
        case "Symptom": return log.symptom_name ?? ""
        case "Date": return dateFormatter.string(from: log.date)
        case "Sev.": return "\(log.severity)"
        case "Notes (S)": return log.notes ?? ""
        case "Triggers (S)": return log.trigger_names?.joined(separator: ", ") ?? ""
        case "Onset (S)": return log.onset_time ?? ""
        case "Emerg. Med. Name": return log.medication_name ?? ""
        case "Emerg. Med. Taken?": return log.med_taken == true ? "Yes" : "No"
        case "Emerg. Med. Worked?": return log.med_worked == true ? "Yes" : "No"
        case "Med. (SE)": return log.medication_name ?? ""
        default: return ""
        }
    }
}

