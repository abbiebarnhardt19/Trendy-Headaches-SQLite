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
                Text("Welcome Back!")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(Color(hex: "#b5c4b9"))
                    .padding(.bottom, 50)
                
                //email label and text box with custom styling
                CustomText(text: "Email")
                SwiftUI.TextField("Enter your email", text: $email)
                    .textFieldStyle(CustomTextField())
                
                // password label and text box wit custom styling
                CustomText(text: "Password")
                SecureField("Enter your password", text: $password)
                    .textFieldStyle(CustomTextField())
                
                // Log In Button, calls function that will check if username and password are right
                Button("Log In") {
                    login()
                }
                .padding()
                .background(Color(hex: "#b5c4b9"))
                .foregroundColor(Color(hex: "#001d00"))
                .cornerRadius(10)
                
                //button to add user to database, for testing only
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
                
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "#001D00"))
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
