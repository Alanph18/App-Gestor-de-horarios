import SwiftUI
import CoreData
import FirebaseAuth

// Vista para agregar un nuevo colaborador.
struct AddColaboradorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @State private var nombreEmpleado: String = "" // Nombre del colaborador.
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información del Colaborador")) {
                    TextField("Nombre del colaborador", text: $nombreEmpleado)
                }
            }
            .navigationTitle("Agregar Colaborador")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveColaborador()
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    // Guarda el colaborador en Core Data.
    private func saveColaborador() {
        let nuevoHorario = Horario(context: viewContext)
        nuevoHorario.nombreEmpleado = nombreEmpleado
        nuevoHorario.userId = Auth.auth().currentUser?.uid ?? "" // Asocia el colaborador al usuario actual.
        
        do {
            try viewContext.save()
        } catch {
            print("Error al guardar el colaborador: \(error.localizedDescription)")
        }
    }
}
