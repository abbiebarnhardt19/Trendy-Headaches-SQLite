//
//  CreateAccountView3.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/30/25.
//

import SwiftUI

struct CreateAccountView3: View {
    var email: String = ""
    var password_one: String = ""
    var security_question: String = ""
    var security_answer: String = ""
    
    let options = ["Classic Light", "Light Pink", "Light Yellow", "Classic Dark", "Dark Green","Dark Blue", "Dark Purple", "Custom"]
    
    @State private var color_theme: String = ""
    @State private var background_color: String = "#001d00"
    @State private var accent_color: String = "#b5c4b9"

    
    var body: some View {
        NavigationStack {
            VStack {
                CustomText(text: "Choose a color theme", color: accent_color)
                
                DropdownMenu(selection: $color_theme, options: options, background: background_color, accent: accent_color)
                    .onChange(of: color_theme) {
                        let colors = DatabaseManager.getThemeColors(theme: color_theme)
                        background_color = colors.background
                        accent_color = colors.accent
                    }.padding(.bottom, 20)
                
                if color_theme == "Custom"{
                    CustomText(text:"Or, design a custom theme by entering two hex codes", color: accent_color)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("", text: $background_color)
                        .textFieldStyle(CustomTextField(background: background_color, accent: accent_color))
                    .padding(.bottom, 15)
                    
                    TextField("", text: $accent_color)
                        .textFieldStyle(CustomTextField(background: background_color, accent: accent_color))
                    .padding(.bottom, 15)
                }
        
                CustomNavButton(label: "Continue",
                        destination: CreateAccountView2(
                            background: background_color,
                            accent: accent_color,
                            email: email,
                            passwordOne: password_one,
                            currentSecurityQuestion: security_question,
                            currentSecurityAnswer: security_answer
                        ), background: background_color, accent: accent_color

            )
                
                
            }
            .padding()
            .CustomView(color: background_color)
        }
    }
}

#Preview {
    CreateAccountView3(email: "testtest",
                       password_one: "password_one",
                       security_question: "security_question",
                       security_answer: "security_answer")
}
