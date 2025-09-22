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
        case 3: // three character hex
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: //six character hex
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: //eight character hex
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
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

struct CustomTextField: View {
    let background: String
    let accent: String
    let placeholder: String
    @Binding var text: String
    var width: CGFloat? = 350
    var height: CGFloat? = 55
    var cornerRadius: CGFloat? = 30
    var textSize: CGFloat? = 22
    var isMultiline: Bool = false
    var isSecure: Bool = false
    
    var body: some View {
        Group {
            if isMultiline {
                TextField(placeholder, text: $text, axis: .vertical)
                    .lineLimit(1...2)
            }
            else if isSecure{
                SecureField(placeholder, text: $text)
            }
            
            else {
                TextField(placeholder, text: $text)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
        .frame(width: width ?? UIScreen.main.bounds.width-50, height: height ?? (isMultiline ? nil : 55))
        .background(Color(hex: accent))
        .foregroundColor(Color(hex: background))
        .cornerRadius(cornerRadius ?? 30)
        .font(.system(size: textSize ?? 22, design: .serif))
        .tint(Color(hex: background))
        .textContentType(nil)
        .padding(.bottom,  8)
    }
}

struct CustomText: View {
    var text: String
    var color: String
    var width: CGFloat?
    var textAlignment: Alignment? = .leading
    var multilineAlignment: TextAlignment? = .leading
    var isBold: Bool = false
    var textSize: CGFloat? = 22
    
    var body: some View {
        Text(text)
            .font(.system(size: textSize ?? 22, design: .serif))
            .fontWeight(isBold ? .bold : .regular) 
            .foregroundColor(Color(hex: color))
            .frame(maxWidth: width ?? .infinity, alignment: textAlignment ?? .leading)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(multilineAlignment ?? .center)
    }
}

struct CustomList: View {
    var items: [String]
    var color: String
    
    var body: some View {
        let maxWidth = UIScreen.main.bounds.width / 2 - 40
        
        // estimate width per character and find the widest item
        let charWidth: CGFloat = 12
        let maxItemWidth = items
            .map { CGFloat($0.count + 2) * charWidth } // +2 for bullet + padding
            .max() ?? (charWidth * 3)
        
        let columnCount = Int(max(1, maxItemWidth / maxWidth))

        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: columnCount),
            spacing: 3
        ) {
            ForEach(items, id: \.self) { item in
                Text("• \(item)")
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(Color(hex: color))
                    .lineLimit(1) // ✅ only one line
                    .truncationMode(.tail) // ✅ add "…" if too long
                    .frame(maxWidth: .infinity, alignment: .center) // ✅ gives it a width to truncate within
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: maxWidth, alignment: .trailing)
        .padding(.bottom, 15)
        .fixedSize(horizontal: false, vertical: true)
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
            .frame(width: UIScreen.main.bounds.width-20)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct CustomButton: View {
    var text: String
    var background: String
    var accent: String
    var height: CGFloat?
    var width: CGFloat?
    var cornerRadius: CGFloat?
    var isBold: Bool = false
    var textSize: CGFloat? = 20
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .frame(width: width ?? 150, height: height ?? 50)
                .background(Color(hex: accent))
                .foregroundColor(Color(hex: background))
                .cornerRadius(cornerRadius ?? 30)
                .font(.system(size: textSize ?? 20, design: .serif))
                .fontWeight(isBold ? .bold : .regular)
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
    var width: CGFloat? = 700
    var height: CGFloat? = 500

    var body: some View {
        BlobShape(waves: waves, amplitude: amplitude, seed: seed)
            .fill(Color(hex: accent))
            .frame(width: width ?? 700, height: height ?? 500)
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
            
            var rng = SeededGenerator(seed: seed)
            let topAmps = (0..<waves).map { _ in amplitude * CGFloat(Double.random(in: 0.7...1.3, using: &rng)) }
            let bottomAmps = (0..<waves).map { _ in amplitude * CGFloat(Double.random(in: 0.7...1.3, using: &rng)) }

            path.move(to: CGPoint(x: 0, y: height))

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

            path.addLine(to: CGPoint(x: width, y: 0))

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
    var width: CGFloat? = 500
    var height: CGFloat? = 600
    
    var body: some View {
        let rect = CGRect(x: 0, y: 0, width: width ?? 500, height: height ?? 600)
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
struct RandomBlob: View {
    var points: Int = 40
      var width: CGFloat
      var height: CGFloat
      var x: CGFloat
      var y: CGFloat
      var rotation: CGFloat
      var accent: String
      var seed: CGFloat = 42

      var body: some View {
          let rect = CGRect(x: 0, y: 0, width: width, height: height)
          let center = CGPoint(x: rect.midX, y: rect.midY)
          let radiusX = rect.width / 2
          let radiusY = rect.height / 2

          // deterministic per-point amplitudes
          let amplitudes: [CGFloat] = (0..<points).map { i in
              let val = sin(CGFloat(i) * 0.5 + seed) * 0.12
                      + cos(CGFloat(i) * 0.3 + seed * 0.7) * 0.12
                      + 1.0
              return min(max(val, 0.85), 1.15)
          }

          let blobPath: Path = {
              var path = Path()
              var blobPoints: [CGPoint] = []

              for i in 0..<points {
                  let angle = 2 * .pi * CGFloat(i) / CGFloat(points)
                  let amp = amplitudes[i]
                  let px = center.x + radiusX * amp * cos(angle)
                  let py = center.y + radiusY * amp * sin(angle)
                  blobPoints.append(CGPoint(x: px, y: py))
              }

              guard blobPoints.count > 1 else { return path }

              // Start at first point
              path.move(to: blobPoints[0])

              // Catmull-Rom smoothing through points
              for i in 0..<blobPoints.count {
                  let p0 = blobPoints[(i - 1 + points) % points]
                  let p1 = blobPoints[i]
                  let p2 = blobPoints[(i + 1) % points]
                  let p3 = blobPoints[(i + 2) % points]

                  let control1 = CGPoint(
                      x: p1.x + (p2.x - p0.x) / 6,
                      y: p1.y + (p2.y - p0.y) / 6
                  )
                  let control2 = CGPoint(
                      x: p2.x - (p3.x - p1.x) / 6,
                      y: p2.y - (p3.y - p1.y) / 6
                  )

                  path.addCurve(to: p2, control1: control1, control2: control2)
              }

              path.closeSubpath()
              return path
          }()

          return blobPath
              .fill(Color(hex: accent))
              .frame(width: width, height: height)
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
    var width: CGFloat
    var height: CGFloat
    var cornerRadius: CGFloat
    var fontSize: CGFloat
    
    var body: some View {
        Menu {
            Picker(selection: $color_theme, label: EmptyView()) {
                ForEach(options, id: \.self) { theme in
                    Text(theme)
                        .padding(.leading, 5)
                }
            }
            
        } label: {
            HStack {
                Text(color_theme)
                    .font(.system(size: fontSize, design: .serif))
                    .padding(.leading, 5)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.trailing, 20)
            }
            .padding(.leading, 10)
            .frame(width: width, height: height, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(hex: accent))
            )
            .foregroundColor(Color(hex: background))
        }
        .onChange(of: color_theme) {
            let colors = DatabaseManager.getThemeColors(theme: color_theme, currentBackground: background, currentAccent: accent)
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
    
    let xList: [CGFloat] = [-20, -100, -100, -20]
    let yList: [CGFloat] = [-90, -40, 10, 60]
    
    @State private var showMenu = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
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
            
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showMenu = false
                        if index < actions.count {
                            actions[index]()
                        }
                    }
                } label: {
                    Text(option)
                        .frame(width: 140, height: 40)
                        .background(Color(hex: accent))
                        .foregroundColor(Color(hex: background))
                        .font(.system(size: 15, design: .serif))
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

struct PolicyTextView: View {
    var policyFileName: String
    var textColor: Color
    
    var policyLines: [String] {
        guard let url = Bundle.main.url(forResource: policyFileName, withExtension: "txt"),
              let contents = try? String(contentsOf: url, encoding: .utf8) else {
            return ["Could not load policy."]
        }
        
        let normalized = contents
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        
        return normalized.components(separatedBy: "\n")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(policyLines, id: \.self) { line in
                if line.starts(with: "##") {
                    Text(line.replacingOccurrences(of: "##", with: ""))
                        .font(.headline)
                        .bold()
                } else if line.starts(with: "#") {
                    Text(line.replacingOccurrences(of: "#", with: ""))
                        .font(.title2)
                        .bold()
                } else if line.starts(with: "•") || line.starts(with: "-") {
                    Text(line)
                        .font(.body)
                        .padding(.leading, 20)
                } else if line.trimmingCharacters(in: .whitespaces).isEmpty {
                    Spacer().frame(height: 8) // blank line
                } else {
                    Text(line)
                        .font(.body)
                }
            }
        }
        .foregroundColor(textColor)
        .padding()
    }
}

struct PolicySheetView: View {
    @Environment(\.dismiss) private var dismiss
    var policyFileName: String
    var showsAgreeButton: Bool
    var onAgree: (() -> Void)?

    private let backgroundColor = Color(hex: "#001d00")
    private let textColor = Color(hex: "#b5c4b9")
    private let textHex = "#b5c4b9"

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
                CustomText(
                    text: "Data Policy",
                    color: textHex,
                    width: 300,
                    textAlignment: .center,
                    textSize: 50
                )

                PolicyTextView(policyFileName: policyFileName, textColor: textColor)
            }
            .background(backgroundColor.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Agree") { dismiss(); onAgree?() }
                        .opacity(showsAgreeButton ? 1 : 0)
                        .disabled(!showsAgreeButton)
                }
            }
        }
    }
}


struct EditableList: View {
    @Binding var items: [String]
    var title: String
    var backgroundColor: String
    var accentColor: String

    var onAdd: (String) -> Void
    var onEdit: (String, String) -> Void
    var onDelete: (String) -> Void

    let width = UIScreen.main.bounds.width / 2 - 15
    let rowHeight = CGFloat(50)

    @State private var newItemText = ""
    @State private var editingIndex: Int? = nil
    @State private var originalValue: String = ""
    
    @State private var showDeleteConfirmation = false
    @State private var itemToDelete: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 0) {
                ForEach(items.indices.filter { items[$0] != "None entered" }, id: \.self) { index in
                    ZStack(alignment: .trailing) {
                        if editingIndex == index {
                            // Editable text field when editing
                            TextField("Enter item", text: Binding(
                                get: { items[index] },
                                set: { items[index] = $0 }
                            ))
                            .padding(.vertical, 10)
                            .padding(.trailing, 80)
                            .padding(.leading, 10)
                            .background(Color(hex: accentColor))
                            .foregroundColor(Color(hex: backgroundColor))
                            .cornerRadius(8)
                            .font(.system(size: 20, design: .serif))
                            .frame(height: 50)

                            HStack {
                                Button(action: {
                                    let newValue = items[index]
                                    if newValue != originalValue {
                                        onEdit(originalValue, newValue)
                                    }
                                    editingIndex = nil
                                }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(hex: backgroundColor))
                                        .font(.system(size: 28))
                                    
                                }
                                .buttonStyle(PlainButtonStyle())
                                Button(action: {
                                    itemToDelete = items[index]
                                    showDeleteConfirmation = true
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(Color(hex: backgroundColor))
                                        .font(.system(size: 28))
                                }
                                .buttonStyle(PlainButtonStyle())

                            }
                            .padding(.trailing, 8)


                        } else {
                            // View-only mode
                            Text(items[index])
                                .padding(.vertical, 10)
                                .padding(.trailing, 80)
                                .padding(.leading, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(hex: accentColor))
                                .foregroundColor(Color(hex: backgroundColor))
                                .cornerRadius(8)
                                .font(.system(size: 20, design: .serif))
                                .frame(height: 50)

                            HStack {
                                Button(action: {
                                    originalValue = items[index]
                                    editingIndex = index
                                }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .foregroundColor(Color(hex: backgroundColor))
                                        .font(.system(size: 28))
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    itemToDelete = items[index]
                                    showDeleteConfirmation = true
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(Color(hex: backgroundColor))
                                        .font(.system(size: 28))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.trailing, 8)
                        }
                    }
                }

                // Add new item row
                HStack {
                    ZStack(alignment: .trailing) {
                        ZStack(alignment: .leading) {
                            // Placeholder
                            if newItemText.isEmpty {
                                Text("New item")
                                    .foregroundColor(Color(hex: backgroundColor))
                                    .padding(.leading, 10)
                                    .padding(.vertical, 10)
                                    .font(.system(size: 20, design: .serif))
                            }

                            // TextField with transparent background
                            TextField("", text: $newItemText)
                                .padding(.vertical, 10)
                                .padding(.leading, 10)
                                .padding(.trailing, 35)
                                .font(.system(size: 20, design: .serif))
                                .foregroundColor(Color(hex: backgroundColor))
                                .background(Color.clear) // <-- important!
                                .cornerRadius(8)
                        }
                        .background(Color(hex: accentColor)) // <-- apply background here, behind both
                        .cornerRadius(8)
                        .frame(height: 50)

                        Button(action: {
                            let trimmed = newItemText.trimmingCharacters(in: .whitespaces)
                            guard !trimmed.isEmpty else { return }
                            items.append(trimmed)
                            onAdd(trimmed)
                            newItemText = ""
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .renderingMode(.template)
                                .foregroundColor(Color(hex: backgroundColor))
                                .padding(.trailing, 8)
                                .font(.system(size: 28))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(newItemText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
        }
        .alert("Are you sure you want to delete this item?",
               isPresented: $showDeleteConfirmation,
               presenting: itemToDelete) { item in
            Button("Delete", role: .destructive) {
                onDelete(item)
                if let index = items.firstIndex(of: item) {
                    items.remove(at: index)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: { item in
            Text("This will mark '\(item)' as inactive.")
        }
        .frame(width: width,
               height: CGFloat(items.indices.filter { items[$0] != "None entered" }.count + 1) * rowHeight)
        .padding(.bottom, 5)
    }
}


import SwiftUI

struct MultipleChoiceButtonGroup: View {
    @Binding var options: [String]
    @Binding var selected: String?
    var accent: String

    let circleWidth: CGFloat = 20
    let spacing: CGFloat = 8
    let charWidth: CGFloat = 14

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FlexibleWrapRadioLayout(items: options, spacing: 12, circleWidth: circleWidth, charWidth: charWidth) { option in
                HStack(spacing: 8) {
                    Circle()
                        .stroke(Color(hex: accent), lineWidth: 2)
                        .background(
                            Circle()
                                .fill(selected == option ? Color(hex: accent) : Color.clear)
                        )
                        .frame(width: circleWidth, height: circleWidth)
                        .onTapGesture {
                            selected = option
                        }

                    CustomText(text: option, color: accent, textSize: 20)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .onTapGesture {
                            selected = option
                        }
                }
                .padding(.trailing, 25)
                .fixedSize()
                .contentShape(Rectangle())
            }
        }
        .padding(.bottom, 10)
    }
}

// MARK: - Flexible Wrap Layout for Radio Buttons
struct FlexibleWrapRadioLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    var items: Data
    var spacing: CGFloat
    var circleWidth: CGFloat
    var charWidth: CGFloat
    var content: (Data.Element) -> Content

    init(items: Data, spacing: CGFloat, circleWidth: CGFloat, charWidth: CGFloat, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.spacing = spacing
        self.circleWidth = circleWidth
        self.charWidth = charWidth
        self.content = content
    }

    var body: some View {
        generateContent(in: UIScreen.main.bounds.width - 20)
    }

    private func generateContent(in totalWidth: CGFloat) -> some View {
        var width: CGFloat = 0
        var rows: [[Data.Element]] = [[]]

        for item in items {
            let itemWidth = estimateWidth(for: item)
            if width + itemWidth + spacing > totalWidth {
                rows.append([item])
                width = itemWidth + spacing
            } else {
                rows[rows.count - 1].append(item)
                width += itemWidth + spacing
            }
        }

        return VStack(alignment: .leading, spacing: spacing) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(alignment: .center, spacing: spacing) {
                    ForEach(rows[rowIndex], id: \.self) { item in
                        content(item)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading) // ✅ left-align rows
            }
        }
    }

    private func estimateWidth(for item: Data.Element) -> CGFloat {
        let textCount = String(describing: item).count
        return circleWidth + 8 + CGFloat(textCount) * charWidth
    }
}





import SwiftUI

struct StepSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    var accentColor: String
    var width: CGFloat

    private var steps: [Double] {
        stride(from: range.lowerBound, through: range.upperBound, by: step).map { $0 }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                let trackWidth = geo.size.width
                let extraMargin: CGFloat = 14
                let usableWidth = trackWidth - 2 * extraMargin
                let spacing = usableWidth / CGFloat(steps.count - 1)
                let index = steps.firstIndex(of: value) ?? 0

                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(hex: accentColor).opacity(0.3))
                        .frame(width: usableWidth + 2 * extraMargin, height: 4)
                        .position(x: trackWidth / 2, y: geo.size.height / 2)

                    Rectangle()
                        .fill(Color(hex: accentColor))
                        .frame(width: CGFloat(index) * spacing, height: 4)
                        .position(x: extraMargin + CGFloat(index) * spacing / 2, y: geo.size.height / 2)

                    ForEach(0..<steps.count, id: \.self) { i in
                        Rectangle()
                            .fill(Color(hex: accentColor))
                            .frame(width: 2, height: 14)
                            .position(x: extraMargin + CGFloat(i) * spacing, y: geo.size.height / 2)
                    }

                    Circle()
                        .fill(Color(hex: accentColor))
                        .frame(width: 28, height: 28)
                        .position(
                            x: extraMargin + CGFloat(index) * spacing,
                            y: geo.size.height / 2
                        )
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { gesture in
                                    let clampedX = min(max(gesture.location.x - extraMargin, 0), usableWidth)
                                    let nearestIndex = Int(round(clampedX / spacing))
                                    let safeIndex = min(max(nearestIndex, 0), steps.count - 1)
                                    value = steps[safeIndex]
                                }
                        )
                }
            }
            .frame(height: 30)

            HStack(spacing: 0) {
                ForEach(steps, id: \.self) { stepValue in
                    CustomText(
                        text: "\(Int(stepValue))",
                        color: accentColor,
                        textAlignment: .center,
                        multilineAlignment: .center,
                        textSize: 18
                    )
                    .frame(width: 35)
                }
            }
            .padding(.horizontal, 10)
        }
        .frame(width: width)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 15)
    }
    
}

struct CustomSingleCheckbox: View {
    var text: String
    var color: String
    @Binding var isOn: Bool
    var textSize: CGFloat = 24

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack {
                CustomText(text:text, color:color, isBold: true, textSize: textSize)
                    .fixedSize(horizontal: true, vertical: false)
                Image(systemName: isOn ? "checkmark.square.fill" : "square")
                    .resizable()
                    .frame(width: textSize , height: textSize)
                    .foregroundColor(Color(hex: color))
                    .padding(.leading, 10)
            Spacer()
                
            }

        }
        .buttonStyle(.plain)
        .frame(width: UIScreen.main.bounds.width-40)
        .padding(.trailing, 10)
        .padding(.bottom, 10)
    }
}
import SwiftUI

struct MultipleChoiceCheckboxGroup: View {
    @Binding var options: [String]
    @Binding var selected: Set<String> // ✅ multiple selections
    var accent: String
    var background: String

    let boxSize: CGFloat = 22
    let spacing: CGFloat = 8
    let charWidth: CGFloat = 14

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FlexibleWrapCheckboxLayout(items: options, spacing: 12, boxSize: boxSize, charWidth: charWidth) { option in
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(selected.contains(option) ? Color(hex: accent) : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(hex: accent), lineWidth: 2)
                            )
                            .frame(width: boxSize, height: boxSize)

                        if selected.contains(option) {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(hex: background)) // ✅ checkmark matches background
                                .font(.system(size: boxSize * 0.7, weight: .bold))
                        }
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            toggleSelection(option)
                        }
                    }

                    CustomText(text: option, color: accent, textSize: 20)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                toggleSelection(option)
                            }
                        }
                }
                .padding(.trailing, 25)
                .fixedSize() // ✅ each item only takes needed width
                .contentShape(Rectangle())
            }
        }
        .padding(.bottom, 10) // ✅ padding is below the *whole group*
    }

    private func toggleSelection(_ option: String) {
        if selected.contains(option) {
            selected.remove(option)
        } else {
            selected.insert(option)
        }
    }
}

// MARK: - Flexible Layout
struct FlexibleWrapCheckboxLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    var items: Data
    var spacing: CGFloat
    var boxSize: CGFloat
    var charWidth: CGFloat
    var content: (Data.Element) -> Content

    init(items: Data, spacing: CGFloat, boxSize: CGFloat, charWidth: CGFloat, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.spacing = spacing
        self.boxSize = boxSize
        self.charWidth = charWidth
        self.content = content
    }

    var body: some View {
        generateContent(in: UIScreen.main.bounds.width - 20)
    }

    private func generateContent(in totalWidth: CGFloat) -> some View {
        var width: CGFloat = 0
        var rows: [[Data.Element]] = [[]]

        for item in items {
            let itemWidth = estimateWidth(for: item)
            if width + itemWidth + spacing > totalWidth {
                // start new row
                rows.append([item])
                width = itemWidth + spacing
            } else {
                rows[rows.count - 1].append(item)
                width += itemWidth + spacing
            }
        }

        return VStack(alignment: .leading, spacing: spacing) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(alignment: .center, spacing: spacing) {
                    ForEach(rows[rowIndex], id: \.self) { item in
                        content(item)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func estimateWidth(for item: Data.Element) -> CGFloat {
        let textCount = String(describing: item).count
        return boxSize + 8 + CGFloat(textCount) * charWidth
    }
}

