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
    
    let options = ["Red (light mode)", "Red (dark mode)", "Green (light mode)", "Green (dark mode)", "Blue (light mode)", "Blue (dark mode)", "Purple (light mode)", "Purple (dark mode)", "Pink (light mode)", "Pink (dark mode)", "White", "Black"]
    
    @State private var color_theme: String = ""
    @State private var background_color: String = "#001d00"
    @State private var accent_color: String = "#b5c4b9"

    
    var body: some View {
        NavigationStack {
            VStack {
                CustomText(text: "Choose a color theme", color: accent_color)
                
                DropdownMenu(selection: $color_theme, options: options, background: background_color, accent: accent_color)
                    .onChange(of: color_theme) {
                        let colors = DatabaseManager.getColors(theme: color_theme)
                        background_color = colors.background
                        accent_color = colors.accent
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
