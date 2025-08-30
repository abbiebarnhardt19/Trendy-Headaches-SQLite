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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                CustomInstructions(text: "Please enter the email address of the account you wish to reset the password of.")
                
                CustomText(text: "Email")
                TextField("", text: $email)
                    .textFieldStyle(CustomTextField())
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
                    Text("No account found with this email")
                        .foregroundColor(.red)
                }
                
                CustomNavButton(
                    label: "Continue",
                    destination: ForgotPasswordView2(enteredEmail: DatabaseManager.shared.normalizedValue(email))
                )
                .disabled(!(emailExists ?? false))
                .opacity((emailExists ?? false) ? 1.0 : 0.5)
            }
            .padding()
            .CustomView()
        }
    }
}

#Preview {
    ForgotPasswordView1()
}
