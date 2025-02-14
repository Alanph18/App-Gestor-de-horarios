import SwiftUI

// MARK: - Authentication Sheet Enum

enum AutenticationSheedView: String, Identifiable {
    case register
    case login
    
    var id: String { rawValue }
}

// MARK: - LaunchScreenView

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
    
    private var background: some View {
        Color(.systemBackground) // Fondo que se adapta al modo claro/oscuro
            .edgesIgnoringSafeArea(.all)
    }
    
    private var content: some View {
        VStack(spacing: 20) {
            logo
            loginButton
            Spacer()
            registerPrompt
        }
        .padding(.top, 20)
    }
    
    private var logo: some View {
        Image("Logo")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 400, maxHeight: 600)
            .padding(.top, 30)
    }
    
    private var loginButton: some View {
        Button {
            authenticationSheedView = .login
        } label: {
            Label("Entra con email", systemImage: "envelope.fill")
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 40)
                .foregroundColor(.white) // Texto blanco para contrastar con el fondo del botón
        }
        .tint(.accentColor) // Usa el color de acento del sistema
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .padding(.horizontal, 40)
    }
    
    private var registerPrompt: some View {
        HStack(spacing: 5) {
            Text("¿No tienes cuenta?")
                .font(.footnote)
                .foregroundColor(.secondary) // Color secundario para adaptarse al modo claro/oscuro
            
            Button {
                authenticationSheedView = .register
            } label: {
                Text("Regístrate")
                    .underline()
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor) // Usa el color de acento del sistema
            }
        }
        .padding(.bottom, 20)
    }
}
