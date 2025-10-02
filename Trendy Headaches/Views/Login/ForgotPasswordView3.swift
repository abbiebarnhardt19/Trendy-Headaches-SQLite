//
//  ForgotPasswordView3.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/29/25.
//

import SwiftUI

struct ForgotPasswordView3: View {
    //  Input
    let enteredEmail: String

    //  State
    @State private var passwordOne = ""
    @State private var passwordTwo = ""
    @State private var isPasswordUpdated = false
    @State private var currentPassword = ""

    // Theme
    private let accent = "#b5c4b9"
    private let background = "#001d00"
    private let leadingPadding: CGFloat = 40
    private let screenWidth = UIScreen.main.bounds.width

    //  Validation
    private var passwordResetValid: Bool {
        passwordOne == passwordTwo &&
        passwordOne != currentPassword &&
        DatabaseManager.isPasswordValid(passwordOne)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: background).ignoresSafeArea()

                ScrollView {
                    ZStack {
                        //  Background Blobs
                        ParametricBlob(points: 45, amplitude: 0.075, x: -160, y: 440, rotation: 335, accent: accent)
                        ParametricBlob(points: 45, amplitude: 0.075, x: 25, y: 350, rotation: 160, accent: accent)

                        VStack {
                            Spacer()

                            //  Header
                            HStack {
                                Spacer()
                                CustomText( text: "Last Step", color: accent, width: 100, textAlignment: .trailing, textSize: 50)
                                .padding(.top, 20)
                                .padding(.bottom, 90)
                                .padding(.trailing, leadingPadding)
                            }

                            //  Password 1
                            CustomText(text: "New Password", color: accent)
                                .padding(.leading, leadingPadding)

                            CustomTextField(background: background, accent: accent,  placeholder: "",  text: $passwordOne,  isSecure: true )

                            // Password warnings
                            if !passwordOne.isEmpty {
                                if !DatabaseManager.isPasswordValid(passwordOne) {
                                    CustomWarningText(text: "8+ chars: uppercase, lowercase, number, & symbol.")
                                        .padding(.bottom, 5)
                                } else if DatabaseManager.hashString(passwordOne) == currentPassword {
                                    CustomWarningText(text: "New password must differ from previous password.")
                                        .padding(.bottom, 5)
                                } else {
                                    CustomWarningText(text: "")
                                        .padding(.bottom, 15)
                                }
                            } else {
                                CustomWarningText(text: "")
                                    .padding(.bottom, 15)
                            }

                            //  Password 2
                            CustomText(text: "Confirm New Password", color: accent)
                                .padding(.leading, leadingPadding)

                            CustomTextField(background: background, accent: accent, placeholder: "", text: $passwordTwo,  isSecure: true )

                            if !passwordTwo.isEmpty && passwordTwo != passwordOne {
                                CustomWarningText(text: "Passwords do not match.")
                                    .padding(.bottom, 5)
                            } else {
                                CustomWarningText(text: " ")
                                    .padding(.bottom, 5)
                            }

                            // Reset Button
                            CustomButton(text: "Reset Password",  background: background, accent: accent, height: 50, width: 200) {
                                isPasswordUpdated = DatabaseManager.resetPassword(forEmail: enteredEmail, newPassword: passwordOne)
                            }
                            .padding(.bottom, 120)
                            .disabled(!passwordResetValid)
                            .opacity(passwordResetValid ? 1.0 : 0.5)
                            .navigationDestination(isPresented: $isPasswordUpdated) {
                                LoginView()
                            }

                            Spacer()
                        }
                    }
                    .onAppear {
                        if let currentUser = DatabaseManager.shared.getUserFromEmail(email: enteredEmail) {
                            currentPassword = DatabaseManager.shared.getSingleColumnValue(
                                userId: currentUser,
                                columnName: "password"
                            ) ?? ""
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ForgotPasswordView3(enteredEmail: "")
}
