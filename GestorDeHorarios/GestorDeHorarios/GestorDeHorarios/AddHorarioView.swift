import SwiftUI
import CoreData
import UserNotifications



struct CustomCalendarView: View {
    @Binding var selectedDates: [Date]
    @State private var currentMonth = Date()
    private let calendar = Calendar.current
    
    var body: some View {
        VStack {
            // Encabezado del calendario (mes y año)
            HStack {
                Button(action: { currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? Date() }) {
                    Image(systemName: "chevron.left").foregroundColor(.blue)
                }
                
                Text(monthYearString(for: currentMonth))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                
                Button(action: { currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? Date() }) {
                    Image(systemName: "chevron.right").foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Días de la semana
            let days = generateDays()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(["L", "M", "X", "J", "V", "S", "D"], id: \.self) { day in
                    Text(day).font(.caption).foregroundColor(.gray)
                }
                
                // Días del mes
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        let isSelected = selectedDates.contains { calendar.isDate($0, inSameDayAs: date) }
                        Text("\(calendar.component(.day, from: date))")
                            .foregroundColor(isSelected ? .white : .primary)
                            .frame(width: 35, height: 35)
                            .background(isSelected ? Color.blue : Color.clear)
                            .clipShape(Circle())
                            .onTapGesture { toggleSelection(date) }
                    } else {
                        Text(" ").frame(width: 35, height: 35)
                    }
                }
            }
        }
    }
    
    // Genera los días del mes
    private func generateDays() -> [Date?] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let offset = (firstWeekday + 5) % 7
        
        var days = Array(repeating: nil as Date?, count: offset)
        days.append(contentsOf: range.map { calendar.date(byAdding: .day, value: $0 - 1, to: startOfMonth)! })
        return days
    }
    
    // Formatea el mes y año
    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    // Selecciona o deselecciona un día
    private func toggleSelection(_ date: Date) {
        if let index = selectedDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: date) }) {
            selectedDates.remove(at: index)
        } else {
            selectedDates.append(date)
        }
    }
}
struct DatePickerRow: View {
    let title: String
    @Binding var selection: Date
    
    var body: some View {
        HStack {
            Text(title).font(.subheadline).foregroundColor(.gray)
            DatePicker("", selection: $selection, displayedComponents: .hourAndMinute)
                .labelsHidden()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct AddHorarioView: View {
    var horario: Horario?
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var nombreEmpleado = ""
    @State private var entradaHora = Date()
    @State private var comidaHora = Date()
    @State private var salidaHora = Date()
    @State private var selectedDates: [Date] = []
    
    // Estado para el colaborador seleccionado
    @State private var selectedEmployee: Horario?
    
    // Lista de colaboradores (horarios)
    @FetchRequest(
        entity: Horario.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Horario.nombreEmpleado, ascending: true)]
    ) var horarios: FetchedResults<Horario>
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Encabezado
                VStack(alignment: .leading, spacing: 8) {
                    Text("Agregar Horario")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Crea un nuevo horario para un colaborador.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
                .background(Color(.systemBackground))

                ScrollView {
                    VStack(spacing: 25) {
                        // Sección: Seleccionar colaborador
                        Section(header: Text("Colaborador").font(.headline)) {
                            Picker("Seleccionar colaborador", selection: $selectedEmployee) {
                                ForEach(horarios, id: \.self) { horario in
                                    Text(horario.nombreEmpleado ?? "Sin nombre")
                                        .tag(horario as Horario?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        
                        // Sección: Selecciona los días
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Selecciona los días")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            CustomCalendarView(selectedDates: $selectedDates)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        
                        // Sección: Selecciona las horas
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Selecciona las horas")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Divider()
                            DatePickerRow(title: "Hora de Entrada", selection: $entradaHora)
                            Divider()
                            DatePickerRow(title: "Hora de Comida", selection: $comidaHora)
                            Divider()
                            DatePickerRow(title: "Hora de Salida", selection: $salidaHora)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 10)
                    .padding(.top, 20)
                }

                // Botón de guardar
                Button(action: {
                    saveHorario()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Guardar Horario")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedEmployee == nil || selectedDates.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                        .shadow(color: Color.blue.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .disabled(selectedEmployee == nil || selectedDates.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
            .navigationTitle("Agendar Horario")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                requestNotificationPermission()
            }
        }
    }
    
    private func saveHorario() {
        // Verifica que se haya seleccionado un colaborador y al menos una fecha
        guard let selectedEmployee = selectedEmployee, !selectedDates.isEmpty else { return }
        
        // Crea un nuevo horario para cada fecha seleccionada
        for date in selectedDates {
            let newHorario = Horario(context: viewContext)
            newHorario.id = UUID()
            newHorario.nombreEmpleado = selectedEmployee.nombreEmpleado // Asigna el nombre del empleado seleccionado
            newHorario.fechaInicio = combineDateAndTime(baseDate: date, time: entradaHora)
            newHorario.fechaComida = combineDateAndTime(baseDate: date, time: comidaHora)
            newHorario.fechaFin = combineDateAndTime(baseDate: date, time: salidaHora)
        }
        
        // Guarda los cambios en Core Data
        do {
            try viewContext.save()
            showNotification() // Muestra la notificación
            print("Horarios guardados correctamente y notificaciones programadas.")
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

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Permiso para notificaciones concedido.")
            } else if let error = error {
                print("Error al solicitar permiso para notificaciones: \(error)")
            }
        }
    }

    private func showNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Horario registrado con éxito"
        content.body = "El horario de \(selectedEmployee?.nombreEmpleado ?? "colaborador") se ha guardado correctamente."
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error al mostrar la notificación: \(error)")
            } else {
                print("Notificación mostrada correctamente.")
            }
        }
    }
}
