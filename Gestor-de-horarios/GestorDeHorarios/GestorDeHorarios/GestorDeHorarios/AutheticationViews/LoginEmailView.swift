import SwiftUI

// Vista de inicio de sesión con email.
struct LoginEmailView: View {
    // MARK: - Properties
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @State private var textFieldEmail: String = ""
    @State private var textFieldPassword: String = ""
    @State private var showForgotPasswordAlert: Bool = false // Estado para la alerta de restablecimiento.

    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            dismissButton
            titlesSection
            subtitleSection
            textFieldsSection
            loginButton
            forgotPasswordButton // Botón para restablecer contraseña.
            errorMessage
            Spacer()
        }
        .padding(.vertical, 20)
        .alert(isPresented: $showForgotPasswordAlert) {
            Alert(
                title: Text("Restablecer contraseña"),
                message: Text("Ingresa tu correo electrónico para recibir un enlace de restablecimiento."),
                primaryButton: .default(Text("Enviar"), action: {
                    authenticationViewModel.sendPasswordReset(email: textFieldEmail)
                }),
                secondaryButton: .cancel()
            )
        }
    }
    
    // MARK: - Subviews
    
    // Botón para cerrar la vista.
    private var dismissButton: some View {
        DismissView()
            .padding(.top, 20)
    }
    
    // Títulos de la vista.
    private var titlesSection: some View {
        VStack(spacing: 10) {
            Text("Tu Gestor de Horarios")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding()
            Divider()
                .frame(height: 2)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.purple, .blue, .green]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .blur(radius: 1)
                .opacity(0.8)
        }
    }
    
    // Subtítulo de la vista.
    private var subtitleSection: some View {
        Text("Ingresa tus datos para acceder")
            .font(.headline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .padding(.top, 10)
    }
    
    // Campos de texto para email y contraseña.
    private var textFieldsSection: some View {
        VStack(spacing: 15) {
            emailField
            PasswordView(password: $textFieldPassword)
        }
        .padding(.horizontal, 32)
    }
    
    // Campo de texto para el email.
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
                    .onChange(of: textFieldEmail) { _ in
                        authenticationViewModel.messageError = nil // Limpiar mensaje de error.
                    }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary, lineWidth: 1)
            )
        }
    }

    // Botón para iniciar sesión.
    private var loginButton: some View {
        Button(action: {
            if textFieldEmail.isEmpty || textFieldPassword.isEmpty {
                authenticationViewModel.messageError = "Por favor, completa todos los campos."
            } else if !isValidEmail(textFieldEmail) {
                authenticationViewModel.messageError = "Por favor, ingresa un correo electrónico válido."
            } else {
                authenticationViewModel.login(email: textFieldEmail, password: textFieldPassword)
            }
        }) {
            Text("Iniciar Sesión")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .padding(.horizontal, 32)
        .padding(.top, 20)
    }

    // Botón para restablecer contraseña.
    private var forgotPasswordButton: some View {
        Button(action: {
            showForgotPasswordAlert = true // Mostrar alerta.
        }) {
            Text("¿Olvidaste tu contraseña?")
                .font(.subheadline)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [.purple, .blue, .green]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .padding(.top, 10)
    }

    // MARK: - Funciones
    
    // Función para validar el formato del email.
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Error Message
    
    // Mensaje de error.
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
