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

    var body: some View {
        NavigationStack {
            ZStack {
                // Your background and blobs

                VStack {
                    ScrollableLogTable(
                        userID: userID,
                        background: background,
                        accent: accent,
                        width: UIScreen.main.bounds.width - 30,
                        onLogTap: { id, table in
                            selectedLogID = id
                            selectedLogTable = table
                        }
                    )
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
    }
}


#Preview {
    ListView(userID: 1, background: .constant("#001d00"), accent: .constant("#b5c4b9"))
}

