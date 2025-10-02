//
//  Table Styles.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SwiftUI

// MARK: - Table View
struct ScrollableLogTable: View {
    var userID: Int64
    var logList: [LogList]
    @State var background: String
    @State var accent: String
    var width: CGFloat
    
    var onLogTap: ((Int64, String) -> Void)? = nil

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .short
        return f
    }

    var body: some View {
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section(header: tableHeader) {
                        ForEach(logList, id: \.id) { log in
                            row(for: log)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    onLogTap?(log.log_id, log.log_type) // pass table name if needed
                                    }

                            if log.id != logList.last?.id {
                                Divider()
                                    .frame(width: width, height: 1)
                                    .background(Color(hex: background).opacity(0.5))
                            }
                        }
                    }
                }
                .frame(width: width)
                .background(Color(hex: accent))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(hex: background).opacity(0.5), lineWidth: 1))
        }
        .frame(width: width, height: 300)
    }

    // MARK: - Row Builder
    private func row(for logList: LogList) -> some View {
        HStack(spacing: 0) {
            CustomText(text: logList.log_type, color: background, width: 110, textAlignment: .center, textSize: 16)
                .padding(.vertical, 5)

            Divider().frame(width: 1, height: 30)
                .background(Color(hex: background).opacity(0.5))

            CustomText(text: logList.symptom, color: background, textAlignment: .center, textSize: 16)
                .padding(.vertical, 5)

            Divider().frame(width: 1, height: 30)
                .background(Color(hex: background).opacity(0.5))

            CustomText(text: dateFormatter.string(from: logList.date), color: background, width: 65, textAlignment: .center, textSize: 16)
                .padding(.vertical, 5)

            Divider().frame(width: 1, height: 30)
                .background(Color(hex: background).opacity(0.5))

            CustomText(text: "\(logList.severity)", color: background, width: 55, textAlignment: .center, textSize: 16)
                .padding(.vertical, 5)
        }
        .background(Color(hex: accent))
    }

    // MARK: - Header
    private var tableHeader: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                CustomText(text:"Log Type", color:background, width:110, textAlignment: .center, isBold: true, textSize: 18)
                    .padding(.vertical, 5)

                Divider().frame(width: 1, height: 30)
                    .background(Color(hex: background).opacity(0.5))

                CustomText(text:"Symptom", color:background, textAlignment: .center, isBold: true, textSize: 18)
                    .padding(.vertical, 5)

                Divider().frame(width: 1, height: 30)
                    .background(Color(hex: background).opacity(0.5))

                CustomText(text:"Date", color:background, width:65, textAlignment: .center, isBold: true, textSize: 18)
                    .padding(.vertical, 5)

                Divider().frame(width: 1, height: 30)
                    .background(Color(hex: background).opacity(0.5))

                CustomText(text:"Sev.", color:background, width:55, textAlignment: .center, isBold: true, textSize: 18)
                    .padding(.vertical, 5)
            }
            .background(Color(hex: accent))

            Divider()
                .frame(width: width, height: 2)
                .background(Color(hex: background).opacity(0.5))
        }
        .background(Color(hex: accent))
    }
}
