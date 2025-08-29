//
//  Styles.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/24/25.
//

import SwiftUI
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
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.top, 10)
            .padding(.bottom, 10)
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .background(Color(hex: "#b5c4b9"))
            .foregroundColor(Color(hex: "#001d00"))
            .cornerRadius(8)
        .padding(.trailing, 20)
        .padding(.leading, 20)
    }

}


struct CustomText: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(Color(hex: "#b5c4b9"))
            .frame(maxWidth:.infinity, alignment: .leading)
        .padding(.trailing, 20)
        .padding(.leading, 20)
    }
}

struct CustomNavButton<Destination: View>: View {
    var label: String
    var destination: Destination

    var body: some View {
        NavigationLink {
            destination
        } label: {
            Text(label)
                .padding(.horizontal, 40)
                .padding(.vertical, 10)
                .background(Color(hex: "#b5c4b9"))
                .foregroundColor(Color(hex: "#001d00"))
                .cornerRadius(10)
        }
        .padding(.top, 10)
        .buttonStyle(.plain)
    }
}

struct TempLinkText: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundColor(Color(hex: "#b5c4b9"))
            .frame(maxWidth:.infinity, alignment: .leading)
    }
}

struct CustomWarningText: View {
    var text: String
    var body: some View {
        Text(text)
            .foregroundColor(.red)
            .font(.footnote)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .multilineTextAlignment(.leading)
    }
}

struct CustomSubtext: View {
    var text: String
    var body: some View {
        Text(text)
            .foregroundColor(.red)
            .font(.footnote)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 5)
            .padding(.bottom, 5)
    }
}

struct CustomWelcome: View {
    var text: String
    var body: some View {
        Text(text)
            .multilineTextAlignment(.center)
            .font(.system(size: 40, weight: .bold))
            .foregroundColor(Color(hex: "#b5c4b9"))
            .padding(.bottom, 10)
    }
}

struct CustomInstructions: View {
    var text: String
    var body: some View {
        Text(text)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Color(hex: "#b5c4b9"))
            .padding(.bottom, 10)
        .padding(.trailing, 15)
        .padding(.leading, 15)
    }
}

extension View {
    func CustomView() -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "#001D00"))
    }
}

struct CustomButton: View {
    var text: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .padding(.top, 15)
                .padding(.bottom, 15)
                .padding(.leading, 15)
                .padding(.trailing,15)
                .background(Color(hex: "#b5c4b9"))
                .foregroundColor(Color(hex: "#001d00"))
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}



