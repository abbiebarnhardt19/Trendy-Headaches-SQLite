//
//  ForogtPasswordView2.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/29/25.
//

import SwiftUI

struct ForgotPasswordView2: View {
    @State private var email: String = ""
    var body: some View {
        NavigationStack {
            VStack {
                CustomInstructions(text: "Please enter the email address of the account you wish to reset the password of.")
                CustomText(text: "Email")
                SecureField("", text: $email)
                    .textFieldStyle(CustomTextField())
                CustomNavButton(label: "Sign In", destination: LoginView())
            }
            .padding()
            .CustomView()
        }
    }
}

#Preview {
    ForgotPasswordView2()
}
