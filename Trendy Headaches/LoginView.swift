//
//  LoginView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/24/25.
//

import SwiftUI


struct LoginView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationStack{
            VStack{
                Text("Welcome Back!")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(Color(hex: "#b5c4b9"))
                    .padding(.bottom, 50)
                
                CustomText(text:"Email")
                TextField("", text: $email).textFieldStyle(CustomTextField()).padding(.bottom, 20)
                
                CustomText(text:"Password")
                TextField("", text: $password).textFieldStyle(CustomTextField()).padding(.bottom, 30)
                
                //go to the temp page, this will turn into the log page
                CustomNavButton(label: "Log In", destination: TempView())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color(hex: "#001D00")
            }
        }
    }
}


#Preview {
    LoginView()
}
