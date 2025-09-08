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
                Color(hex: background).ignoresSafeArea()
                
                SameAmplitudeBlob(waves: 10, amplitude: 20, accent:accent, x:140, y: -200, rotation: 110)

                SameAmplitudeBlob(waves: 10, amplitude:20, accent:accent, x:280, y: -120, rotation: 290)

                VStack {
                    CustomWelcome(text:"Forgot your password?", color:accent, alignment: .center, textAlignment: .center, width: 300)
                    
                    CustomInstructions(text:"No worries! Enter your email below to start the password reset process.", color: accent)
                    
                    TextField("", text: $email)
                        .textFieldStyle(CustomTextField(background: background, accent: accent))
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
                    }
                    
                    else{
                        CustomWarningText(text: " ")
                    }
                    
                    CustomNavButton(
                        label: "Continue",
                        destination: ForgotPasswordView2(enteredEmail: DatabaseManager.normalizedValue(email)), background: background, accent: accent, width: 160)
                    .disabled(!(emailExists ?? false))
                    .opacity((emailExists ?? false) ? 1.0 : 0.5)
                }
           }
        }
    }
}

#Preview {
    ForgotPasswordView1()
}
