//
//  AuthenticationRepository.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 03/02/25.
//

import Foundation

final class AuthenticationRepository{
    private let authenticationFirebaseDatasource: AuthenticationFirebaseDatasource
    
    init(authenticationFirebaseDatasource: AuthenticationFirebaseDatasource = AuthenticationFirebaseDatasource()){
        self.authenticationFirebaseDatasource = authenticationFirebaseDatasource
    }
    func getCurretUser() -> User? {
        authenticationFirebaseDatasource.getCurrentUser()
    }
    func createNewUser(email: String, password: String, completionBlock: @escaping (Result<User, Error>) -> Void){
        authenticationFirebaseDatasource.createNewUser(email: email, password: password, completionBlock: completionBlock)
    }
    func login(email: String, password: String, completionBlock: @escaping (Result<User, Error>) -> Void){
        authenticationFirebaseDatasource.login(email: email, password: password, completionBlock: completionBlock)
    }
    func logout() throws{
        try authenticationFirebaseDatasource.logout()
    }
}
