//
//  GestorDeHorariosApp.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 14/01/25.
import SwiftUI
import Firebase
import FirebaseAnalytics

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()  // Inicializa Firebase
        
        return true
    }
}

@main
struct GestorDeHorariosApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authenticationViewModel = AuthenticationViewModel()
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            // Pasa el contexto a las vistas según corresponda
            if let user = authenticationViewModel.user {
                // Si hay un usuario autenticado, muestra ContentView
                ContentView(authenticationViewModel: authenticationViewModel)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                // Si no hay usuario, muestra la pantalla de inicio
                LaunchScreenView(authenticationViewModel: authenticationViewModel)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
