//
//  NotificationManager.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 14/01/25.
//
/*import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private var notificationPermissionGranted = false

    private init() {
        checkPermissionStatus()
    }
    func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🚀 Notificación de Prueba"
        content.body = "Si ves esto, las notificaciones están funcionando correctamente."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // Se ejecuta en 5 segundos

        let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("⛔ Error al enviar notificación de prueba: \(error.localizedDescription)")
            } else {
                print("✅ Notificación de prueba programada en 5 segundos.")
            }
        }
    }
    // 🔹 Solicitar permisos de notificación
    func requestPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error al solicitar permisos de notificación: \(error.localizedDescription)")
                } else {
                    self?.notificationPermissionGranted = granted
                    print("Permisos de notificación: \(granted ? "Concedidos" : "Denegados")")
                }
            }
        }
    }
    
    // 🔹 Comprobar permisos al iniciar la app
    private func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationPermissionGranted = settings.authorizationStatus == .authorized
                print("Estado de los permisos: \(self.notificationPermissionGranted ? "Permitidos" : "Denegados")")
            }
        }
    }

    // 🔹 Programar notificación solo si los permisos están concedidos
    func scheduleNotification(for horario: Horario) {
        checkPermissionStatus()  // Verifica permisos antes de programar
        
        guard notificationPermissionGranted else {
            print("⛔ No se puede programar la notificación: permisos denegados.")
            return
        }
        
        guard let fechaInicio = horario.fechaInicio else {
            print("⛔ No se puede programar la notificación: fecha de inicio es nil.")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Recordatorio de horario"
        content.body = "Recuerda que \(horario.nombreEmpleado ?? "alguien") tiene un horario asignado el \(formattedDate(fechaInicio))"
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fechaInicio)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("⛔ Error al programar la notificación: \(error.localizedDescription)")
            } else {
                print("✅ Notificación programada para: \(self.formattedDate(fechaInicio))")
            }
        }
    }
    
    // 🔹 Formatear fecha para mostrar en la notificación
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}*/
