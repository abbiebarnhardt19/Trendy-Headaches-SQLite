//
//  Table Styles.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SwiftUI

// MARK: - Table View
struct ScrollableLogTable: View {
    var userID: Int64
    var logList: [UnifiedLog]
    @State var background: String
    @State var accent: String
    var width: CGFloat
    var height: CGFloat
    
    var onLogTap: ((Int64, String) -> Void)? = nil

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .short
        return f
    }

    var body: some View {
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section(header: tableHeader) {
                        ForEach(logList, id: \.id) { log in
                            row(for: log)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    onLogTap?(log.log_id, log.log_type) // pass table name if needed
                                    }

                            if log.id != logList.last?.id {
                                Divider()
                                    .frame(width: width, height: 1)
                                    .background(Color(hex: background).opacity(0.5))
                            }
                        }
                    }
                }
                .frame(width: width)
                .background(Color(hex: accent))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(hex: background).opacity(0.5), lineWidth: 1))
        }
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color(hex: background).opacity(0.5), lineWidth: 1)
            )
    }

    private func row(for logList: UnifiedLog) -> some View {
        HStack(spacing: 0) {
            CustomText(text: logList.log_type, color: background, width: 110, textAlignment: .center, textSize: 16)
                .padding(.vertical, 5)

            Divider().frame(width: 1, height: 30)
                .background(Color(hex: background).opacity(0.5))

            // If it’s a Symptom log, show the symptom name; otherwise, the side effect name
            CustomText(
                text: logList.symptom_name ?? logList.side_effect_name ?? "N/A",
                color: background,
                width: 120,
                textAlignment: .center,
                textSize: 16
            )
            .padding(.vertical, 5)

            Divider().frame(width: 1, height: 30)
                .background(Color(hex: background).opacity(0.5))

            CustomText(text: dateFormatter.string(from: logList.date), color: background, width: 65, textAlignment: .center, textSize: 16)
                .padding(.vertical, 5)

            Divider().frame(width: 1, height: 30)
                .background(Color(hex: background).opacity(0.5))

            CustomText(text: "\(logList.severity)", color: background, width: 55, textAlignment: .center, textSize: 16)
                .padding(.vertical, 5)
        }
        .background(Color(hex: accent))
    }


    // MARK: - Header
    private var tableHeader: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                CustomText(text:"Log Type", color:background, width:110, textAlignment: .center, isBold: true, textSize: 18)
                    .padding(.vertical, 5)

                Divider().frame(width: 1, height: 30)
                    .background(Color(hex: background).opacity(0.5))

                CustomText(text:"Symptom", color:background, textAlignment: .center, isBold: true, textSize: 18)
                    .padding(.vertical, 5)

                Divider().frame(width: 1, height: 30)
                    .background(Color(hex: background).opacity(0.5))

                CustomText(text:"Date", color:background, width:65, textAlignment: .center, isBold: true, textSize: 18)
                    .padding(.vertical, 5)

                Divider().frame(width: 1, height: 30)
                    .background(Color(hex: background).opacity(0.5))

                CustomText(text:"Sev.", color:background, width:55, textAlignment: .center, isBold: true, textSize: 18)
                    .padding(.vertical, 5)
            }
            .background(Color(hex: accent))

            Divider()
                .frame(width: width, height: 2)
                .background(Color(hex: background).opacity(0.5))
        }
        .background(Color(hex: accent))
    }
}

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
    @State var selectedColumns: [String]
    
    @State var showColumnList: Bool = false
//    @State var columnOptions: [String] = ["Log Type", "Date", "Symptom", "Severity", "Symp. Onset (S)", "Emerg. Meds (S)", "Triggers (S)", "Symp. Desc. (S)", "Notes (S)", "Med. (SE)"]
//    @State var selectedColumns: [String] = ["Log Type", "Date", "Symptom", "Severity"]
    
    
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
