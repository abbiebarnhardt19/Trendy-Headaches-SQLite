import SwiftUI
import SQLite

struct LoginView: SwiftUI.View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var loginError: String? = nil
    
    var body: some SwiftUI.View {
        NavigationStack {
            VStack(spacing: 20) {

                Text("Welcome Back!")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(Color(hex: "#b5c4b9"))
                    .padding(.bottom, 50)
                
                // Email
                CustomText(text: "Email")
                SwiftUI.TextField("Enter your email", text: $email)
                    .textFieldStyle(CustomTextField())
                
                // Password
                CustomText(text: "Password")
                SecureField("Enter your password", text: $password)
                    .textFieldStyle(CustomTextField())
                
                // Log In Button
                Button("Log In") {
                    login()
                }
                .padding()
                .background(Color(hex: "#b5c4b9"))
                .foregroundColor(Color(hex: "#001d00"))
                .cornerRadius(10)
                
                Button("Add User") {
                    do {
                        let newUserId = try DatabaseManager.shared.addUser(
                            firstName: "Abigail",
                            emailAddress: "Abbie@example.com",
                            phone: "1234567890",
                            birthDate: Date(),
                            passwordHash: "Hashed_password_here"
                        )
                        print("Added user with ID: \(newUserId)")
                    } catch {
                        print("Insert error: \(error)")
                    }
                }
                .padding()
                .background(Color(hex: "#b5c4b9"))
                .foregroundColor(Color(hex: "#001d00"))
                .cornerRadius(10)
                
                // Error message
                if let loginError = loginError {
                    Text(loginError)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
                
                // Programmatic navigation
                NavigationLink("", destination: TempView(), isActive: $isLoggedIn)
                    .hidden()
                
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "#001D00"))
            .onAppear {
                // Ensure database is initialized
                _ = DatabaseManager.shared
            }
        }
    }
    
    // MARK: - Login Function
    private func login() {
        do {
            let success = try DatabaseManager.shared.loginUser(
                emailAddress: email,
                passwordInput: password
            )
            
            if success {
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
