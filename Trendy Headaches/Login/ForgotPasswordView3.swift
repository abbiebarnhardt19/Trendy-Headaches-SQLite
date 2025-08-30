//
//  ForgotPasswordView3.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/29/25.
//

import SwiftUI

struct ForgotPasswordView3: View {

    let enteredEmail: String
    
    @State private var password_one: String = ""
    @State private var password_two: String = ""
    @State private var isPasswordUpdated: Bool = false
    @State private var currentPassword: String = ""
    
    private var passwordResetValid: Bool {
        DatabaseManager.PasswordResetHelper.isPasswordResetValid(
            newPassword: password_one,
            confirmPassword: password_two,
            currentHashedPassword: currentPassword
        )
    }
    
    private func loadCurrentPassword() {
        let result = DatabaseManager.PasswordResetHelper.getCurrentPassword(forEmail: enteredEmail)
        currentPassword = result.currentPassword
    }
    
    private func resetPassword() {
        do {
            try DatabaseManager.PasswordResetHelper.updatePassword(forEmail: enteredEmail, newPassword: password_one)
            isPasswordUpdated = true
        } catch {
            print("Error updating password: \(error.localizedDescription)")
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                CustomText(text: "New Password")
                SecureField("", text: $password_one)
                    .textFieldStyle(CustomTextField())
                
                if !DatabaseManager.PasswordResetHelper.isPasswordValid(password_one) && !password_one.isEmpty {
                    CustomWarningText(text: "Password must be at least 8 characters, contain uppercase, lowercase, number, and special character.")
                }
                
                if !password_one.isEmpty && CryptoHelper.hashString(password_one) == currentPassword {
                    CustomWarningText(text: "New password must be different from previous password.")
                }
                
                CustomText(text: "Confirm New Password")
                SecureField("", text: $password_two)
                    .textFieldStyle(CustomTextField())
                
                if !password_two.isEmpty && password_two != password_one {
                    CustomWarningText(text: "Passwords do not match.")
                }
                
                CustomButton(text: "Reset Password") {
                    resetPassword()
                }
                .padding(.top, 15)
                .disabled(!passwordResetValid)
                .opacity(passwordResetValid ? 1.0 : 0.5)
                
                // Invisible NavigationLink that triggers when update is successful
                .navigationDestination(isPresented: $isPasswordUpdated) {
                    LoginView()
                }
            }
            .CustomView()
            .onAppear {
                loadCurrentPassword()
            }
        }
        .CustomView()
    }
}

#Preview {
    ForgotPasswordView3(enteredEmail: "")
}
