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
                return (month, counts)
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
        let allSymptoms = Array(Set(monthlySymptomData.flatMap { $0.symptoms.map { $0.symptom } })).sorted()
        let colorPalette = baseColor.generateHarmoniousColors(from: baseColor, count: allSymptoms.count)
        let colorMap = Dictionary(uniqueKeysWithValues: zip(allSymptoms, colorPalette))

        // Calculate nice intervals for y-axis
        let yStep = max(1, Int(ceil(Double(maxCount) / 5.0)))
        let yMax = Int(ceil(Double(maxCount) / Double(yStep))) * yStep
        let yValues = stride(from: 0, through: yMax, by: yStep).map { $0 }
        let chartHeight: CGFloat = 200
        let yAxisWidth: CGFloat = 10

        VStack(alignment: .leading, spacing: 10) {
            CustomText(text: "Logs by Symptom", color: bg, width: 250, textSize: 25)
                .padding(.bottom, 10)
                .padding(.leading, 15)

            HStack(alignment: .top, spacing: 0) {
                // Y-axis labels
                VStack(spacing: 0) {
                    ForEach(yValues.reversed(), id: \.self) { value in
                        CustomText(text: "\(value)", color: bg, width: yAxisWidth, textAlign: .trailing, textSize: 10)
                            .padding(.trailing, 7)
                            .padding(.bottom, 6)
                            .frame(height: 1)
                        
                        if value > 0 {
                            Spacer()
                                .frame(height: chartHeight * CGFloat(yStep) / CGFloat(yMax))
                        }
                    }
                }
                .frame(height: chartHeight, alignment: .top)
                
                // Chart area with grid lines behind bars
                ZStack(alignment: .topLeading) {
                    // Grid lines (full width)
                    VStack(spacing: 0) {
                        ForEach(yValues.reversed(), id: \.self) { value in
                            Rectangle()
                                .fill(Color(hex: bg).opacity(0.3))
                                .frame(height: 1)
                            
                            if value > 0 {
                                Spacer()
                                    .frame(height: chartHeight * CGFloat(yStep) / CGFloat(yMax))
                            }
                        }
                    }
                    .frame(height: chartHeight)
                    
                    // Bars on top
                    HStack(alignment: .bottom, spacing: 10) {
                        ForEach(monthlySymptomData, id: \.month) { monthData in
                            VStack(spacing: 2) {
                                ZStack(alignment: .bottom) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(baseColor.opacity(0.2))

                                    if !monthData.symptoms.isEmpty {
                                        VStack(spacing: 0) {
                                            ForEach(monthData.symptoms, id: \.symptom) { symptomData in
                                                let heightRatio = CGFloat(symptomData.count) / CGFloat(yMax)
                                                Rectangle()
                                                    .fill(colorMap[symptomData.symptom] ?? .gray)
                                                    .frame(height: chartHeight * heightRatio)
                                            }
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                                .frame(width: (width-15-(10*11)-10)/12, height: chartHeight)

                                CustomText(text: monthLabel(for: monthData.month), color: bg, textAlign: .center, textSize: 8)
                                    .fixedSize()
                                    .frame(height: 30)
                                    .padding(.top, 7)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .frame(width: width)
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
        .background(Color(hex: accent))
        .cornerRadius(30)
        .frame(width: width)
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
