import SwiftUI
import CoreData
import UserNotifications
import FirebaseAuth

// Vista para agregar un nuevo horario.
struct AddHorarioView: View {
    var horario: Horario? = nil
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var nombreEmpleado = ""
    @State private var entradaHora = Date()
    @State private var comidaHora = Date()
    @State private var salidaHora = Date()
    @State private var selectedDates: [Date] = []
    @FetchRequest private var horarios: FetchedResults<Horario>

    // MARK: - Initializer
    init() {
        let userId = Auth.auth().currentUser?.uid ?? ""
        let request: NSFetchRequest<Horario> = Horario.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Horario.nombreEmpleado, ascending: true)]
        
        _horarios = FetchRequest(fetchRequest: request)
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Encabezado
                headerSection
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
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Sección: Seleccionar colaborador
                        colaboradorSection
                        
                        // Sección: Selecciona los días
                        diasSection
                        
                        // Sección: Selecciona las horas
                        horasSection
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                // Botón de guardar
                saveButton
            }
            .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
            .navigationTitle("Agendar Horario")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                requestNotificationPermission()
            }
        }
    }
    
    // MARK: - Subviews
    
    // Encabezado de la vista.
    private var headerSection: some View {
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
    }
    
    // Sección para seleccionar el colaborador.
    private var colaboradorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Colaborador")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(width: 100, alignment: .leading)
              
                Picker("Seleccionar colaborador", selection: $nombreEmpleado) {
                    Text("Seleccionar colaborador").tag("")
                    ForEach(uniqueEmployeeNames, id: \.self) { name in
                        Text(name)
                            .tag(name)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .frame(width: 200, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    // Sección para seleccionar los días.
    private var diasSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Selecciona los días")
                .font(.headline)
                .foregroundColor(.primary)
            
            CustomCalendarView(selectedDates: $selectedDates)
        }
    }
    
    // Sección para seleccionar las horas.
    private var horasSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Selecciona las horas")
                .font(.headline)
                .foregroundColor(.primary)
            
            DatePickerRow(title: "Hora de Entrada", selection: $entradaHora)
            Divider()
            DatePickerRow(title: "Hora de Comida", selection: $comidaHora)
            Divider()
            DatePickerRow(title: "Hora de Salida", selection: $salidaHora)
        }
    }
    
    // Botón para guardar el horario.
    private var saveButton: some View {
        Button(action: {
            saveHorario()
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Guardar Horario")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(nombreEmpleado.isEmpty || selectedDates.isEmpty ? Color.gray : Color.black)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .disabled(nombreEmpleado.isEmpty || selectedDates.isEmpty)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    // Lista de nombres únicos de colaboradores.
    private var uniqueEmployeeNames: [String] {
        let allNames = horarios.compactMap { $0.nombreEmpleado }
        return Array(Set(allNames)).sorted()
    }
    
    // MARK: - Helper Functions
    
  
    // Guarda el horario en Core Data.
    private func saveHorario() {
        guard !nombreEmpleado.isEmpty, !selectedDates.isEmpty else { return }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: No hay usuario autenticado.")
            return
        }
        
        for date in selectedDates {
            let newHorario = Horario(context: viewContext)
            newHorario.id = UUID()
            newHorario.nombreEmpleado = nombreEmpleado
            newHorario.fechaInicio = combineDateAndTime(baseDate: date, time: entradaHora)
            newHorario.fechaComida = combineDateAndTime(baseDate: date, time: comidaHora)
            newHorario.fechaFin = combineDateAndTime(baseDate: date, time: salidaHora)
            newHorario.userId = userId
        }
        
        do {
            try viewContext.save()
            showNotification()
            print("Horarios guardados correctamente y notificaciones programadas.")
        } catch {
            print("Error al guardar: \(error)")
        }
    }
    
    // Combina una fecha base con una hora específica.
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
    
    // Solicita permiso para notificaciones.
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Permiso para notificaciones concedido.")
            } else if let error = error {
                print("Error al solicitar permiso para notificaciones: \(error)")
            }
        }
    }
    
    // Muestra una notificación cuando se guarda el horario.
    private func showNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Horario registrado con éxito"
        content.body = "El horario de \(nombreEmpleado) se ha guardado correctamente."
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
