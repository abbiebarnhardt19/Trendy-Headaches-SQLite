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
    let leading_padding = CGFloat(40)
    let screen_width = UIScreen.main.bounds.width
    
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
            ZStack{
                //set background color
                Color(hex: background).ignoresSafeArea()
                ScrollView{
                    ZStack {
                        //asymetric blobs
                        ParametricBlob(points: 40, amplitude: 0.075, x:-140, y:270, rotation:210, accent:accent)
                        ParametricBlob(points: 40, amplitude: 0.075, x:10, y:500, rotation:17, accent:accent)
                        
                        VStack {
                            //header text
                            HStack{
                                CustomText(text:"Please answer your security question", color:accent, width:screen_width/2, textAlignment: .leading, multilineAlignment: .leading, textSize: 50)
                                    .padding(.leading, leading_padding)
                                Spacer()
                            }
                            
                            VStack {
                                //display user's security question based off email
                                CustomText(text: securityQuestion, color: accent)
                                    .padding(.leading, leading_padding)
                                    .padding(.top, 30)
                                
                                //enter answer
                                CustomTextField(background: background, accent: accent, placeholder:"", text: $enteredAnswer, isSecure: true)
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
    }
}

#Preview {
    ForgotPasswordView2(enteredEmail: "testtest@test.com")
}
