import SwiftUI
import SQLite

struct LoginView: SwiftUI.View {
    //  Theme
    var background: String = "#001d00"
    var accent: String = "#b5c4b9"
    
    //  State
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn = false
    @State private var loginError: String? = nil
    @State private var userId: Int64? = nil
    
    //  Layout
    private let leadingPadding: CGFloat = 25
    
    var body: some SwiftUI.View {
        NavigationStack {
            ZStack {
                LoginBackgroundComponents(background: background, accent: accent)
                //  Content
                VStack(spacing: 15) {
                    CustomText(text: "Log In",  color: accent, width: 200, textAlignment: .center,  textSize: 50 )
                    .padding(.bottom, 20)
                    
                    // Email
                    CustomText(text: "Email", color: accent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, leadingPadding)
                    
                    CustomTextField(background: background, accent: accent, placeholder: "", text: $email)
                    
                    // Password
                    CustomText(text: "Password", color: accent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, leadingPadding)
                    
                    CustomTextField(background: background, accent: accent, placeholder: "", text: $password, isSecure: true)
                    
                    // Forgot Password Link
                    CustomLink(destination: ForgotPasswordView1(), text: "Forgot Password?", accent: accent)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, leadingPadding)
                        .padding(.top, 5)
                    
                    // Login Button
                    CustomButton(text: "Log In", background: background, accent: accent) {
                        let result = DatabaseManager.shared.attemptLogin(email: email, password: password)
                        userId = result.userId
                        loginError = result.error
                        isLoggedIn = userId != nil
                    }
                    .padding(.top, 10)
                    
                    // Error Message
                    if let loginError = loginError {
                        CustomWarningText(text: loginError)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        CustomWarningText(text: " ") // Reserve space
                    }
                }
                .padding(.horizontal)
                .onAppear { _ = DatabaseManager.shared }
                
                //  Navigation
                .navigationDestination(isPresented: $isLoggedIn) {
                    if let userId = userId {
                        LogView(userID: userId, background: .constant(background),  accent: .constant(accent) )
                        .navigationBarBackButtonHidden(true)
                    } else {
                        Text("Oops! Something went wrong. Please try again later.")
                            .foregroundColor(.red)
                    }
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
