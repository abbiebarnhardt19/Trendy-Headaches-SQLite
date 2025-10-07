//
//  Custom Text and Buttons.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SwiftUI

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
    var bottomPadding: CGFloat? = 8
    var alignment: TextAlignment = .leading
    
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
                    .multilineTextAlignment(alignment)
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
        .padding(.bottom,  bottomPadding ?? 8)
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

        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: columnCount), spacing: 3) {
            ForEach(items, id: \.self) { item in
                Text("• \(item)")
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(Color(hex: color))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .center)
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
