import SwiftUI

struct CreateAccountView: View {
    @State private var first_name: String = ""
    @State private var email: String = ""
    @State private var security_question: String = ""
    @State private var security_answer: String = ""
    @State private var password_one: String = ""
    @State private var password_two: String = ""
    @State private var emailAvailable: Bool = true
    
    @State private var emailCheckTask: Task<Void, Never>? = nil  // for debounce
    
    private var formIsValid: Bool {
        !security_question.isEmpty &&
        !security_answer.isEmpty &&
        !email.isEmpty &&
        !password_one.isEmpty &&
        !password_two.isEmpty &&
        (password_one == password_two) &&
        DatabaseManager.isPasswordValid(password_one) &&
        emailAvailable
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 15) {
                    CustomWelcome(text: "Welcome!")
                    CustomInstructions(text: "Please fill in the following fields to begin creating your account.")
                    
                    CustomText(text: "Email")
                    TextField("", text: $email)
                        .textFieldStyle(CustomTextField())
                        .onChange(of: email) {
                            emailCheckTask?.cancel()
                            emailCheckTask = Task {
                                try? await Task.sleep(nanoseconds: 500_000_000)
                                if !Task.isCancelled {
                                    emailAvailable = !DatabaseManager.doesEmailExist(email)
                                }
                            }
                        }
                    
                    if !emailAvailable && !email.isEmpty {
                        CustomWarningText(text: "There is already an account associated with this email")
                    }
                    
                    CustomText(text: "Password")
                    SecureField("", text: $password_one)
                        .textFieldStyle(CustomTextField())
                    
                    if !DatabaseManager.isPasswordValid(password_one) && !password_one.isEmpty {
                        CustomWarningText(text: "Password must be at least 8 characters, contain uppercase, lowercase, number, and special character.")
                    }
                    
                    CustomText(text: "Confirm Password")
                    SecureField("", text: $password_two)
                        .textFieldStyle(CustomTextField())
                    
                    if !password_two.isEmpty && password_two != password_one {
                        CustomWarningText(text: "Passwords do not match.")
                    }
                    
                    CustomText(text: "Security Question")
                    TextField("", text: $security_question)
                        .textFieldStyle(CustomTextField())
                    
                    CustomText(text: "Security Question Answer")
                    TextField("", text: $security_answer)
                        .textFieldStyle(CustomTextField())
                    
                    CustomNavButton(
                        label: "Continue",
                        destination: CreateAccountView2(
                            email: email,
                            passwordOne: password_one,
                            currentSecurityQuestion: security_question,
                            currentSecurityAnswer: security_answer
                        )
                    )
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1.0 : 0.5)
                }
            }
            .CustomView()
        }
    }
}

#Preview {
    NavigationStack {
        CreateAccountView()
    }
}
