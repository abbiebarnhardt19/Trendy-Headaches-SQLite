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
    @Binding var symptomOptions: [String]
    @Binding var selectedSymptoms: [String]
    
    @State var showColumnList: Bool = false
    @State var showLogTypeOptions: Bool = false
    @State var showDateOptions: Bool = false
    @State var showSeverityOptions: Bool = false
    @State var showSymptomOptions: Bool = false
    
    @State private var expandedWidth: CGFloat = 215
    @State private var unexpandedWidth: CGFloat = 145
    
    var body: some View {
        let boolList = [showColumnList, showLogTypeOptions, showDateOptions, showSeverityOptions, showSymptomOptions]
        

        
        VStack(spacing:10){
                VStack{
                    HStack{
                        CustomText(text:"Columns", color: background, width:110, textAlignment: .center, isBold: true)
                        Button(action: { showColumnList.toggle()
                            expandedWidth = showColumnList ? 315 : 215}) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: background))
                                .frame(width: 10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                    }
                
                    if showColumnList{
                        MultipleChoiceCheckboxGroup(options: $columnOptions, selected: $selectedColumns, accent: background, background: accent, width:expandedWidth-15)
                            .padding(.leading, 10)
                        
                    }
                    
                }
          .frame(width: boolList.contains(true) ? expandedWidth : unexpandedWidth)
            
                VStack{
                    HStack{
                        CustomText(text:"Log Type", color: background, width:110, textAlignment: .center, isBold: true)
                        Button(action: { showLogTypeOptions.toggle()
                            expandedWidth = showLogTypeOptions ? 150 : 215}) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: background))
                                .frame(width: 10)
                        }
                        .buttonStyle(PlainButtonStyle())
                            Spacer()
                        
                    }
                    if showLogTypeOptions{
                        MultipleChoiceCheckboxGroup(options: .constant(["Symptom", "Side Effect"]), selected: $logType, accent: background, background: accent, width:expandedWidth)
                            .padding(.leading, 10)
                    }
                }
                .frame(width: boolList.contains(true) ? expandedWidth : unexpandedWidth)
            
                VStack{
                    HStack{
                        CustomText(text:"Date", color: background, width:60, textAlignment: .center, isBold: true)
                        Button(action: { showDateOptions.toggle()
                            expandedWidth = showDateOptions ? 315 : 215}) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: background))
                                .frame(width: 10)
                        }
                        .buttonStyle(PlainButtonStyle())

                            Spacer()
                        
                    }
                    
                    if showDateOptions{
                        VStack{
                            HStack{
                                Spacer()
                                DatePickerTextFieldDropdown(selectedDate: $startDate, textFieldValue: $stringStartDate, background: $accent, accent: $background, textFieldWidth: 125, arrowSpecialCase: true, labelText: false, textSize: 19, iconSize: 22)
                                CustomText(text: "to ", color: background, width:50)
                                DatePickerTextFieldDropdown(selectedDate: $endDate, textFieldValue: $stringEndDate, background: $accent, accent: $background, textFieldWidth: 125, arrowSpecialCase: true, labelText: false, textSize: 19, iconSize: 22)
                                Spacer()
                            }
                                if endDate<startDate{
                                    CustomWarningText(text: "*Start must be before end.")
                            }
                        }
                        .padding(.leading, 10)
                    }
                }
                .frame(width: boolList.contains(true) ? expandedWidth : unexpandedWidth)
            
                VStack{
                    HStack{
                        CustomText(text:"Severity", color: background, width:100, textAlignment: .center, isBold: true)
                        Button(action: { showSeverityOptions.toggle()
                            expandedWidth = showSeverityOptions ? 190 : 215}) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: background))
                                .frame(width: 10)
                        }
                        .buttonStyle(PlainButtonStyle())

                            Spacer()
                        
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
                            Spacer()
                        }
                        .padding(.leading, 10)
                    }
                }
                .frame(width: boolList.contains(true) ? expandedWidth : unexpandedWidth)
            
                VStack{
                    HStack{
                        CustomText(text:"Symptoms", color: background, width:125, textAlignment: .center, isBold: true)
                        Button(action: { showSymptomOptions.toggle()
                            expandedWidth = showSymptomOptions ? 315 : 215}) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: background))
                                .frame(width: 10)
                        }
                        .buttonStyle(PlainButtonStyle())
                            Spacer()
                    }
                    if showSymptomOptions{
                        MultipleChoiceCheckboxGroup(options: $symptomOptions, selected: $selectedSymptoms, accent: background, background: accent, width:expandedWidth-15)
                            .padding(.leading, 10)
                    }
                }
                .frame(width: boolList.contains(true) ? expandedWidth : unexpandedWidth)
            
            }
            .padding(10)
            .padding(.trailing, 10)
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(hex: background), lineWidth: 3))
            .background(Color(hex:accent))
            .cornerRadius(20)
            .padding(.bottom, 40)
    }
}

struct ScrollableLogTable: View {
    var userID: Int64
    var logList: [UnifiedLog]
    var selectedColumns: [String]
    @State var background: String
    @State var accent: String
    @State var height: CGFloat
    @State var width: CGFloat
    @Binding var deleteCount: Int64
    
    @State private var showDeleteAlert = false
    @State private var logToDelete: UnifiedLog? = nil

    var onLogTap: ((Int64, String) -> Void)? = nil
    
    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .short
        return f
    }

    var columnMaxWidths: [String: CGFloat] = ["Log Type": 115, "Em. Med. Taken?": 130, "Em. Med. Name": 130, "Em. Med. Worked?": 130, "Sev." : 62]
    var columnMinWidths: [String: CGFloat] = ["Log Type":115, "Date": 65, "Symptom": 120, "Sev.":62]
    
    

    private func width(for column: String) -> CGFloat {
        let charWidth: CGFloat = 10
        let padding: CGFloat = 5
        let headerCount = column.count
        let maxRowCount = logList.map { value(for: column, in: $0).count }.max() ?? 0
        let maxCount = max(headerCount, maxRowCount)
        let rawWidth = CGFloat(maxCount) * charWidth + padding
        let maxWidth = columnMaxWidths[column] ?? .infinity
        let minWidth = columnMinWidths[column] ?? 0
        return min(max(rawWidth, minWidth), maxWidth)
    }

    var body: some View {
        
        let rowHeight: CGFloat = 31 
        let headerHeight: CGFloat = 35
        let contentHeight = headerHeight + CGFloat(logList.count) * rowHeight
        
        VStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: true) {
                        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                            Section(header: tableHeader) {
                                ForEach(logList, id: \.id) { log in
                                    row(for: log)
                                        .contentShape(Rectangle())
                                        .onLongPressGesture(minimumDuration: 1.0) {
                                            logToDelete = log
                                            showDeleteAlert = true
                                        }
                                        .simultaneousGesture(
                                            TapGesture()
                                                .onEnded {
                                                    onLogTap?(log.log_id, log.log_type)
                                                }
                                        )
                                    if log.id != logList.last?.id {
                                        Divider()
                                            .frame(height: 1)
                                            .background(Color(hex: background).opacity(0.5))
                                    }
                                }
                            }
                        }
                        .background(Color(hex: accent))
                        .fixedSize(horizontal: true, vertical: true)
                    }
                    .frame(maxWidth: width)
                }
            }
            .frame(height: min(height, contentHeight))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color(hex: background).opacity(0.5), lineWidth: 1)
            )
        }
        .alert("Delete Log?", isPresented: $showDeleteAlert, presenting: logToDelete) { log in
            Button("Delete", role: .destructive) {
                DatabaseManager.shared.deleteLog(logID: log.log_id, table: log.log_type)
                deleteCount += 1
            }
            Button("Cancel", role: .cancel) { }
        } message: { log in
            Text("Are you sure you want to delete this log?")
        }
    }

    private var tableHeader: some View {
        VStack(spacing: 0) {
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
                    .frame(width: width(for: column), height: 35)
                    if column != selectedColumns.last {
                        Divider()
                            .frame(width: 1)
                            .background(Color(hex: background).opacity(0.5))
                    }
                }
            }
            .background(Color(hex: accent))
            Divider()
                .frame(height: 1)
                .background(Color(hex: background).opacity(0.5))
        }
    }

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
                .frame(width: width(for: column), height: 30)
                if column != selectedColumns.last {
                    Divider()
                        .frame(width: 1)
                        .background(Color(hex: background).opacity(0.5))
                }
            }
        }
        .background(Color(hex: accent))
    }

    private func value(for column: String, in log: UnifiedLog) -> String {
        switch column {
        case "Log Type": return log.log_type
        case "Symptom": return log.symptom_name ?? ""
        case "Date": return dateFormatter.string(from: log.date)
        case "Sev.": return "\(log.severity)"
        case "Notes": return log.notes ?? ""
        case "Triggers": return log.trigger_names?.joined(separator: ", ") ?? ""
        case "Onset": return log.onset_time ?? ""
        case "Em. Med. Name": return log.medication_name ?? ""
        case "Em. Med. Taken?": return log.med_taken == true ? "Yes" : "No"
        case "Em. Med. Worked?": return log.med_worked == true ? "Yes" : "No"
        case "S.E. Med.": return log.medication_name ?? ""
        default: return ""
        }
    }
}


// MARK: - Preference Keys
private struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

private struct ViewWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}
