import SwiftUI
import CoreData

struct EditHorarioView: View {
    @Environment(\ .presentationMode) var presentationMode
    
    // MARK: - Propiedades
    @State private var nombreEmpleado = ""
    @State private var entradaHora = Date()
    @State private var comidaHora = Date()
    @State private var salidaHora = Date()
    @State private var hasChanges = false
    
    var horario: Horario?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Título principal
                Text("Editar Horario")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                
                // Sección de nombre del colaborador
                VStack(alignment: .leading, spacing: 5) {
                    Text("Nombre del Colaborador")
                        .font(.headline)
                        .foregroundColor(.black)
                    Text(nombreEmpleado)
                        .font(.title3)
                        .fontWeight(.medium)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                Text("Estás editando los datos del horario en curso.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Línea decorativa
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
                
                // MARK: - Selectores de Hora
                CustomDatePicker(title: "Hora de Entrada", selection: $entradaHora, hasChanges: $hasChanges)
                CustomDatePicker(title: "Hora de Comida", selection: $comidaHora, hasChanges: $hasChanges)
                CustomDatePicker(title: "Hora de Salida", selection: $salidaHora, hasChanges: $hasChanges)
                
                // Botón para guardar cambios
                Button(action: {
                    saveHorario()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Guardar Cambios")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(hasChanges ? Color.black : Color(.systemGray3))
                        .cornerRadius(12)
                }
                .disabled(!hasChanges)
                .padding(.top, 10)
            }
            .padding()
            .navigationTitle("Editor de horas")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let horario = horario {
                    nombreEmpleado = horario.nombreEmpleado ?? ""
                    entradaHora = horario.fechaInicio ?? Date()
                    comidaHora = horario.fechaComida ?? Date()
                    salidaHora = horario.fechaFin ?? Date()
                }
            }
        }
    }
    
    // MARK: - Funciones Auxiliares
    /// Combina una fecha base con una hora específica
    private func combineDateAndTime(baseDate: Date?, time: Date) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: baseDate ?? Date())
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        return calendar.date(from: DateComponents(
            year: dateComponents.year,
            month: dateComponents.month,
            day: dateComponents.day,
            hour: timeComponents.hour,
            minute: timeComponents.minute
        )) ?? Date()
    }
    
    /// Guarda los cambios en el horario editado
    private func saveHorario() {
        guard let horario = horario else { return }
        let context = PersistenceController.shared.container.viewContext
        
        horario.fechaInicio = combineDateAndTime(baseDate: horario.fechaInicio, time: entradaHora)
        horario.fechaComida = combineDateAndTime(baseDate: horario.fechaComida, time: comidaHora)
        horario.fechaFin = combineDateAndTime(baseDate: horario.fechaFin, time: salidaHora)
        
        do {
            try context.save()
            hasChanges = false
        } catch {
            print("Error al guardar el horario: \(error)")
        }
    }
}

// MARK: - Componente Personalizado para Selección de Hora
struct CustomDatePicker: View {
    let title: String
    @Binding var selection: Date
    @Binding var hasChanges: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
            
            DatePicker("", selection: $selection, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .onChange(of: selection) { _ in
                    hasChanges = true
                }
        }
    }
}

