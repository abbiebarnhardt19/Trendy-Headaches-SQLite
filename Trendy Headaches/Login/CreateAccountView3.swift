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
    
    @State private var color_theme: String = "Dark Green"
    @State private var background: String = "#001d00"
    @State private var accent: String = "#b5c4b9"
    
    let foregroundForDifference = Color(
        red: abs(0 - 0)/255.0,
        green: abs(29 - 0)/255.0,
        blue: abs(0 - 0)/255.0
    )

    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: background).ignoresSafeArea()
                
                SameAmplitudeBlob(waves: 10, amplitude: 20, accent: accent, x:100, y: -220, rotation: -180)
                
                SameAmplitudeBlob(waves: 10, amplitude:20, accent: accent, x:100, y: -220, rotation: 360)
                
                VStack{

                    CustomText(text: "Choose a color theme", color: accent)
                        .padding(.leading, 165)

                    CustomDropdown(color_theme: $color_theme, background: $background, accent: $accent, options: options)

                    if color_theme == "Custom"{
                        CustomText(text:"Or, enter two hex codes to design a theme", color: accent)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: 390, alignment: .leading)
                        
                        HStack{
                            TextField("", text: background != "#001d00" && accent != "#b5c4b9" ? $background : .constant(""))
                                .textFieldStyle(CustomTextField(background: background, accent: accent, width: 160))
                                .padding(.trailing, 20)
                                .multilineTextAlignment(.center)
                                
                            TextField("", text: background != "#001d00" && accent != "#b5c4b9" ? $accent : .constant(""))
                                .textFieldStyle(CustomTextField(background: background, accent: accent, width: 160))
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    CustomNavButton(label: "Continue", destination: CreateAccountView2(background: background, accent: accent, email: email, passwordOne: password_one, currentSecurityQuestion: security_question, currentSecurityAnswer: security_answer), background: background, accent: accent
                    )
                }
            }
        }
    }
}

#Preview {
    CreateAccountView3(email: "testtest", password_one: "password_one", security_question: "security_question", security_answer: "security_answer")
}
