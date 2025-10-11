//
//  ForgotPasswordView3.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/28/25.
//
import SwiftUI

struct ForgotPasswordView1: View {
    // Editable fields
    @State private var email: String = ""
    @State private var emailExists: Bool? = nil
    @State private var emailCheckTask: Task<Void, Never>? = nil
    
    // Theme colors and layout
    private let accent = "#b5c4b9"
    private let background = "#001d00"
    private let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationStack {
            ZStack {
                Forgot1BGComps(background: background, accent: accent)
                
                VStack(spacing: 20) {
                    // Header and instructions
                    CustomText(text: "Forgot your password?", color: accent, width: screenWidth - 50, textAlignment: .center, multilineAlignment: .center,  textSize: 50)
                    
                    CustomText( text: "No worries! Enter your email below to start the password reset process.",  color: accent, width: screenWidth - 50,  textAlignment: .center, multilineAlignment: .center, textSize: 18)
                    
                    // Email input with debounced availability check
                    CustomTextField(background: background, accent: accent, placeholder: "", text: $email)
                        .keyboardType(.emailAddress)
                        .onChange(of: email) {
                            emailCheckTask?.cancel()
                            emailCheckTask = Task {
                                try? await Task.sleep(nanoseconds: 500_000_000)
                                if !Task.isCancelled {
                                    emailExists = Database.doesEmailExist(email)
                                }
                            }
                        }
                    
                    // Warning message
                    if let exists = emailExists, !exists {
                        CustomWarningText(text: "No account found with this email")
                    } else {
                        CustomWarningText(text: " ")
                    }
                    
                    // Continue button
                    CustomNavButton( label: "Continue", destination: ForgotPasswordView2(enteredEmail: Database.normalizedValue(email)), background: background, accent: accent,  width: screenWidth / 2 - 20)
                    .disabled(!(emailExists ?? false))
                    .opacity((emailExists ?? false) ? 1.0 : 0.5)
                }
                .padding()
            }
        }
    }
}

#Preview {
    ForgotPasswordView1()
}
