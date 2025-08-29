//
//  InitialView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/24/25.
//

import SwiftUI

struct InitialView: View {
    var body: some View {
        NavigationStack{
            VStack{
                //go to the page where you sign in or sign up
                //this page will get more styling later
                CustomNavButton(label: "Sign In", destination: LoginView())
                CustomNavButton(label: "Sign Up", destination: CreateAccountView())
            }
            .CustomView()
            //access the database
            .onAppear{
                _ = DatabaseManager.shared
            }
        }
        .CustomView()
    }
}

#Preview {
    InitialView()
}
