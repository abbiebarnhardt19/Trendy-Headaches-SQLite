import SwiftUI
import SQLite

struct LoginView: SwiftUI.View {
    
    //page colors
    var background: String = "#001d00"
    var accent: String = "#b5c4b9"
    
    //editable varables
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var loginError: String? = nil
    @State private var userId: Int64? = nil
    
    //used for leading padding so it only needs to be changed in one place
    let leading_padding = CGFloat(20)
    
    var body: some SwiftUI.View {
        NavigationStack {
            ZStack {
                //set background color
                Color(hex: background).ignoresSafeArea()

                //asymetrical blobs
                ParametricBlob(points: 45, amplitude: 0.075, x:-100, y:425, rotation:195, accent: accent)
                ParametricBlob(points: 45, amplitude: 0.075, x:-30, y:425, rotation:30, accent:accent)
                
                VStack{
                    //header text
                    CustomText(text: "Log In", color: accent, width: 200, textAlignment: .center, textSize: 50)
                        .padding(.bottom, 20)
                    
                    //email label and textbox
                    CustomText(text: "Email", color: accent)
                        .padding(.leading, leading_padding)
                    
                    CustomTextField(background: background, accent: accent, placeholder: "", text: $email)
                    
                    //password label and textbox
                    CustomText(text: "Password", color: accent)
                        .padding(.leading, leading_padding)
                    
                    CustomTextField(background: background, accent: accent, placeholder: "", text: $password, isSecure: true)
                    
                    //link to fogot password page
                    CustomLink(destination: ForgotPasswordView1(), text: "Forgot Password?", accent: accent)
                        .padding(.leading, 170)
                    
                    //login button, on click attempt login. Use result of leogin to get user id, login error, and update isLoggedIn
                    CustomButton(text: "Log In", background: background, accent: accent) {
                        let result = DatabaseManager.shared.attemptLogin(email: email, password: password)
                        userId = result.userId
                        loginError = result.error
                        isLoggedIn = userId != nil
                    }
                    
                    //diplay login error if it exists
                    if let loginError = loginError {
                        CustomWarningText(text: loginError)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    //reserve space for error
                    else{
                        CustomWarningText(text: " ")
                    }
                }
                
                //grab database
                .onAppear {
                    _ = DatabaseManager.shared
                }
                
                //when isLoggedIn is true, move to the main app and pass it the colors based on the email
                .navigationDestination(isPresented: $isLoggedIn) {
                    if let userId = userId {
//                        let accentColor = DatabaseManager.shared.getSingleColumnValue(userId: userId, columnName: "accent_color")
//                        let backgroundColor = DatabaseManager.shared.getSingleColumnValue(userId: userId, columnName: "background_color")
//                        NavBarView(userID: userId, backgroundColor: backgroundColor ?? background, accentColor: accentColor ?? accent)
                        ProfileView(userID: userId, backgroundColor: .constant(background), accentColor: .constant(accent))
                    } else {
                        // if for whatever reason userID doesn't exist
                        Text("Oops! Something went wrong. Please try again later.")
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
