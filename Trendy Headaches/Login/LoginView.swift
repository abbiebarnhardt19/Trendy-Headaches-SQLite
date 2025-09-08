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
                Color(hex: background).ignoresSafeArea()

                ParametricBlob(points: 20, amplitude: 0.3)
                    .fill(Color(hex: accent))
                    .frame(width: 400, height: 300)
                    .offset(x:-100, y: 425)
                    .rotationEffect(.degrees(180))
                
                ParametricBlob(points: 20, amplitude: 0.3)
                    .fill(Color(hex: accent))
                    .frame(width: 400, height: 300)
                    .offset(x:-30, y:425)
                    .rotationEffect(.degrees(11))
                
                VStack() {
                    CustomWelcome(text:"Log In", color: accent)
                    
                    CustomText(text: "Email", color: accent)
                        .padding(.leading, 20)
                    
                    TextField("", text: $email)
                        .textFieldStyle(CustomTextField(background: background, accent: accent))
                    
                    CustomText(text: "Password", color: accent)
                        .padding(.leading, 20)
                        .padding(.top, 15)
                    
                    SecureField("", text: $password)
                        .textFieldStyle(CustomTextField(background: background, accent: accent))
                      
                    
                    CustomLink(destination: ForgotPasswordView1(), text: "Forgot Password", accent: accent)
                        .padding(.leading, 170)
                    
                    CustomButton(text: "Log In", background: background, accent: accent, height: 55, width: 180) {
                        let result = DatabaseManager.shared.attemptLogin(email: email, password: password)
                        userId = result.userId
                        loginError = result.error
                        isLoggedIn = userId != nil
                    }
                    .padding(.top, 7)
                    
                    if let loginError = loginError {
                        Text(loginError)
                            .foregroundColor(.red)
                            .font(.system(size: 14, design: .serif))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 10)
                    }
                    else{
                        Text("                     ")
                            .foregroundColor(.red)
                            .font(.system(size: 14, design: .serif))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 10)
                            .padding(.horizontal, 15)
                        
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
