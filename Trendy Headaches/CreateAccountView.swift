import SwiftUI

struct CreateAccountView: View {
    @State private var first_name: String = ""
    @State private var email: String = ""
    @State private var password_one: String = ""
    @State private var password_two: String = ""
    @State private var emailAvailable: Bool = true
    @FocusState private var focusedField: Field?

    //use this so it checks only once you click out of the field
    enum Field {
        case email
    }

    //check if all fields are filled in, if passwords match and are complex enough,
    //and email does not already exist
    private var formIsValid: Bool {
        !first_name.isEmpty &&
        !email.isEmpty &&
        !password_one.isEmpty &&
        !password_two.isEmpty &&
        (password_one == password_two) &&
        isPasswordValid(password_one) &&
        emailAvailable
    }
    
    //check password complexity
    func isPasswordValid(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z\\d]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    //check if email is already in database
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
                Text("Welcome!")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(Color(hex: "#b5c4b9"))
                    .padding(.bottom, 20)
                    .padding(.top, 30)

                Text("Please fill in the following fields to begin creating your account.")
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#b5c4b9"))
                    .padding(.bottom, 20)

                CustomText(text: "First Name")
                TextField("Enter your first name", text: $first_name)
                    .textFieldStyle(CustomTextField())

                //only check email once you click out
                CustomText(text: "Email")
                TextField("Enter your email", text: $email)
                    .textFieldStyle(CustomTextField())
                    .focused($focusedField, equals: .email)
                    .onChange(of: focusedField) { newField in
                        // When user leaves email field
                        if newField != .email {
                            checkEmailAvailability()
                        }
                    }
                
                //if email exists, display statement
                //make warning style?
                if !emailAvailable && !email.isEmpty {
                    Text("There is already an account associated with this email")
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        .multilineTextAlignment(.leading)
                }


                CustomText(text: "Password")
                SecureField("Enter your password", text: $password_one)
                    .textFieldStyle(CustomTextField())

                //display complexity warning
                if !isPasswordValid(password_one) && !password_one.isEmpty {
                    Text("Password must be at least 8 characters, contain uppercase, lowercase, number, and special character.")
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                }

                CustomText(text: "Confirm Password")
                SecureField("Re-enter your password", text: $password_two)
                    .textFieldStyle(CustomTextField())
                    .padding(.bottom, 10)

                // check if passwords match
                if !password_two.isEmpty {
                    if password_two != password_one
                    {
                        Text("Passwords do not match")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.leading)
                    }
                    

                }

                //gray out button until form is valid
                CustomNavButton(label: "Continue", destination: CreateAccountView2())
                    .padding(.top, 30)
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1.0 : 0.5)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "#001D00"))
        }
    }
}
