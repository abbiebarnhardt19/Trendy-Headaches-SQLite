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
    
    @State var showColumnList: Bool = false
    
    var body: some View {
        VStack(spacing:10){
            VStack{
                HStack{
                    CustomText(text:"Columns", color: background, width:100, textAlignment: .trailing)
                        .padding(.trailing, 5)
                    Button(action: { showColumnList.toggle() }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: background))
                            .frame(width: 10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 30)
                    if showColumnList{
                        Spacer()
                    }
                }
                if showColumnList{
                    MultipleChoiceCheckboxGroup(options: $columnOptions, selected: $selectedColumns, accent: background, background: accent)
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
// MARK: - Table View
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

    var body: some View {

        VStack {
            ScrollView(.vertical, showsIndicators: true) {
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
                }
                .frame(width: width)
            }
        }
        .frame(width: width, height: height)
        .background(Color(hex: accent))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(hex: background).opacity(0.5), lineWidth: 1)
        )

        
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
                .frame(minWidth: 80, alignment: .center) // dynamic width with min

                if column != selectedColumns.last {
                    Divider()
                        .frame(width: 1, height: 30)
                        .background(Color(hex: background).opacity(0.5))
                }
            }
        }
        .background(Color(hex: accent))
    }

    // MARK: - Header
    private var tableHeader: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(selectedColumns, id: \.self) { column in
                    CustomText(
                        text: column,
                        color: background,
                        textAlignment: .center,
                        isBold: true,
                        textSize: 18
                    )
                    .padding(.vertical, 5)
                    .padding(.horizontal, 8)
                    .frame(minWidth: 80, alignment: .center) // dynamic width

                    if column != selectedColumns.last {
                        Divider()
                            .frame(width: 1, height: 30)
                            .background(Color(hex: background).opacity(0.5))
                    }
                }
            }
            .background(Color(hex: accent))

            Divider()
                .frame(height: 2)
                .background(Color(hex: background).opacity(0.5))
        }
        .background(Color(hex: accent))
    }

    // MARK: - Helpers
    private func value(for column: String, in log: UnifiedLog) -> String {
        switch column {
        case "Log Type":
            return log.log_type
        case "Symptom":
            return log.symptom_name ?? log.side_effect_name ?? "N/A"
        case "Date":
            return dateFormatter.string(from: log.date)
        case "Severity":
            return "\(log.severity)"
        case "Notes (S)":
            return log.notes ?? "N/A"
//        case "Triggers (S)":
//            return log.triggers ?? "—"
        case "Symp. Onset (S)":
            return log.onset_time ?? "N/A"
        case "Emerg. Meds (S)":
            return log.medication_name ?? "N/A"
        case "Med. (SE)":
            return log.medication_name ?? "N/A"
        default:
            return "N/A"
        }
    }
}
