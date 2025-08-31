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
                CustomNavButton(label: "Sign In", destination: LoginView(), background: "#b5c4b9", accent: "#001d00")
                CustomNavButton(label: "Sign Up", destination: CreateAccountView(), background: "#b5c4b9", accent: "#001d00")
            }
            .CustomView(color: "#001d00")
            .onAppear{
                _ = DatabaseManager.shared
            }
        }
        .CustomView(color: "#001d00")
    }
}

#Preview {
    InitialView()
}
