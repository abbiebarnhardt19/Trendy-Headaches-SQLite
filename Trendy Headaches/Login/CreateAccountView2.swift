import SwiftUI
import CryptoKit

struct CreateAccountView2: View {
    var background: String = ""
    var accent: String = ""
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
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Text("Continue Creating Your Account")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color(hex: accent))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    CustomInstructions(text: "These fields are optional and help us provide personalized insights from your data. Add multiple items by separating them with commas.", color: accent)
                }
                
                VStack(spacing: 15) {
                    CustomText(text: "Symptom or Illness", color: accent)
                    TextField("", text: $symptoms)
                        .textFieldStyle(CustomTextField(background: background, accent: accent))
                    
                    CustomText(text: "Preventative Medications", color: accent)
                    TextField("", text: $preventativeMeds)
                        .textFieldStyle(CustomTextField(background: background, accent: accent))
                    
                    CustomText(text: "Emergency Medications", color: accent)
                    TextField("", text: $emergencyMeds)
                        .textFieldStyle(CustomTextField(background: background, accent: accent))
                    
                    CustomText(text: "Triggers", color: accent)
                    TextField("", text: $triggers)
                        .textFieldStyle(CustomTextField(background: background, accent: accent))
                }
                
                CustomButton(text: "Create Account", background: accent, accent: background) {
                    do {
                        try DatabaseManager.createUser(
                            email: email,
                            password: passwordOne,
                            securityQuestion: currentSecurityQuestion,
                            securityAnswer: currentSecurityAnswer,
                            background: background,
                            accent: accent,
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

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
        .CustomView(color: background)
        .navigationDestination(isPresented: $accountCreated) {
            LoginView(background: background, accent: accent)
        }
    }
}


#Preview {
    NavigationStack {
        CreateAccountView2()
    }
}
