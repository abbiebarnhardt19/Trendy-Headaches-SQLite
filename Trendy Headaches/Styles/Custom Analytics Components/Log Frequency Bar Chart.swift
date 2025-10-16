//
//  Log Frequency Bar Chart.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/14/25.
//

import SwiftUI

struct CustomStackedBarChart: View {
    var logList: [UnifiedLog]
    var accent: String
    var bg: String
    var width: CGFloat
    @Binding var hideChart: Bool

    @State var showKey: Bool = false
    @State var yearOffset: Int = 0
    @State private var selectedMonth: Date? = nil
    @State private var selectedSymptom: String? = nil

    //get all the month data
    private var data: [(month: Date, symptoms: [(symptom: String, count: Int)])] {
        let calendar = Calendar.current
        let startMonth = calendar.date(byAdding: .month, value: -11, to: calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!)!
        
        let months = (0..<12).compactMap { calendar.date(byAdding: .month, value: $0, to: startMonth) }
        let logsByMonth = Dictionary(grouping: logList.filter { $0.date >= startMonth }) {
            calendar.date(from: calendar.dateComponents([.year, .month], from: $0.date))!
        }
        
        return months.map { month in
            (month, logsByMonth[month]?.reduce(into: [String: Int]()) { $0[$1.symptom_name ?? "Unknown", default: 0] += 1 }
                    .map { ($0.key, $0.value) } ?? [])
        }
    }

    private var maxCount: Int {
        max(data.map { $0.symptoms.map(\.count).reduce(0, +) }.max() ?? 1, 1)
    }

    private var symptomOrder: [String] {
        let globalSymptomCounts = Dictionary(grouping: data.flatMap { $0.symptoms }) { $0.symptom }
            .mapValues { $0.map(\.count).reduce(0, +) }
        return globalSymptomCounts.sorted {
            if $0.value == $1.value { return $0.key > $1.key }
            return $0.value < $1.value
        }.map { $0.key }
    }

    var body: some View {
        let baseColor = Color(hex: accent)
        let colorMap = Dictionary(uniqueKeysWithValues: zip(symptomOrder, baseColor.generateHarmoniousColors(from: baseColor, count: symptomOrder.count)))

        let chartHeight: CGFloat = 150
        let yStep = max(1, Int(ceil(Double(maxCount) / 5)))
        let yMax = ((maxCount + yStep - 1) / yStep) * yStep
        let yValues = Array(stride(from: 0, through: yMax, by: yStep))

        let yAxisWidth: CGFloat = 15
        let barSpacing: CGFloat = 10
        let barWidth = (width - yAxisWidth - barSpacing * 11 - 20) / 12

        VStack(alignment: .leading, spacing: 10) {
            // Buttons
            HStack {
                Button(action: { yearOffset -= 1 }) { Image(systemName: "chevron.left").foregroundColor(Color(hex:bg)) }
                
                CustomText(text:"Logs by Symptom", color:bg, width:150, textAlign:.center, textSize:18)
                
                Button(action: { yearOffset += 1 }) { Image(systemName:"chevron.right").foregroundColor(yearOffset>=0 ? Color(hex:bg).opacity(0.3) : Color(hex:bg)) }
                    .disabled(yearOffset>=0)
                
                Spacer()
                
                Button(action:{showKey.toggle()}) { CustomText(text:"Key", color:accent, width:40, textAlign:.center, textSize:12).frame(height:25).background(Color(hex:bg)).cornerRadius(20) }
                
                Button(action:{hideChart.toggle()}) { CustomText(text:"Hide", color:accent, width:45, textAlign:.center, textSize:12).frame(height:25).background(Color(hex:bg)).cornerRadius(20) }
                
                CustomButton(text:"Hide", bg: accent, accent: bg, height: 25, width: 45){hideChart.toggle()}
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            // Chart area with Y-axis and bars
            ZStack(alignment:.topLeading) {
                HStack(alignment: .top, spacing:0) {
                    // Y-axis
                    VStack(spacing:0) {
                        ForEach(yValues.reversed(), id:\.self) { value in
                            CustomText(text:"\(value)", color:bg, width:yAxisWidth, textAlign:.trailing, textSize:10)
                                .padding(.trailing,7)
                                .frame(height:1)
                                .offset(y:-3)
                            if value>0 { Spacer().frame(height: chartHeight*CGFloat(yStep)/CGFloat(yMax)) }
                        }
                    }
                    .frame(height: chartHeight, alignment:.top)
                    
                    // Bars + grid
                    ZStack(alignment:.topLeading) {
                        // Grid lines
                        VStack(spacing:0) {
                            ForEach(yValues.reversed(), id:\.self) { value in
                                Rectangle().fill(Color(hex:bg).opacity(0.3)).frame(height:1)
                                if value>0 { Spacer().frame(height: chartHeight*CGFloat(yStep)/CGFloat(yMax)) }
                            }
                        }
                        .frame(height: chartHeight)
                        
                        // Bars
                        HStack(alignment:.bottom, spacing:barSpacing) {
                            ForEach(data, id:\.month) { monthData in
                                VStack(spacing:2) {
                                    ZStack(alignment:.bottom) {
                                        RoundedRectangle(cornerRadius:6).fill(baseColor.opacity(0.2))
                                        VStack(spacing: 0) {
                                            let popGap: CGFloat = 8

                                            ForEach(symptomOrder, id: \.self) { symptom in
                                                if let s = monthData.symptoms.first(where: { $0.symptom == symptom }) {
                                                    let segmentHeight = chartHeight * CGFloat(s.count) / CGFloat(yMax)
                                                    let isSelected = selectedMonth == monthData.month && selectedSymptom == s.symptom
                                                    let topPadding: CGFloat = isSelected ? popGap / 2 : 0
                                                    let bottomPadding: CGFloat = isSelected ? popGap / 2 : 0

                                                    Rectangle()
                                                        .fill(colorMap[s.symptom] ?? .gray)
                                                        .frame(height: segmentHeight)
                                                        .padding(.top, topPadding)
                                                        .padding(.bottom, bottomPadding)
                                                        .onTapGesture {
                                                            withAnimation(.spring()) {
                                                                if selectedMonth == monthData.month && selectedSymptom == s.symptom {
                                                                    selectedMonth = nil
                                                                    selectedSymptom = nil
                                                                } else {
                                                                    selectedMonth = monthData.month
                                                                    selectedSymptom = s.symptom
                                                                }
                                                            }
                                                        }
                                                }
                                            }
                                        }

                                        .clipShape(RoundedRectangle(cornerRadius:8))
                                    }
                                    .frame(width:barWidth,height:chartHeight)
                                    
                                    CustomText(text: monthLabel(for: monthData.month), color:bg, textAlign:.center, textSize:8)
                                        .fixedSize()
                                        .frame(height:30)
                                        .padding(.top,3)
                                        .offset(x:2)
                                }
                            }
                        }
                    }
                }
                
                // popup if segment is selected
                if let selectedMonth, let selectedSymptom {
                    TooltipOverlay(month: selectedMonth, symptom: selectedSymptom, data: data, symptomOrder: symptomOrder, chartWidth: width, chartHeight: chartHeight, maxCount: maxCount, colorMap: colorMap)
                }
            }
            .frame(height:chartHeight+30)
            
            //symptom legend
            // Symptom legend using FlexibleWrap
            if showKey {
                FlexibleWrap(
                    items: symptomOrder,
                    spacing: 10,
                    circleWidth: 10,
                    charWidth: 7
                ) { symptom in
                    HStack(spacing: 5) {
                        Circle()
                            .fill(colorMap[symptom] ?? .gray)
                            .frame(width: 10, height: 10)
                        Text(symptom.capitalizedWords.count > 10
                             ? String(symptom.capitalizedWords.prefix(10)) + "…"
                             : symptom.capitalizedWords)
                            .font(.system(size: 12))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                .padding(.leading, 25)
                .padding(.bottom, 5)
            }

        }
        .padding(.vertical,10)
        .background(Color(hex:accent))
        .cornerRadius(30)
        .frame(width:width)
    }

    private var monthFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMM yyyy"
        return df
    }

    private func monthLabel(for date: Date) -> String {
        let month = monthFormatter.string(from: date).prefix(3)
        let year = monthFormatter.string(from: date).suffix(4)
        return "\(month),\n\(year)"
    }
}

struct TooltipOverlay: View {
    var month: Date
    var symptom: String
    var data: [(month: Date, symptoms: [(symptom: String, count: Int)])]
    var symptomOrder: [String]
    var chartWidth: CGFloat
    var chartHeight: CGFloat
    var maxCount: Int
    var colorMap: [String: Color]

    @State private var measuredWidth: CGFloat = 0
    @State private var measuredHeight: CGFloat = 0

    private struct TooltipWidthKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }

    private struct TooltipHeightKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }

    var tooltipInfo: (x: CGFloat, y: CGFloat, width: CGFloat, color: Color, count: Int, segmentHeight: CGFloat, percent: Double)? {
        let calendar = Calendar.current
        guard let monthData = data.first(where: { calendar.isDate($0.month, equalTo: month, toGranularity: .month) }),
              let symptomData = monthData.symptoms.first(where: { $0.symptom == symptom }) else {
            return nil
        }

        // total logs in the month
        let totalCount = monthData.symptoms.map(\.count).reduce(0, +)
        let percent = totalCount > 0 ? Double(symptomData.count) / Double(totalCount) * 100 : 0

        // existing calculations...
        let yAxisWidth: CGFloat = 15
        let chartHorizontalPadding: CGFloat = 20
        let barSpacing: CGFloat = 10
        let actualBarCount = CGFloat(max(1, data.count))
        let computedBarWidth = (chartWidth - yAxisWidth - (barSpacing * (actualBarCount - 1)) - chartHorizontalPadding) / actualBarCount
        let usedBarWidth = computedBarWidth.isFinite && computedBarWidth > 0 ? computedBarWidth : (chartWidth - yAxisWidth - (barSpacing * 11) - 20) / 12

        let index = data.firstIndex(where: { calendar.isDate($0.month, equalTo: month, toGranularity: .month) }) ?? 0
        let barAreaXOffset = yAxisWidth + (chartHorizontalPadding / 2)
        let barLeftX = barAreaXOffset + CGFloat(index) * (usedBarWidth + barSpacing)
        let barRightX = barLeftX + usedBarWidth

        let yMax = CGFloat(maxCount)
        var cumulativeHeight: CGFloat = 0
        var segmentHeight: CGFloat = 0
        for name in symptomOrder {
            if let data = monthData.symptoms.first(where: { $0.symptom == name }) {
                let h = chartHeight * CGFloat(data.count) / yMax
                if name == symptom {
                    segmentHeight = h
                    break
                } else {
                    cumulativeHeight += h
                }
            }
        }

        let segmentCenterY = cumulativeHeight + segmentHeight / 2

        let gap: CGFloat = 10
        let effectiveTooltipWidth = max(60, measuredWidth > 0 ? measuredWidth : 120)
        let leftMost = effectiveTooltipWidth / 2
        let rightMost = chartWidth - effectiveTooltipWidth / 2

        var centerX: CGFloat
        if barRightX + gap + effectiveTooltipWidth <= chartWidth {
            centerX = barRightX + gap + effectiveTooltipWidth / 2
        } else if barLeftX - gap - effectiveTooltipWidth >= 0 {
            centerX = barLeftX - gap - effectiveTooltipWidth / 2
        } else {
            let spaceRight = chartWidth - barRightX - gap
            let spaceLeft = barLeftX - gap
            if spaceRight >= spaceLeft {
                centerX = min(rightMost, max(leftMost, barRightX + gap + effectiveTooltipWidth / 2))
            } else {
                centerX = min(rightMost, max(leftMost, barLeftX - gap - effectiveTooltipWidth / 2))
            }
        }
        centerX = min(rightMost, max(leftMost, centerX))

        return (x: centerX, y: segmentCenterY, width: effectiveTooltipWidth, color: colorMap[symptom] ?? .gray, count: symptomData.count, segmentHeight: segmentHeight, percent: percent)
    }


    var body: some View {
        if let info = tooltipInfo {
            let textColor: Color = Color.isHexColorDark(info.color.hexString) ? .white : .black
            
            VStack(spacing: 2) {
                Text(symptom.capitalizedWords)
                    .font(.system(size: 12, weight: .bold, design: .serif))
                    .fixedSize()
                Text("\(info.count) logs (\(Int(info.percent))%)")
                    .font(.system(size: 10, design: .serif))
                    .fixedSize()
            }
            .foregroundColor(textColor)
            .padding(6)
            .background(
                ZStack {
                    info.color
                        .cornerRadius(6) // only apply cornerRadius here
                    GeometryReader { proxy in
                        Color.clear.preference(key: TooltipWidthKey.self, value: proxy.size.width)
                    }
                    GeometryReader { proxy in
                        Color.clear.preference(key: TooltipHeightKey.self, value: proxy.size.height)
                    }
                }
            )
            .onPreferenceChange(TooltipWidthKey.self) { value in
                DispatchQueue.main.async { self.measuredWidth = value }
            }
            .onPreferenceChange(TooltipHeightKey.self) { height in
                DispatchQueue.main.async { self.measuredHeight = height }
            }
            .position(x: info.x, y: info.y + 5)
        }

    }


}

extension DateFormatter {
    static var monthYear: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMMM yyyy"
        return df
    }
}

extension String {
    var capitalizedWords: String {
        self
            .split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }
}
