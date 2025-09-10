//
//  ForgotPasswordView3.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/29/25.
//

import SwiftUI

struct ForgotPasswordView3: View {
    //email from before
    let enteredEmail: String
    
    //editable variables
    @State private var password_one: String = ""
    @State private var password_two: String = ""
    @State private var isPasswordUpdated: Bool = false
    @State private var currentPassword: String = ""
    
    //colors and padding
    let accent = "#b5c4b9"
    let background = "#001d00"
    let leading_padding = CGFloat(20)
    
    //check if the new password match, are complex enough, and are not the same as the old password
    private var passwordResetValid: Bool {
        password_one == password_two &&
        password_one != currentPassword &&
        DatabaseManager.isPasswordValid(password_one)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                //set background color
                Color(hex: background).ignoresSafeArea()
                
                //asymetric blobs
                ParametricBlob(points:25, amplitude: 0.15, x:-100, y:450, rotation:335, accent:accent)
                ParametricBlob(points: 25, amplitude: 0.15, x:25, y:450, rotation:160, accent:accent)
                
                VStack{
                    //header text
                    CustomWelcome(text:"Last Step", color: accent, textAlignment: .trailing,  width:100)
                        .padding(.leading, 170)
                        .padding(.bottom, 50)
                    
                    //password one label and text box
                    CustomText(text: "New Password", color: accent)
                        .padding(.leading, leading_padding)
                    
                    SecureField("", text: $password_one)
                        .textFieldStyle(CustomTextField(background: background, accent: accent))
                    
                    
                    //complexity warning
                    if !DatabaseManager.isPasswordValid(password_one) && !password_one.isEmpty {
                        CustomWarningText(text: "8+ chars: uppercase, lowercase, number, & symbol.")
                            .padding(.bottom, 5)
                    }
                    
                    //same as previous warning, check if the hashed entered value matches the hashed password in the database
                    else if !password_one.isEmpty && DatabaseManager.hashString(password_one) == currentPassword {
                        CustomWarningText(text: "New password must be different from previous password.")
                            .padding(.bottom, 5)
                    }
                    
                    //reserve warning space
                    else{
                        CustomWarningText(text: "")
                            .padding(.bottom, 15)
                    }
                    
                    //password two label and text box
                    CustomText(text: "Confirm New Password", color: accent)
                        .padding(.leading, leading_padding)
                    
                    SecureField("", text: $password_two)
                        .textFieldStyle(CustomTextField(background: background, accent: accent))
                    
                    
                    //passwords don't match warning
                    if !password_two.isEmpty && password_two != password_one {
                        CustomWarningText(text: "Passwords do not match.")
                            .padding(.bottom, 5)
                    }
                    
                    //reserve space for warning
                    else{
                        CustomWarningText(text: " ")
                            .padding(.bottom, 5)
                    }
                    
                    //reset password in database, disabled until new password is valid
                    CustomButton(text: "Reset Password", background: background, accent: accent, height: 50, width: 200) {
                        isPasswordUpdated = DatabaseManager.resetPassword(forEmail: enteredEmail, newPassword: password_one)
                    }
                    .padding(.bottom, 120)
                    .disabled(!passwordResetValid)
                    .opacity(passwordResetValid ? 1.0 : 0.5)
                    
                    //when the password is successfully updated, go to login
                    .navigationDestination(isPresented: $isPasswordUpdated) {
                        LoginView()
                    }
                }
                
            }
            //get the current hashed password from the email
            .onAppear {
                let currentUser = DatabaseManager.shared.getUserFromEmail(email: enteredEmail)
                currentPassword = DatabaseManager.shared.getSingleColumnValue(userId: currentUser ?? -1, columnName: "password") ?? ""
            }
        }
    }
}

#Preview {
    ForgotPasswordView3(enteredEmail: "")
}
