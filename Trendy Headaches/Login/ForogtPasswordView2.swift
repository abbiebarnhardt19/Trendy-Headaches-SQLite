//
//  ForgotPasswordView3.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/28/25.
//import SwiftUI
import SwiftUI

struct ForgotPasswordView2: View {
    let enteredEmail: String
    
    @State private var securityQuestion: String = ""
    @State private var securityAnswerHash: String = ""
    @State private var enteredAnswer: String = ""
    @State private var userID: Int64? = nil
    
    let accent = "#b5c4b9"
    let background = "#001d00"
    
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
                ZStack{

                    // Background blobs (fixed)
                    ParametricBlob(points: 18, amplitude: 0.2)
                        .fill(Color(hex: accent))
                        .frame(width: 400, height: 300)
                        .offset(x: -80, y: 400)   // use offset instead of position
                        .rotationEffect(.degrees(200))
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                    
                    ParametricBlob(points: 20, amplitude: 0.2)
                        .fill(Color(hex: accent))
                        .frame(width: 500, height: 300)
                        .offset(x: 10, y: 400)   // use offset instead of position
                        .rotationEffect(.degrees(11))
                        .ignoresSafeArea()
                        .allowsHitTesting(false)

                }
                .ignoresSafeArea(.keyboard)

                
                // Foreground content
                VStack(alignment: .leading, spacing: 40) {
                    // Title pinned top-left
                    Text("Please answer your security question")
                        .font(.system(size: 50, design: .serif))
                        .foregroundColor(Color(hex: accent))
                        .frame(width: 220, alignment: .leading)
                        .padding(.leading, 80)
                        
                    
                    // Question + input + button
                    VStack() {
                        CustomText(text: "Test question", color: accent)
                            .padding(.leading, 60)
                        
                        SecureField("", text: $enteredAnswer)
                            .textFieldStyle(
                                CustomTextField(background: background, accent: accent, height: 60, width: 350))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        if !enteredAnswer.isEmpty && !isCorrectAnswer {
                            CustomWarningText(text: "Answers do not match.")
                                .padding(.leading, 70)
                        } else {
                            CustomWarningText(text: " ")
                        }
                        
                        CustomNavButton(
                            label: "Continue",
                            destination: ForgotPasswordView3(enteredEmail: enteredEmail),
                            background: background,
                            accent: accent
                        )
                        .disabled(!isCorrectAnswer)
                        .padding(.bottom, 180)
                        
                    }
                }
                
            }
            .CustomView(color: background)
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
