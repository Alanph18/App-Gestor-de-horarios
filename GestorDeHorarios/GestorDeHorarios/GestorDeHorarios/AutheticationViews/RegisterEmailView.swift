//
//  RegisterEmailView.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 03/02/25.
//

import SwiftUI

struct RegisterEmailView: View {
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @State var textFieldEmail: String = ""
    @State var textFieldPassword: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            DismissView()
                .padding(.top, 16)
                
            VStack(spacing: 4) {
                Text("Bienvenido al")
                    .font(.title2)
                    .foregroundColor(.primary)
                Text("Gestor de horarios")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .multilineTextAlignment(.center)
            
            Text("Coloca la siguiente información para registrarte")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            VStack(spacing: 16) {
                TextField("Ingresa tu correo electrónico", text: $textFieldEmail)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Ingresa tu contraseña", text: $textFieldPassword)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                    .autocapitalization(.none)
            }
            .padding(.horizontal, 32)
            
            Button(action: {
                authenticationViewModel.createNewUser(email: textFieldEmail, password: textFieldPassword)
            }) {
                Text("Aceptar")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 32)
            .padding(.top, 10)
            
            if let messageError = authenticationViewModel.messageError {
                Text(messageError)
                    .font(.body)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
            
            Spacer()
        }
    }
}

#Preview {
    RegisterEmailView(authenticationViewModel: AuthenticationViewModel())
}
