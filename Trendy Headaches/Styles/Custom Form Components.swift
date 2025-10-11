//
//  Custom Form Components.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SwiftUI

struct MultipleChoiceCheckboxGroup: View {
    @Binding var options: [String]
    @Binding var selected: [String]
    var accent: String
    var background: String
    var width: CGFloat = 140
    
    let boxSize: CGFloat = 22
    let spacing: CGFloat = 8
    
    var body: some View {
        FlexibleWrapCheckboxLayout(
            items: options,
            spacing: spacing,
            maxWidth: width
        ) { option in
            HStack(spacing: 6) {
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
                            .foregroundColor(Color(hex: background))
                            .font(.system(size: boxSize * 0.7, weight: .bold))
                    }
                }
                
                CustomText(text: option, color: accent, textSize: 20)
                    .lineLimit(1)
                    .fixedSize()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.15)) {
                    if let index = selected.firstIndex(of: option) {
                        selected.remove(at: index)
                    } else {
                        selected.append(option)
                    }
                }
            }
        }
        .frame(width: width, alignment: .leading)
    }
}

struct FlexibleWrapCheckboxLayout<Item: Hashable, Content: View>: View {
    var items: [Item]
    var spacing: CGFloat
    var maxWidth: CGFloat
    var content: (Item) -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            let rows = computeRows()
            ForEach(rows.indices, id: \.self) { rowIndex in
                HStack(spacing: spacing) {
                    ForEach(rows[rowIndex], id: \.self) { item in
                        content(item)
                            .fixedSize()
                            .padding(.trailing, 15)
                            .padding(.bottom, 5)
                    }
                }
            }
        }
        .frame(width: maxWidth, alignment: .leading)
    }

    private func computeRows() -> [[Item]] {
        var rows: [[Item]] = []
        var currentRow: [Item] = []
        var currentWidth: CGFloat = 0

        for item in items {
            let itemWidth: CGFloat = estimateWidth(of: item)

            if currentWidth + itemWidth + spacing > maxWidth {
                rows.append(currentRow)
                currentRow = [item]
                currentWidth = itemWidth + spacing
            } else {
                currentRow.append(item)
                currentWidth += itemWidth + spacing
            }
        }

        if !currentRow.isEmpty { rows.append(currentRow) }
        return rows
    }

    private func estimateWidth(of item: Item) -> CGFloat {
        if let text = item as? String {
            return text.width(usingFont: .systemFont(ofSize: 20)) + 6 + 22 // text + spacing + checkbox
        } else {
            return 50
        }
    }
}

//custom switch
struct CustomToggle: View {
    var color: String
    @Binding var feature: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(hex: color))
            .frame(width: 50, height: 32)
            .overlay(Circle()
                .fill(.white)
                .padding(3)
                .offset(x: feature ? 10 : -10) )
            .onTapGesture { feature.toggle() }
    }
}

//color picker in text field
struct ColorPickerTextField: View {
    var accent: String
    var background: String
    @Binding var var_to_change: String
    var placeholder: String = ""
    var width: CGFloat
    var corner: CGFloat? = 30
    
    @State private var selectedColor: Color = .white
    
    var body: some View {
        CustomTextField(bg: background, accent: accent, placeholder: placeholder, text: $var_to_change, width: width, corner: corner ?? 30)
        .frame(height: 40)
        .overlay(alignment: .trailing) {
            ZStack {
                Image(systemName: "eyedropper")
                    .foregroundColor(Color(hex: background))
                    .font(.system(size: 17, weight: .bold))
                    .padding(.trailing, 15)
                
                // Transparent but tappable ColorPicker over the same spot
                ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                    .labelsHidden()
                    .opacity(0.015)
                    .frame(width: 28, height: 28)
                    .contentShape(Circle())
                    .padding(.trailing, 15)
            }
            .padding(.bottom, 8)
        }
        .onChange(of: selectedColor, initial: false) { oldColor, newColor in
            var_to_change = colorToHex(newColor)
        }
        .onAppear {
            selectedColor = Color(hex: var_to_change)
        }
    }
    
    //convert color to hex code
    private func colorToHex(_ color: Color) -> String {
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "#%02X%02X%02X", Int(red * 255),  Int(green * 255), Int(blue * 255))
    }
}

//calender dropdown in text field
struct DatePickerTextFieldDropdown: View {
    @Binding var selectedDate: Date
    @Binding var textFieldValue: String
    @Binding var background: String
    @Binding var accent: String
    @State var textFieldWidth: CGFloat = 220
    @State var arrowSpecialCase: Bool = false
    @State var labelText: String = "Date:"
    @State var textSize: CGFloat = 22
    @State var iconSize: CGFloat = 25
    @State var isBold: Bool = true
    
    @State private var showDatePicker: Bool = false
    @State private var screenWidth = UIScreen.main.bounds.width
    
    private var formatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .short
        return f
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                // TextField with button overlay
                HStack{
                    CustomText(text: labelText, color: accent, bold: isBold, textSize: 24)
                        .frame(width: 62, height: 45, alignment: .center)
                    
                    CustomTextField(bg: background, accent: accent,  placeholder: " ",  text: $textFieldValue,  width: textFieldWidth, textSize: textSize, botPad: 0)
                }
                //put the calendar button over the text field
                .overlay(
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation { showDatePicker.toggle() } }){
                            Image(systemName: "calendar")
                                .foregroundColor(Color(hex: background))
                                .font(.system(size: iconSize))
                                .padding(.trailing, 15)
                        }
                    })
                .buttonStyle(PlainButtonStyle())
                
                // Calendar dropdown
                if showDatePicker {
                    DatePicker(" ", selection: $selectedDate, in: ...Date(), displayedComponents: .date )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .frame(
                        width: screenWidth * (arrowSpecialCase ? 0.6 : 0.85),
                        height: screenWidth * (arrowSpecialCase ? 0.7: 0.85)
                    )
                    .scaleEffect(arrowSpecialCase ? 0.75 : 1.0)

                    .background(Color(hex: accent))
                    .accentColor(Color(hex: background))
                    .tint(Color(hex: background))
                    .cornerRadius(20)
                    .padding()
                    .padding(.bottom, 45)
                    .offset(y: 60)
                    .colorScheme(Color.isHexColorDark(accent) ? .dark : .light)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onChange(of: selectedDate) {
                        textFieldValue = formatter.string(from: selectedDate)
                        withAnimation { showDatePicker = false }
                    }
                }
            }
        }
    }
}

//checkbox with label next to it
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
                CustomText(text: text, color: color, bold: true, textSize: textSize)
                Image(systemName: isOn ? "checkmark.square.fill" : "square")
                    .resizable()
                    .frame(width: textSize, height: textSize)
                    .foregroundColor(Color(hex: color))
            }
            .padding(.trailing, 30)
            .padding(.bottom, 10)
        }
        .buttonStyle(.plain)
        .frame(width: UIScreen.main.bounds.width - 40)
    }
}

// mutliple choice group with dynamic sizing
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
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func estimateWidth(for item: Data.Element) -> CGFloat {
        let textCount = String(describing: item).count
        return circleWidth + 8 + CGFloat(textCount) * charWidth
    }
}

//numerical slider
struct StepSlider: View {
    @Binding var value: Int64
    let range: ClosedRange<Int64>
    let step: Int
    var accentColor: String
    var width: CGFloat

    private var steps: [Int64] {
        stride(from: range.lowerBound, through: range.upperBound, by: step).map { $0 }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                let trackWidth = geo.size.width
                let margin: CGFloat = 14
                let usableWidth = trackWidth - 2 * margin
                let spacing = usableWidth / CGFloat(steps.count - 1)
                let index = steps.firstIndex(of: value) ?? 0

                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(hex: accentColor).opacity(0.3))
                        .frame(width: usableWidth + 2 * margin, height: 4)
                        .position(x: trackWidth / 2, y: geo.size.height / 2)

                    Rectangle()
                        .fill(Color(hex: accentColor))
                        .frame(width: CGFloat(index) * spacing, height: 4)
                        .position(x: margin + CGFloat(index) * spacing / 2, y: geo.size.height / 2)

                    ForEach(0..<steps.count, id: \.self) { i in
                        Rectangle()
                            .fill(Color(hex: accentColor))
                            .frame(width: 2, height: 14)
                            .position(x: margin + CGFloat(i) * spacing, y: geo.size.height / 2)
                    }

                    Circle()
                        .fill(Color(hex: accentColor))
                        .frame(width: 28, height: 28)
                        .position(x: margin + CGFloat(index) * spacing, y: geo.size.height / 2)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { gesture in
                                    let clampedX = min(max(gesture.location.x - margin, 0), usableWidth)
                                    let nearestIndex = Int(round(clampedX / spacing))
                                    let safeIndex = min(max(nearestIndex, 0), steps.count - 1)
                                    value = steps[safeIndex]
                                })
                }
            }
            .frame(height: 30)

            HStack(spacing: 0) {
                ForEach(steps, id: \.self) { stepValue in
                    CustomText(text: "\(Int(stepValue))",  color: accentColor, textAlign: .center,  textSize: 18)
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
                        .background( Circle()
                            .fill(selected == option ? Color(hex: accent) : Color.clear))
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
        .padding(.leading, 5)
        .onAppear{
            if options.count == 1{
                selected = options[0]
            }
        }
    }
}

//dropdown option picker
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
            .background( RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(hex: accent)))
            .foregroundColor(Color(hex: background))
        }
        .onChange(of: color_theme) {
            let colors = Database.getThemeColors(theme: color_theme, currentBackground: background, currentAccent: accent)
            background = colors.background
            accent = colors.accent
        }
        .buttonStyle(.plain)
        .padding(.bottom, 20)
    }
}
