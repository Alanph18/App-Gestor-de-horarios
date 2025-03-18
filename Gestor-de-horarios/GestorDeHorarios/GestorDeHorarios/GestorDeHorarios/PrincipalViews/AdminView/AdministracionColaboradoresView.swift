import SwiftUI
import CoreData
import FirebaseAuth

// Vista para administrar colaboradores.
struct AdministracionColaboradoresView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    private var userId: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Horario.nombreEmpleado, ascending: true)]
    ) var horarios: FetchedResults<Horario>
    
    @State private var showingAddColaborador = false
    @State private var showingDeleteAllConfirmation = false
    @State private var colaboradorToDelete: String? = nil
    
    // MARK: - Initializer
    init() {
        let request: NSFetchRequest<Horario> = Horario.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Horario.nombreEmpleado, ascending: true)]
        _horarios = FetchRequest(fetchRequest: request)
    }
    
    // Lista de nombres únicos de colaboradores.
    var uniqueEmployeeNames: [String] {
        let allNames = horarios.compactMap { $0.nombreEmpleado }
        return Array(Set(allNames)).sorted()
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                Text("Agrega a los colaboradores para tus horarios.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Divider()
                    .frame(height: 2)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .blue, .green]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .blur(radius: 1)
                    .opacity(0.8)
                
                if uniqueEmployeeNames.isEmpty {
                    emptyStateView
                } else {
                    colaboradoresList
                }
            }
            .navigationTitle("Administrador de Colaboradores")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddColaborador = true }) {
                        Label("Agregar", systemImage: "plus")
                            .font(.title2)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    if !uniqueEmployeeNames.isEmpty {
                        Button(action: { showingDeleteAllConfirmation = true }) {
                            Label("Eliminar Todo", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddColaborador) {
                AddColaboradorView()
            }
            .alert("Estas seguro que deseas eliminar a \(colaboradorToDelete ?? "")", isPresented: Binding<Bool>(
                get: { colaboradorToDelete != nil },
                set: { if !$0 { colaboradorToDelete = nil } }
            )) {
                Button("Eliminar", role: .destructive) {
                    if let nombre = colaboradorToDelete {
                        deleteColaborador(nombre: nombre)
                    }
                }
                Button("Cancelar", role: .cancel) {}
            }
            .alert("Eliminar todos los colaboradores", isPresented: $showingDeleteAllConfirmation) {
                Button("Eliminar Todo", role: .destructive) {
                    deleteAllColaboradores()
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Esta acción no se puede deshacer.")
            }
        }
    }
    
    // MARK: - Subviews
    
    // Vista cuando no hay colaboradores registrados.
    private var emptyStateView: some View {
        VStack {
            Image(systemName: "person.crop.circle.badge.xmark")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Aún no hay colaboradores registrados")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.top, 8)
        }
        .padding()
    }
    
    // Lista de colaboradores.
    private var colaboradoresList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(uniqueEmployeeNames, id: \.self) { nombre in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(nombre)
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            Text("Colaborador activo")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        Button(action: {
                            colaboradorToDelete = nombre
                        }) {
                            Image(systemName: "trash")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)
                    .transition(.scale)
                }
            }
            .padding(.top)
        }
    }
    
    // MARK: - Helper Functions
    
    // Elimina un colaborador específico.
    private func deleteColaborador(nombre: String) {
        let horariosAEliminar = horarios.filter { $0.nombreEmpleado == nombre }
        for horario in horariosAEliminar {
            viewContext.delete(horario)
        }
        saveContext()
    }
    
    // Elimina todos los colaboradores.
    private func deleteAllColaboradores() {
        for horario in horarios {
            viewContext.delete(horario)
        }
        saveContext()
    }
    
    // Guarda los cambios en el contexto de Core Data.
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error al guardar cambios: \(error.localizedDescription)")
        }
    }
}
