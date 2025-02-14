//
//  GestorDeHorariosApp.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 14/01/25.
import SwiftUI
import Firebase
import FirebaseAnalytics
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()  // Inicializa Firebase

        // Solicitar permisos para notificaciones
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error al solicitar permisos de notificaciones: \(error)")
            } else if granted {
                print("Permisos de notificaciones concedidos")
            } else {
                print("Permisos de notificaciones denegados")
            }
        }
        
        // Registrar para recibir notificaciones en primer plano
        application.registerForRemoteNotifications()
        
        return true
    }

    // Manejar notificaciones mientras la app está en primer plano
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
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
            if authenticationViewModel.user != nil {
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
