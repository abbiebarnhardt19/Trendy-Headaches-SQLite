//
//  Log Frequency Bar Chart.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/14/25.

import SwiftUI

struct CustomStackedBarChart: View {
    var logList: [UnifiedLog]
    var accent: String
    var bg: String
    var width: CGFloat

    private var monthlySymptomData: [(month: Date, symptoms: [(symptom: String, count: Int)])] {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let startMonth = calendar.date(byAdding: .month, value: -11, to: currentMonth)!
        let months = (0...11).compactMap { calendar.date(byAdding: .month, value: $0, to: startMonth) }
        let filtered = logList.filter { $0.date >= startMonth }
        let byMonth = Dictionary(grouping: filtered) { log -> Date in
            let comps = calendar.dateComponents([.year, .month], from: log.date)
            return calendar.date(from: comps)!
        }
        return months.map { month in
            if let logs = byMonth[month] {
                let symptomGroups = Dictionary(grouping: logs, by: { $0.symptom_name ?? "Unknown" })
                let counts = symptomGroups.map { (symptom, logs) in (symptom, logs.count) }
                return (month, counts.sorted { $0.0 < $1.0 })
            } else {
                return (month, [])
            }
        }
    }

    private var maxCount: Int {
        max(monthlySymptomData.map { $0.symptoms.map(\.count).reduce(0, +) }.max() ?? 1, 1)
    }

    var body: some View {
        let baseColor = Color(hex: accent)
        let allSymptoms = Array(Set(monthlySymptomData.flatMap { $0.symptoms.map { $0.symptom } }))
        let colorPalette = baseColor.generateHarmoniousColors(from: baseColor, count: allSymptoms.count)
        let colorMap = Dictionary(uniqueKeysWithValues: zip(allSymptoms, colorPalette))

        let yDivisions = min(5, maxCount > 0 ? maxCount : 5)
        let chartHeight: CGFloat = 200
        let yAxisWidth: CGFloat = 14

        VStack(alignment: .leading, spacing: 10) {
            CustomText(text: "Logs by Symptom", color: bg, width: 250, textSize: 25)
                .padding(.bottom, 15)
                .padding(.leading, 15)

            HStack(alignment: .top, spacing: 5) {
                // Y-axis labels
                VStack(spacing: 0) {
                    ForEach(Array(0...yDivisions).reversed(), id: \.self) { i in
                        let value = Int(Double(maxCount) * Double(i) / Double(yDivisions))
                        CustomText(text: "\(value)", color: bg, width: yAxisWidth, textAlign: .center, textSize: 12)
                            .frame(height: 1, alignment: .center)
                        if i > 0 {
                            Spacer()
                                .frame(height: chartHeight / CGFloat(yDivisions))
                        }
                    }
                }
                .frame(height: chartHeight)
                
                ZStack(alignment: .topLeading) {
                    // Grid lines
                    VStack(spacing: 0) {
                        ForEach(0...yDivisions, id: \.self) { i in
                            Rectangle()
                                .fill(Color(hex: bg).opacity(0.3))
                                .frame(height: 1)
                            
                            if i < yDivisions {
                                Spacer()
                                    .frame(height: chartHeight / CGFloat(yDivisions))
                            }
                        }
                    }
                    .frame(height: chartHeight)
                    
                    // Bars
                    HStack(alignment: .bottom, spacing: 5) {
                        ForEach(monthlySymptomData, id: \.month) { monthData in
                            VStack(spacing: 2) {
                                ZStack(alignment: .bottom) {
                                    //y axis lines
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(baseColor.opacity(0.2))

                                    //each bar
                                    if !monthData.symptoms.isEmpty {
                                        VStack(spacing: 0) {
                                            ForEach(monthData.symptoms, id: \.symptom) { symptomData in
                                                let heightRatio = CGFloat(symptomData.count) / CGFloat(maxCount)
                                                Rectangle()
                                                    .fill(colorMap[symptomData.symptom] ?? .gray)
                                                    .frame(height: chartHeight * heightRatio)
                                            }
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                                .frame(width: 20)

                                //x axis label
                                CustomText(text: monthLabel(for: monthData.month), color: bg, textAlign: .center, textSize: 9)
                                    .fixedSize()
                                    .frame(height: 30)
                                    .padding(.top, 5)
                                    .padding(.leading, 3)
                            }
                        }
                    }
                }
            }
            .frame(width: width)
            .padding(.horizontal, 5)
        }
        //background box
        .padding(.vertical)
        .background(Color(hex: accent))
        .cornerRadius(30)
        .padding()
    }

    private var monthFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMM yyyy"
        return df
    }

    private func monthLabel(for date: Date) -> String {
        let month = monthFormatter.string(from: date).prefix(3)
        let year = monthFormatter.string(from: date).suffix(4)
        return "\(month),\n\(year)"
    }
}
