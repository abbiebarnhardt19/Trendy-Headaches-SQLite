//
//  ForgotPasswordView2.swift
//  Trendy Headaches
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
        let normalizedInput = DatabaseManager.shared.normalizedEmail(
            enteredAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        let hashedInput = CryptoHelper.hashString(normalizedInput)
        return hashedInput == securityAnswerHash
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                CustomText(text: securityQuestion)
                
                SecureField("", text: $enteredAnswer)
                    .textFieldStyle(CustomTextField())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                if !enteredAnswer.isEmpty && !isCorrectAnswer {
                    CustomWarningText(text: "Answers do not match.")
                }
                
                CustomNavButton(label: "Continue", destination: ForgotPasswordView3())
                    .disabled(!isCorrectAnswer)
            }
            .padding()
            .CustomView()
            .onAppear {
                loadSecurityQuestion()
            }
        }
    }
    
    private func loadSecurityQuestion() {
        guard let id = DatabaseManager.shared.getUserFromEmail(email: enteredEmail) else {
            userID = nil
            securityQuestion = ""
            securityAnswerHash = ""
            return
        }
        
        userID = id
        securityQuestion = DatabaseManager.shared.getSingleColumnValue(
            userId: id,
            columnName: "security_question"
        ) ?? ""
        
        // Load the hashed security answer exactly as stored
        securityAnswerHash = DatabaseManager.shared.getSingleColumnValue(
            userId: id,
            columnName: "security_answer"
        ) ?? ""
    }
}

#Preview {
    ForgotPasswordView2(enteredEmail: "test@example.com")
}
