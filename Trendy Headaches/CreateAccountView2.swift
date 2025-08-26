//
//  CreateAccountView2.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/25/25.
//

import SwiftUI

struct CreateAccountView2: View {
    var firstName: String = ""
    var email: String = ""
    var passwordOne: String = ""
    
    var body: some View {
        VStack {
            Text("First Name: \(firstName)")
            Text("Email: \(email)")
            Text("Password: \(passwordOne)")
        }
    }
}

#Preview {
    CreateAccountView2()
}
