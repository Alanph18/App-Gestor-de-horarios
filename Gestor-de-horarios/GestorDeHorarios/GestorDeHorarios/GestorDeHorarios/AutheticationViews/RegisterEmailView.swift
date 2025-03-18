import SwiftUI

// Vista de registro con email.
struct RegisterEmailView: View {
    // MARK: - Properties
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @State private var textFieldEmail: String = ""
    @State private var textFieldPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var showSuccessMessage: Bool = false

    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            dismissButton
            titlesSection
            subtitleSection
            textFieldsSection
            registerButton
            errorMessage
            successMessage
            Spacer()
        }
        .padding(.vertical, 20)
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
            Text("¡Bienvenido!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text("Regístrate para empezar")
                .font(.title2)
                .foregroundColor(.secondary)
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
        Text("Coloca la siguiente información para registrarte")
            .font(.subheadline)
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("Campo de correo electrónico")
            
            HStack {
                Image(systemName: "envelope")
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
                TextField("Ingresa tu correo electrónico", text: $textFieldEmail)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .font(.subheadline)
                    .accessibilityLabel("Correo electrónico")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary, lineWidth: 1)
            )
            .accessibilityElement(children: .combine)
        }
    }
    
    // Botón para registrarse.
    private var registerButton: some View {
        Button(action: {
            if validateFields() {
                isLoading = true
                authenticationViewModel.createNewUser(email: textFieldEmail, password: textFieldPassword)
            }
        }) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            } else {
                Text("Registrarse")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 20)
        .disabled(isLoading)
    }
    
    // Mensaje de error.
    private var errorMessage: some View {
        Group {
            if let messageError = authenticationViewModel.messageError {
                Text(messageError)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 10)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // Mensaje de éxito.
    private var successMessage: some View {
        Group {
            if showSuccessMessage {
                Text("¡Registro exitoso!")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.top, 10)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    // Valida los campos del formulario.
    private func validateFields() -> Bool {
        guard !textFieldEmail.isEmpty else {
            authenticationViewModel.messageError = "El correo electrónico no puede estar vacío."
            return false
        }
        
        guard textFieldEmail.contains("@") && textFieldEmail.contains(".") else {
            authenticationViewModel.messageError = "Por favor, introduce un correo electrónico válido."
            return false
        }
        
        guard !textFieldPassword.isEmpty else {
            authenticationViewModel.messageError = "La contraseña no puede estar vacía."
            return false
        }
        
        guard textFieldPassword.count >= 6 else {
            authenticationViewModel.messageError = "La contraseña debe tener al menos 6 caracteres."
            return false
        }
        
        authenticationViewModel.messageError = nil
        return true
    }
}


