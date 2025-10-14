//
//  Log Frequency Bar Chart.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/14/25.
//
import SwiftUI

struct CustomStackedBarChart: View {
    var logList: [UnifiedLog]
    var accent: String // hex string
    var bg: String     // hex string
    var width: CGFloat

    @State private var selectedMonth: Date? = nil

    // MARK: - Aggregated Data
    private var monthlySymptomData: [(month: Date, symptoms: [(symptom: String, count: Int)])] {
        let calendar = Calendar.current
        let now = Date()
        let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
        
        let startMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: oneYearAgo))!
        let months = (0..<12).compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: startMonth)
        }
        
        let filtered = logList.filter { $0.date >= startMonth }
        
        let byMonth = Dictionary(grouping: filtered) { log -> Date in
            let comps = calendar.dateComponents([.year, .month], from: log.date)
            return calendar.date(from: comps)!
        }
        
        return months.map { month in
            if let logs = byMonth[month] {
                let symptomGroups = Dictionary(grouping: logs, by: { $0.symptom_name ?? "Unknown" })
                let counts = symptomGroups.map { (symptom, logs) in
                    (symptom, logs.count)
                }
                return (month, counts.sorted(by: { $0.0 < $1.0 }))
            } else {
                return (month, [])
            }
        }
    }

    // MARK: - Max Height Normalization
    private var maxCount: Int {
        monthlySymptomData.map { $0.symptoms.map(\.count).reduce(0, +) }.max() ?? 1
    }

    // MARK: - Body
    var body: some View {
        // Convert accent string to Color
        let baseColor = Color(hex: accent)
        
        // Collect all unique symptoms as non-optional Strings
        let allSymptoms = Array(Set(monthlySymptomData.flatMap { $0.symptoms.map { $0.symptom } }))

        // Generate colors
        let colorPalette = baseColor.generateHarmoniousColors(from: baseColor, count: allSymptoms.count)

        // Map symptoms to colors
        let colorMap = Dictionary(uniqueKeysWithValues: zip(allSymptoms, colorPalette))

        
        VStack(alignment: .leading) {
            Text("Headache Symptoms by Month")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(monthlySymptomData, id: \.month) { monthData in
                    VStack {
                        GeometryReader { geo in
                            ZStack(alignment: .bottom) {
                                // Accent-colored background for bar container
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(hex: accent).opacity(0.2))
                                
                                if !monthData.symptoms.isEmpty {
                                    VStack(spacing: 0) {
                                        ForEach(monthData.symptoms, id: \.symptom) { symptomData in
                                            let heightRatio = CGFloat(symptomData.count) / CGFloat(maxCount)
                                            let color = colorMap[symptomData.symptom] ?? .gray

                                            Rectangle()
                                                .fill(color)
                                                .frame(height: geo.size.height * heightRatio)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 1)
                                                        .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                                                )
                                        }
                                    }
                                } 
                            }
                        }
                        .frame(height: 200)
                        
                        CustomText(text:shortMonthFormatter.string(from: monthData.month), color: bg,  width:20, textAlign: .center, textSize: 8)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .frame(width: width, height: 250)
        }
        .padding(.vertical)
        .background(Color(hex: accent))
        .cornerRadius(15)
        .padding()
    }

    // MARK: - Formatters
    private var shortMonthFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMM"
        return df
    }
    private var monthFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMMM yyyy"
        return df
    }
}
