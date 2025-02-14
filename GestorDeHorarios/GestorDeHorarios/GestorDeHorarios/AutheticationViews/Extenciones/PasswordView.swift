//
//  PasswordView.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 04/02/25.
import SwiftUI

struct PasswordView: View {
    @Binding var password: String
    @State private var isPasswordVisible: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            Text("Contraseña")
                .font(.headline)
                .foregroundColor(.primary)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)

            HStack {
                Image(systemName: "lock")
                    .foregroundColor(.gray)
                
                if isPasswordVisible {
                    TextField("Ingresa tu contraseña", text: $password)
                } else {
                    SecureField("Ingresa tu contraseña", text: $password)
                }

                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                        .foregroundColor(.gray)
                }
            }
            .autocapitalization(.none)
            .font(.subheadline)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
        }
    }
}

// Vista previa
#Preview {
    PasswordView(password: .constant("")) // Uso con binding simulado
}
