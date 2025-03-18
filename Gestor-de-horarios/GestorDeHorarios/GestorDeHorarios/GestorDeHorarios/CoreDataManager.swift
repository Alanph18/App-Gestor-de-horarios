import CoreData

// Clase para gestionar operaciones de Core Data.
class CoreDataManager {
    // MARK: - Shared Instance
    static let shared = CoreDataManager() // Instancia compartida para toda la app.

    // MARK: - Properties
    var context: NSManagedObjectContext {
        return PersistenceController.shared.container.viewContext // Contexto de Core Data.
    }
    
    // MARK: - Helper Functions
    
    // Guarda los cambios en el contexto de Core Data.
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                print("Contexto guardado correctamente.")
            } catch {
                print("Error al guardar el contexto: \(error)")
            }
        }
    }

    // Obtiene los horarios asociados a un usuario.
    func fetchHorarios(for userId: String) -> [Horario] {
        let request: NSFetchRequest<Horario> = Horario.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error al obtener los horarios: \(error)")
            return []
        }
    }

    // Elimina un horario específico.
    func delete(horario: Horario) {
        context.delete(horario)
        saveContext()
    }

    // Imprime los horarios almacenados en Core Data.
    func printStoredHorarios() {
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
}
