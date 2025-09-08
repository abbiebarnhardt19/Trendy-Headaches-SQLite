import SwiftUI
import SQLite

struct LoginView: SwiftUI.View {
    
    var background: String = "#001d00"
    var accent: String = "#b5c4b9"
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var loginError: String? = nil
    @State private var userId: Int64? = nil
    
    let leading_padding = CGFloat(20)
    
    var body: some SwiftUI.View {
        NavigationStack {
            ZStack {
                Color(hex: background).ignoresSafeArea()

                ParametricBlob(points: 20, amplitude: 0.3, x:-100, y:425, rotation:180, accent: accent)
                
                ParametricBlob(points: 20, amplitude: 0.3, x:-30, y:425, rotation:11, accent:accent)
                
                VStack{
                    CustomWelcome(text:"Log In", color: accent, alignment: .center, textAlignment: .center, width: 200)
                    
                    CustomText(text: "Email", color: accent)
                        .padding(.leading, leading_padding)
                    
                    TextField("", text: $email)
                        .textFieldStyle(CustomTextField(background: background, accent: accent))
                    
                    CustomText(text: "Password", color: accent)
                        .padding(.leading, leading_padding)
                    
                    SecureField("", text: $password)
                        .textFieldStyle(CustomTextField(background: background, accent: accent))
                    
                    CustomLink(destination: ForgotPasswordView1(), text: "Forgot Password", accent: accent)
                        .padding(.leading, 170)
                    
                    CustomButton(text: "Log In", background: background, accent: accent) {
                        let result = DatabaseManager.shared.attemptLogin(email: email, password: password)
                        userId = result.userId
                        loginError = result.error
                        isLoggedIn = userId != nil
                    }
                    
                    if let loginError = loginError {
                        CustomWarningText(text: loginError)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    else{
                        CustomWarningText(text: " ")
                    }
                }
                
                .onAppear {
                    _ = DatabaseManager.shared
                }
                .navigationDestination(isPresented: $isLoggedIn) {
                    if let userId = userId {
                        let normalizedEmail = DatabaseManager.normalizedValue(email)
                        let (backgroundColor, accentColor) = DatabaseManager.getColors(email: normalizedEmail)
                        NavBarView(userID: userId, backgroundColor: backgroundColor, accentColor: accentColor)
                    } else {
                        // Fallback view if something goes wrong
                        Text("Error: Could not retrieve user ID")
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
