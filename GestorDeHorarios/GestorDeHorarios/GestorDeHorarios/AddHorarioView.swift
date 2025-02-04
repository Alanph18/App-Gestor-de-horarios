//
//  AddHorarioView.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 14/01/25.
import SwiftUI
import CoreData

struct AddHorarioView: View {
   var horario: Horario? // Permitir valores opcionales

   @Environment(\.managedObjectContext) private var viewContext
   @Environment(\.presentationMode) var presentationMode
   
   @State private var nombreEmpleado = ""
   @State private var entradaHora = Date()
   @State private var comidaHora = Date()
   @State private var salidaHora = Date()
   @State private var selectedDates: [Date] = []
   
   private let calendar = Calendar.current

   var body: some View {
       NavigationView {
           VStack {
               Text("Agregar un nuevo Horario")
                   .font(.title)
                   .fontWeight(.bold)
                   .padding(.top, 20)
               
               ScrollView {
                   VStack(alignment: .leading) {
                       TextField("Nombre del empleado", text: $nombreEmpleado)
                           .padding()
                           .background(Color(.systemGray6))
                           .cornerRadius(8)
                           .padding(.horizontal)
                   }
                   
                   VStack(alignment: .leading, spacing: 20) {
                       Text("Selecciona los días:")
                           .font(.headline)
                           .padding(.horizontal)
                       
                       CalendarView3(selectedDates: $selectedDates, highlightedDates: [15, 30])
                           .padding(.horizontal)
                   }
                   
                   VStack(alignment: .leading, spacing: 20) {
                       Text("Selecciona las horas:")
                           .font(.headline)
                           .padding(.horizontal)
                       
                       DatePickerRow(title: "Hora de Entrada", selection: $entradaHora)
                       DatePickerRow(title: "Hora de Comida", selection: $comidaHora)
                       DatePickerRow(title: "Hora de Salida", selection: $salidaHora)
                   }
                   
                   Spacer()
                   
                   Button(action: {
                       saveHorario()
                       presentationMode.wrappedValue.dismiss()
                   }) {
                       Text("Guardar Horario")
                           .font(.headline)
                           .foregroundColor(.white)
                           .padding()
                           .frame(maxWidth: .infinity)
                           .background(nombreEmpleado.isEmpty || selectedDates.isEmpty ? Color.gray : Color.blue)
                           .cornerRadius(12)
                           .padding(.horizontal)
                   }
                   .disabled(nombreEmpleado.isEmpty || selectedDates.isEmpty)
               }
           }
       }
   }
   
   private func saveHorario() {
       guard !nombreEmpleado.isEmpty, !selectedDates.isEmpty else { return }
       
       for date in selectedDates {
           let horario = Horario(context: viewContext)
           horario.id = UUID()
           horario.nombreEmpleado = nombreEmpleado
           horario.fechaInicio = combineDateAndTime(baseDate: date, time: entradaHora)
           horario.fechaComida = combineDateAndTime(baseDate: date, time: comidaHora)
           horario.fechaFin = combineDateAndTime(baseDate: date, time: salidaHora)
           horario.esDiaPico = isDiaPico(date: date)
       }
       
       do {
           try viewContext.save()
           print("Horario guardado correctamente")
       } catch {
           print("Error al guardar: \(error)")
       }
   }
   
   private func combineDateAndTime(baseDate: Date, time: Date) -> Date {
       let calendar = Calendar.current
       let dateComponents = calendar.dateComponents([.year, .month, .day], from: baseDate)
       let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
       return calendar.date(from: DateComponents(
           year: dateComponents.year,
           month: dateComponents.month,
           day: dateComponents.day,
           hour: timeComponents.hour,
           minute: timeComponents.minute
       )) ?? Date()
   }
   
   private func isDiaPico(date: Date) -> Bool {
       let day = calendar.component(.day, from: date)
       return day == 15 || day == 30
   }
}

struct DatePickerRow: View {
   let title: String
   @Binding var selection: Date
   
   var body: some View {
       HStack {
           Text(title)
               .font(.subheadline)
               .foregroundColor(.gray)
               .padding(.horizontal)
           
           DatePicker("", selection: $selection, displayedComponents: .hourAndMinute)
               .labelsHidden()
               .padding()
               .background(Color(.systemGray6))
               .cornerRadius(8)
               .padding(.horizontal)
       }
   }
}

struct CalendarView3: View {
    @Binding var selectedDates: [Date]
    var highlightedDates: [Int]
    private let calendar = Calendar.current
    @State private var currentMonth: Date = Date()

    // Función para obtener los días del mes con la alineación correcta
    private var daysInMonth: [Date?] {
        // Obtener el primer día del mes
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        
        // Obtener el día de la semana para el primer día del mes
        let firstWeekday = calendar.component(.weekday, from: startOfMonth) - 1 // Ajuste para que empiece desde lunes (0 = lunes, 1 = martes, etc.)

        // Calcular la cantidad de días vacíos antes del primer día del mes
        let leadingSpaces = (firstWeekday - calendar.firstWeekday) % 7
        var days: [Date?] = []

        // Agregar los días vacíos (espacios antes del primer día)
        if leadingSpaces > 0 {
            for _ in 0..<leadingSpaces {
                days.append(nil)
            }
        }

        // Agregar los días del mes
        for day in range {
            let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
            days.append(date)
        }

        return days
    }

    var body: some View {
        VStack {
            HStack {
                Button(action: { currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? Date() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .padding()
                }

                Text(monthYearString(for: currentMonth))
                    .font(.headline)
                    .frame(maxWidth: .infinity)

                Button(action: { currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? Date() }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            .padding(.horizontal)

            // Grilla de días de la semana
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(["D", "L", "M", "X", "J", "V", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                }

                // Los días del mes con la alineación correcta
                ForEach(daysInMonth.indices, id: \.self) { index in
                    if let date = daysInMonth[index] { // Solo mostrar días válidos
                        let day = calendar.component(.day, from: date)
                        let isSelected = selectedDates.contains(where: { calendar.isDate($0, inSameDayAs: date) })
                        let isHighlighted = highlightedDates.contains(day)

                        Text("\(day)")
                            .fontWeight(isHighlighted ? .bold : .regular)
                            .foregroundColor(isSelected ? .white : isHighlighted ? .red : .primary)
                            .frame(width: 40, height: 40)
                            .background(isSelected ? Color.blue : isHighlighted ? Color.red.opacity(0.3) : Color.clear)
                            .clipShape(Circle())
                            .onTapGesture {
                                toggleDateSelection(date)
                            }
                            .padding(2)
                    }
                }
            }
            .padding(.top, 10)
        }
        .animation(.easeInOut, value: selectedDates) // Animación suave
    }

    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func toggleDateSelection(_ date: Date) {
        if let index = selectedDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: date) }) {
            selectedDates.remove(at: index)
        } else {
            selectedDates.append(date)
        }
    }
}







