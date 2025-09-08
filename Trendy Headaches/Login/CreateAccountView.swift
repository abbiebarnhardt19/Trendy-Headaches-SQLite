import SwiftUI
import SwiftUI

struct CreateAccountView: View {
    @State private var first_name: String = ""
    @State private var email: String = ""
    @State private var security_question: String = ""
    @State private var security_answer: String = ""
    @State private var password_one: String = ""
    @State private var password_two: String = ""
    @State private var emailAvailable: Bool = true
    
    @State private var emailCheckTask: Task<Void, Never>? = nil
    
    let accent = "#b5c4b9"
    let background = "#001d00"
    
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
            ZStack(alignment: .top) {
                Color(hex: background).ignoresSafeArea()
                
                SameAmplitudeBlob(waves: 30, amplitude:5, seed: 4)
                    .fill(Color(hex: accent))
                    .frame(width: 700, height: 500)
                    .offset(x:0, y: -340)
                    .rotationEffect(.degrees(-35))
                
                SameAmplitudeBlob(waves: 30, amplitude:5, seed: 4)
                    .fill(Color(hex: accent))
                    .frame(width: 700, height: 500)
                    .offset(x:100, y: -500)
                    .rotationEffect(.degrees(-215))
                
                GeometryReader { geo in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            CustomWelcome(text: "Create Account", color: accent)
                                .padding(.top, 0) // close to nav bar
                            
                            VStack(spacing: 10) {
                                CustomText(text: "Email", color: accent)
                                    .padding(.leading, 220)
                                
                                TextField("", text: $email)
                                    .textFieldStyle(CustomTextField(background: background, accent: accent, height: 50, width: 350))
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
                                    CustomWarningText(text: "There is already an account using this email")
                                        .padding(.leading, 15)
                                } else {
                                    CustomWarningText(text: "")
                                }
                                
                                CustomText(text: "Password", color: accent)
                                    .padding(.leading, 220)
                                
                                SecureField("", text: $password_one)
                                    .textFieldStyle(CustomTextField(background: background, accent: accent, height: 50, width: 350))
                                
                                if !DatabaseManager.isPasswordValid(password_one) && !password_one.isEmpty {
                                    CustomWarningText(text: "8+ characters, uppercase, lowercase, number, and symbol")
                                        .padding(.leading, 15)
                                } else {
                                    CustomWarningText(text: "")
                                }
                                
                                CustomText(text: "Confirm Password", color: accent)
                                    .padding(.leading, 220)
                                
                                SecureField("", text: $password_two)
                                    .textFieldStyle(CustomTextField(background: background, accent: accent, height: 50, width: 350))
                                
                                if !password_two.isEmpty && password_two != password_one {
                                    CustomWarningText(text: "Passwords do not match.")
                                        .padding(.leading, 15)
                                } else {
                                    CustomWarningText(text: "")
                                }
                                
                                CustomText(text: "Security Question", color: accent)
                                    .padding(.leading, 220)
                                
                                TextField("", text: $security_question)
                                    .textFieldStyle(CustomTextField(background: background, accent: accent, height: 50, width: 350))
                                    .padding(.bottom, 25)
                                
                                CustomText(text: "Security Question Answer", color: accent)
                                    .padding(.leading, 220)
                                
                                TextField("", text: $security_answer)
                                    .textFieldStyle(CustomTextField(background: background, accent: accent, height: 50, width: 350))
                                
                                CustomNavButton(
                                    label: "Continue",
                                    destination: CreateAccountView3(
                                        email: email,
                                        password_one: password_one,
                                        security_question: security_question,
                                        security_answer: security_answer
                                    ),
                                    background: background,
                                    accent: accent,
                                    height: 50,
                                    width: 150
                                )
                                .disabled(!formIsValid)
                                .opacity(formIsValid ? 1.0 : 0.5)
                            }
                            .padding(.bottom, 120)
                            
                        }
                        .frame(minHeight: geo.size.height)
                    }
                }
                
            }

        }
    }
}

#Preview {
    NavigationStack {
        CreateAccountView()
    }
}
