//
//  Styles.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/24/25.
//

import SwiftUI
import Foundation

//allow swift to use hex codes
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit, e.g. #FFF)
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RGB (24-bit, e.g. #00FF00)
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // ARGB (32-bit, e.g. #FF00FF00)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

struct CustomTextField: TextFieldStyle {
    let background: String
    let accent: String
    let width: CGFloat?
    
    init(background: String, accent: String, width: CGFloat? = nil) {
        self.background = background
        self.accent = accent
        self.width = width
    }
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 20)
            .padding(.vertical, 5)
            .frame(width: width ?? 350, height: 55)
            .background(Color(hex: accent))
            .foregroundColor(Color(hex: background))
            .cornerRadius(30)
            .tint(Color(hex: background))
        .padding(.bottom, 8)
    }
}

struct CustomText: View {
    var text: String
    var color: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 22, design: .serif))
            .foregroundColor(Color(hex: color))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
    }
}

struct CustomListHeader: View {
    var text: String
    var color: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 22, weight: .bold, design: .serif))
            .foregroundColor(Color(hex: color))
            .frame(maxWidth: 175, alignment: .center)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
    }
}

struct CustomList: View {
    var items: [String]
    var color: String
    
    var body: some View {
            let screenWidth = UIScreen.main.bounds.width
            let maxWidth = screenWidth / 2 - 20
            let columnCount = calculateColumnCount(items: items, maxWidth: maxWidth)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: columnCount),
                spacing: 3
            ) {
                ForEach(items, id: \.self) { item in
                    Text("• \(item)")
                        .font(.system(size: 18, design: .serif))
                        .foregroundColor(Color(hex: color))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(width: maxWidth, alignment: .trailing)
            .padding(.bottom, 15)
    }
    
    private func calculateColumnCount(items: [String], maxWidth: CGFloat) -> Int {
        guard !items.isEmpty else { return 1 }
        
        let charWidth: CGFloat = 12
        let itemWidths = items.map { CGFloat($0.count + 2) * charWidth }

        for columns in stride(from: items.count, through: 1, by: -1) {
            let columnWidth = maxWidth / CGFloat(columns)
            if itemWidths.allSatisfy({ $0 <= columnWidth }) {
                return columns
            }
        }
        return 1
    }
}






struct CustomNavButton<Destination: View>: View {
    var label: String
    var destination: Destination
    var background: String
    var accent: String
    var width: CGFloat?

    var body: some View {
        NavigationLink {
            destination
        } label: {
            Text(label)
                .frame(width: width ?? 180, height: 55)
                .background(Color(hex: accent))
                .foregroundColor(Color(hex: background))
                .cornerRadius(30)
                .font(.system(size: 20, design: .serif))
                
        }
        .buttonStyle(.plain)
        .padding(.vertical, 7)
    }
}

struct CustomLink<Destination: View>: View {
    var destination: Destination
    var text: String
    var accent: String
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            Text(text)
                .font(.system(size: 18, design: .serif))
                .foregroundColor(Color(hex: accent))
                .underline(true, color: Color(hex: accent))
                .background(Color.clear)
        }
        .padding(.bottom,15)
        .buttonStyle(.plain)
    }
}

struct CustomWarningText: View {
    var text: String
    var body: some View {
        Text(text)
            .foregroundColor(.red)
            .font(.system(size: 14, design: .serif))
            .padding(.horizontal, 18)
            .frame(width: 400)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct CustomWelcome: View {
    var text: String
    var color: String
    var textAlignment: TextAlignment
    var width: CGFloat
    var body: some View {
        Text(text)
            .multilineTextAlignment(textAlignment)
            .fixedSize(horizontal: false, vertical: true)
            .font(.system(size: 50, design: .serif))
            .foregroundColor(Color(hex: color))
            .padding(.vertical, 10)
            .frame(width:width)
    }
}

struct CustomInstructions: View {
    var text: String
    var color: String
    var body: some View {
        Text(text)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: 350)
            .multilineTextAlignment(.center)
            .font(.system(size: 18, design: .serif))
            .foregroundColor(Color(hex: color))
        .padding(.horizontal, 15)
        .padding(.bottom, 17)
    }
}

struct CustomButton: View {
    var text: String
    var background: String
    var accent: String
    var height: CGFloat?
    var width: CGFloat?
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .frame(width: width ?? 150, height: height ?? 50)
                .background(Color(hex: accent))
                .foregroundColor(Color(hex: background))
                .cornerRadius(30)
                .font(.system(size: 20, design: .serif))
    
        }
        .buttonStyle(.plain)
        .padding(.bottom, 10)
    }
}

extension CGPoint {
    func scale(x xScale: CGFloat, y yScale: CGFloat) -> CGPoint {
        CGPoint(x: self.x * xScale, y: self.y * yScale)
    }
}

struct SameAmplitudeBlob: View {
    var waves: Int
    var amplitude: CGFloat
    var accent: String
    var x: CGFloat
    var y: CGFloat
    var rotation: CGFloat
    
    let seed = 4

    var body: some View {
        BlobShape(waves: waves, amplitude: amplitude, seed: seed)
            .fill(Color(hex: accent))
            .frame(width: 700, height: 500)
            .offset(x:x, y:y)
            .rotationEffect(.degrees(rotation))
    }

    private struct BlobShape: Shape {
        var waves: Int
        var amplitude: CGFloat
        var seed: Int

        func path(in rect: CGRect) -> Path {
            var path = Path()
            let step = rect.width / CGFloat(waves)
            var rng = SeededGenerator(seed: seed)

            path.move(to: .zero)

            for i in 0..<waves {
                let startX = CGFloat(i) * step
                let endX = startX + step

                let midX = (startX + endX) / 2
                let midY = midX * (rect.height / rect.width)

                let controlAmp1 = amplitude * CGFloat(Double.random(in: 0.7...1.3, using: &rng))
                let controlAmp2 = amplitude * CGFloat(Double.random(in: 0.7...1.3, using: &rng))
                let direction: CGFloat = (i % 2 == 0 ? -1 : 1)

                let controlX1 = startX + step * 0.25
                let controlY1 = midY + direction * controlAmp1

                let controlX2 = startX + step * 0.75
                let controlY2 = midY + direction * controlAmp2

                path.addCurve(
                    to: CGPoint(x: endX, y: endX * (rect.height / rect.width)),
                    control1: CGPoint(x: controlX1, y: controlY1),
                    control2: CGPoint(x: controlX2, y: controlY2)
                )
            }

            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.closeSubpath()
            return path
        }
    }
}

import SwiftUI

struct WavyTopBottomRectangle: View {
    var waves: Int
    var amplitude: CGFloat
    var accent: String
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    let seed = 4

    var body: some View {
        let path: Path = {
            var path = Path()
            let step = width / CGFloat(waves)
            
            // Precompute amplitudes for top and bottom edges
            var rng = SeededGenerator(seed: seed)
            let topAmps = (0..<waves).map { _ in amplitude * CGFloat(Double.random(in: 0.7...1.3, using: &rng)) }
            let bottomAmps = (0..<waves).map { _ in amplitude * CGFloat(Double.random(in: 0.7...1.3, using: &rng)) }

            // Start at bottom-left
            path.move(to: CGPoint(x: 0, y: height))

            // Bottom wavy edge
            for i in 0..<waves {
                let startX = CGFloat(i) * step
                let endX = startX + step
                let direction: CGFloat = (i % 2 == 0 ? 1 : -1)

                let controlX1 = startX + step * 0.25
                let controlY1 = height + direction * bottomAmps[i]

                let controlX2 = startX + step * 0.75
                let controlY2 = height + direction * bottomAmps[i]

                path.addCurve(
                    to: CGPoint(x: endX, y: height),
                    control1: CGPoint(x: controlX1, y: controlY1),
                    control2: CGPoint(x: controlX2, y: controlY2)
                )
            }

            // Right edge (straight)
            path.addLine(to: CGPoint(x: width, y: 0))

            // Top wavy edge
            for i in (0..<waves).reversed() {
                let startX = CGFloat(i+1) * step
                let endX = startX - step
                let direction: CGFloat = (i % 2 == 0 ? 1 : -1)

                let controlX1 = startX - step * 0.25
                let controlY1 = 0 + direction * topAmps[i]

                let controlX2 = startX - step * 0.75
                let controlY2 = 0 + direction * topAmps[i]

                path.addCurve(
                    to: CGPoint(x: endX, y: 0),
                    control1: CGPoint(x: controlX1, y: controlY1),
                    control2: CGPoint(x: controlX2, y: controlY2)
                )
            }

            // Left edge (straight) back to bottom-left
            path.addLine(to: CGPoint(x: 0, y: height))
            path.closeSubpath()
            
            return path
        }()

        return path
            .fill(Color(hex: accent))
            .frame(width: width, height: height)
            .offset(x: x, y: y)
    }
}


struct ParametricBlob: View {
    var points: Int = 20
    var amplitude: CGFloat
    var x: CGFloat
    var y: CGFloat
    var rotation: CGFloat
    var accent: String
    
    var body: some View {
        let rect = CGRect(x: 0, y: 0, width: 500, height: 600)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radiusX = rect.width / 2
        let radiusY = rect.height / 2
        
        let blobPath: Path = {
            var path = Path()
            var blobPoints: [CGPoint] = []
            
            for i in 0..<points {
                let angle = 2 * CGFloat.pi * CGFloat(i) / CGFloat(points)
                let offset = sin(CGFloat(i) * 2) * amplitude
                
                let x = center.x + (radiusX * (1 + offset)) * cos(angle)
                let y = center.y + (radiusY * (1 + offset)) * sin(angle)
                blobPoints.append(CGPoint(x: x, y: y))
            }
            
            if let first = blobPoints.first {
                path.move(to: first)
            }
            
            for i in 0..<points {
                let next = blobPoints[(i + 1) % points]
                let midX = (blobPoints[i].x + next.x) / 2
                let midY = (blobPoints[i].y + next.y) / 2
                let mid = CGPoint(x: midX, y: midY)
                
                path.addQuadCurve(to: mid, control: blobPoints[i])
            }
            
            path.closeSubpath()
            return path
        }()
        
        return blobPath
            .fill(Color(hex: accent))
            .frame(width: 400, height: 300)
            .offset(x: x, y: y)
            .rotationEffect(.degrees(rotation))
    }
}


// Reproducible random generator
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: Int) { self.state = UInt64(seed) }
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1
        return state
    }
}

struct CustomDropdown: View {
    @Binding var color_theme: String
    @Binding var background: String
    @Binding var accent: String
    var options: [String]
    
    var body: some View {
        Menu {
            Picker(selection: $color_theme, label: EmptyView()) {
                ForEach(options, id: \.self) { theme in
                    Text(theme)
                }
                
            }
            
        } label: {
            HStack {
                Text(color_theme)
                    .font(.system(size: 22, design: .serif))
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.trailing, 20)
            }
            .padding(.leading, 20)
            .frame(width: 350, height: 50, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(hex: accent))
            )
            .foregroundColor(Color(hex: background))
        }
        .onChange(of: color_theme) {
            let colors = DatabaseManager.getThemeColors(theme: color_theme)
            background = colors.background
            accent = colors.accent
        }
        .buttonStyle(.plain)
        .padding(.bottom, 20)
    }
}

struct CustomFloatButton: View {
    var accent: String
    var background: String
    var options: [String]
    var actions: [() -> Void]
    
    // Manually entered offsets
    let xList: [CGFloat] = [-20, -100, -100, -20] // customize per button
    let yList: [CGFloat] = [-90, -40, 10, 60]   // customize per button
    
    @State private var showMenu = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Main floating button
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showMenu.toggle()
                }
                
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 40, design: .serif))
                    .padding(20)
                    .background(Color(hex: accent))
                    .foregroundColor(Color(hex: background))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            // Menu buttons using manual x/y lists
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showMenu = false
                        if index < actions.count {
                            actions[index]()  // Call the corresponding action
                        }
                    }
                } label: {
                    Text(option)
                        .frame(width: 160, height: 40)
                        .background(Color(hex: accent))
                        .foregroundColor(Color(hex: background))
                        .font(.system(size: 16, design: .serif))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color(hex: background), lineWidth: 2)
                        )
                        .opacity(showMenu ? 1 : 0)
                        .scaleEffect(showMenu ? 1 : 0.5)
                }
                .buttonStyle(.plain)
                .offset(x: xList[index], y: yList[index])
            }
        }
        .frame(height: 200)
    }
}


struct PolicySheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var policyText: String = ""
    
    /// The name of the policy file in your bundle (without extension)
    var policyFileName: String
    
    /// Whether to show an "Agree" button
    var showsAgreeButton: Bool
    
    /// Closure to run when "Agree" is tapped
    var onAgree: (() -> Void)?
    
    // Reuse your app colors
    private let backgroundColor = Color(hex: "#001d00") // dark green
    private let textColor = Color(hex: "#b5c4b9")
    private let textHex = "#b5c4b9"

    var body: some View {
        NavigationStack {
            ScrollView {
                CustomWelcome(text: "Data Policy", color: textHex, textAlignment: .center, width: 300)
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(policyText.components(separatedBy: "\n"), id: \.self) { line in
                        let trimmed = line.trimmingCharacters(in: .whitespaces)
                        
                        if trimmed.isEmpty {
                            Spacer().frame(height: 8)
                        } else if isMajorHeading(trimmed) {
                            Text(trimmed)
                                .font(.system(.title2, design: .serif))
                                .fontWeight(.heavy)
                                .foregroundColor(textColor)
                                .padding(.top, 12)
                        } else if isSubHeading(trimmed) {
                            Text(trimmed)
                                .font(.system(.headline, design: .serif))
                                .fontWeight(.bold)
                                .foregroundColor(textColor)
                                .padding(.top, 0)
                        } else {
                            Text(trimmed)
                                .font(.system(.body, design: .serif))
                                .foregroundColor(textColor)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding()
            }
            .background(backgroundColor.ignoresSafeArea())
            .toolbarBackground(backgroundColor, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(textColor)
                }
                
                if showsAgreeButton {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Agree") {
                            dismiss()
                            onAgree?()
                        }
                        .bold()
                        .foregroundColor(textColor)
                    }
                }
            }
            .onAppear {
                loadPolicyText()
            }
        }
    }
    
    // MARK: - Helpers
    
    private func loadPolicyText() {
        if let url = Bundle.main.url(forResource: policyFileName, withExtension: "txt"),
           let contents = try? String(contentsOf: url, encoding: .utf8) {
            policyText = contents
        } else {
            policyText = "Could not load policy."
        }
    }
    
    private func isMajorHeading(_ line: String) -> Bool {
        let normalized = line.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ":", with: "")
        let majorHeadings = [
            "Introduction",
            "What Data We Collect",
            "How We Use Your Data",
            "How We Store Your Data",
            "Your Control Over Your Data",
            "Our Commitment to You"
        ]
        return majorHeadings.contains(normalized)
    }
    
    private func isSubHeading(_ line: String) -> Bool {
        let normalized = line.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ":", with: "")
        let subHeadings = [
            "Account Data (mandatory)",
            "Health Data (optional)",
            "Log Data (Core Functionality)"
        ]
        return subHeadings.contains(normalized)
    }
}

