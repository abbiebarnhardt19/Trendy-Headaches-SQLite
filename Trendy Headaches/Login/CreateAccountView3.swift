//
//  CreateAccountView3.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/30/25.
//

import SwiftUI

struct CreateAccountView3: View {
    
    //form entries from previous page
    var email: String = ""
    var password_one: String = ""
    var security_question: String = ""
    var security_answer: String = ""
    
    //color theme options
    let options = ["Classic Light", "Light Pink", "Light Yellow", "Classic Dark", "Dark Green","Dark Blue", "Dark Purple", "Custom"]
    
    //editable variables, set to defaults
    @State private var color_theme: String = "Dark Green"
    @State private var background: String = "#001d00"
    @State private var accent: String = "#b5c4b9"
    
    //leading padding constant
    let leading_padding = CGFloat(10)
    
    var body: some View {
        NavigationStack {
            ZStack {
                //set background color
                Color(hex: background).ignoresSafeArea()
                
                //corner symmetric blobs
                SameAmplitudeBlob(waves: 10, amplitude: 20, accent: accent, x:100, y: -220, rotation: -180)
                SameAmplitudeBlob(waves: 10, amplitude:20, accent: accent, x:100, y: -220, rotation: 360)
                
                VStack{
                    //header
                    CustomText(text: "Choose a color theme", color: accent)
                        .padding(.leading, 165)

                    //dropdown with theme options
                    CustomDropdown(color_theme: $color_theme, background: $background, accent: $accent, options: options, width: 350, height:50, cornerRadius: 30, fontSize: 22)

                    //if they chose custom, show additional instructions and text boxes
                    if color_theme == "Custom"{
                        //custom instructions
                        CustomText(text:"Or, enter two hex codes to design a theme", color: accent)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: 390, alignment: .leading)
                            .padding(.leading, 20)
                        
                        //side by side text boxes for two hex codes
                        HStack {
                            TextField("", text: $background)
                                .textFieldStyle(CustomTextField(background: background, accent: accent, width: 160))
                                .padding(.trailing, 20)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 18, design: .serif)) // optional, if you want serif font

                            TextField("", text: $accent)
                                .textFieldStyle(CustomTextField(background: background, accent: accent, width: 160))
                                .multilineTextAlignment(.center)
                                .font(.system(size: 18, design: .serif)) // optional, if you want serif font
                        }
                    }
                    
                    //button to move to next page with previous form information and new colors
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
