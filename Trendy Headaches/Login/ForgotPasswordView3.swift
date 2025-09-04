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
        DatabaseManager.isPasswordResetValid(
            newPassword: password_one,
            confirmPassword: password_two,
            currentHashedPassword: currentPassword
        )
    }
    
//    private func loadCurrentPassword() {
//        let result = DatabaseManager.getCurrentPassword(forEmail: enteredEmail)
//        currentPassword = result.currentPassword
//    }
//    
//    private func resetPassword() {
//        do {
//            try DatabaseManager.updatePassword(forEmail: enteredEmail, newPassword: password_one)
//            isPasswordUpdated = true
//        } catch {
//            print("Error updating password: \(error.localizedDescription)")
//        }
//    }

    var body: some View {
        NavigationStack {
            VStack {
                CustomText(text: "New Password", color: "#b5c4b9")
                SecureField("", text: $password_one)
                    .textFieldStyle(CustomTextField(background: "#001d00", accent: "#b5c4b9", height: 60, width: 160))
                    .padding(.bottom, 15)
                
                if !DatabaseManager.isPasswordValid(password_one) && !password_one.isEmpty {
                    CustomWarningText(text: "Password must be at least 8 characters, contain uppercase, lowercase, number, and special character.")
                }
                
                if !password_one.isEmpty && DatabaseManager.hashString(password_one) == currentPassword {
                    CustomWarningText(text: "New password must be different from previous password.")
                }
                
                CustomText(text: "Confirm New Password", color: "#b5c4b9")
                SecureField("", text: $password_two)
                    .textFieldStyle(CustomTextField(background: "#001d00", accent: "#b5c4b9", height: 60, width: 160))
                
                if !password_two.isEmpty && password_two != password_one {
                    CustomWarningText(text: "Passwords do not match.")
                }
                
                CustomButton(text: "Reset Password", background: "#b5c4b9", accent: "#001d00") {
                    isPasswordUpdated = DatabaseManager.resetPassword(enteredEmail: enteredEmail, password_one: password_one)
                }
                .padding(.top, 15)
                .disabled(!passwordResetValid)
                .opacity(passwordResetValid ? 1.0 : 0.5)
                
                // Invisible NavigationLink that triggers when update is successful
                .navigationDestination(isPresented: $isPasswordUpdated) {
                    LoginView()
                }
            }
            .CustomView(color: "#001d00")
            .onAppear {
                currentPassword = DatabaseManager.loadCurrentPassword(enteredEmail: enteredEmail)
            }
        }
        .CustomView(color: "#001d00")
    }
}

#Preview {
    ForgotPasswordView3(enteredEmail: "")
}
