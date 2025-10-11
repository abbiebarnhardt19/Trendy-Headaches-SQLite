//
//  ForgotPasswordView2.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/28/25.
//

import SwiftUI

struct ForgotPasswordView2: View {
    // MARK: - Input
    let enteredEmail: String

    // MARK: - State
    @State private var securityQuestion = ""
    @State private var securityAnswerHash = ""
    @State private var enteredAnswer = ""
    @State private var userID: Int64? = nil

    // MARK: - Theme
    private let accent = "#b5c4b9"
    private let background = "#001d00"
    private let leadingPadding: CGFloat = 30
    private let screenWidth = UIScreen.main.bounds.width

    // MARK: - Validation
    private var isCorrectAnswer: Bool {
        guard !enteredAnswer.isEmpty else { return false }
        let normalizedInput = DatabaseManager.normalizedValue(
            enteredAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        return DatabaseManager.hashString(normalizedInput) == securityAnswerHash
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Forgot2BackgroundComponents(background: background, accent: accent)

                ScrollView {
                    ZStack {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            //  Header
                            HStack {
                                CustomText(text: "Please answer your security question", color: accent,  width: screenWidth / 2, textAlignment: .leading, multilineAlignment: .leading, textSize: 50)
                                .padding(.leading, leadingPadding)
                                Spacer()
                            }

                            //  Security Question
                            CustomText(text: securityQuestion, color: accent)
                                .padding(.leading, leadingPadding)
                                .padding(.top, 30)

                            // Answer Field
                            CustomTextField( background: background, accent: accent,  placeholder: "", text: $enteredAnswer, isSecure: true)
                                .padding(.leading, leadingPadding-10)
                            .disableAutocorrection(true)

                            //  Warning
                            if !enteredAnswer.isEmpty && !isCorrectAnswer {
                                CustomWarningText(text: "Answers do not match.")
                            } else {
                                CustomWarningText(text: " ")
                            }

                            //  Continue Button
                            CustomNavButton( label: "Continue", destination: ForgotPasswordView3(enteredEmail: enteredEmail),  background: background,accent: accent )
                            .disabled(!isCorrectAnswer)
                        }
                    }
                }
                .onAppear {
                    userID = DatabaseManager.shared.getUserFromEmail(email: enteredEmail)
                    securityQuestion = DatabaseManager.shared.getSingleColumnValue(
                        userId: userID ?? -1,
                        columnName: "security_question"
                    ) ?? ""
                    securityAnswerHash = DatabaseManager.shared.getSingleColumnValue(
                        userId: userID ?? -1,
                        columnName: "security_answer"
                    ) ?? ""
                }
            }
        }
    }
}

#Preview {
    ForgotPasswordView2(enteredEmail: "testtest@test.com")
}
