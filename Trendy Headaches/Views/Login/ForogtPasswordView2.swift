//
//  ForgotPasswordView2.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/28/25.
//

import SwiftUI

struct ForgotPasswordView2: View {
    // MARK: - Input
    let email: String

    // MARK: - State
    @State private var SQ = ""
    @State private var SA = ""
    @State private var answer = ""
    @State private var userID: Int64? = nil

    // MARK: - Theme
    private let accent = "#b5c4b9"
    private let bg = "#001d00"
    private let leadPadd: CGFloat = 30
    private let screenWidth = UIScreen.main.bounds.width

    // MARK: - Validation
    private var correct: Bool {
        guard !answer.isEmpty else { return false }
        let normAnswer = Database.normalize(
            answer.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        return Database.hashString(normAnswer) == SA
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Forgot2BGComps(bg: bg, accent: accent)

                ScrollView {
                    ZStack {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            //  Header
                            HStack {
                                CustomText(text: "Please answer your security question", color: accent,  width: screenWidth / 2, textAlign: .leading, multiAlign: .leading, textSize: 50)
                                .padding(.leading, leadPadd)
                                Spacer()
                            }

                            //  Security Question
                            CustomText(text: SQ, color: accent)
                                .padding(.leading, leadPadd)
                                .padding(.top, 30)

                            // Answer Field
                            CustomTextField( bg: bg, accent: accent,  placeholder: "", text: $answer, secure: true)
                                .padding(.leading, leadPadd-10)
                            .disableAutocorrection(true)

                            //  Warning
                            if !answer.isEmpty && !correct {
                                CustomWarningText(text: "Answers do not match.")
                            } else {
                                CustomWarningText(text: " ")
                            }

                            //  Continue Button
                            HStack{
                                Spacer()
                                CustomNavButton( label: "Continue", dest: ForgotPasswordView3(email: email),  bg: bg, accent: accent )
                                    .disabled(!correct)
                                Spacer()
                            }
                        }
                    }
                }
                .onAppear {
                    userID = Database.shared.userFromEmail(email: email)
                    SQ = Database.shared.getSingleVal(userId: userID ?? -1, col: "security_question") ?? ""
                    SA = Database.shared.getSingleVal(userId: userID ?? -1, col: "security_answer") ?? ""
                }
            }
        }
    }
}

#Preview {
    ForgotPasswordView2(email: "testtest@test.com")
}
