//
//  ForgotPasswordView3.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/28/25.

import SwiftUI

struct ForgotPasswordView2: View {
    let enteredEmail: String
    
    @State private var securityQuestion: String = ""
    @State private var securityAnswerHash: String = ""
    @State private var enteredAnswer: String = ""
    @State private var userID: Int64? = nil
    
    let accent = "#b5c4b9"
    let background = "#001d00"
    let leading_padding = CGFloat(20)
    
    private var isCorrectAnswer: Bool {
        guard !enteredAnswer.isEmpty else { return false }
        let normalizedInput = DatabaseManager.normalizedValue(
            enteredAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        let hashedInput = DatabaseManager.hashString(normalizedInput)
        return hashedInput == securityAnswerHash
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: background).ignoresSafeArea()
                
                ParametricBlob(points: 18, amplitude: 0.2, x:-80, y:400, rotation:200, accent:accent)
                
                ParametricBlob(points: 20, amplitude: 0.2, x:10, y:400, rotation:11, accent:accent)
                
                VStack {
                    // Title pinned top-left
                    CustomWelcome(text:"Please answer your security question", color: accent, alignment:.leading, textAlignment: .leading, width:220)
                        .padding(.trailing, 120)
                    
                    // Question + input + button
                    VStack {
                        CustomText(text: "test test", color: accent)
                            .padding(.leading, leading_padding)
                        
                        SecureField("", text: $enteredAnswer)
                            .textFieldStyle(CustomTextField(background: background,accent: accent))
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        
                        if !enteredAnswer.isEmpty && !isCorrectAnswer {
                            CustomWarningText(text: "Answers do not match.")
                        }
                        else {
                            CustomWarningText(text: " ")
                        }
                        
                        CustomNavButton(
                            label: "Continue", destination: ForgotPasswordView3(enteredEmail: enteredEmail), background: background, accent: accent
                        )
                        .disabled(!isCorrectAnswer)
                        .padding(.bottom, 170)
                    }
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .onAppear {
            let result = DatabaseManager.getSecurityQuestionAndAnswer(forEmail: enteredEmail)
            userID = result.userId
            securityQuestion = result.question
            securityAnswerHash = result.hashedAnswer
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    ForgotPasswordView2(enteredEmail: "test@example.com")
}
