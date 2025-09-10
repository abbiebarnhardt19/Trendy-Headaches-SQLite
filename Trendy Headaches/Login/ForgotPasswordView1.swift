//
//  ForgotPasswordView3.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/28/25.
//
import SwiftUI

struct ForgotPasswordView1: View {
    //editable variables
    @State private var email: String = ""
    @State private var emailExists: Bool? = nil
    @State private var emailCheckTask: Task<Void, Never>? = nil
    
    
    //theme colors
    let accent = "#b5c4b9"
    let background = "#001d00"
    
    var body: some View {
        NavigationStack {
            ZStack {
                //set background color
                Color(hex: background).ignoresSafeArea()
                
                //symetrical corner blobs
                SameAmplitudeBlob(waves: 10, amplitude: 20, accent:accent, x:140, y: -200, rotation: 110)
                SameAmplitudeBlob(waves: 10, amplitude:20, accent:accent, x:280, y: -120, rotation: 290)

                VStack {
                    //header + instructions
                    CustomWelcome(text:"Forgot your password?", color:accent, textAlignment: .center, width: 300)
                    CustomInstructions(text:"No worries! Enter your email below to start the password reset process.", color: accent)
                    
                    //email text box, uses debouncing to check once user stopped typing if email exists
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
                    
                    //if the email does not exist, diplay error
                    if let exists = emailExists, !exists {
                        CustomWarningText(text: "No account found with this email")
                    }
                    
                    //reserve room for error
                    else{
                        CustomWarningText(text: " ")
                    }
                    
                    //button to continue, disabled until email that exists in database is entered. Pass email to next page
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
