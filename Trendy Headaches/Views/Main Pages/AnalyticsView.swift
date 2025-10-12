//
//  AnalyticsView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/31/25.
//

import SwiftUI

struct AnalyticsView: View {
    
    var userID: Int64
    @Binding var bg: String
    @Binding var accent: String
    
    @State var logs: [UnifiedLog] = []
    
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
    
    @State private var calKey: Bool = false
    @State private var hideCalendar: Bool = false
    
    // List of icons to cycle through
    let icons = [ "circle.fill",  "square.fill",  "triangle.fill", "star.fill", "diamond.fill", "hexagon.fill", "heart.fill", "bolt.fill", "leaf.fill", "flame.fill"]

    // Keep a mapping from symptom name -> icon
    @State private var symptomToIcon: [String: String] = [:]

    //assign the icons to the symptoms
    func icon(for symptom: String?) -> String {
        guard let name = symptom, !name.isEmpty else {
            return  "questionmark.square.fill"
        }

        if let assignedIcon = symptomToIcon[name] {
            return assignedIcon
        } else {
            // Assign next available icon in a cycle
            let nextIcon = icons[symptomToIcon.count % icons.count]
            symptomToIcon[name] = nextIcon
            return nextIcon
        }
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                AnalyticsBGComps(bg: bg, accent: accent)
                ScrollView{
                    VStack(spacing: 0) {
                        HStack{
                            Spacer()
                            CustomText(text: "Analytics", color: accent, width: 220, textSize: 53)
                        }
                        .frame(width: screenWidth)
                        .padding(.bottom, 20)
                        .padding(.trailing, 60)
                        .padding(.top, 30)

                        if !hideCalendar{
                            HStack{
                                CalendarView(logs: logs, showKey: $calKey, hideChart: $hideCalendar, background: bg, accent: accent, width:screenWidth-60, symptomToIcon: symptomToIcon)
                                    .padding(.horizontal, 10)
                            }
                            if calKey{
                                SeverityKeyBar(accent: accent, width: screenWidth-40, height:20)
                                SymptomKey(symptomToIcon: symptomToIcon, accent: accent, width: screenWidth-40)
                            }
                        }
                        else{
                            HiddenChart(bg: bg, accent: accent, chart: "Calendar", width: screenWidth,  hideChart: $hideCalendar)
                        }
                    }
                }
                
                // Nav bar overlay at bottom
                VStack {
                    Spacer()
                    NavBarView(userID: userID, bg: $bg,  accent: $accent, selected: .constant(2))
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(10)
                .onAppear{
                    logs = Database.shared.getLogList(userID: userID)
                    var mapping: [String: String] = [:]
                    for (index, symptom) in Set(logs.compactMap { $0.symptom_name }).sorted().enumerated() {
                        mapping[symptom] = icons[index % icons.count]
                    }
                    symptomToIcon = mapping
                }
            }
        }
    }
}


#Preview {
    AnalyticsView(userID: 1, bg: .constant("#001d00"), accent: .constant("#b5c4b9"))
}
