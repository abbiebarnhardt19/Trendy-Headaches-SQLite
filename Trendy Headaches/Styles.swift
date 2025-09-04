//
//  Styles.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/24/25.
//

import SwiftUI
import Foundation

//dark green: #001d00
//light green: #b5c4b9

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
    let height: CGFloat?
    let width: CGFloat?
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 20) // ensures text doesn't touch edges
            .padding(.vertical, 6)
            .frame(width: width ?? 150, height: height ?? 50)
            .background(Color(hex: accent))
            .foregroundColor(Color(hex: background))
            .cornerRadius(30)
            .tint(Color(hex: background))
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
            .padding(.trailing, 20)
            .padding(.leading, 20)
    }
}

struct CustomList: View {
    var items: [String]
    var color: String
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        if items.count > 1{
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(items, id: \.self) { item in
                    Text("• \(item)")
                        .font(.system(size: 18, design: .serif))
                        .foregroundColor(Color(hex: color))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                }
            }
        }
        else{
            Text("• \(items[0])")
                .font(.system(size: 18, design: .serif))
                .foregroundColor(Color(hex: color))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
        }
    }
}


struct CustomNavButton<Destination: View>: View {
    var label: String
    var destination: Destination
    var background: String
    var accent: String
    var height: CGFloat?
    var width: CGFloat?

    var body: some View {
        NavigationLink {
            destination
        } label: {
            Text(label)
                .frame(width: width ?? 150, height: height ?? 50)
                .background(Color(hex: accent))
                .foregroundColor(Color(hex: background))
                .cornerRadius(20)
                .font(.system(size: 20, design: .serif))
        }
        .padding(.top, 10)
        .buttonStyle(.plain)
    }
}

struct TempLinkText: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.system(size: 12, design: .serif))
            .foregroundColor(Color(hex: "#b5c4b9"))
            .frame(maxWidth:.infinity, alignment: .leading)
    }
}


//under textField text
struct CustomWarningText: View {
    var text: String
    var body: some View {
        Text(text)
            .foregroundColor(.red)
            .font(.system(size: 12, design: .serif))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: 350, alignment: .leading)
            .padding(.top, 10)
            .padding(.horizontal, 15)
    }
}

//main title text
struct CustomWelcome: View {
    var text: String
    var color: String
    var body: some View {
        Text(text)
            .multilineTextAlignment(.center)
            .font(.system(size: 40, design: .serif))
            .foregroundColor(Color(hex: color))
            .padding(.bottom, 10)
    }
}

//text that goes under titletext
struct CustomInstructions: View {
    var text: String
    var color: String
    var body: some View {
        Text(text)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            .font(.system(size: 20, weight: .bold, design: .serif))
            .foregroundColor(Color(hex: color))
            .padding(.bottom, 10)
        .padding(.trailing, 15)
        .padding(.leading, 15)
    }
}

//sets the background color
//make this so it takes in the string and gets the hex codes from that?
extension View {
    func CustomView(color: String) -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: color))
    }
}

//stylied button
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
    }
}
struct DropdownMenu: View {
    @Binding var selection: String
    let options: [String]
    let background: String  // hex string for background
    let accent: String      // hex string for accent
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            
            // Dropdown label (currently selected option)
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(selection.isEmpty ? "Select an option" : selection)
                        .foregroundColor(selection.isEmpty ? Color(hex: accent) : Color(hex: accent))
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(Color(hex: accent))
                }
                .padding()
                .background(Color(hex: background).opacity(0.2))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: accent), lineWidth: 2)
                )
            }
            
            // Dropdown options
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            selection = option
                            withAnimation {
                                isExpanded = false
                            }
                        }) {
                            HStack {
                                Text(option)
                                    .foregroundColor(Color(hex: accent))
                                Spacer()
                            }
                            .padding()
                            .background(Color(hex: background))
                        }
                        .buttonStyle(.plain)
                        
                        if option != options.last {
                            Divider()
                        }
                    }
                }
                .background(Color(hex: background))
                .cornerRadius(10)
                .shadow(radius: 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
                
            }
        }
        .padding(.horizontal, 20)
    }
        
}

extension CGPoint {
    func scale(x xScale: CGFloat, y yScale: CGFloat) -> CGPoint {
        CGPoint(x: self.x * xScale, y: self.y * yScale)
    }
}

struct SameAmplitudeBlob: Shape {
    var waves: Int
    var amplitude: CGFloat
    var seed: Int = Int.random(in: 0...10_000)

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step = rect.width / CGFloat(waves)
        var rng = SeededGenerator(seed: seed)

        path.move(to: CGPoint(x: 0, y: 0))

        for i in 0..<waves {
            let startX = CGFloat(i) * step
            let endX = startX + step

            // Midpoint along the diagonal
            let midX = (startX + endX) / 2
            let midY = midX * (rect.height / rect.width)

            // Randomized amplitudes for control points
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

struct ParametricBlob: Shape {
    var points: Int = 20
    var amplitude: CGFloat = 0.2 // ebb depth
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radiusX = rect.width / 2   // ellipse horizontal radius
        let radiusY = rect.height / 2  // ellipse vertical radius
        
        var blobPoints: [CGPoint] = []
        
        for i in 0..<points {
            let angle = 2 * CGFloat.pi * CGFloat(i) / CGFloat(points)
            let offset = sin(CGFloat(i) * 2) * amplitude // ebb control
            
            let point = CGPoint(
                x: center.x + (radiusX * (1 + offset)) * cos(angle),
                y: center.y + (radiusY * (1 + offset)) * sin(angle)
            )
            blobPoints.append(point)
        }
        
        path.move(to: blobPoints.first!)
        
        for i in 0..<points {
            let next = blobPoints[(i + 1) % points]
            let mid = CGPoint(
                x: (blobPoints[i].x + next.x) / 2,
                y: (blobPoints[i].y + next.y) / 2
            )
            path.addQuadCurve(to: mid, control: blobPoints[i])
        }
        
        path.closeSubpath()
        return path
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
