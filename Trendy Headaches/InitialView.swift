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
                //go to the temp page, this will turn into the log page
                CustomNavButton(label: "Sign In", destination: LoginView())
                CustomNavButton(label: "Sign Up", destination: CreateAccountView())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color(hex: "#001D00")
            }
        }
    }
}

#Preview {
    InitialView()
}
