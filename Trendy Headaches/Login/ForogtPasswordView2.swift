//
//  ForgotPasswordView3.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/28/25.
//
import SwiftUI

struct ForgotPasswordView2: View {
    let enteredEmail: String
    
    
    @State private var securityQuestion: String = ""
    @State private var securityAnswerHash: String = ""   // stored hashed value
    @State private var enteredAnswer: String = ""
    @State private var userID: Int64? = nil
    
    let accent = "#b5c4b9"
    let background = "#001d00"
    
    // Computed property to check if entered answer is correct
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
                Color.clear
                    .background(
                        ZStack {
                            ParametricBlob(points: 18, amplitude: 0.2)
                                .fill(Color(hex: accent))
                                .frame(width: 400, height: 300)
                                .offset(x:-80, y: 400)
                                .rotationEffect(.degrees(200))

                            ParametricBlob(points: 20, amplitude: 0.2)
                                .fill(Color(hex: accent))
                                .frame(width: 500, height: 300)
                                .offset(x:10, y: 400)
                                .rotationEffect(.degrees(11))
                        }
                        .ignoresSafeArea()
                    )
                
                // Foreground content
                VStack {
                    Text("Please answer your security question")
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 40, design: .serif))
                        .foregroundColor(Color(hex: accent))
                        .frame(maxWidth: 200)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                
                VStack {
                    CustomText(text: "Test Question", color: accent)
                        .padding(.top, 100)
                    
                    SecureField("", text: $enteredAnswer)
                        .textFieldStyle(CustomTextField(background: background, accent: accent, height: 60, width: 350))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    if !enteredAnswer.isEmpty && !isCorrectAnswer {
                        CustomWarningText(text: "Answers do not match.")
                            .padding(.leading, 20)
                    }
                    else{
                        CustomWarningText(text: "                      ")
                            .padding(.leading, 20)
                        
                    }
                    
                    CustomNavButton(
                        label: "Continue",
                        destination: ForgotPasswordView3(enteredEmail: enteredEmail),
                        background: background,
                        accent: accent
                    )
                    .disabled(!isCorrectAnswer)
                    .padding(.top, 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .onAppear {
                let result = DatabaseManager.getSecurityQuestionAndAnswer(forEmail: enteredEmail)
                userID = result.userId
                securityQuestion = result.question
                securityAnswerHash = result.hashedAnswer
            }
            .CustomView(color: background)
        }
    }
}

#Preview {
    ForgotPasswordView2(enteredEmail: "test@example.com")
}
