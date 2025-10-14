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
//    var accent: String // hex string
//    var bg: String     // hex string
//
//    @State private var selectedMonth: Date? = nil
//
//    // MARK: - Aggregated Data
//    private var monthlySymptomData: [(month: Date, symptoms: [(symptom: String, count: Int)])] {
//        let calendar = Calendar.current
//        let now = Date()
//        let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
//        
//        let startMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: oneYearAgo))!
//        let months = (0..<12).compactMap { offset in
//            calendar.date(byAdding: .month, value: offset, to: startMonth)
//        }
//        
//        let filtered = logList.filter { $0.date >= startMonth }
//        
//        let byMonth = Dictionary(grouping: filtered) { log -> Date in
//            let comps = calendar.dateComponents([.year, .month], from: log.date)
//            return calendar.date(from: comps)!
//        }
//        
//        return months.map { month in
//            if let logs = byMonth[month] {
//                let symptomGroups = Dictionary(grouping: logs, by: { $0.symptom_name ?? "Unknown" })
//                let counts = symptomGroups.map { (symptom, logs) in
//                    (symptom, logs.count)
//                }
//                return (month, counts.sorted(by: { $0.0 < $1.0 }))
//            } else {
//                return (month, [])
//            }
//        }
//    }
//
//    // MARK: - Max Height Normalization
//    private var maxCount: Int {
//        monthlySymptomData.map { $0.symptoms.map(\.count).reduce(0, +) }.max() ?? 1
//    }
//
//    // MARK: - Body
//    var body: some View {
//        // Convert accent string to Color
//        let baseColor = Color(hex: accent)
//        
//        // Collect all unique symptoms
//        let allSymptoms = Array(Set(monthlySymptomData.flatMap { $0.symptoms.map { $0.symptom } }))
//        
//        // Generate harmonious colors
//        let colorPalette = baseColor.generateHarmoniousColors(from: baseColor, count: allSymptoms.count)
//        let colorMap = Dictionary(uniqueKeysWithValues: zip(allSymptoms, colorPalette))
//        
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
//                                // Accent-colored background for bar container
//                                RoundedRectangle(cornerRadius: 6)
//                                    .fill(baseColor.opacity(0.2))
//                                
//                                if !monthData.symptoms.isEmpty {
//                                    VStack(spacing: 0) {
//                                        ForEach(monthData.symptoms, id: \.symptom) { symptomData in
//                                            let heightRatio = CGFloat(symptomData.count) / CGFloat(maxCount)
//                                            let color = colorMap[symptomData.symptom] ?? .gray
//                                            
//                                            Rectangle()
//                                                .fill(color)
//                                                .frame(height: geo.size.height * heightRatio)
//                                                .overlay(
//                                                    RoundedRectangle(cornerRadius: 1)
//                                                        .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
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
//            // Detail Section
//            if let selectedMonth = selectedMonth,
//               let monthData = monthlySymptomData.first(where: { $0.month == selectedMonth }) {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("Details for \(monthFormatter.string(from: selectedMonth))")
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
//                                    .fill(colorMap[data.symptom] ?? .gray)
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
//        .background(Color(hex: bg).opacity(0.15))
//        .cornerRadius(15)
//        .padding()
//    }
//
//    // MARK: - Formatters
//    private var shortMonthFormatter: DateFormatter {
//        let df = DateFormatter()
//        df.dateFormat = "MMM"
//        return df
//    }
//    private var monthFormatter: DateFormatter {
//        let df = DateFormatter()
//        df.dateFormat = "MMMM yyyy"
//        return df
//    }
//}
