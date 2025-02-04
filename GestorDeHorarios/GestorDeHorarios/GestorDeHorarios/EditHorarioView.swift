//
//  EditHorarioView.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 20/01/25.

import SwiftUI
import CoreData

struct EditHorarioView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var nombreEmpleado = ""
    @State private var entradaHora = Date()
    @State private var comidaHora = Date()
    @State private var salidaHora = Date()
    var horario: Horario? // Esta es la propiedad opcional que se pasa al inicializar la vista

    var body: some View {
        VStack {
            // Encabezado
            VStack(alignment: .leading) {
                Text("Editar Horario")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Text("Realiza cambios en el horario seleccionado.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.bottom, 20)
            .background(Color(.systemGray6)) // Fondo claro moderno

            ScrollView {
                VStack(spacing: 30) {
                    // Sección: Nombre del empleado
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Nombre del Empleado")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Nombre del Empleado", text: $nombreEmpleado)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }

                    // Sección: Hora de entrada
                    HStack(alignment: .center, spacing: 10) {
                        Text("Hora de Entrada")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        DatePicker(
                            "Seleccionar Hora",
                            selection: $entradaHora,
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                    }

                    // Sección: Hora de comida
                    HStack(alignment: .center, spacing: 10) {
                        Text("Hora de Comida")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        DatePicker(
                            "Seleccionar Hora",
                            selection: $comidaHora,
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                    }

                    // Sección: Hora de salida
                    HStack(alignment: .center, spacing: 10) {
                        Text("Hora de Salida")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        DatePicker(
                            "Seleccionar Hora",
                            selection: $salidaHora,
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                    }

                    // Botón de guardar
                    Button(action: {
                        saveHorario() // Guardar cambios
                        presentationMode.wrappedValue.dismiss() // Cerrar la vista
                    }) {
                        Text("Guardar Cambios")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .disabled(nombreEmpleado.isEmpty) // Deshabilitar si el nombre está vacío
                    .opacity(nombreEmpleado.isEmpty ? 0.5 : 1)
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
        }
        .onAppear {
            if let horario = horario {
                // Desempaquetando el horario opcional para asignar los valores a las variables
                nombreEmpleado = horario.nombreEmpleado ?? ""
                entradaHora = horario.fechaInicio ?? Date()
                comidaHora = horario.fechaComida ?? Date()
                salidaHora = horario.fechaFin ?? Date()
            }
        }
    }

    // Función para combinar fecha y hora
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

    // Guardar los cambios del horario
    private func saveHorario() {
        guard let horario = horario else { return } // Asegurarse de que el horario no sea nil

        let context = PersistenceController.shared.container.viewContext
        
        // Actualizar los valores del horario con los datos de la vista
        horario.nombreEmpleado = nombreEmpleado
        horario.fechaInicio = combineDateAndTime(baseDate: horario.fechaInicio, time: entradaHora)
        horario.fechaComida = combineDateAndTime(baseDate: horario.fechaComida, time: comidaHora)
        horario.fechaFin = combineDateAndTime(baseDate: horario.fechaFin, time: salidaHora)

        do {
            try context.save() // Intentar guardar los cambios
        } catch {
            print("Error al guardar el horario: \(error)") // Manejar el error
        }
    }
}
