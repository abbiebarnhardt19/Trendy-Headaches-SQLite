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
                CustomInstructions(text: "Please enter the email address of the account you wish to reset the password of.", color: "#b5c4b9")
                
                CustomText(text: "Email", color: "#b5c4b9")
                TextField("", text: $email)
                    .textFieldStyle(CustomTextField(background: "#001d00", accent: "#b5c4b9", height: 60, width: 160))
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
                    destination: ForgotPasswordView2(enteredEmail: DatabaseManager.normalizedValue(email)), background: "#001d00", accent: "#b5c4b9"
                )
                .disabled(!(emailExists ?? false))
                .opacity((emailExists ?? false) ? 1.0 : 0.5)
            }
            .padding()
            .CustomView(color: "#001d00")
        }
    }
}

#Preview {
    ForgotPasswordView1()
}
