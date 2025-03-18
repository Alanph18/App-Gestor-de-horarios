import SwiftUI
// MARK: - PasswordView
// Vista para ingresar y mostrar/ocultar una contraseña.
struct PasswordView: View {
    @Binding var password: String // Binding para almacenar la contraseña.
    @State private var isPasswordVisible: Bool = false // Estado para mostrar/ocultar la contraseña.

    var body: some View {
        VStack(spacing: 8) {
            // Título de la sección.
            Text("Contraseña")
                .font(.headline)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)

            // Campo de texto para la contraseña.
            HStack {
                Image(systemName: "lock") // Ícono de candado.
                    .foregroundColor(.gray)
                
                // Alternar entre TextField y SecureField.
                if isPasswordVisible {
                    TextField("Ingresa tu contraseña", text: $password)
                } else {
                    SecureField("Ingresa tu contraseña", text: $password)
                }

                // Botón para mostrar/ocultar la contraseña.
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                        .foregroundColor(.gray)
                }
            }
            .autocapitalization(.none) // Evita mayúsculas automáticas.
            .font(.subheadline)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1)) // Borde redondeado.
        }
    }
}

