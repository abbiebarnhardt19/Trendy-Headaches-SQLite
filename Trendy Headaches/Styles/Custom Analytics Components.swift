//
//  Custom Analytics Components.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SwiftUI
import Charts

struct CalendarView: View {
    let logs: [UnifiedLog]
    @Binding var showKey: Bool
    @Binding var hideChart: Bool
    var background: String
    var accent: String
    var width: CGFloat
    let symptomToIcon: [String: String]

    func icon(for symptom: String?) -> String {
        guard let name = symptom, !name.isEmpty else { return "questionmark.square.fill" }
        return symptomToIcon[name] ?? "questionmark.square.fill"
    }
    
    @State private var currentMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    @State private var isFullScreen = false
    
    var body: some View {
        VStack(spacing: 10) {
            // Month Navigation
            HStack {
                Spacer()
                Button(action: { changeMonth(by: -1) }) { Image(systemName: "chevron.left")
                    .foregroundColor(Color(hex: background))}
                .frame(width:5)
                .padding(.leading, 5)
                
                CustomText(text:monthYearString(for: currentMonth), color: background,  width:110, textSize: 18)
                
                Button(action: { changeMonth(by: 1) }) { Image(systemName: "chevron.right")
                    .foregroundColor(Color(hex: background))}
                .frame(width:5)
                
                Spacer()
                
                //show key button
                Button(action: {showKey.toggle()}){
                    CustomText(text: "Key", color: accent,  width:60, textAlign: .center, textSize: 16)
                        .frame(height: 27)
                        .background(Color(hex: background))
                        .cornerRadius(20)
                    }
                Spacer()
                
                Button(action: {hideChart.toggle()}){
                    CustomText(text: "Hide", color: accent,  width:70, textAlign: .center, textSize: 16)
                        .frame(height: 27)
                        .background(Color(hex: background))
                        .cornerRadius(20)
                    }
                Spacer()
            }
            
            // Weekday Labels
            HStack {
                ForEach(weekDays, id: \.self) { day in
                    CustomText(text: day, color: background, textAlign: .center,  textSize: 14)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar Grid
            let days = makeDays()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 0, maximum: .infinity)), count: 7), spacing: 10 )
            {
                ForEach(days.indices, id: \.self) { idx in
                    if let date = days[idx] {
                        ZStack {
                            let dayLogs = logs.filter { calendar.isDate($0.date, inSameDayAs: date) }
                            
                            if dayLogs.count == 1 {
                                // Single log: icon below number
                                VStack(spacing: 2) {
                                    Text("\(calendar.component(.day, from: date))")
                                        .foregroundColor(Color(hex: background))
                                        .fontWeight(isToday(date) ? .bold : .regular)
                                    
                                    Image(systemName: icon(for: dayLogs[0].symptom_name ?? "Unknown"))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 8, height: 8)
                                        .foregroundColor(color(forSeverity: dayLogs[0].severity))
                                        .padding(.top, 2)
                                }
                            } else if dayLogs.count > 1 {
                                // Multiple logs: use icons around number
                                ForEach(dayLogs.indices, id: \.self) { i in
                                    let log = dayLogs[i]
                                    let angle = Double(i) / Double(dayLogs.count) * 360
                                    let radius: CGFloat = 14

                                    Image(systemName: icon(for: log.symptom_name))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 8, height: 8)
                                        .foregroundColor(color(forSeverity: log.severity))
                                        .offset(x: cos(angle * .pi / 180) * radius, y: sin(angle * .pi / 180) * radius)
                                }
                                // Day number in center
                                Text("\(calendar.component(.day, from: date))")
                                    .foregroundColor(Color(hex: background))
                                    .fontWeight(isToday(date) ? .bold : .regular)
                            } else {
                                // No logs
                                Text("\(calendar.component(.day, from: date))")
                                    .foregroundColor(Color(hex: background))
                                    .fontWeight(isToday(date) ? .bold : .regular)
                            }
                        }
                        .frame(height: 40)
                    } else {
                        Spacer().frame(height: 40)
                    }
                }
            }
        }
        .frame(width: width, height: width-50)
        .padding()
        .background(Color(hex: accent))
        .cornerRadius(15)
    }

//change the moth
    private func changeMonth(by offset: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: offset, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    //get the month and year for the month change
    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
    
    //check if it is today to make the date bold
    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    //assign the days to their spot on the grid
    private func makeDays() -> [Date?] {
        var days: [Date?] = []
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        
        for _ in 1..<firstWeekday { days.append(nil) }
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day-1, to: firstDay) {
                days.append(date)
            }
        }
        return days
    }
    
    // Map severity to color
    private func color(forSeverity severity: Int64) -> Color {
        switch severity {
        case 1: return Color(hex: "#FFB950")
        case 2: return Color(hex: "#FFAD33")
        case 3: return Color(hex: "#FF931F")
        case 4: return Color(hex: "#FF7E33")
        case 5: return Color(hex: "#FA5E1F")
        case 6: return Color(hex: "#EC3F13")
        case 7: return Color(hex: "#B81702")
        case 8: return Color(hex: "#A50104")
        case 9: return Color(hex: "#8E0103")
        case 10: return Color(hex: "#7A0103")
        default: return Color.gray
        }
    }
}


//make a key for mapping the shapes to the symptoms
struct SymptomKey: View {
    let symptomToIcon: [String: String]
    var accent: String
    var width: CGFloat
    var itemHeight: CGFloat = 13

    var body: some View {
        self.generateContent()
            .frame(width: width, alignment: .leading)
    }

    private func generateContent() -> some View {
        var widthUsed: CGFloat = 0
        var rows: [[(String, String)]] = [[]]

        for symptom in symptomToIcon.keys.sorted() {
            let iconName = symptomToIcon[symptom] ?? "questionmark.square.fill"
            let displayText = String(symptom.prefix(12))
            let itemWidth = textWidth(for: displayText) + itemHeight

            if widthUsed + itemWidth > width {
                rows.append([])
                widthUsed = 0
            }
            rows[rows.count - 1].append((symptom, iconName))
            widthUsed += itemWidth
        }

        return VStack(alignment: .leading) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack {
                    ForEach(rows[rowIndex], id: \.0) { item in
                        HStack(spacing: 4) {
                            Image(systemName: item.1)
                                .resizable()
                                .scaledToFit()
                                .frame(width: itemHeight, height: itemHeight)
                                .foregroundColor(Color(hex: accent))
                            CustomText(text:String(item.0.prefix(12)), color: accent, textSize: 12)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        .padding(.vertical, 2)
                        .padding(.horizontal, 4)
                    }
                }
            }
        }
    }

    // Estimate width of text
    private func textWidth(for text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 14)
        let attributes = [NSAttributedString.Key.font: font]
        let size = text.size(withAttributes: attributes)
        return size.width
    }
}

//make the gradient bar for the severity key
struct SeverityKeyBar: View {
    var accent: String
    var width: CGFloat = 300
    var height: CGFloat = 20
    
    private let severityColors: [Color] = [Color(hex: "#FFB950"), Color(hex: "#FFAD33"), Color(hex: "#FF931F"), Color(hex: "#FF7E33"), Color(hex: "#FA5E1F"), Color(hex: "#EC3F13"), Color(hex: "#B81702"),  Color(hex: "#A50104"), Color(hex: "#8E0103"), Color(hex: "#7A0103")]
    
    var body: some View {
        VStack{
            // gradient bar
            RoundedRectangle(cornerRadius: width / 2)
                .fill(LinearGradient(gradient: Gradient(colors: severityColors), startPoint: .leading, endPoint: .trailing))
                .frame(width: width, height: height)
            
            //Labels
            HStack(spacing: 0) {
                ForEach((1...10), id: \.self) { i in
                    CustomText(text:"\(i)", color:accent,  textAlign: .center, textSize: 14)
                        .frame(width: width / 10)
                }
            }
            .frame(height: height)
        }
        .frame(width: width,  height: height, alignment: .top)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.top, 15)
        .padding(.bottom, 40)
    }
}

struct HiddenChart: View {
    var bg: String
    var accent: String
    var chart: String
    var width: CGFloat
    @Binding var hideChart: Bool
    
    var body: some View {
        let buttonText = "Show \(chart) Visual"
        // Calculate text width using system font that matches your button text size
        let textWidth = buttonText.width(usingFont: .systemFont(ofSize: 25, weight: .regular))
        
        HStack {
            CustomButton(
                text: buttonText,
                bg: bg,
                accent: accent,
                height: 50,
                width: textWidth + 60, // Add some horizontal padding
                corner: 30,
                bold: false,
                textSize: 25,
                action: { hideChart.toggle() }
            )
        }
        .frame(width: width)
    }
}
//
//struct SeverityPieChart: View {
//    var logList: [UnifiedLog]
//    var accent: String
//    
//    @State private var selectedSlice: String? = nil
//    
//    private var severityCounts: [(severity: String, count: Int)] {
//        let grouped = Dictionary(grouping: logList, by: { $0.severity })
//        return grouped
//            .map { (key, value) in (severity: String(key), count: value.count) }
//            .sorted { Int($0.severity)! < Int($1.severity)! } // fixed order
//    }
//    
//    var body: some View {
//        let chartSize: CGFloat = 250
//        let baseColor = Color(hex: accent)
//        
//        ZStack {
//            ForEach(severityCounts.indices, id: \.self) { idx in
//                let item = severityCounts[idx]
//                let start = startAngle(for: idx)
//                let end = endAngle(for: idx)
//                let mid = Angle(degrees: (start.degrees + end.degrees)/2)
//                
//                let sliceColor = baseColor.rotatedHue(by: Double(idx)/Double(severityCounts.count))
//                let hex = sliceColor.toHex() ?? accent
//                let textColor: Color = Color.isHexColorDark(hex) ? .white : .black
//                
//                // Draw slice
//                PieSliceShape(startAngle: start, endAngle: end)
//                    .fill(sliceColor)
//                    .frame(width: chartSize, height: chartSize)
//                    .onTapGesture {
//                        withAnimation {
//                            // Toggle selection
//                            if selectedSlice == item.severity {
//                                selectedSlice = nil
//                            } else {
//                                selectedSlice = item.severity
//                            }
//                        }
//                    }
//                
//                // Draw label
//                let radius = chartSize / 3
//                let x = chartSize/2 + CGFloat(cos(mid.radians)) * radius
//                let y = chartSize/2 + CGFloat(sin(mid.radians)) * radius
//                
//                Text(item.severity)
//                    .font(.system(size: 18, design: .serif))
//                    .foregroundColor(textColor)
//                    .position(x: x, y: y)
//                
//                // Draw dividing lines
//                PieSliceDivider(angle: start)
//                    .stroke(Color.black, lineWidth: 3)
//                
//                if idx == severityCounts.count - 1 {
//                    PieSliceDivider(angle: end)
//                        .stroke(Color.black, lineWidth: 3)
//                }
//            }
//            
//            // Tooltip popup
//            if let selected = selectedSlice,
//               let item = severityCounts.first(where: { $0.severity == selected }) {
//                Text("\(item.severity): \(item.count) item\(item.count > 1 ? "s" : "")")
//                    .padding(8)
//                    .background(Color(.systemBackground))
//                    .cornerRadius(8)
//                    .shadow(radius: 4)
//                    .transition(.scale.combined(with: .opacity))
//                    .onTapGesture {
//                        withAnimation { selectedSlice = nil }
//                    }
//            }
//        }
//        .frame(width: chartSize, height: chartSize)
//        .padding()
//    }
//    
//    // Calculate start angle of slice
//    private func startAngle(for index: Int) -> Angle {
//        let total = severityCounts.map(\.count).reduce(0, +)
//        let sumBefore = severityCounts.prefix(index).map(\.count).reduce(0, +)
//        return Angle(degrees: Double(sumBefore) / Double(total) * 360 - 90)
//    }
//    
//    // Calculate end angle of slice
//    private func endAngle(for index: Int) -> Angle {
//        let total = severityCounts.map(\.count).reduce(0, +)
//        let sumUpTo = severityCounts.prefix(index + 1).map(\.count).reduce(0, +)
//        return Angle(degrees: Double(sumUpTo) / Double(total) * 360 - 90)
//    }
//}
//
//// Pie slice shape
//struct PieSliceShape: Shape {
//    var startAngle: Angle
//    var endAngle: Angle
//    
//    func path(in rect: CGRect) -> Path {
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let radius = min(rect.width, rect.height) / 2
//        
//        var path = Path()
//        path.move(to: center)
//        path.addArc(center: center,
//                    radius: radius,
//                    startAngle: startAngle,
//                    endAngle: endAngle,
//                    clockwise: false)
//        path.closeSubpath()
//        return path
//    }
//}
//
//// Divider line
//struct PieSliceDivider: Shape {
//    var angle: Angle
//    
//    func path(in rect: CGRect) -> Path {
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let radius = min(rect.width, rect.height) / 2
//        let endPoint = CGPoint(
//            x: center.x + CGFloat(cos(angle.radians)) * radius,
//            y: center.y + CGFloat(sin(angle.radians)) * radius
//        )
//        
//        var path = Path()
//        path.move(to: center)
//        path.addLine(to: endPoint)
//        return path
//    }
//}

// Struct for bullet list items
struct SymptomCount: Identifiable {
    let id = UUID()
    let symptom: String
    let count: Int
}

import SwiftUI

// MARK: - Main Pie Chart View
struct SeverityPieChart: View {
    var logList: [UnifiedLog]
    var accent: String
    var bg: String
    
    @State private var selectedSlice: String? = nil
    
    // Count logs per severity
    private var severityCounts: [(severity: String, count: Int)] {
        let grouped = Dictionary(grouping: logList, by: { $0.severity })
        return grouped
            .map { (severity: String($0.key), count: $0.value.count) }
            .sorted { Int($0.severity)! < Int($1.severity)! }
    }
    
    var body: some View {
        let chartSize: CGFloat = 250
        let baseColor = Color(hex: accent)
        let popOutOffset: CGFloat = 15
        
        ZStack {
            // Draw slices
            ForEach(severityCounts.indices, id: \.self) { idx in
                let item = severityCounts[idx]
                let start = startAngle(for: idx)
                let end = endAngle(for: idx)
                let mid = Angle(degrees: (start.degrees + end.degrees)/2)
                
                let sliceColor = baseColor.rotatedHue(by: Double(idx)/Double(severityCounts.count))
                let hex = sliceColor.toHex() ?? accent
                let textColor: Color = Color.isHexColorDark(hex) ? .white : .black
                
                // Determine offset if selected
                let isSelected = selectedSlice == item.severity
                let dx = isSelected ? CGFloat(cos(mid.radians)) * popOutOffset : 0
                let dy = isSelected ? CGFloat(sin(mid.radians)) * popOutOffset : 0
                
                // Draw slice with popout
                PieSliceShape(startAngle: start, endAngle: end)
                    .fill(sliceColor)
                    .frame(width: chartSize, height: chartSize)
                    .offset(x: dx, y: dy)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            if selectedSlice == item.severity {
                                selectedSlice = nil
                            } else {
                                selectedSlice = item.severity
                            }
                        }
                    }
                
                // Draw label inside slice
                let radius = chartSize / 3
                let x = chartSize/2 + CGFloat(cos(mid.radians)) * radius + dx
                let y = chartSize/2 + CGFloat(sin(mid.radians)) * radius + dy
                
                Text(item.severity)
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(textColor)
                    .position(x: x, y: y)
                
                // Draw dividing lines (attached to center)
                PieSliceDivider(angle: start)
                    .stroke(Color.black, lineWidth: 3)
                
                if idx == severityCounts.count - 1 {
                    PieSliceDivider(angle: end)
                        .stroke(Color.black, lineWidth: 3)
                }
            }
            
            // Tooltip popup
            // Tooltip popup
            if let selected = selectedSlice {
                let logsForSlice = logList.filter { String($0.severity) == selected }

                // Count logs per symptom
                let symptomCounts: [SymptomCount] = Dictionary(grouping: logsForSlice, by: { $0.symptom_name ?? "" })
                    .map { SymptomCount(symptom: $0.key, count: $0.value.count) }
                    .sorted { $0.symptom < $1.symptom }

                // Compute mid-angle of selected slice
                if let idx = severityCounts.firstIndex(where: { $0.severity == selected }) {
                    let start = startAngle(for: idx)
                    let end = endAngle(for: idx)
                    let mid = Angle(degrees: (start.degrees + end.degrees)/2)

                    let total = logsForSlice.count
                    let severityNumber = selected
                    let logText = total == 1 ? "Log" : "Logs"

                    // Offset distance for the tooltip
                    let tooltipOffset: CGFloat = 50
                    let dx = CGFloat(-cos(mid.radians)) * tooltipOffset
                    let dy = CGFloat(-sin(mid.radians)) * tooltipOffset

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Sev. \(severityNumber): \(total) \(logText) (\(Int(Double(total) / Double(logList.count) * 100))%)")
                            .foregroundColor(Color(hex: accent))
                            .font(.system(size: 18, design: .serif))

                        ForEach(symptomCounts) { item in
                            HStack(alignment: .top, spacing: 6) {
                                Text("•")
                                    .foregroundColor(Color(hex: accent))
                                    .font(.system(size: 16, design: .serif))
                                
                                // Truncate symptom to max 12 characters with ellipsis if needed
                                let maxLength = 8
                                let truncatedSymptom = item.symptom.count > maxLength
                                    ? String(item.symptom.prefix(maxLength)) + "…"
                                    : item.symptom
                                
                                Text("\(truncatedSymptom): \(item.count) (\(Int(Double(item.count) / Double(total) * 100))%)")
                                    .foregroundColor(Color(hex: accent))
                                    .font(.system(size: 16, design: .serif))
                            }
                        }

                    }
                    .padding(15)
                    .background(Color(hex: bg))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(hex: accent), lineWidth: 5)
                    )
                    .cornerRadius(15)
                    .offset(x: dx, y: dy) // move diagonally from slice
                    .transition(.scale.combined(with: .opacity))
                    .onTapGesture {
                        withAnimation { selectedSlice = nil }
                    }
                }
            }

        }
        .frame(width: chartSize, height: chartSize)
        .padding()
    }
    
    // MARK: - Angle helpers
    private func startAngle(for index: Int) -> Angle {
        let total = severityCounts.map(\.count).reduce(0, +)
        let sumBefore = severityCounts.prefix(index).map(\.count).reduce(0, +)
        return Angle(degrees: Double(sumBefore) / Double(total) * 360 - 90)
    }
    
    private func endAngle(for index: Int) -> Angle {
        let total = severityCounts.map(\.count).reduce(0, +)
        let sumUpTo = severityCounts.prefix(index + 1).map(\.count).reduce(0, +)
        return Angle(degrees: Double(sumUpTo) / Double(total) * 360 - 90)
    }
}

// MARK: - Pie slice shape
struct PieSliceShape: Shape {
    var startAngle: Angle
    var endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        var path = Path()
        path.move(to: center)
        path.addArc(center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        path.closeSubpath()
        return path
    }
}

// MARK: - Divider line
struct PieSliceDivider: Shape {
    var angle: Angle
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let endPoint = CGPoint(
            x: center.x + CGFloat(cos(angle.radians)) * radius,
            y: center.y + CGFloat(sin(angle.radians)) * radius
        )
        
        var path = Path()
        path.move(to: center)
        path.addLine(to: endPoint)
        return path
    }
}
