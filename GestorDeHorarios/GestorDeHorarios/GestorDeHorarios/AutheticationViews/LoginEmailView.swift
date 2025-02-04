//
//  LoginEmailView.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 03/02/25.
//
import SwiftUI

struct LoginEmailView: View {
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @State var textFieldEmail: String = ""
    @State var textFieldPassword: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            DismissView()
                .padding(.top, 16)
            
            VStack(spacing: 4) {
                Text("Bienvenido a")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Tu Gestor de Horarios")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .multilineTextAlignment(.center)
            
            Text("Ingresa tus datos para acceder")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            VStack(spacing: 16) {
                TextField("Correo electrónico", text: $textFieldEmail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                SecureField("Contraseña", text: $textFieldPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            }
            
            Button(action: {
                authenticationViewModel.login(email: textFieldEmail, password: textFieldPassword)
            }) {
                Text("Iniciar Sesión")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding(.horizontal, 32)
            
            if let messageError = authenticationViewModel.messageError {
                Text(messageError)
                    .font(.body)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    LoginEmailView(authenticationViewModel: AuthenticationViewModel())
}
