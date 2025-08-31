import SwiftUI
import SQLite

struct LoginView: SwiftUI.View {
    
    // Optional parameters with defaults
    var background: String = "#001d00"
    var accent: String = "#b5c4b9"
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var loginError: String? = nil
    @State private var userId: Int64? = nil
    
    var body: some SwiftUI.View {
        NavigationStack {
            VStack(spacing: 20) {
                CustomWelcome(text: "Welcome Back!", color: accent)
                
                CustomText(text: "Email", color: accent)
                TextField("", text: $email)
                    .textFieldStyle(CustomTextField(background: background, accent: accent))
                
                CustomText(text: "Password", color: accent)
                SecureField("", text: $password)
                    .textFieldStyle(CustomTextField(background: background, accent: accent))
                
                if let loginError = loginError {
                    CustomWarningText(text: loginError)
                }
                
                CustomButton(text: "Log In", background: accent, accent: background) {
                    let result = DatabaseManager.shared.attemptLogin(email: email, password: password)
                    userId = result.userId
                    loginError = result.error
                    isLoggedIn = userId != nil
                }
                
                CustomNavButton(label: "Forgot Password", destination: ForgotPasswordView1(), background: background, accent: accent)
            }
            
            .onAppear {
                _ = DatabaseManager.shared
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                if let userId = userId {
                    TempView(currentUserId: userId)
                }
            }
        }
        .CustomView(color: background)
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
