import SwiftUI

struct CreateAccountView2: View {
    var email: String = ""
    var passwordOne: String = ""
    var currentSecurityQuestion: String = ""
    var currentSecurityAnswer: String = ""
    
    
    @State private var symptoms: String = ""
    @State private var preventativeMeds: String = ""
    @State private var emergencyMeds: String = ""
    @State private var triggers: String = ""
    @State private var errorMessage: String = ""
    @State private var accountCreated = false  // <-- New state
    
    var body: some View {
        NavigationStack {
            VStack {
               Text("Continue Creating Your Account")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(Color(hex: "#b5c4b9"))
                    .padding(.bottom, 20)

                
                CustomInstructions(text: "These fields are optional. If you’d like to add more than one item, please separate them with a comma. We’ll only use this info to help filter your data logs to give you better insights.")
                
                CustomText(text: "Symptom or Illness")
                TextField("", text: $symptoms)
                    .textFieldStyle(CustomTextField())
                
                CustomText(text: "Preventative Medications")
                TextField("", text: $preventativeMeds)
                    .textFieldStyle(CustomTextField())
                
                CustomText(text: "Emergency Medications")
                TextField("", text: $emergencyMeds)
                    .textFieldStyle(CustomTextField())
                
                CustomText(text: "Triggers")
                TextField("", text: $triggers)
                    .textFieldStyle(CustomTextField())
                
                CustomButton(text: "Create Account") {
                    createAccount()
                }
                .padding(.top, 15)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top)
                }
                
                Spacer()
                
                // Hidden navigation link triggered when account is created
                .navigationDestination(isPresented: $accountCreated) {
                    LoginView()
                }
            }
            .CustomView()
        }
    }
    
    private func createAccount() {
        do {
            let userId = try DatabaseManager.shared.addUser(
                security_question_string: currentSecurityQuestion,
                security_answer_string: currentSecurityAnswer,
                emailAddress: email,
                passwordHash: passwordOne,
                preventativeMedsCSV: preventativeMeds,
                emergencyMedsCSV: emergencyMeds,
                symptomsCSV: symptoms,
                triggersCSV: triggers
            )
            print("User created with ID: \(userId)")
            errorMessage = ""
            
            // Navigate to LoginView
            accountCreated = true
            
        } catch {
            errorMessage = "Failed to create account: \(error.localizedDescription)"
            print(error)
        }
    }
}

#Preview {
    CreateAccountView2(email: "test@test.com", passwordOne: "password123", currentSecurityQuestion: "?", currentSecurityAnswer: "answer")
}
