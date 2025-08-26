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
                CustomWelcome(text: "Welcome!")
                CustomInstructions(text: "Please fill in the following fields to begin creating your account.")

                //start of form
                CustomText(text: "First Name")
                TextField("Enter your first name", text: $first_name)
                    .textFieldStyle(CustomTextField())

                //enter email and only check email once you click out
                CustomText(text: "Email")
                TextField("Enter your email", text: $email)
                    .textFieldStyle(CustomTextField())
                    .focused($focusedField, equals: .email)
                    .onChange(of: focusedField) { oldValue, newValue in
                        if newValue != .email {
                            checkEmailAvailability()
                        }
                    }


                //if email already exists, display warning
                if !emailAvailable && !email.isEmpty {
                    CustomWarningText(text: "There is already an account associated with this email")
                }
                
                CustomText(text: "Password")
                SecureField("Enter your password", text: $password_one)
                    .textFieldStyle(CustomTextField())

                //display warning if it password is not complex enough
                if !isPasswordValid(password_one) && !password_one.isEmpty {
                    CustomSubtext(text: "Password must be at least 8 characters, contain uppercase, lowercase, number, and special character.")
                }

                CustomText(text: "Confirm Password")
                SecureField("Re-enter your password", text: $password_two)
                    .textFieldStyle(CustomTextField())

                // check if passwords match, if not, display warning
                if !password_two.isEmpty {
                    if password_two != password_one
                    {
                        CustomWarningText(text: "Passwords do not match.")
                    }
                }

                //gray out button until form is valid
                CustomNavButton(label: "Continue", destination: CreateAccountView2())
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1.0 : 0.5)
            }
            .CustomView()
        }
    }
}
