//
//  ForgotPasswordView3.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/28/25.
//
import SwiftUI

struct ForgotPasswordView2: View {
    let enteredEmail: String   // passed from ForgotPasswordView1
    
    @State private var securityQuestion: String = ""
    @State private var securityAnswerHash: String = ""   // stored hashed value
    @State private var enteredAnswer: String = ""
    @State private var userID: Int64? = nil
    
    // Computed property to check if entered answer is correct
    private var isCorrectAnswer: Bool {
        guard !enteredAnswer.isEmpty else { return false }
        let normalizedInput = DatabaseManager.shared.normalizedValue(
            enteredAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        let hashedInput = DatabaseManager.hashString(normalizedInput)
        return hashedInput == securityAnswerHash
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                CustomInstructions(text: "Please answer the following security question to proceed.")
                
                CustomText(text: securityQuestion)
                
                SecureField("", text: $enteredAnswer)
                    .textFieldStyle(CustomTextField())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                if !enteredAnswer.isEmpty && !isCorrectAnswer {
                    CustomWarningText(text: "Answers do not match.")
                }
                
                CustomNavButton(label: "Continue", destination: ForgotPasswordView3(enteredEmail: enteredEmail))
                    .disabled(!isCorrectAnswer)
            }
            .padding()
            .CustomView()
            .onAppear {
                // directly assign values using the helper in CustomFunctions
                let result = DatabaseManager.getSecurityQuestionAndAnswer(forEmail: enteredEmail)
                userID = result.userId
                securityQuestion = result.question
                securityAnswerHash = result.hashedAnswer
            }
        }
    }
}

#Preview {
    ForgotPasswordView2(enteredEmail: "test@example.com")
}
