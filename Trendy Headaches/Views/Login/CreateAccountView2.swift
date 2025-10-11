import SwiftUI

struct CreateAccountView2: View {
    // Form data from previous pages
    var email: String = ""
    var passwordOne: String = ""
    var securityQuestion: String = ""
    var securityAnswer: String = ""
    
    // Color theme options
    private let themeOptions = [ "Classic Light", "Light Pink", "Classic Dark", "Dark Green", "Dark Blue", "Dark Purple", "Custom" ]
    
    // User-selected theme values
    @State private var selectedTheme: String = "Dark Green"
    @State private var background: String = "#001D00"
    @State private var accent: String = "#B5C4B9"
    @State private var selectedColor: Color = .blue
    // Layout constants
    private let leadingPadding: CGFloat = 180
    private let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationStack {
            ZStack {
                Create2BGComps(background: background, accent: accent)
                
                VStack(spacing: 20) {
                    // Header
                    CustomText(text: "Choose a color theme", color: accent)
                        .padding(.leading, leadingPadding)

                    // Theme dropdown
                    CustomDropdown(color_theme: $selectedTheme, background: $background, accent: $accent, options: themeOptions,  width: screenWidth - 50, height: 50, cornerRadius: 30, fontSize: 22)

                    // Custom theme input fields
                    if selectedTheme == "Custom" {
                        CustomText(text: "Or, enter two hex codes to design a theme", color: accent, width: screenWidth - 50,  multiAlign: .center)
                        .padding(.bottom, 10)
                        
                        HStack (spacing: 20){
                            ColorPickerTextField(
                                        accent: accent,
                                        background: background,
                                        var_to_change: $background,
                                        placeholder: "Enter HEX color",
                                        width: UIScreen.main.bounds.width / 2 - 40)
                            
                            ColorPickerTextField(
                                        accent: accent,
                                        background: background,
                                        var_to_change: $accent,
                                        placeholder: "Enter HEX color",
                                        width: UIScreen.main.bounds.width / 2 - 40)
                        }
                    }
                    
                    // Continue button
                    CustomNavButton(label: "Continue", dest: CreateAccountView3( background: background, accent: accent, email: email, passwordOne: passwordOne, currentSecurityQuestion: securityQuestion,  currentSecurityAnswer: securityAnswer), bg: background,  accent: accent)
                }
                .padding()
            }
        }
    }
}

#Preview {
    CreateAccountView2(
        email: "test@example.com",
        passwordOne: "password123",
        securityQuestion: "Your first pet?",
        securityAnswer: "Fluffy"
    )
}
