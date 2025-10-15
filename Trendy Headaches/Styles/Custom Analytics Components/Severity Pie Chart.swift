//
//  Severity Pie Chart.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/14/25.
//
import SwiftUI

// Struct for bullet list items
struct SymptomCount: Identifiable {
    let id = UUID()
    let symptom: String
    let count: Int
}


struct SeverityPieChart: View {
    var logList: [UnifiedLog]
    var accent: String
    var bg: String
    @Binding var hideChart: Bool
    
    @State private var selectedSlice: String? = nil
    
    private var severityCounts: [(severity: String, count: Int)] {
        let grouped = Dictionary(grouping: logList, by: { $0.severity })
        return grouped
            .map { (severity: String($0.key), count: $0.value.count) }
            .sorted { Int($0.severity)! < Int($1.severity)! }
    }
    
    var body: some View {
        let chartSize: CGFloat = 170
        let baseColor = Color(hex: accent)
        let popOutOffset: CGFloat = 15

        var sliceColors: [Color] {
            baseColor.generateHarmoniousColors(from: baseColor, count: severityCounts.count)
        }

        ZStack {
            // Square background
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(hex: accent))
                .frame(width: UIScreen.main.bounds.width -  30, height: chartSize + 70)

            VStack {
                // Label above chart
                HStack{
                    CustomText(text:"Log Severity", color: bg, width: 140, textSize: 20)
                        .padding(.leading, 30)
                    Spacer()
                    Button(action: {hideChart.toggle()}){
                        CustomText(text: "Hide", color: accent,  width:60, textAlign: .center, textSize: 16)
                            .frame(height: 27)
                            .background(Color(hex: bg))
                            .cornerRadius(20)
                        }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 20)
                }
                .frame(width: UIScreen.main.bounds.width -  30)
                .padding(.top, 15)

                // Pie chart
                ZStack {
                    ForEach(severityCounts.indices, id: \.self) { idx in
                        let item = severityCounts[idx]
                        let start = startAngle(for: idx)
                        let end = endAngle(for: idx)
                        let mid = Angle(degrees: (start.degrees + end.degrees)/2)
                        
                        let sliceColor = sliceColors[idx]
                        let hex = sliceColor.toHex() ?? accent
                        let textColor: Color = Color.isHexColorDark(hex) ? .white : .black
                        
                        // Pop-out offset
                        let isSelected = selectedSlice == item.severity
                        let dx = isSelected ? cos(mid.radians) * popOutOffset : 0
                        let dy = isSelected ? sin(mid.radians) * popOutOffset : 0
                        
                        // Slice with black border
                        PieSliceShape(startAngle: start, endAngle: end)
                            .fill(sliceColor)
                            .overlay(
                                PieSliceShape(startAngle: start, endAngle: end)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            .frame(width: chartSize, height: chartSize)
                            .offset(x: dx, y: dy)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedSlice = selectedSlice == item.severity ? nil : item.severity
                                }
                            }
                        
                        // Label on slice
                        let labelRadius = chartSize * 0.35
                        let labelX = chartSize/2 + cos(mid.radians) * labelRadius + dx
                        let labelY = chartSize/2 + sin(mid.radians) * labelRadius + dy
                        
                        Text(item.severity)
                            .font(.system(size: 18, design: .serif))
                            .foregroundColor(textColor)
                            .position(x: labelX, y: labelY)
                    }
                    if let selected = selectedSlice,
                           let idx = severityCounts.firstIndex(where: { $0.severity == selected }) {
                            let item = severityCounts[idx]
                            let start = startAngle(for: idx)
                            let end = endAngle(for: idx)
                            let mid = Angle(degrees: (start.degrees + end.degrees) / 2)

                            let tooltipOffset: CGFloat = 50
                            let dx = CGFloat(-cos(mid.radians)) * tooltipOffset
                            let dy = CGFloat(-sin(mid.radians)) * tooltipOffset

                            // Build your symptom breakdown for this severity
                            let severityNumber = item.severity
                            let total = item.count
                            let logText = total == 1 ? "log" : "logs"
                            let symptomCounts: [SymptomCount] = makeSymptomCounts(for: selected)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Sev. \(severityNumber): \(total) \(logText) (\(Int(Double(total) / Double(logList.count) * 100))%)")
                                    .foregroundColor(Color(hex: accent))
                                    .font(.system(size: 18, design: .serif))

                                ForEach(symptomCounts) { item in
                                    HStack(alignment: .top, spacing: 6) {
                                        Text("•")
                                            .foregroundColor(Color(hex: accent))
                                            .font(.system(size: 16, design: .serif))
                                        
                                        let maxLength = 8
                                        let truncated = item.symptom.count > maxLength
                                            ? String(item.symptom.prefix(maxLength)) + "…"
                                            : item.symptom
                                        
                                        Text("\(truncated): \(item.count) (\(Int(Double(item.count) / Double(total) * 100))%)")
                                            .foregroundColor(Color(hex: accent))
                                            .font(.system(size: 16, design: .serif))
                                    }
                                }
                            }
                            .padding(10)
                            .background(Color(hex: bg))
                            .cornerRadius(10)
                            .shadow(radius: 4)
                            .position(x: chartSize / 2 + dx, y: chartSize / 2 + dy)
                            .transition(.opacity.combined(with: .scale))
                            .animation(.easeInOut, value: selectedSlice)
                        }
                }
                .frame(width: chartSize, height: chartSize)
                
                Spacer()
            }
            .frame(width: chartSize + 40, height: chartSize + 80)
        }
    }
    
    private func startAngle(for index: Int) -> Angle {
        let total = severityCounts.map(\.count).reduce(0, +)
        let sumBefore = severityCounts.prefix(index).map(\.count).reduce(0, +)
        return Angle(degrees: Double(sumBefore) / Double(total) * 360 - 90)
    }
    
    private func endAngle(for index: Int) -> Angle {
        let total = severityCounts.map(\.count).reduce(0, +)
        let sumUpTo = severityCounts.prefix(index + 1).map(\.count).reduce(0, +)
        return Angle(degrees: Double(sumUpTo) / Double(total) * 360 - 90)
    }
    private func makeSymptomCounts(for severity: String) -> [SymptomCount] {
        // Convert string severity to Int64 for comparison
        guard let severityInt = Int64(severity) else { return [] }

        // Filter logs matching the selected severity
        let filteredLogs = logList.filter { $0.severity == severityInt }

        // Group by symptom (assuming UnifiedLog has a `symptom` property)
        let grouped = Dictionary(grouping: filteredLogs, by: { $0.symptom_name })

        // Convert dictionary to [SymptomCount] and sort by descending count
        let counts = grouped.map { (symptom, logs) in
            SymptomCount(symptom: symptom ?? "", count: logs.count)
        }

        return counts.sorted { $0.count > $1.count }
    }


}


// MARK: - Pie slice shape
struct PieSliceShape: Shape {
    var startAngle: Angle
    var endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        var path = Path()
        path.move(to: center)
        path.addArc(center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        path.closeSubpath()
        return path
    }
}

// MARK: - Divider line
struct PieSliceDivider: Shape {
    var angle: Angle
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let endPoint = CGPoint(
            x: center.x + CGFloat(cos(angle.radians)) * radius,
            y: center.y + CGFloat(sin(angle.radians)) * radius
        )
        
        var path = Path()
        path.move(to: center)
        path.addLine(to: endPoint)
        return path
    }
}
