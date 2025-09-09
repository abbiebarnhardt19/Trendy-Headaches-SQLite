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
    
    let accent = "#b5c4b9"
    let background = "#001d00"
    
    let leading_padding = CGFloat(20)
    
    private var passwordResetValid: Bool {
        DatabaseManager.isPasswordResetValid(
            newPassword: password_one,
            confirmPassword: password_two,
            currentHashedPassword: currentPassword
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: background).ignoresSafeArea()
                
                ParametricBlob(points:25, amplitude: 0.15, x:-100, y:450, rotation:335, accent:accent)
                
                ParametricBlob(points: 25, amplitude: 0.15, x:25, y:450, rotation:160, accent:accent)
                
                VStack{
                    CustomWelcome(text:"Last Step", color: accent, alignment: .trailing, textAlignment: .trailing,  width:100)
                        .padding(.leading, 210)
                        .padding(.bottom, 50)
                    
                    CustomText(text: "New Password", color: accent)
                        .padding(.leading, leading_padding)
                    
                    SecureField("", text: $password_one)
                        .textFieldStyle(CustomTextField(background: background, accent: accent))
                    
                    if !DatabaseManager.isPasswordValid(password_one) && !password_one.isEmpty {
                        CustomWarningText(text: "Password must be 8+ characters, including an uppercase, lowercase, number, and symbol.")
                            .padding(.bottom, 5)
                    }
                    
                    else if !password_one.isEmpty && DatabaseManager.hashString(password_one) == currentPassword {
                        CustomWarningText(text: "New password must be different from previous password.")
                            .padding(.bottom, 5)
                    }
                    else{
                        CustomWarningText(text: "")
                            .padding(.bottom, 30)
                    }
                    
                    CustomText(text: "Confirm New Password", color: accent)
                        .padding(.leading, leading_padding)
                    
                    SecureField("", text: $password_two)
                        .textFieldStyle(CustomTextField(background: background, accent: accent))
                    
                    if !password_two.isEmpty && password_two != password_one {
                        CustomWarningText(text: "Passwords do not match.")
                            .padding(.bottom, 5)
                    }
                    else{
                        CustomWarningText(text: " ")
                            .padding(.bottom, 5)
                    }
                    
                    CustomButton(text: "Reset Password", background: background, accent: accent, height: 50, width: 200) {
                        isPasswordUpdated = DatabaseManager.resetPassword(enteredEmail: enteredEmail, password_one: password_one)
                    }
                    .padding(.bottom, 140)
                    .disabled(!passwordResetValid)
                    .opacity(passwordResetValid ? 1.0 : 0.5)
                    
                    .navigationDestination(isPresented: $isPasswordUpdated) {
                        LoginView()
                    }
                }
                
            }
            .onAppear {
                currentPassword = DatabaseManager.loadCurrentPassword(enteredEmail: enteredEmail)}
        }
    }
}

#Preview {
    ForgotPasswordView3(enteredEmail: "")
}
