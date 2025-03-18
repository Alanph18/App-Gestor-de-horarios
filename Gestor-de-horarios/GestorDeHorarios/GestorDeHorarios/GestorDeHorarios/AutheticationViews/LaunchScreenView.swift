import SwiftUI

// Enumeración para manejar las vistas de autenticación (login y registro).
enum AutenticationSheedView: String, Identifiable {
    case register
    case login
    
    var id: String { rawValue }
}

// MARK: - LaunchScreenView
// Vista de inicio que muestra opciones de login y registro.
struct LaunchScreenView: View {
    // MARK: - Properties
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @State private var authenticationSheedView: AutenticationSheedView?
    
    // MARK: - Body
    var body: some View {
        ZStack {
            background
            content
        }
        .sheet(item: $authenticationSheedView) { sheet in
            switch sheet {
            case .register:
                RegisterEmailView(authenticationViewModel: authenticationViewModel)
            case .login:
                LoginEmailView(authenticationViewModel: authenticationViewModel)
            }
        }
    }
    
    // MARK: - Subviews
    
    // Fondo de la pantalla.
    private var background: some View {
        Color(hex: "F8F8F8") // Color de fondo.
            .edgesIgnoringSafeArea(.all)
    }
    
    // Contenido principal.
    private var content: some View {
        VStack(spacing: 20) {
            logo
            loginButton
            Spacer()
            registerPrompt
        }
        .padding(.top, 20)
    }
    
    // Logo de la aplicación.
    private var logo: some View {
        Image("Logo")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 400, maxHeight: 600)
            .padding(.top, 30)
    }
    
    // Botón para iniciar sesión.
    private var loginButton: some View {
        Button {
            authenticationSheedView = .login
        } label: {
            Label("Entra con email", systemImage: "envelope.fill")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .tint(.accentColor)
        .padding(.horizontal, 40)
    }
    
    // Mensaje y botón para registrarse.
    private var registerPrompt: some View {
        HStack(spacing: 5) {
            Text("¿No tienes cuenta?")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            Button {
                authenticationSheedView = .register
            } label: {
                Text("Regístrate")
                    .font(.subheadline)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .blue, .green]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
        .padding(.bottom, 20)
    }
}
