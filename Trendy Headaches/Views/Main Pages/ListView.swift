//
//  ListView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 9/19/25.
//

import SwiftUI

struct ListView: View {
    var userID: Int64
    @Binding var background: String
    @Binding var accent: String

    @State private var selectedLogID: Int64? = nil
    @State private var selectedLogTable: String? = nil
    @State private var showLogCreation: Bool = false
    
    @State private var logList: [UnifiedLog] = []
    @State private var showFilterPopup: Bool = false
    
    @State var columnOptions: [String] = ["Log Type", "Date", "Symptom", "Sev.", "Onset (S)", "Emerg. Med. Taken?", "Emerg. Med. Name", "Emerg. Med. Worked?", "Triggers (S)", "Symp. Desc. (S)", "Notes (S)", "Med. (SE)"]
    @State var selectedColumns: [String] = ["Log Type", "Date", "Symptom", "Sev."]
    
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    
    @State var stringStartDate: String = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
    @State var stringEndDate: String = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
    
    @State var sevStart: Int64 = 1
    @State var sevEnd: Int64 = 10
    
    @State var logTypeFilter: [String] = ["Symptom", "Side Effect"]
    
    @State var symptomOptions: [String] = []
    @State var selectedSymptoms: [String] = []
    
    
    var screenWidth: CGFloat = UIScreen.main.bounds.width
    var screenHeight: CGFloat = UIScreen.main.bounds.height
    
    //height minus the blob height
    var popupHeight: CGFloat = UIScreen.main.bounds.height-150 - 170 - 110
    
    func filterLogs() {
        let allLogs = DatabaseManager.shared.getLogList(userID: userID)
        logList = allLogs.filter { log in
            // Filter by log type
            guard logTypeFilter.contains(log.log_type) else { return false }
            
            // Filter by start date
            if log.date < startDate { return false }
            
            // Filter by end date
            if log.date > endDate { return false }
            
            if log.severity < sevStart { return false }
            if log.severity > sevEnd { return false }
            
            // ✅ Extract unique, non-empty symptom names
            symptomOptions = Array(Set(logList.compactMap { log in
                if let symptom = log.symptom_name, !symptom.isEmpty {
                    return symptom
                } else {
                    return nil
                }
            })).sorted()
            
            // Optionally initialize selectedSymptoms to all available ones
            selectedSymptoms = symptomOptions
            
            return true
        }
    }


    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: background).ignoresSafeArea()
                
                SameAmplitudeBlob(waves: 4, amplitude: 20, accent: accent, x: 30, y: -375, rotation: 0, width:350, height:170)
                    .zIndex(5)
                SameAmplitudeBlob(waves: 4, amplitude: 20, accent: accent, x: 30, y: -270, rotation: 180, width:350, height:150)
                    .zIndex(5)
                
                VStack {
                    HStack{
                        CustomText(text: "List View", color: accent, width:210, textAlignment: .leading,  multilineAlignment: .leading,  textSize: 53)
                        .padding(.leading, 20)
                        Spacer()
                       
                    }
                    .padding(.top, 25)
                    
                    HStack{
                        Spacer()
                        ScrollableLogTable( userID: userID, logList: logList, selectedColumns: selectedColumns, background: background, accent: accent, height: popupHeight, width: screenWidth - 20, onLogTap: { id, table in
                            selectedLogID = id
                            selectedLogTable = table
                        })
                        Spacer()
                    }
                    Spacer()
                }
                
                if showFilterPopup {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            filterPopUp(accent: accent, background: background, columnOptions: columnOptions, selectedColumns: $selectedColumns, logType: $logTypeFilter, startDate: $startDate, endDate: $endDate, stringStartDate: $stringStartDate, stringEndDate: $stringEndDate, sevStart: $sevStart, sevEnd: $sevEnd, symptomOptions: $symptomOptions, selectedSymptoms: $selectedSymptoms)
                                .padding(.trailing, 20)
                                .padding(.bottom, 120) 
                            
                        }
                    }
                    .transition(.move(edge: .bottom))
                    .zIndex(10)
                }

                // filter button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FilterDropDown(background: background, accent: accent, showPopUp: $showFilterPopup)
                    }
                    .padding(.bottom, 80)
                }
                
                //nav bar
                VStack {
                    Spacer()
                    NavBarView(userID: userID, background: $background,  accent: $accent)
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(1)
            }
            .navigationDestination(isPresented: $showLogCreation) {
                LogView(userID: userID, background: $background, accent: $accent)
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(
                isPresented: Binding(
                    get: { selectedLogID != nil },
                    set: { if !$0 { selectedLogID = nil } } ) ) {
                if let id = selectedLogID, let table = selectedLogTable {
                    LogView(userID: userID, existingLogID: id, existingLogTable: table, background: $background, accent: $accent)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
        .onAppear{
            logList = DatabaseManager.shared.getLogList(userID: userID)
            
            if let earliest = logList.map({ $0.date }).min() {
                startDate = earliest
                stringStartDate = DateFormatter.localizedString(from: earliest, dateStyle: .short, timeStyle: .none)
            }
        }
        .onChange(of: startDate) {  filterLogs() }
        .onChange(of: endDate) { filterLogs() }
        .onChange(of: logTypeFilter) {  filterLogs() }
        .onChange(of: sevStart) { filterLogs() }
        .onChange(of: sevEnd) {  filterLogs() }
    }
}

#Preview {
    ListView(userID: 1, background: .constant("#001d00"), accent: .constant("#b5c4b9"))
}

