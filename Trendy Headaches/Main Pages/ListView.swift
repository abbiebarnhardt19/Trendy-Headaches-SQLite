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
    
    @State private var logList: [LogList] = []

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: background).ignoresSafeArea()
                
                SameAmplitudeBlob(waves: 4, amplitude: 20, accent: accent, x: 30, y: -365, rotation: 0, width:350, height:150)
                SameAmplitudeBlob(waves: 4, amplitude: 20, accent: accent, x: 30, y: -270, rotation: 180, width:350, height:150)

                VStack {
                    HStack{
                        CustomText(text: "List View", color: accent, width:100, textAlignment: .leading,  multilineAlignment: .leading,  textSize: 43)
                        .padding(.leading, 50)
                        Spacer()
                    }
                    
                    ScrollableLogTable( userID: userID, logList: logList, background: background, accent: accent, width: UIScreen.main.bounds.width - 20, onLogTap: { id, table in
                            selectedLogID = id
                            selectedLogTable = table
                        })
                    Spacer()
                }

                // Floating "Add" button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showLogCreation = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 36))
                                .foregroundColor(Color(hex: background))
                                .frame(width: 60, height: 60)
                                .background(Color(hex: accent))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 30)
                    }
                    .padding(.bottom, 80)
                }
                
                VStack {
                    Spacer()
                    NavBarView(
                        userID: userID,
                        background: $background,
                        accent: $accent
                    )
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(1)
            }
            .navigationDestination(isPresented: $showLogCreation) {
                LogView(userID: userID, background: $background, accent: $accent)
            }
            .navigationDestination(
                isPresented: Binding(
                    get: { selectedLogID != nil },
                    set: { if !$0 { selectedLogID = nil } }
                )
            ) {
                if let id = selectedLogID, let table = selectedLogTable {
                    LogView(userID: userID, existingLogID: id, existingLogTable: table, background: $background, accent: $accent)
                }
            }

        }
        .onAppear{
            logList = DatabaseManager.shared.getLogList(userID: userID)
        }
    }
}


#Preview {
    ListView(userID: 1, background: .constant("#001d00"), accent: .constant("#b5c4b9"))
}

