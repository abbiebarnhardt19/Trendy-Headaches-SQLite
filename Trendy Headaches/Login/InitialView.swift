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
                CustomNavButton(label: "Sign In", destination: LoginView())
                CustomNavButton(label: "Sign Up", destination: CreateAccountView())
            }
            .CustomView()
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
