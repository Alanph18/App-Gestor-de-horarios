//
//  LaunchScreenView.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 14/01/25.
//

import SwiftUI

enum AutenticationSheedView: String, Identifiable {
    case register
    case login
    
    var id: String { rawValue }
}

struct LaunchScreenView: View {
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @State private var authenticationSheedView: AutenticationSheedView?
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                
            
            Button {
                authenticationSheedView = .login
            } label: {
                Label("Entra con email", systemImage: "envelope.fill")
                    .frame(maxWidth: .infinity)
            }
            .tint(.black)
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .padding(.horizontal, 40)
            
            Spacer()
            
            HStack(spacing: 5) {
                Text("¿No tienes cuenta?")
                Button {
                    authenticationSheedView = .register
                } label: {
                    Text("Regístrate")
                        .underline()
                        .fontWeight(.semibold)
                }
                .tint(.black)
            }
            .font(.footnote)
            .padding(.bottom, 20)
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
}

