import SwiftUI

struct CreateAccountView2: View {
    var firstName: String = ""
    var email: String = ""
    var passwordOne: String = ""
    
    @State private var symptoms: String = ""
    @State private var preventativeMeds: String = ""
    @State private var emergencyMeds: String = ""
    @State private var triggers: String = ""
    @State private var errorMessage: String = ""
    @State private var accountCreated = false  // <-- New state
    
    var body: some View {
        NavigationStack {
            VStack {
                CustomInstructions(text: "These fields are optional. If you’d like to add more than one item, please separate them with a comma. We’ll only use this info to help filter your data logs to give you better insights.")
                
                CustomText(text: "Symptoms")
                TextField("", text: $symptoms)
                    .textFieldStyle(CustomTextField())
                
                CustomText(text: "Preventative Medications")
                TextField("", text: $preventativeMeds)
                    .textFieldStyle(CustomTextField())
                
                CustomText(text: "Emergency Medications")
                TextField("", text: $emergencyMeds)
                    .textFieldStyle(CustomTextField())
                
                CustomText(text: "Symptom Triggers")
                TextField("", text: $triggers)
                    .textFieldStyle(CustomTextField())
                
                Button("Create Account") {
                    createAccount()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top)
                }
                
                Spacer()
                
                // Hidden navigation link triggered when account is created
                NavigationLink(destination: LoginView(), isActive: $accountCreated) {
                    EmptyView()
                }
            }
            .CustomView()
        }
    }
    
    private func createAccount() {
        do {
            let userId = try DatabaseManager.shared.addUser(
                firstName: firstName,
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
            CustomWarningText(text: error.localizedDescription)
            print(errorMessage)
        }
    }
}

#Preview {
    CreateAccountView2(firstName: "Abbie", email: "test@test.com", passwordOne: "password123")
}
