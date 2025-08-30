import SwiftUI
import SQLite

struct LoginView: SwiftUI.View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var loginError: String? = nil
    @State private var userId: Int64? = nil
    
    var body: some SwiftUI.View {
        NavigationStack {
            VStack(spacing: 20) {
                CustomWelcome(text: "Welcome Back!")
                
                CustomText(text: "Email")
                TextField("", text: $email)
                    .textFieldStyle(CustomTextField())
                
                CustomText(text: "Password")
                SecureField("", text: $password)
                    .textFieldStyle(CustomTextField())
                
                if let loginError = loginError {
                    CustomWarningText(text: loginError)
                }
                
                CustomButton(text: "Log In") {
                    let result = DatabaseManager.shared.attemptLogin(email: email, password: password)
                    userId = result.userId
                    loginError = result.error
                    isLoggedIn = userId != nil
                }
                
                CustomNavButton(label: "Forgot Password", destination: ForgotPasswordView1())
            }
            .CustomView()
            .onAppear {
                _ = DatabaseManager.shared
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                if let userId = userId {
                    TempView(currentUserId: userId)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
