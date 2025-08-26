import SwiftUI

struct CreateAccountView: View {
    @State private var first_name: String = ""
    @State private var email: String = ""
    @State private var password_one: String = ""
    @State private var password_two: String = ""
    @State private var emailAvailable: Bool = true
    
    @State private var emailCheckTask: Task<Void, Never>? = nil  // for debounce
    
    // Check if all fields are filled in, passwords match & complex enough, email available
    private var formIsValid: Bool {
        !first_name.isEmpty &&
        !email.isEmpty &&
        !password_one.isEmpty &&
        !password_two.isEmpty &&
        (password_one == password_two) &&
        isPasswordValid(password_one) &&
        emailAvailable
    }
    
    // Password complexity check
    func isPasswordValid(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z\\d]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    // Check if email is already in database
    private func checkEmailAvailability() {
        do {
            emailAvailable = try !DatabaseManager.shared.emailExists(email)
        } catch {
            print("Database error: \(error.localizedDescription)")
            emailAvailable = false
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                CustomWelcome(text: "Welcome!")
                CustomInstructions(text: "Please fill in the following fields to begin creating your account.")

                // First Name
                CustomText(text: "First Name")
                TextField("Enter your first name", text: $first_name)
                    .textFieldStyle(CustomTextField())

                // Email with live debounced check
                CustomText(text: "Email")
                TextField("Enter your email", text: $email)
                    .textFieldStyle(CustomTextField())
                    .onChange(of: email) { _ in
                        // Cancel previous task if user types quickly
                        emailCheckTask?.cancel()
                        emailCheckTask = Task {
                            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                            if !Task.isCancelled {
                                checkEmailAvailability()
                            }
                        }
                    }

                // Warning if email already exists
                if !emailAvailable && !email.isEmpty {
                    CustomWarningText(text: "There is already an account associated with this email")
                }

                // Password
                CustomText(text: "Password")
                SecureField("Enter your password", text: $password_one)
                    .textFieldStyle(CustomTextField())

                if !isPasswordValid(password_one) && !password_one.isEmpty {
                    CustomSubtext(text: "Password must be at least 8 characters, contain uppercase, lowercase, number, and special character.")
                }

                // Confirm Password
                CustomText(text: "Confirm Password")
                SecureField("Re-enter your password", text: $password_two)
                    .textFieldStyle(CustomTextField())

                if !password_two.isEmpty && password_two != password_one {
                    CustomWarningText(text: "Passwords do not match.")
                }

                // Continue button
                CustomNavButton(
                    label: "Continue",
                    destination: CreateAccountView2(
                        firstName: first_name,
                        email: email,
                        passwordOne: password_one
                    )
                )
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
            }
            .CustomView()
        }
    }
}
