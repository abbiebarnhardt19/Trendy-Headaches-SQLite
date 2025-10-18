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
    @State private var hideCalendar: Bool = true
    @State private var hideSeverity: Bool = false
    @State private var hideFreqChart: Bool = true
    
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
                        .padding(.vertical, 25)
                        .padding(.trailing, 20)

                        if !hideCalendar{
                            CalendarView(logs: logs, hideChart: $hideCalendar, bg: bg, accent: accent, width: screenWidth - 60, sympIcon: generateSymptomToIconMap(from: logs))
                        }
                        else{
                            HiddenChart(bg: bg, accent: accent, chart: "Calendar", width: screenWidth,  hideChart: $hideCalendar)
                        }
                        
                        if !hideSeverity{
                            SeverityPieChart(logList: logs, accent: accent, bg: bg, hideChart: $hideSeverity)
                                .padding(.bottom, 10)
                        }
                        else{
                            HiddenChart(bg: bg, accent: accent, chart: "Log Severity", width: screenWidth,  hideChart: $hideSeverity)
                        }
                        
                        if !hideFreqChart{
                            CustomStackedBarChart(logList: logs, accent: accent, bg: bg, width:screenWidth-40, hideChart: $hideFreqChart)
                        }
                        else{
                            HiddenChart(bg: bg, accent: accent, chart: "Logs by Symptom", width: screenWidth,  hideChart: $hideFreqChart)
                        }
                    }
                    .padding(.bottom, 150)
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
                }
            }
        }
    }
}

#Preview {
    AnalyticsView(userID: 1, bg: .constant("#001d00"), accent: .constant("#b5c4b9"))
}
