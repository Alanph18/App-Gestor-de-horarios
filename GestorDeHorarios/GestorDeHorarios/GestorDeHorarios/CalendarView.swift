//
//  CalendarView.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 14/01/25.
import SwiftUI
import CoreData

struct CalendarView: View {
    @State private var selectedDates: Set<Date> = []
    @State private var vacations: [Date: [String: Color]] = [:]
    @State private var collaboratorName: String = ""
    @State private var collaboratorColor: Color = .pink
    var horarios: FetchedResults<Horario>

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Nombre del colaborador
                collaboratorNameField

                // Selector de color
                colorPicker

                // Calendario gráfico con fechas resaltadas
                calendarPicker

                // Fechas seleccionadas
                selectedDatesView

                // Lista de colaboradores con sus días de vacaciones
                vacationList(for: selectedDates)

                // Botón para guardar las vacaciones
                saveButton
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(15)
            .navigationTitle("Calendario de Vacaciones")
        }
    }

    // Campo para el nombre del colaborador
    private var collaboratorNameField: some View {
        TextField("Nombre del colaborador", text: $collaboratorName)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
    }

    // Selector de color
    private var colorPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Seleccionar color")
                .font(.subheadline)

            Picker("Seleccionar color", selection: $collaboratorColor) {
                Text("Rosa").tag(Color.pink)
                Text("Verde").tag(Color.green)
                Text("Azul").tag(Color.blue)
                Text("Amarillo").tag(Color.yellow)
                Text("Lavanda").tag(Color.purple)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom)
        }
    }

    // Calendario gráfico con fechas resaltadas
    private var calendarPicker: some View {
        ZStack {
            DatePicker(
                "Selecciona las fechas de vacaciones",
                selection: Binding(
                    get: { selectedDates.first ?? Date() },
                    set: { toggleSelection(for: $0) }
                ),
                displayedComponents: [.date]
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .padding()
            .accentColor(.blue)

            // Añadir los círculos para las fechas seleccionadas
            ForEach(selectedDates.sorted(), id: \.self) { date in
                GeometryReader { geometry in
                    Circle()
                        .fill(Color.blue.opacity(0.4))
                        .frame(width: 20, height: 20)
                        .position(x: getPositionForDate(date, in: geometry.size).x,
                                  y: getPositionForDate(date, in: geometry.size).y)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // Calcula la posición de cada fecha en el calendario
    private func getPositionForDate(_ date: Date, in size: CGSize) -> CGPoint {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date)
        
        // Ajusta la posición de acuerdo con el día y la semana
        let xPos = CGFloat(components.day ?? 0) * (size.width / 7)
        let yPos = size.height / 2 // Ajusta esto dependiendo de cómo quieras la posición vertical
        
        return CGPoint(x: xPos, y: yPos)
    }

    // Mostrar las fechas seleccionadas de manera amigable
    private var selectedDatesView: some View {
        Group {
            if !selectedDates.isEmpty {
                Text("Fechas seleccionadas:")
                    .font(.headline)
                    .padding(.top)

                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(selectedDates.sorted(), id: \.self) { date in
                            Text(formatDate(date))
                                .font(.subheadline)
                                .padding(8)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }

    // Función para mostrar la lista de colaboradores con sus fechas de vacaciones
    private func vacationList(for selectedDates: Set<Date>) -> some View {
        var collaborators: [String] = []

        for date in selectedDates {
            if let assigned = vacations[date] {
                collaborators.append(contentsOf: assigned.keys)
            }
        }

        if collaborators.isEmpty {
            return AnyView(Text("No hay vacaciones para estas fechas.")
                            .foregroundColor(.gray)
                            .padding())
        } else {
            return AnyView(
                List(collaborators, id: \.self) { collaborator in
                    HStack {
                        Text(collaborator)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 5)
                }
                .listStyle(PlainListStyle())
            )
        }
    }

    // Función para seleccionar o deseleccionar fechas
    private func toggleSelection(for date: Date) {
        if selectedDates.contains(date) {
            selectedDates.remove(date)
        } else {
            selectedDates.insert(date)
        }
    }

    // Formato de la fecha
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }

    // Botón para guardar las vacaciones
    private var saveButton: some View {
        Button(action: saveVacation) {
            HStack {
                Spacer()
                Text("Guardar")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
        .padding()
    }

    // Función para guardar las vacaciones y reiniciar la selección
    private func saveVacation() {
        guard !collaboratorName.isEmpty else { return }

        for date in selectedDates {
            if vacations[date] != nil {
                vacations[date]?[collaboratorName] = collaboratorColor
            } else {
                vacations[date] = [collaboratorName: collaboratorColor]
            }
        }

        // Limpiar campos después de guardar
        collaboratorName = ""
        selectedDates.removeAll() // Reinicia las fechas seleccionadas
    }
}
