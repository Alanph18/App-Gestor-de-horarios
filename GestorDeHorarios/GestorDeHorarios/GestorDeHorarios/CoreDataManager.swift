//
//  CoreDataManager.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 14/01/25.
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()

    var context: NSManagedObjectContext {
        return PersistenceController.shared.container.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    private func printStoredHorarios() {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Horario> = Horario.fetchRequest()

        do {
            let horarios = try context.fetch(request)
            for horario in horarios {
                print("Horario guardado - Nombre: \(horario.nombreEmpleado ?? "Sin nombre"), Entrada: \(horario.fechaInicio ?? Date()), Comida: \(horario.fechaComida ?? Date()), Salida: \(horario.fechaFin ?? Date())")
            }
        } catch {
            print("Error al obtener los horarios: \(error)")
        }
    }

    
    func delete(horario: Horario) {
        context.delete(horario)
        saveContext()
    }
    
    // Fetch horarios
    func fetchHorarios() -> [Horario] {
        let request: NSFetchRequest<Horario> = Horario.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch horarios: \(error)")
            return []
        }
    }
}

