//
//  RegisterEmailView.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 03/02/25.
//

import SwiftUI

struct RegisterEmailView: View {
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
            registerButton
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
            Text("¡Bienvenido!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text("Regístrate para empezar")
                .font(.title2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var imageSection: some View {
        Image("ImageRegister")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 400, maxHeight: 80)
            .padding(.top, 10)
    }
    
    private var subtitleSection: some View {
        Text("Coloca la siguiente información para registrarte")
            .font(.subheadline)
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
                .frame(maxWidth: .infinity, alignment: .leading)
            
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
    
    private var registerButton: some View {
        Button(action: {
            authenticationViewModel.createNewUser(email: textFieldEmail, password: textFieldPassword)
        }) {
            Text("Registrarse")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal, 32)
        .padding(.top, 20)
    }
    
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
}

// MARK: - Preview

#Preview {
    RegisterEmailView(authenticationViewModel: AuthenticationViewModel())
}
