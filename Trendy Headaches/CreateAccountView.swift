//
//  CreateAccountView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/24/25.
//

import SwiftUI

struct CreateAccountView: View {
    @State private var first_name: String = ""
    @State private var email: String = ""
    @State private var password_one: String = ""
    @State private var password_two: String = ""
    var body: some View {
        NavigationStack{
            
            VStack {
                Text("Welcome!")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(Color(hex: "#b5c4b9"))
                    .padding(.bottom, 20)
                    .padding(.top, 30)
                
                Text("Please fill in the following fields to begin creating your account.")
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#b5c4b9"))
                    .padding(.bottom, 20)
                
                
                //email label and text box with custom styling
                CustomText(text: "First Name")
                SwiftUI.TextField("Enter your first name", text: $first_name)
                    .textFieldStyle(CustomTextField())
                
                // password label and text box wit custom styling
                CustomText(text: "Email")
                TextField("Enter your email", text: $email)
                    .textFieldStyle(CustomTextField())
                
                CustomText(text: "Password")
                SecureField("Enter your password", text: $password_one)
                    .textFieldStyle(CustomTextField())
                
                Text("Passwords must be at least 8 characters and contain at least one uppercase letter, lowercase letter, number, and special character.")
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(Color(hex: "#b5c4b9"))
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 5)
                    .padding(.top, 5)
                    .font(.system(size: 15))
                
                CustomText(text: "Confirm Password")
                SecureField("Renter your password", text: $password_two)
                    .textFieldStyle(CustomTextField())
                    .padding(.bottom, 50)
                
                CustomNavButton(label: "Continue", destination: CreateAccountView2())
                //button to move to next page, confirm passwords match and email is not
                //already in database, and check password complexity
                //will need to pass info to next page before adding to database
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "#001D00"))
        }
    }
}



#Preview {
    CreateAccountView()
}
