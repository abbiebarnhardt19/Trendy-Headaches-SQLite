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
            ZStack {
                
                ParametricBlob(points: 20, amplitude: 0.3)
                    .fill(Color(hex: accent))
                    .frame(width: 400, height: 300)
                    .offset(x:-100, y: 400)
                    .rotationEffect(.degrees(180))
                
                ParametricBlob(points: 20, amplitude: 0.3)
                    .fill(Color(hex: accent))
                    .frame(width: 400, height: 300)
                    .offset(x:-30, y: 400)
                    .rotationEffect(.degrees(11))
                
                VStack() {
                    Text("Log In")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 50, weight: .bold, design: .serif))
                        .foregroundColor(Color(hex: accent))
                        .padding(.bottom, 20)
                    
                    CustomText(text: "Email", color: accent)
                        .padding(.leading, 160)
                    TextField("", text: $email)
                        .textFieldStyle(CustomTextField(background: background, accent: accent, height: 60, width: 350))
                    
                    CustomText(text: "Password", color: accent)
                        .padding(.leading, 160)
                        .padding(.top, 15)
                    SecureField("", text: $password)
                        .textFieldStyle(CustomTextField(background: background, accent: accent, height: 60, width: 350))
                        
                    NavigationLink(destination: ForgotPasswordView1()) {
                        Text("Forgot Password?")
                            .font(.system(size: 18, design: .serif))
                            .foregroundColor(Color(hex: accent))
                            .underline(true, color: Color(hex: accent))
                            .background(Color.clear) // forces label background transparent
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.leading, 170)
                    .padding(.vertical, 15)
                    
                    CustomButton(text: "Log In", background: background, accent: accent, height: 55, width: 180) {
                        let result = DatabaseManager.shared.attemptLogin(email: email, password: password)
                        userId = result.userId
                        loginError = result.error
                        isLoggedIn = userId != nil
                    }
                    .padding(.top, 7)
                    
                    if let loginError = loginError {
                        CustomWarningText(text: loginError)
                            .padding(.leading, 260)
                            .padding(.top, 15)
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
        .CustomView(color: background)
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
