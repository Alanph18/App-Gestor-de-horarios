import CoreData

// Controlador de persistencia para Core Data.
struct PersistenceController {
    // MARK: - Shared Instance
    static let shared = PersistenceController() // Instancia compartida para toda la app.

    // MARK: - Preview Instance
    static var preview: PersistenceController = {
        // Instancia para vistas previas (en memoria).
        let result = PersistenceController(inMemory: true)
        return result
    }()

    // MARK: - Properties
    let container: NSPersistentContainer // Contenedor de Core Data.

    // MARK: - Initializer
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "GestorDeHorarios") // Nombre del modelo de Core Data.
        
        // Configuración para usar almacenamiento en memoria (útil para pruebas y vistas previas).
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Carga el almacenamiento persistente.
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Error al cargar el almacenamiento persistente: \(error), \(error.userInfo)")
            }
        }
        
        // Configura el contexto para fusionar cambios automáticamente.
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
