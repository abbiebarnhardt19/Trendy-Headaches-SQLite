import SwiftUI


struct CalendarView: View {
    let logs: [UnifiedLog]
    var background: String
    var accent: String
    var width: CGFloat // pass in width
    
    @State private var currentMonth: Date = Date()
    private let calendar = Calendar.current
    private let weekDays = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    
    // List of icons to cycle through
    let availableIcons = [
        "square.fill", "triangle.fill", "star.fill", "diamond.fill",
        "hexagon.fill", "heart.fill", "bolt.fill", "leaf.fill", "flame.fill"
    ]
    let unknownIcon = "questionmark.square.fill"

    // Keep a mapping from symptom name -> icon
    @State private var symptomToIcon: [String: String] = [:]

    func icon(for symptom: String?) -> String {
        guard let name = symptom, !name.isEmpty else {
            return unknownIcon
        }

        if let assignedIcon = symptomToIcon[name] {
            return assignedIcon
        } else {
            // Assign next available icon in a cycle
            let nextIcon = availableIcons[symptomToIcon.count % availableIcons.count]
            symptomToIcon[name] = nextIcon
            return nextIcon
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            // Month Navigation
            HStack {
                Button(action: { changeMonth(by: -1) }) { Image(systemName: "chevron.left")
                    .foregroundColor(Color(hex: background))}
                Spacer()
                Text(monthYearString(for: currentMonth))
                    .font(.headline)
                    .foregroundColor(Color(hex: background))
                Spacer()
                Button(action: { changeMonth(by: 1) }) { Image(systemName: "chevron.right")
                    .foregroundColor(Color(hex: background))}
            }
            
            // Weekday Labels
            HStack {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color(hex: background))
                }
            }
            
            
            // Calendar Grid
            // Calendar Grid
            let days = makeDays()
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(minimum: 0, maximum: .infinity)), count: 7),
                spacing: 10
            ) {
                ForEach(days.indices, id: \.self) { idx in
                    if let date = days[idx] {
                        ZStack {
                            let dayLogs = logs.filter { calendar.isDate($0.date, inSameDayAs: date) }
                            
                            if dayLogs.count == 1 {
                                // Single log: dot below number
                                VStack(spacing: 2) {
                                    Text("\(calendar.component(.day, from: date))")
                                        .foregroundColor(Color(hex: background))
                                        .fontWeight(isToday(date) ? .bold : .regular)
                                    
                                    Circle()
                                        .fill(color(forSeverity: dayLogs[0].severity))
                                        .frame(width: 5, height: 5)
                                        .padding(.top, 2)
                                }
                            } else if dayLogs.count > 1 {
                                // Multiple logs: use icons around number
                                ForEach(dayLogs.indices, id: \.self) { i in
                                    let log = dayLogs[i]
                                    let angle = Double(i) / Double(dayLogs.count) * 360
                                    let radius: CGFloat = 14
                                    let iconName = icon(for: log.symptom_name ?? "Unknown")

                                    Image(systemName: icon(for: log.symptom_name))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 8, height: 8)
                                        .foregroundColor(color(forSeverity: log.severity))
                                        .offset(
                                            x: cos(angle * .pi / 180) * radius,
                                            y: sin(angle * .pi / 180) * radius
                                        )

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

    
    // MARK: Helpers
    private func changeMonth(by offset: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: offset, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    private func makeDays() -> [Date?] {
        var days: [Date?] = []
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstDay) // 1 = Sunday
        
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
        default: return Color.gray // fallback
        }
    }
}


//
//
//struct CalendarView: View {
//    let logs: [UnifiedLog]
//    var background: String
//    var accent: String
//    var width: CGFloat // pass in width
//    
//    @State private var currentMonth: Date = Date()
//    private let calendar = Calendar.current
//    private let weekDays = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
//    
//    var body: some View {
//        VStack(spacing: 10) {
//            // Month Navigation
//            HStack {
//                Button(action: { changeMonth(by: -1) }) { Image(systemName: "chevron.left")
//                    .foregroundColor(Color(hex: background))}
//                Spacer()
//                Text(monthYearString(for: currentMonth))
//                    .font(.headline)
//                    .foregroundColor(Color(hex: background))
//                Spacer()
//                Button(action: { changeMonth(by: 1) }) { Image(systemName: "chevron.right")
//                    .foregroundColor(Color(hex: background))}
//            }
//            
//            // Weekday Labels
//            HStack {
//                ForEach(weekDays, id: \.self) { day in
//                    Text(day)
//                        .font(.subheadline)
//                        .frame(maxWidth: .infinity)
//                        .foregroundColor(Color(hex: background))
//                }
//            }
//            
//            
//            // Calendar Grid
//            // Calendar Grid
//            let days = makeDays()
//            LazyVGrid(
//                columns: Array(repeating: GridItem(.flexible(minimum: 0, maximum: .infinity)), count: 7),
//                spacing: 10
//            ) {
//                ForEach(days.indices, id: \.self) { idx in
//                    if let date = days[idx] {
//                        ZStack {
//                            let dayLogs = logs.filter { calendar.isDate($0.date, inSameDayAs: date) }
//                            
//                            if dayLogs.count == 1 {
//                                // Single log: dot below number
//                                VStack(spacing: 2) {
//                                    Text("\(calendar.component(.day, from: date))")
//                                        .foregroundColor(Color(hex: background))
//                                        .fontWeight(isToday(date) ? .bold : .regular)
//                                    
//                                    Circle()
//                                        .fill(color(forSeverity: dayLogs[0].severity))
//                                        .frame(width: 6, height: 6)
//                                        .padding(.top, 2)
//                                }
//                            } else if dayLogs.count > 1 {
//                                // Multiple logs: circle around number
//                                ForEach(dayLogs.indices, id: \.self) { i in
//                                    let log = dayLogs[i]
//                                    let angle = Double(i) / Double(dayLogs.count) * 360
//                                    let radius: CGFloat = 13
//                                    
//                                    Circle()
//                                        .fill(color(forSeverity: log.severity))
//                                        .frame(width: 6, height: 6)
//                                        .offset(x: cos(angle * .pi / 180) * radius,
//                                                y: sin(angle * .pi / 180) * radius)
//                                }
//                                
//                                // Day number in center
//                                Text("\(calendar.component(.day, from: date))")
//                                    .foregroundColor(Color(hex: background))
//                                    .fontWeight(isToday(date) ? .bold : .regular)
//                            } else {
//                                // No logs
//                                Text("\(calendar.component(.day, from: date))")
//                                    .foregroundColor(Color(hex: background))
//                                    .fontWeight(isToday(date) ? .bold : .regular)
//                            }
//                        }
//                        .frame(height: 40)
//                    } else {
//                        Spacer().frame(height: 40)
//                    }
//                }
//            }
//        }
//        .frame(width: width, height: width)
//        .padding()
//        .background(Color(hex: accent))
//        .cornerRadius(15)
//    }
//
//    
//    // MARK: Helpers
//    private func changeMonth(by offset: Int) {
//        if let newMonth = calendar.date(byAdding: .month, value: offset, to: currentMonth) {
//            currentMonth = newMonth
//        }
//    }
//    
//    private func monthYearString(for date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "LLLL yyyy"
//        return formatter.string(from: date)
//    }
//    
//    private func isToday(_ date: Date) -> Bool {
//        calendar.isDateInToday(date)
//    }
//    
//    private func makeDays() -> [Date?] {
//        var days: [Date?] = []
//        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
//        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
//        let firstWeekday = calendar.component(.weekday, from: firstDay) // 1 = Sunday
//        
//        for _ in 1..<firstWeekday { days.append(nil) }
//        for day in range {
//            if let date = calendar.date(byAdding: .day, value: day-1, to: firstDay) {
//                days.append(date)
//            }
//        }
//        return days
//    }
//    
//    // Map severity to color
//    private func color(forSeverity severity: Int64) -> Color {
//        switch severity {
//        case 1: return Color(hex: "#FFB950")
//        case 2: return Color(hex: "#FFAD33")
//        case 3: return Color(hex: "#FF931F")
//        case 4: return Color(hex: "#FF7E33")
//        case 5: return Color(hex: "#FA5E1F")
//        case 6: return Color(hex: "#EC3F13")
//        case 7: return Color(hex: "#B81702")
//        case 8: return Color(hex: "#A50104")
//        case 9: return Color(hex: "#8E0103")
//        case 10: return Color(hex: "#7A0103")
//        default: return Color.gray // fallback
//        }
//    }
//}

struct SeverityKeyBar: View {
    var accent: String
    var width: CGFloat = 20
    var height: CGFloat = 300
    
    private let severityColors: [Color] = [
        Color(hex: "#FFB950"), // 1
        Color(hex: "#FFAD33"), // 2
        Color(hex: "#FF931F"), // 3
        Color(hex: "#FF7E33"), // 4
        Color(hex: "#FA5E1F"), // 5
        Color(hex: "#EC3F13"), // 6
        Color(hex: "#B81702"), // 7
        Color(hex: "#A50104"), // 8
        Color(hex: "#8E0103"), // 9
        Color(hex: "#7A0103")  // 10
    ]
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Vertical gradient bar
            RoundedRectangle(cornerRadius: width / 2)
                .fill(LinearGradient(
                    gradient: Gradient(colors: severityColors),
                    startPoint: .bottom,
                    endPoint: .top
                ))
                .frame(width: width, height: height)
            
            // Number labels evenly spaced
            VStack(spacing: 0) {
                ForEach((1...10).reversed(), id: \.self) { i in
                    CustomText(text:"\(i)", color:accent,  textAlignment: .center, textSize: 14)
                        .frame(height: height / 10)
                }
            }
            .frame(height: height) // Make sure VStack matches the bar height
        }
        .frame(width: width + 30, height: height, alignment: .top) // HStack fixed size
        .fixedSize(horizontal: false, vertical: true)
        .padding(.trailing, 10)
    }
}
