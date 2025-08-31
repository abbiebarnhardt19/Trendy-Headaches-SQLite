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
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.top, 10)
            .padding(.bottom, 10)
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .background(Color(hex: accent))
            .foregroundColor(Color(hex: background))
            .cornerRadius(8)
            .padding(.leading, 20)
            .padding(.trailing, 20)
    }
}


struct CustomText: View {
    var text: String
    var color: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(Color(hex: color))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing, 20)
            .padding(.leading, 20)
    }
}

struct CustomNavButton<Destination: View>: View {
    var label: String
    var destination: Destination
    var background: String
    var accent: String

    var body: some View {
        NavigationLink {
            destination
        } label: {
            Text(label)
                .padding(.horizontal, 40)
                .padding(.vertical, 10)
                .background(Color(hex: accent))
                .foregroundColor(Color(hex: background))
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


//under textField text
struct CustomWarningText: View {
    var text: String
    var body: some View {
        Text(text)
            .foregroundColor(.red)
            .font(.footnote)
            .multilineTextAlignment(.leading) // ensures multi-line text aligns left
            .frame(maxWidth: .infinity, alignment: .leading) // ensures single-line stays left
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 15)
            .padding(.trailing, 15)
    }
}

//main title text
struct CustomWelcome: View {
    var text: String
    var color: String
    var body: some View {
        Text(text)
            .multilineTextAlignment(.center)
            .font(.system(size: 50, weight: .bold))
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
            .font(.system(size: 20, weight: .bold))
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
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .padding(.vertical, 10)
                .padding(.leading, 15)
                .padding(.trailing,15)
                .background(Color(hex: background))
                .foregroundColor(Color(hex: accent))
                .cornerRadius(10)
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
    }
}
