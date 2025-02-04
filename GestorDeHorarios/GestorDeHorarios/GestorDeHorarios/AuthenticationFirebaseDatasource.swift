//
//  AuthenticationFirebaseDatasource.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 03/02/25.
//

import Foundation
import FirebaseAuth

struct User{
    let email: String

}
final class AuthenticationFirebaseDatasource{
    func getCurrentUser() -> User?{
        guard let email = Auth.auth().currentUser?.email else{
            return nil
        }
        return .init(email: email)
    }
    func createNewUser(email: String, password: String, completionBlock: @escaping(Result<User, Error>) -> Void){
        Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
            if let error = error {
                print("Error al crear un nuevo usuario\(error.localizedDescription)")
                completionBlock(.failure(error))
                return
            }
            let email = authDataResult?.user.email ?? "No email"
            print("Se ha creado un Usuario con la informacion siguiente \(email)")
            completionBlock(.success(.init(email: email)))
            
        }
    }
    func login(email: String, password: String, completionBlock: @escaping(Result<User, Error>) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            if let error = error {
                print("Error al cargar al usuario\(error.localizedDescription)")
                completionBlock(.failure(error))
                return
            }
            let email = authDataResult?.user.email ?? "No email"
            print("Usuario cargado con la informacion siguiente \(email)")
            completionBlock(.success(.init(email: email)))
            
        }
    }
    func logout() throws {
        try Auth.auth().signOut()
    }
}
