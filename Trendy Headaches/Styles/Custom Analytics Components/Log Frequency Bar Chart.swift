//
//  Log Frequency Bar Chart.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/14/25.
//

import SwiftUI
//
//struct CustomStackedBarChart: View {
//    var logList: [UnifiedLog]
//    var accent: String
//    var background: String
//
//    @State private var selectedMonth: Date? = nil
//
//    // MARK: - Aggregated Data
//    private var monthlySymptomData: [(month: Date, symptoms: [(symptom: String, count: Int)])] {
//        let calendar = Calendar.current
//        let now = Date()
//        let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
//
//        // Start from first day of one year ago
//        let startMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: oneYearAgo))!
//
//        // List of the past 12 months (inclusive)
//        let months: [Date] = (0..<12).compactMap { offset in
//            calendar.date(byAdding: .month, value: offset, to: startMonth)
//        }
//
//        // Filter logs within the last year
//        let filtered = logList.filter { $0.date >= startMonth }
//
//        // Group logs by month start
//        let byMonth = Dictionary(grouping: filtered) { log -> Date in
//            let comps = calendar.dateComponents([.year, .month], from: log.date)
//            return calendar.date(from: comps)!
//        }
//
//        // Ensure every month has an entry (even empty)
//        let result: [(Date, [(String, Int)])] = months.map { month in
//            if let logs = byMonth[month] {
//                let symptomGroups = Dictionary(grouping: logs, by: { log in
//                    log.symptom_name ?? "Unknown"
//                })
//                let counts = symptomGroups.map { (symptom, logs) in
//                    (symptom, logs.count)
//                }
//                return (month, counts.sorted(by: { $0.0 < $1.0 }))
//            } else {
//                return (month, [])
//            }
//        }
//
//        return result
//    }
//
//    // MARK: - Computed Max
//    private var maxCount: Int {
//        let totalCounts = monthlySymptomData.map { $0.symptoms.map(\.count).reduce(0, +) }
//        let maxVal = totalCounts.max() ?? 0
//        return max(maxVal, 1) // avoid dividing by 0
//    }
//
//    // MARK: - Body
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Headache Symptoms by Month")
//                .font(.headline)
//                .padding(.horizontal)
//
//            HStack(alignment: .bottom, spacing: 10) {
//                ForEach(monthlySymptomData, id: \.month) { monthData in
//                    VStack {
//                        GeometryReader { geo in
//                            ZStack(alignment: .bottom) {
//                                // Empty background bar
//                                RoundedRectangle(cornerRadius: 3)
//                                    .fill(Color.gray.opacity(0.1))
//
//                                if !monthData.symptoms.isEmpty {
//                                    VStack(spacing: 0) {
//                                        ForEach(monthData.symptoms, id: \.symptom) { symptomData in
//                                            let heightRatio = CGFloat(symptomData.count) / CGFloat(maxCount)
//                                            Rectangle()
//                                                .fill(colorForSymptom(symptomData.symptom))
//                                                .frame(height: geo.size.height * heightRatio)
//                                                .overlay(
//                                                    RoundedRectangle(cornerRadius: 2)
//                                                        .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
//                                                )
//                                        }
//                                    }
//                                    .animation(.easeInOut(duration: 0.35), value: monthData.symptoms)
//                                } else {
//                                    RoundedRectangle(cornerRadius: 3)
//                                        .fill(Color.gray.opacity(0.25))
//                                        .frame(height: 4)
//                                }
//                            }
//                        }
//                        .frame(height: 200)
//                        .onTapGesture {
//                            withAnimation(.easeInOut) {
//                                selectedMonth = monthData.month == selectedMonth ? nil : monthData.month
//                            }
//                        }
//
//                        // Month label
//                        Text(shortMonthFormatter.string(from: monthData.month))
//                            .font(.caption)
//                            .foregroundStyle(.secondary)
//                    }
//                    .frame(maxWidth: .infinity)
//                }
//            }
//            .padding(.horizontal)
//            .frame(height: 250)
//
//            // Detail section
//            if let selectedMonth = selectedMonth,
//               let monthData = monthlySymptomData.first(where: { $0.month == selectedMonth }) {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("Details for \(monthFormatter.string(from: selectedMonth)):")
//                        .font(.subheadline)
//                        .bold()
//
//                    if monthData.symptoms.isEmpty {
//                        Text("No symptoms logged this month.")
//                            .font(.caption)
//                            .foregroundStyle(.secondary)
//                    } else {
//                        ForEach(monthData.symptoms, id: \.symptom) { data in
//                            HStack {
//                                Circle()
//                                    .fill(colorForSymptom(data.symptom))
//                                    .frame(width: 10, height: 10)
//                                Text("\(data.symptom): \(data.count)")
//                                    .font(.caption)
//                            }
//                        }
//                    }
//                }
//                .padding(.horizontal)
//                .transition(.opacity.combined(with: .slide))
//            }
//        }
//        .padding(.vertical)
//        .background(Color(hex: background).opacity(0.15))
//        .cornerRadius(15)
//        .padding()
//    }
//
//    // MARK: - Helpers
//    private func colorForSymptom(_ symptom: String) -> Color {
//        let hash = abs(symptom.hashValue)
//        let hue = Double(hash % 360) / 360.0
//        return Color(hue: hue, saturation: 0.6, brightness: 0.8)
//    }
//
//    private var shortMonthFormatter: DateFormatter {
//        let df = DateFormatter()
//        df.dateFormat = "MMM"
//        return df
//    }
//
//    private var monthFormatter: DateFormatter {
//        let df = DateFormatter()
//        df.dateFormat = "MMMM yyyy"
//        return df
//    }
//}
