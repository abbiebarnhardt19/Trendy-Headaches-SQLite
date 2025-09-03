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
                    CustomWelcome(text: "Welcome!", color: "#b5c4b9")
                    CustomInstructions(text: "Please fill in the following fields to begin creating your account.", color: "#b5c4b9")
                    
                    CustomText(text: "Email", color: "#b5c4b9")
                    TextField("", text: $email)
                        .textFieldStyle(CustomTextField(background: "#001d00", accent: "#b5c4b9", height: 60, width: 160))
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
                    
                    CustomText(text: "Password", color: "#b5c4b9")
                    SecureField("", text: $password_one)
                        .textFieldStyle(CustomTextField(background: "#001d00", accent: "#b5c4b9", height: 60, width: 160))
                    
                    if !DatabaseManager.isPasswordValid(password_one) && !password_one.isEmpty {
                        CustomWarningText(text: "Password must be at least 8 characters, contain uppercase, lowercase, number, and special character.")
                    }
                    
                    CustomText(text: "Confirm Password", color: "#b5c4b9")
                    SecureField("", text: $password_two)
                        .textFieldStyle(CustomTextField(background: "#001d00", accent: "#b5c4b9", height: 60, width: 160))
                    
                    if !password_two.isEmpty && password_two != password_one {
                        CustomWarningText(text: "Passwords do not match.")
                    }
                    
                    CustomText(text: "Security Question", color: "#b5c4b9")
                    TextField("", text: $security_question)
                        .textFieldStyle(CustomTextField(background: "#001d00", accent: "#b5c4b9", height: 60, width: 160))
                    
                    CustomText(text: "Security Question Answer", color: "#b5c4b9")
                    TextField("", text: $security_answer)
                        .textFieldStyle(CustomTextField(background: "#001d00", accent: "#b5c4b9", height: 60, width: 160))
                    
                    CustomNavButton(
                        label: "Continue",
                        destination: CreateAccountView3(
                            email: email,
                            password_one: password_one,
                            security_question: security_question,
                            security_answer: security_answer
                        ), background: "#001d00", accent: "#b5c4b9"
                    )
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1.0 : 0.5)
                }
            }
        }
        .CustomView(color: "#001d00")
    }
}

#Preview {
    NavigationStack {
        CreateAccountView()
    }
}
