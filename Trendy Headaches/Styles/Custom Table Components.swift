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

    @State private var expandedWidth: CGFloat = 215
    @State private var unexpandedWidth: CGFloat = 255

    enum FilterSection {
        case none, columns, logType, date, severity, symptoms
    }

    @State private var expandedSection: FilterSection = .none
    @State private var dropdownWidths: [FilterSection: (collapsed: CGFloat, expanded: CGFloat)] = [
        .columns: (100, 315),
        .logType: (100, 140),
        .date: (55, 300),
        .severity: (90, 190),
        .symptoms: (120, 300)
    ]


    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // MARK: Columns
                sectionButton(title: "Columns", section: .columns) {
                    MultipleChoiceCheckboxGroup(
                        options: $columnOptions,
                        selected: $selectedColumns,
                        accent: background,
                        background: accent,
                        width: expandedWidth
                    )
                    .padding(.leading, 10)
                    .padding(.top, 10)
                }
            

            // MARK: Log Type
            sectionButton(title: "Log Type", section: .logType) {
                MultipleChoiceCheckboxGroup(
                    options: .constant(["Symptom", "Side Effect"]),
                    selected: $logType,
                    accent: background,
                    background: accent,
                    width: expandedWidth
                )
                .padding(.top, 10)
            }

            // MARK: Date
            sectionButton(title: "Date", section: .date) {
                VStack {
                    HStack {
                        DatePickerTextFieldDropdown(
                            selectedDate: $startDate,
                            textFieldValue: $stringStartDate,
                            background: $accent,
                            accent: $background,
                            textFieldWidth: 125,
                            arrowSpecialCase: true,
                            labelText: false,
                            textSize: 19,
                            iconSize: 22
                        )
                        .padding(.top, 10)
                        CustomText(text: "to ", color: background, width: 50)
                            .padding(.top, 10)
                        DatePickerTextFieldDropdown(
                            selectedDate: $endDate,
                            textFieldValue: $stringEndDate,
                            background: $accent,
                            accent: $background,
                            textFieldWidth: 125,
                            arrowSpecialCase: true,
                            labelText: false,
                            textSize: 19,
                            iconSize: 22
                        )
                        .padding(.top, 10)
                    }
                    if endDate < startDate {
                        CustomWarningText(text: "*Start must be before end.")
                    }
                }
                .padding(.leading, 10)
            }

            // MARK: Severity
            sectionButton(title: "Severity", section: .severity) {
                HStack {
                    CustomTextField(
                        background: accent,
                        accent: background,
                        placeholder: "",
                        text: Binding(get: { String(sevStart) }, set: { sevStart = Int64($0) ?? 0 }),
                        width: 65,
                        alignment: .center
                    )
                    .padding(.top, 10)
                    CustomText(text: " to ", color: background, width: 30)
                        .padding(.top, 10)
                    CustomTextField(
                        background: accent,
                        accent: background,
                        placeholder: "",
                        text: Binding(get: { String(sevEnd) }, set: { sevEnd = Int64($0) ?? 0 }),
                        width: 65,
                        alignment: .center
                    )
                    .padding(.top, 10)
                }
                .padding(.leading, 10)
            }

            // MARK: Symptoms
            sectionButton(title: "Symptoms", section: .symptoms) {
                MultipleChoiceCheckboxGroup(
                    options: $symptomOptions,
                    selected: $selectedSymptoms,
                    accent: background,
                    background: accent,
                    width: expandedWidth
                )
                .padding(.leading, 10)
                .padding(.top, 10)
            }
        }
        .padding(10)
        .padding(.trailing, 10)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(hex: background), lineWidth: 3)
        )
        .background(Color(hex: accent))
        .cornerRadius(20)
        .padding(.bottom, 40)
    }
        

    // MARK: Section Button Helper
    @ViewBuilder
    private func sectionButton<Content: View>(
        title: String,
        section: FilterSection,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let widths = dropdownWidths[section] ?? (300, 300)
        let expandedWidth = widths.expanded
        let isExpanded = expandedSection == section
        
        let currentWidth: CGFloat = {
            if let activeWidths = dropdownWidths[expandedSection] {
                // Use the expanded width of the active section
                return expandedSection == .none ? widths.collapsed : activeWidths.expanded
            } else {
                // Default fallback
                return widths.collapsed
            }
        }()
        
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 5) {
                    CustomText(
                        text: title,
                        color: background,
                        width: currentWidth,
                        textAlignment: .leading,
                        isBold: true
                    )
                    
                    Button(action: {
                        withAnimation(.easeInOut) {
                            self.expandedSection = isExpanded ? .none : section
                        }
                    }) {
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: background))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 5)
                
                if isExpanded {
                    content()
                        .frame(width: expandedWidth, alignment: .leading)
                }
                
            }
            .frame(width: isExpanded ? currentWidth : 160, alignment: .leading)
        
    }
}

extension String {
    func width(usingFont font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        return (self as NSString).size(withAttributes: attributes).width
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

    var onLogTap: ((Int64, String) -> Void)? = nil

    @State private var columnWidths: [String: CGFloat] = [:]
    @State private var defaultWidths: [String: CGFloat] = [:]
    @State private var activeColumn: String? = nil
    @State private var dragOffset: CGFloat = 0

    @State private var showDeleteAlert = false
    @State private var logToDelete: UnifiedLog? = nil

    private let headerHeight: CGFloat = 35
    private let rowHeight: CGFloat = 31

    // 👇 Your actual custom width rules
    let columnMaxWidths: [String: CGFloat] = [
//        "Log Type": 115,
        "Em. Med. Taken?": 170,
        "Em. Med. Name": 150,
        "Em. Med. Worked?": 180,
//        "Sev.": 62
    ]
    let columnMinWidths: [String: CGFloat] = [
        "Log Type": 115,
        "Date": 70,
        "Symptom": 110,
        "Sev.": 62,
        "Onset": 120
    ]

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .short
        return f
    }
    
    var tableWidth: CGFloat {
        let contentWidth = selectedColumns.reduce(0) { sum, col in
            sum + (columnWidths[col] ?? defaultWidths[col] ?? 100)
        }
        return min(width, contentWidth)
    }


    private func autoWidth(for column: String) -> CGFloat {
        let charWidth: CGFloat = 9.5
        let padding: CGFloat = 16
        let headerCount = column.count
        let maxRowCount = logList.map { value(for: column, in: $0).count }.max() ?? 0
        let maxCount = max(headerCount, maxRowCount)
        let rawWidth = CGFloat(maxCount) * charWidth + padding

        let maxWidth = columnMaxWidths[column] ?? .infinity
        let minWidth = columnMinWidths[column] ?? 60
        
        return min(max(rawWidth, minWidth), maxWidth)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Outer wrapper for rounded corners
            ZStack(alignment: .topLeading) {
                Color.clear // takes no extra space

                ScrollView([.vertical, .horizontal], showsIndicators: true) {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        Section(header:
                            VStack(spacing: 0) {
                                headerRow
                            Rectangle()
                                .fill(Color(hex: background))
                                .frame(height: 2)
                            }
                        ) {
                            ForEach(logList, id: \.id) { log in
                                row(for: log)
                                Rectangle()
                                    .fill(Color(hex: background).opacity(0.3))
                                    .frame(height: 2)
                            }
                        }
                    }
                    .background(Color(hex: accent))
                }

            }
            .background(Color(hex: accent)) // extends clip to empty areas
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: background).opacity(0.5), lineWidth: 1)
            )


            .frame(height: min(height, headerHeight + CGFloat(logList.count) * rowHeight))
            .frame(width: tableWidth)
            //need to do this so it expands to full width when columns are added
        }

        .onAppear {
            UIScrollView.appearance().bounces = false
            UIScrollView.appearance().showsVerticalScrollIndicator = true
            UIScrollView.appearance().showsHorizontalScrollIndicator = true

            // Use modern API to get the app’s windows
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                for window in windowScene.windows {
                    for subview in window.subviews {
                        if let scrollView = subview as? UIScrollView {
                            scrollView.flashScrollIndicators()
                        }
                    }
                }
            }
            for col in selectedColumns {
                let width = autoWidth(for: col)
                columnWidths[col] = width
                defaultWidths[col] = width
            }
        }
        .alert("Delete Log?", isPresented: $showDeleteAlert, presenting: logToDelete) { log in
            Button("Delete", role: .destructive) {
                DatabaseManager.shared.deleteLog(logID: log.log_id, table: log.log_type)
                deleteCount += 1
            }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text("Are you sure you want to delete this log?")
        }
    }

    // MARK: - Header
    private var headerRow: some View {
        HStack(spacing: 0) {
            ForEach(selectedColumns, id: \.self) { column in
                ZStack(alignment: .trailing) {
                    CustomText(
                        text: column,
                        color: background,
                        textAlignment: .center,
                        multilineAlignment: .center,
                        isBold: true,
                        textSize: 18
                    )
                    .frame(width: effectiveWidth(for: column), height: headerHeight)
                    .background(Color.blend(Color(hex: background), Color(hex: accent), ratio: 0.6))


                    // Resize handle
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 10)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 1)
                                .onChanged { value in
                                    if activeColumn != column {
                                        activeColumn = column
                                        dragOffset = 0
                                    }
                                    dragOffset = value.translation.width
                                }
                                .onEnded { value in
                                    if let col = activeColumn {
                                        let minWidth = columnMinWidths[col] ?? 60
                                        let maxWidth = columnMaxWidths[col] ?? .infinity
                                        let newWidth = (columnWidths[col] ?? autoWidth(for: col)) + value.translation.width
                                        columnWidths[col] = min(max(newWidth, minWidth), maxWidth)
                                    }
                                    activeColumn = nil
                                    dragOffset = 0
                                }
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                columnWidths[column] = defaultWidths[column]
                            }
                        }
                }
                Rectangle()
                    .fill(Color(hex: background).opacity(0.8))
                    .frame(width: 2)
            }
        }
        .background(Color(hex: accent))
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
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: effectiveWidth(for: column), height: rowHeight)
                .background(Color(hex: accent))
                
                Rectangle()
                    .fill(Color(hex: background).opacity(0.3))
                    .frame(width: 2)
            }
        }
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: 1.0) {
            logToDelete = log
            showDeleteAlert = true
        }
        .simultaneousGesture(
            TapGesture().onEnded {
                onLogTap?(log.log_id, log.log_type)
            }
        )
    }


    // MARK: - Width Logic
    private func effectiveWidth(for column: String) -> CGFloat {
        let minWidth = columnMinWidths[column] ?? 60
        let maxWidth = columnMaxWidths[column] ?? .infinity
        if column == activeColumn {
            let proposed = (columnWidths[column] ?? autoWidth(for: column)) + dragOffset
            return min(max(proposed, minWidth), maxWidth)
        } else {
            return columnWidths[column] ?? autoWidth(for: column)
        }
    }

    // MARK: - Value Mapping
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
        default: return ""
        }
    }
}
