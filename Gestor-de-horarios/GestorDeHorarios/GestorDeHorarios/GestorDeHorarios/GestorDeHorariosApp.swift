//  GestorDeHorariosApp.swift
//  GestorDeHorarios
//  Created by Josue Alan Pablo Hernández on 14/01/25.

import SwiftUI
import Firebase
import FirebaseAnalytics
import UserNotifications

// MARK: - AppDelegate
// AppDelegate es responsable de manejar eventos del ciclo de vida de la aplicación y configuraciones iniciales.
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    // Este método se llama cuando la aplicación termina de lanzarse.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configura Firebase en la aplicación.
        FirebaseApp.configure()
        
        // Solicitar permisos para enviar notificaciones al usuario.
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        // Solicitar autorización para mostrar alertas, sonidos y badges.
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error al solicitar permisos de notificaciones: \(error)")
            } else if granted {
                print("Permisos de notificaciones concedidos")
            } else {
                print("Permisos de notificaciones denegados")
            }
        }
        
        // Registrar la aplicación para recibir notificaciones remotas.
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // Este método maneja las notificaciones cuando la aplicación está en primer plano.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Mostrar la notificación como un banner, reproducir un sonido y actualizar el badge.
        completionHandler([.banner, .sound, .badge])
    }
}

// MARK: - GestorDeHorariosApp
// Punto de entrada principal de la aplicación.
@main
struct GestorDeHorariosApp: App {
    
    // Adaptador para conectar el AppDelegate con la aplicación SwiftUI.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // ViewModel para manejar la autenticación del usuario.
    @StateObject var authenticationViewModel = AuthenticationViewModel()
    
    // Controlador de persistencia para Core Data.
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            // Verifica si hay un usuario autenticado.
            if authenticationViewModel.user != nil {
                // Si hay un usuario autenticado, muestra la vista principal (ContentView).
                ContentView(authenticationViewModel: authenticationViewModel)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                // Si no hay usuario autenticado, muestra la pantalla de inicio (LaunchScreenView).
                LaunchScreenView(authenticationViewModel: authenticationViewModel)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
