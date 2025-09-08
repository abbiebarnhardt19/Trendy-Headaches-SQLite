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
                
                VStack{
                    ParametricBlob(points:25, amplitude: 0.15)
                        .fill(Color(hex: accent))
                        .frame(width: 400, height: 300)
                        .offset(x: -0, y: 550)
                        .rotationEffect(.degrees(335))
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                    
                    ParametricBlob(points: 25, amplitude: 0.15)
                        .fill(Color(hex: accent))
                        .frame(width: 500, height: 300)
                        .offset(x: 30, y: 550)
                        .rotationEffect(.degrees(160))
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                    
                }
                
                
                VStack(alignment: .trailing, spacing: 30) {
                    // Title pinned top-left
                    Text("Last Step")
                        .font(.system(size: 50, design: .serif))
                        .foregroundColor(Color(hex: accent))
                        .frame(width: 100, alignment: .trailing)
                        .padding(.trailing, 80)
                        .padding(.top, 70)
                    
                    
                    // Question + input + button
                    GeometryReader { geo in
                        VStack() {
                            CustomText(text: "New Password", color: accent)
                                .padding(.leading, 60)
                                .padding(.top, 40)
                            
                            SecureField("", text: $password_one)
                                .textFieldStyle(CustomTextField(background: background, accent: accent, height: 60, width: 350))
                            
                            
                            if !DatabaseManager.isPasswordValid(password_one) && !password_one.isEmpty {
                                CustomWarningText(text: "Password must be 8+ characters, including an uppercase, lowercase, number, and symbol.")
                                    .padding(.leading, 20)
                                    .padding(.bottom, 5)
                            }
                            
                            else if !password_one.isEmpty && DatabaseManager.hashString(password_one) == currentPassword {
                                CustomWarningText(text: "New password must be different from previous password.")
                                    .padding(.leading, 20)
                                    .padding(.bottom, 10)
                            }
                            else{
                                CustomWarningText(text: "                                                                                    ")
                                    .padding(.leading, 20)
                                    .padding(.bottom, 20)
                            }
                            
                            CustomText(text: "Confirm New Password", color: accent)
                                .padding(.leading, 60)
                            
                            SecureField("", text: $password_two)
                                .textFieldStyle(CustomTextField(background: background, accent: accent, height: 60, width: 350))
                            
                            if !password_two.isEmpty && password_two != password_one {
                                CustomWarningText(text: "Passwords do not match.")
                                    .padding(.leading, 20)
                            }
                            else{
                                CustomWarningText(text: " ")
                            }
                            
                            CustomButton(text: "Reset Password", background: background, accent: accent, height: 50, width: 200) {
                                isPasswordUpdated = DatabaseManager.resetPassword(enteredEmail: enteredEmail, password_one: password_one)
                            }
                            .padding(.top, 15)
                            .padding(.bottom, 150)
                            .disabled(!passwordResetValid)
                            .opacity(passwordResetValid ? 1.0 : 0.5)
                            
                            // Invisible NavigationLink that triggers when update is successful
                            .navigationDestination(isPresented: $isPasswordUpdated) {
                                LoginView()
                            }
                        }
                        .padding(.top, geo.safeAreaInsets.top - 44)
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
