import SwiftUI
import CryptoKit

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
    @State private var accountCreated = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Text("Continue Creating Your Account")
                            .multilineTextAlignment(.center)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(Color(hex: "#b5c4b9"))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        CustomInstructions(text: "These fields are optional and help us provide personalized insights from your data. Add multiple items by separating them with commas.")
                    }
                    
                    VStack(spacing: 15) {
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
                        
                    }
                    
                    CustomButton(text: "Create Account") {
                        createAccount()
                    }
                    .padding(.top, 10)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 0) // Increase horizontal padding for margin
                .padding(.vertical, 10)
            }
            
            .navigationDestination(isPresented: $accountCreated) {
                LoginView()
            }
            .CustomView()
        }
    }
    
    private func createAccount() {
        do {
            let userId = try DatabaseManager.shared.addUser(
                security_question_string: currentSecurityQuestion,
                security_answer_string: CryptoHelper.hashString(currentSecurityAnswer),
                emailAddress: DatabaseManager.shared.normalizedEmail(email),
                passwordHash: CryptoHelper.hashString(passwordOne),
                userColor: "green",
                preventativeMedsCSV: preventativeMeds,
                emergencyMedsCSV: emergencyMeds,
                symptomsCSV: symptoms,
                triggersCSV: triggers
            )
            print("User created with ID: \(userId)")
            errorMessage = ""
            accountCreated = true
        } catch {
            errorMessage = "Failed to create account: \(error.localizedDescription)"
            print(error)
        }
    }
}

#Preview {
    NavigationStack {
        CreateAccountView2()
    }
}

