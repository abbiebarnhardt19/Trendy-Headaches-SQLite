//
//  Custom Analytics Components.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SwiftUI

struct CalendarView: View {
    let logs: [UnifiedLog]
    @Binding var showKey: Bool
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
    
    var body: some View {
        VStack(spacing: 10) {
            // Month Navigation
            HStack {
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
                    CustomText(text:showKey ? "Dismiss Key" : "Show Key", color: accent,  width:110, textAlign: .center, textSize: 16)
                        .frame(height: 27)
                        .background(Color(hex: background))
                        .cornerRadius(20)
                }
                .padding(.trailing, 5)
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
        .frame(width: width, height: width)
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
    var width: CGFloat = 20
    var height: CGFloat = 300
    
    private let severityColors: [Color] = [Color(hex: "#FFB950"), Color(hex: "#FFAD33"), Color(hex: "#FF931F"), Color(hex: "#FF7E33"), Color(hex: "#FA5E1F"), Color(hex: "#EC3F13"), Color(hex: "#B81702"),  Color(hex: "#A50104"), Color(hex: "#8E0103"), Color(hex: "#7A0103")]
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // gradient bar
            RoundedRectangle(cornerRadius: width / 2)
                .fill(LinearGradient(gradient: Gradient(colors: severityColors), startPoint: .bottom, endPoint: .top))
                .frame(width: width, height: height)
            
            //Labels
            VStack(spacing: 0) {
                ForEach((1...10).reversed(), id: \.self) { i in
                    CustomText(text:"\(i)", color:accent,  textAlign: .center, textSize: 14)
                        .frame(height: height / 10)
                }
            }
            .frame(height: height)
        }
        .frame(width: width + 30, height: height, alignment: .top)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.trailing, 10)
    }
}
