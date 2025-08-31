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
                CustomWelcome(text: "Welcome Back!", color: "#b5c4b9")
                
                CustomText(text: "Email", color: "#b5c4b9")
                TextField("", text: $email)
                    .textFieldStyle(CustomTextField(background: "#001d00", accent: "#b5c4b9"))
                
                CustomText(text: "Password", color: "#b5c4b9")
                SecureField("", text: $password)
                    .textFieldStyle(CustomTextField(background: "#001d00", accent: "#b5c4b9"))
                
                if let loginError = loginError {
                    CustomWarningText(text: loginError)
                }
                
                CustomButton(text: "Log In", background: "#b5c4b9", accent: "#001d00") {
                    let result = DatabaseManager.shared.attemptLogin(email: email, password: password)
                    userId = result.userId
                    loginError = result.error
                    isLoggedIn = userId != nil
                }
                
                CustomNavButton(label: "Forgot Password", destination: ForgotPasswordView1(), background: "#001d00", accent: "#b5c4b9")
            }
            .CustomView(color: "#001d00")
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
