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
                //header text
                CustomWelcome(text: "Welcome Back!")

                //start of form
                CustomText(text: "Email")
                SwiftUI.TextField("", text: $email)
                    .textFieldStyle(CustomTextField())
                
                CustomText(text: "Password")
                SecureField("", text: $password)
                    .textFieldStyle(CustomTextField())
                
                // Error message
                if let loginError = loginError {
                    CustomWarningText(text: loginError)
                }
                
                // Log In Button, calls function that will check if username and password are right
                CustomButton(text: "Log In") {
                    login()
                }
            }
            .CustomView()
            .onAppear {
                // Ensure database is initialized
                _ = DatabaseManager.shared
            }
            
            // if the login info is valid, go to the next page
            .navigationDestination(isPresented: $isLoggedIn) {
                if let userId = userId {
                    TempView(userId: userId)
                }
            }
        }
    }
    
    // login function
    private func login() {
        do {
            if let id = try DatabaseManager.shared.loginUser(
                emailAddress: email,
                passwordInput: password
            ) {
                userId = id
                isLoggedIn = true
                loginError = nil
            } else {
                loginError = "Invalid email or password."
                isLoggedIn = false
            }
        } catch {
            loginError = "Database error: \(error.localizedDescription)"
        }
    }
}
