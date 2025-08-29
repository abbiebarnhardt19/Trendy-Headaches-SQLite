import SwiftUI

struct ForgotPasswordView1: View {
    @State private var email: String = ""
    @State private var emailExists: Bool? = nil
    @State private var emailCheckTask: Task<Void, Never>? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                CustomInstructions(text: "Please enter the email address of the account you wish to reset the password of.")
                
                CustomText(text: "Email")
                TextField("", text: $email)
                    .textFieldStyle(CustomTextField())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .onChange(of: email) {
                        emailCheckTask?.cancel()
                        emailCheckTask = Task {
                            try? await Task.sleep(nanoseconds: 500_000_000)
                            if !Task.isCancelled {
                                checkEmailAvailability()
                            }
                        }
                    }
                
                if let exists = emailExists {
                    if !exists {
                        Text("No account found with this email")
                            .foregroundColor(.red)
                    }
                }
                
                CustomNavButton(label: "Continue", destination: ForgotPasswordView2())
                    .disabled(!(emailExists ?? false)) // disable if nil or false
                    .opacity((emailExists ?? false) ? 1.0 : 0.5)
            }
            .padding()
            .CustomView()
        }
    }
    

    
    private func checkEmailAvailability() {
        do {
            // emailExists returns true if account exists
            let cleaned = DatabaseManager.shared.normalizedEmail(email)
            emailExists = try DatabaseManager.shared.emailExists(cleaned)
        } catch {
            print("Database error: \(error.localizedDescription)")
            emailExists = nil
        }
    }
}

#Preview {
    ForgotPasswordView1()
}
