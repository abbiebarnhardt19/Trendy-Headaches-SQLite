//
//  ForgotPasswordView3.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/28/25.
//
import SwiftUI

struct ForgotPasswordView1: View {
    @State private var email: String = ""
    @State private var emailExists: Bool? = nil
    @State private var emailCheckTask: Task<Void, Never>? = nil
    
    let accent = "#b5c4b9"
    let background = "#001d00"
    
    var body: some View {
        NavigationStack {
            ZStack {
                ParametricBlob(points: 20, amplitude: 0.3)
                    .fill(Color(hex: accent))
                    .frame(width: 400, height: 300)
                    .offset(x:-100, y: 400)
                    .rotationEffect(.degrees(180))
                
                ParametricBlob(points: 20, amplitude: 0.3)
                    .fill(Color(hex: accent))
                    .frame(width: 400, height: 300)
                    .offset(x:-30, y: 400)
                    .rotationEffect(.degrees(11))

                
                VStack() {
                    Text("Forgot your password?")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 50, design: .serif))
                        .foregroundColor(Color(hex: accent))
                        .padding(.bottom, 20)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 300)
                    
                    Text("No worries! Enter your email below to start the password reset process.")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 20, design: .serif))
                        .foregroundColor(Color(hex: accent))
                        .padding(.bottom, 20)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 350)
                    
                    TextField("", text: $email)
                        .textFieldStyle(CustomTextField(background: background, accent: accent, height: 60, width: 350))
                        .keyboardType(.emailAddress)
                        .onChange(of: email) {
                            emailCheckTask?.cancel()
                            emailCheckTask = Task {
                                try? await Task.sleep(nanoseconds: 500_000_000)
                                if !Task.isCancelled {
                                    // call the fully qualified static helper
                                    emailExists = DatabaseManager.doesEmailExist(email)
                                }
                            }
                        }
                    
                    if let exists = emailExists, !exists {
                        CustomWarningText(text: "No account found with this email")
                            .padding(.leading, 220)
                    }
                    
                    CustomNavButton(
                        label: "Continue",
                        destination: ForgotPasswordView2(enteredEmail: DatabaseManager.normalizedValue(email)), background: background, accent: accent, height: 45, width: 160)
                    .disabled(!(emailExists ?? false))
                    .opacity((emailExists ?? false) ? 1.0 : 0.5)
                    .padding(.top, 10)
                }
           }
            .CustomView(color: background)
        }
    }
}

#Preview {
    ForgotPasswordView1()
}
