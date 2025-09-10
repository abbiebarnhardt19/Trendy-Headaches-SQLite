//
//  ForgotPasswordView3.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/28/25.

import SwiftUI

struct ForgotPasswordView2: View {
    //passed through variable
    let enteredEmail: String
    
    //editable variable
    @State private var securityQuestion: String = ""
    @State private var securityAnswerHash: String = ""
    @State private var enteredAnswer: String = ""
    @State private var userID: Int64? = nil
    
    //colors and padding
    let accent = "#b5c4b9"
    let background = "#001d00"
    let leading_padding = CGFloat(20)
    
    //check if the answer correct after removing capitals and whitespace. Comapred the hashed normalized value to hashed value in database
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
                //set background color
                Color(hex: background).ignoresSafeArea()
                
                //asymetric blobs
                ParametricBlob(points: 18, amplitude: 0.2, x:-80, y:400, rotation:200, accent:accent)
                ParametricBlob(points: 20, amplitude: 0.2, x:10, y:400, rotation:11, accent:accent)
                
                VStack {
                    //header text
                    CustomWelcome(text:"Please answer your security question", color: accent, textAlignment: .leading, width:220)
                        .padding(.trailing, 120)
                    
                    VStack {
                        //display user's security question based off email
                        CustomText(text: securityQuestion, color: accent)
                            .padding(.leading, leading_padding)
                        
                        //enter answer
                        SecureField("", text: $enteredAnswer)
                            .textFieldStyle(CustomTextField(background: background,accent: accent))
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        
                        //if they have attempted to answer but it is wrong, display warning
                        if !enteredAnswer.isEmpty && !isCorrectAnswer {
                            CustomWarningText(text: "Answers do not match.")
                        }
                        
                        //reserve space for warning
                        else {
                            CustomWarningText(text: " ")
                        }
                        
                        //move to next page once anwer is correct, pass email
                        CustomNavButton(
                            label: "Continue", destination: ForgotPasswordView3(enteredEmail: enteredEmail), background: background, accent: accent
                        )
                        .disabled(!isCorrectAnswer)
                        .padding(.bottom, 170)
                    }
                }
            }
        }
        //get the user id, security question, and security answer based off the previously entered email on page load
        .onAppear {
            //let result = DatabaseManager.getSecurityQuestionAndAnswer(forEmail: enteredEmail)
            userID = DatabaseManager.shared.getUserFromEmail(email: enteredEmail)
            securityQuestion = DatabaseManager.shared.getSingleColumnValue(userId: userID ?? -1, columnName: "security_question") ?? ""
            securityAnswerHash = DatabaseManager.shared.getSingleColumnValue(userId: userID ?? -1, columnName: "security_answer") ?? ""
        }
    }
}

#Preview {
    ForgotPasswordView2(enteredEmail: "test@example.com")
}
