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
                        do {
                            try DatabaseManager.createUser(
                                email: email,
                                password: passwordOne,
                                securityQuestion: currentSecurityQuestion,
                                securityAnswer: currentSecurityAnswer,
                                symptoms: symptoms,
                                preventativeMeds: preventativeMeds,
                                emergencyMeds: emergencyMeds,
                                triggers: triggers
                            )
                            errorMessage = ""
                            accountCreated = true
                        } catch {
                            errorMessage = "Failed to create account: \(error.localizedDescription)"
                        }
                    }
                    .padding(.top, 10)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 0)
                .padding(.vertical, 10)
            }
            .navigationDestination(isPresented: $accountCreated) {
                LoginView()
            }
            .CustomView()
        }
    }
}

#Preview {
    NavigationStack {
        CreateAccountView2()
    }
}
