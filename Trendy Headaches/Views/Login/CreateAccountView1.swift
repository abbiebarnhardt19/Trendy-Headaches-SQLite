import SwiftUI

struct CreateAccountView: View {
    
    // Editable fields
    @State private var first_name: String = ""
    @State private var email: String = ""
    @State private var security_question: String = ""
    @State private var security_answer: String = ""
    @State private var password_one: String = ""
    @State private var password_two: String = ""
    @State private var emailAvailable: Bool = true
    @State private var emailCheckTask: Task<Void, Never>? = nil
    
    // Colors and layout
    private let accent = "#b5c4b9"
    private let background = "#001d00"
    private let leading_padding = CGFloat(30)
    
    // Computed property: form validation
    private var formIsValid: Bool {
        !email.isEmpty &&
        !password_one.isEmpty &&
        !password_two.isEmpty &&
        !security_question.isEmpty &&
        !security_answer.isEmpty &&
        password_one == password_two &&
        DatabaseManager.isPasswordValid(password_one) &&
        emailAvailable
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Create1BackgroundComponents(background: background, accent: accent)
                
                ScrollView {
                    ZStack {
                        VStack(spacing: 5) {
                            header
                            emailSection
                            passwordSection
                            confirmPasswordSection
                            securitySection
                            continueButton
                        }
                        .padding(.top, 10)
                    }
                }
            }
        }
    }
}

// MARK: - Subviews
private extension CreateAccountView {
    var header: some View {
        CustomText(text: "Create Account", color: accent, textAlignment: .center, textSize: 50)
            .padding(.bottom, 10)
    }
    
    var emailSection: some View {
        VStack(spacing: 5) {
            fieldLabel("Email")
            CustomTextField(background: background, accent: accent, placeholder: "", text: $email)
                .onChange(of: email) {
                    debounceEmailCheck()
                }
            
            if !emailAvailable && !email.isEmpty {
                CustomWarningText(text: "There is already an account using this email")
            } else {
                CustomWarningText(text: "") // spacing placeholder
                    .padding(.bottom, 11)
            }
        }
    }
    
    var passwordSection: some View {
        VStack(spacing: 5) {
            fieldLabel("Password")
            CustomTextField(background: background, accent: accent, placeholder: "", text: $password_one, isSecure: true)
            
            if !DatabaseManager.isPasswordValid(password_one) && !password_one.isEmpty {
                CustomWarningText(text: "8+ chars: uppercase, lowercase, number, & symbol")
            } else {
                CustomWarningText(text: "      ")
            }
        }
    }
    
    var confirmPasswordSection: some View {
        VStack(spacing: 5) {
            fieldLabel("Confirm Password")
            CustomTextField(background: background, accent: accent, placeholder: "", text: $password_two, isSecure: true)
            
            if !password_two.isEmpty && password_two != password_one {
                CustomWarningText(text: "Passwords do not match.")
            } else {
                CustomWarningText(text: "       ")
            }
        }
    }
    
    var securitySection: some View {
        VStack(spacing: 5) {
            fieldLabel("Security Question")
            CustomTextField(background: background, accent: accent, placeholder: "", text: $security_question)
            
            CustomWarningText(text: "       ") // for spacing
            
            fieldLabel("Security Question Answer")
            CustomTextField(background: background, accent: accent, placeholder: "", text: $security_answer)
        }
    }
    
    var continueButton: some View {
        CustomNavButton(
            label: "Continue",
            destination: CreateAccountView2(email: email, passwordOne: password_one,  securityQuestion: security_question,  securityAnswer: security_answer),  background: background, accent: accent, width: 150)
        .disabled(!formIsValid)
        .opacity(formIsValid ? 1 : 0.5)
        .padding(.bottom, 45)
    }
    
    func fieldLabel(_ text: String) -> some View {
        CustomText(text: text, color: accent)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, leading_padding)
    }
    
    func debounceEmailCheck() {
        emailCheckTask?.cancel()
        emailCheckTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 sec delay
            if !Task.isCancelled {
                emailAvailable = !DatabaseManager.doesEmailExist(email)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateAccountView()
    }
}
