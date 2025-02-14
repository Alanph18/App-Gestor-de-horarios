import SwiftUI

struct LoginEmailView: View {
    // MARK: - Properties
    
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @State private var textFieldEmail: String = ""
    @State private var textFieldPassword: String = ""
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            dismissButton
            titlesSection
            imageSection
            subtitleSection
            textFieldsSection
            loginButton
            errorMessage
            Spacer()
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Subviews
    
    private var dismissButton: some View {
        DismissView()
            .padding(.top, 20)
    }
    
    private var titlesSection: some View {
        VStack(spacing: 10) {
            Text("Bienvenido de regreso a")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text("Tu Gestor de Horarios")
                .font(.title2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var imageSection: some View {
        Image("ImageLogin")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 400, maxHeight: 100)
            .padding(.top, 20)
    }
    
    private var subtitleSection: some View {
        Text("Ingresa tus datos para acceder")
            .font(.headline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .padding(.top, 10)
    }
    
    private var textFieldsSection: some View {
        VStack(spacing: 15) {
            emailField
            PasswordView(password: $textFieldPassword)
        }
        .padding(.horizontal, 32)
    }
    
    private var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Correo")
                .font(.headline)
                .foregroundColor(.primary)
                .bold()
            
            HStack {
                Image(systemName: "envelope")
                    .foregroundColor(.secondary)
                TextField("Ingresa tu correo electrónico", text: $textFieldEmail)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .font(.subheadline)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary, lineWidth: 1)
            )
        }
    }
    
    private var loginButton: some View {
        Button(action: {
            authenticationViewModel.login(email: textFieldEmail, password: textFieldPassword)
        }) {
            Text("Iniciar Sesión")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .padding(.horizontal, 32)
        .padding(.top, 20)
    }
    
    private var errorMessage: some View {
        Group {
            if let messageError = authenticationViewModel.messageError {
                Text(messageError)
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    LoginEmailView(authenticationViewModel: AuthenticationViewModel())
}
