import SwiftUI
import CoreData
import UserNotifications
import FirebaseAuth

// MARK: - CalendarVacationView
// Vista que muestra un calendario de vacaciones.
struct CalendarVacationView: View {
    @Binding var vacations: [Vacation]
    @State private var currentMonth: Date = Date()
    @State private var showingEmployees = false
    @State private var selectedDate: Date? = nil
    @State private var showExportSheet = false
    @State private var pdfData: Data?
    
    private let calendar = Calendar.current
    
    // Días del mes actual.
    var daysInMonth: [Date] {
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        return range.map { calendar.date(byAdding: .day, value: $0 - 1, to: firstDayOfMonth)! }
    }

    var body: some View {
        VStack(spacing: 16) {
            monthHeaderView()
            calendarGridView()
            exportPDFButton()
        }
        .padding(.vertical)
        .sheet(isPresented: $showingEmployees) {
            if let selectedDate = selectedDate {
                EmployeesOnVacationView(date: selectedDate, vacations: vacations)
            }
        }
        .sheet(isPresented: $showExportSheet) {
            if let pdfData = pdfData {
                ActivityView(activityItems: [pdfData])
            }
        }
    }
}

// MARK: - Subviews
extension CalendarVacationView {
    
    // Encabezado del mes con botones de navegación.
    private func monthHeaderView() -> some View {
        HStack {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)!
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Spacer()
            
            Text(monthName(currentMonth))
                .font(.headline)
                .padding(.vertical, 10)
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)!
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
    
    // Cuadrícula del calendario.
    private func calendarGridView() -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            ForEach(daysInMonth, id: \.self) { day in
                dayCellView(day: day)
            }
        }
        .padding(.horizontal)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    // Celda de un día en el calendario.
    private func dayCellView(day: Date) -> some View {
        VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: day))")
                .frame(width: 40, height: 40)
                .background(isVacationDay(day) ? getColorForVacationDay(day) : Color.clear)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .onLongPressGesture {
                    selectedDate = day
                    showingEmployees = true
                }
        }
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
        .padding(4)
    }
    
    // Botón para exportar el calendario como PDF.
    private func exportPDFButton() -> some View {
        Button(action: {
            pdfData = generatePDFFromVacations()
            showExportSheet = true
        }) {
            Text("Compartir PDF")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .cornerRadius(12)
                .padding(.horizontal)
        }
        .disabled(vacations.isEmpty)
    }
}

// MARK: - Helper Functions
extension CalendarVacationView {
    
    // Obtiene el nombre del mes y año.
    private func monthName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    // Verifica si un día es de vacaciones.
    private func isVacationDay(_ day: Date) -> Bool {
        return vacations.contains { vacation in
            guard let startDate = vacation.startDate, let endDate = vacation.endDate else { return false }
            return day >= startDate && day <= endDate
        }
    }
    
    // Obtiene los nombres de los empleados de vacaciones en un día específico.
    private func getEmployeeNamesForDay(_ day: Date) -> String? {
        let employees = vacations.filter { vacation in
            guard let startDate = vacation.startDate, let endDate = vacation.endDate else { return false }
            return day >= startDate && day <= endDate
        }
        .map { $0.employeeName ?? "Sin nombre" }
        
        return employees.joined(separator: ", ")
    }
    
    // Obtiene el color asociado a un día de vacaciones.
    private func getColorForVacationDay(_ day: Date) -> Color {
        if let vacation = vacations.first(where: { day >= $0.startDate! && day <= $0.endDate! }),
           let colorHex = vacation.color,
           let vacationColor = Color(hex1: colorHex) {
            return vacationColor
        }
        return Color.clear
    }
    
    // Genera un PDF con el calendario de vacaciones.
    private func generatePDFFromVacations() -> Data {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))

        let data = pdfRenderer.pdfData { context in
            context.beginPage()
            
            // Fuentes
            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let monthFont = UIFont.boldSystemFont(ofSize: 18)
            let dayFont = UIFont.systemFont(ofSize: 12)
            let vacationFont = UIFont.systemFont(ofSize: 10)

            // Título
            let title = "Calendario de Vacaciones"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.black
            ]
            let titleSize = title.size(withAttributes: titleAttributes)
            let titleRect = CGRect(x: (612 - titleSize.width) / 2, y: 50, width: titleSize.width, height: titleSize.height)
            title.draw(in: titleRect, withAttributes: titleAttributes)

            // Mes y año
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM yyyy"
            let monthYear = dateFormatter.string(from: currentMonth)
            let monthAttributes: [NSAttributedString.Key: Any] = [
                .font: monthFont,
                .foregroundColor: UIColor.black
            ]
            let monthSize = monthYear.size(withAttributes: monthAttributes)
            let monthRect = CGRect(x: (612 - monthSize.width) / 2, y: titleRect.maxY + 20, width: monthSize.width, height: monthSize.height)
            monthYear.draw(in: monthRect, withAttributes: monthAttributes)

            // Días de la semana
            let daysOfWeek = ["Lun", "Mar", "Mie", "Jue", "Vie", "Sab", "Dom"]
            let dayWidth: CGFloat = 70
            let dayHeight: CGFloat = 40
            let padding: CGFloat = 4
            var yOffset: CGFloat = monthRect.maxY + 20
            var xOffset: CGFloat = 50

            // Dibujar los días de la semana
            for day in daysOfWeek {
                let dayRect = CGRect(x: xOffset, y: yOffset, width: dayWidth, height: dayHeight)
                let dayAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 12),
                    .foregroundColor: UIColor.black
                ]
                let dayText = day as NSString
                dayText.draw(in: dayRect, withAttributes: dayAttributes)

                let borderPath = UIBezierPath(rect: dayRect)
                borderPath.stroke()

                xOffset += dayWidth + padding
            }

            yOffset += dayHeight + padding

            // Obtener el primer día del mes y el número de días
            let calendar = Calendar.current
            let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
            let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!
            let totalDays = range.count

            // Obtener el día de la semana del primer día del mes (1 = Domingo, 2 = Lunes, etc.)
            let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
            // Ajustar para que Lunes sea 0, Domingo sea 6
            let firstWeekdayIndex = (firstWeekday + 5) % 7

            // Iniciar el dibujo de los días del mes
            var currentDay = 1
            let totalRows = Int(ceil(Double(totalDays + firstWeekdayIndex) / 7.0))

            for row in 0..<totalRows {
                // Reiniciar el desplazamiento horizontal al inicio de cada fila
                xOffset = 50

                for column in 0..<7 {
                    // Calcular la posición del día
                    let dayRect = CGRect(x: xOffset, y: yOffset, width: dayWidth, height: dayHeight)
                    let borderPath = UIBezierPath(rect: dayRect)
                    borderPath.stroke()

                    // Verificar si el día actual debe ser dibujado
                    if (row == 0 && column >= firstWeekdayIndex) || (row > 0 && currentDay <= totalDays) {
                        // Dibujar el número del día
                        let dayNumberAttributes: [NSAttributedString.Key: Any] = [
                            .font: dayFont,
                            .foregroundColor: UIColor.black
                        ]
                        let dayNumberText = "\(currentDay)" as NSString
                        dayNumberText.draw(in: dayRect, withAttributes: dayNumberAttributes)

                        // Si es un día de vacaciones, dibujar el nombre del empleado
                        let currentDate = calendar.date(byAdding: .day, value: currentDay - 1, to: firstDayOfMonth)!
                        if isVacationDay(currentDate), let employeeNames = getEmployeeNamesForDay(currentDate) {
                            let vacationAttributes: [NSAttributedString.Key: Any] = [
                                .font: vacationFont,
                                .foregroundColor: UIColor.black
                            ]
                            let vacationText = employeeNames as NSString
                            let vacationRect = CGRect(x: xOffset, y: yOffset + 15, width: dayWidth, height: dayHeight - 15)
                            vacationText.draw(in: vacationRect, withAttributes: vacationAttributes)
                        }

                        currentDay += 1
                    }

                    // Mover a la siguiente columna
                    xOffset += dayWidth + padding
                }

                // Mover a la siguiente fila
                yOffset += dayHeight + padding
            }
        }

        return data
    }
}

// MARK: - AgendarVacacionesView
// Vista para agendar vacaciones.
struct AgendarVacacionesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Vacation.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Vacation.startDate, ascending: true)],
        predicate: NSPredicate(format: "userId == %@", Auth.auth().currentUser?.uid ?? "")
    ) var vacations: FetchedResults<Vacation>
    
    @State private var selectedEmployee: String? = nil
    @State private var selectedColor: Color = .black
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    @FetchRequest(
        entity: Horario.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Horario.nombreEmpleado, ascending: true)],
        predicate: NSPredicate(format: "userId == %@", Auth.auth().currentUser?.uid ?? "")
    ) var horarios: FetchedResults<Horario>
    
    var uniqueEmployeeNames: [String] {
        let allNames = horarios.compactMap { $0.nombreEmpleado }
        let uniqueNames = Array(Set(allNames)).sorted()
        return uniqueNames
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Form {
                        Section(header: Text("Colaborador").font(.headline)) {
                            Picker("Seleccionar colaborador", selection: $selectedEmployee) {
                                Text("Seleccione un colaborador").tag(nil as String?)
                                ForEach(uniqueEmployeeNames, id: \.self) { name in
                                    Text(name).tag(name as String?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        Section(header: Text("Color del colaborador").font(.headline)) {
                            ColorPicker("Selecciona un color", selection: $selectedColor)
                        }
                        
                        Section(header: Text("Fechas de vacaciones").font(.headline)) {
                            DatePicker("Fecha de inicio", selection: $startDate, displayedComponents: .date)
                            DatePicker("Fecha de fin", selection: $endDate, in: startDate..., displayedComponents: .date)
                        }
                        
                        Section {
                            Button(action: saveVacation) {
                                Text("Guardar Vacaciones")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        
                        Section(header: Text("Vacaciones programadas").font(.headline)) {
                            List {
                                ForEach(vacations.filter { $0.endDate ?? Date() >= Date() }, id: \.id) { vacation in
                                    VStack(alignment: .leading) {
                                        Text(vacation.employeeName ?? "Sin nombre")
                                            .font(.headline)
                                        Text("Del \(formatDate(vacation.startDate ?? Date())) al \(formatDate(vacation.endDate ?? Date()))")
                                            .font(.subheadline)
                                    }
                                }
                                .onDelete(perform: deleteVacation)
                            }
                            .frame(height: 60)
                        }
                    }
                    .frame(height: 800)
                    
                    CalendarVacationView(vacations: .constant(Array(vacations)))
                        .frame(height: 400)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .navigationTitle("Agendar Vacaciones")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func saveVacation() {
        guard let selectedEmployee = selectedEmployee else {
            print("Por favor, seleccione un colaborador.")
            return
        }

        let existingVacation = vacations.first { vacation in
            vacation.employeeName == selectedEmployee &&
            vacation.startDate == startDate &&
            vacation.endDate == endDate
        }

        if existingVacation != nil {
            print("Ya existe una vacación para este empleado en las mismas fechas.")
            return
        }

        let newVacation = Vacation(context: viewContext)
        newVacation.id = UUID()
        newVacation.employeeName = selectedEmployee
        newVacation.startDate = startDate
        newVacation.endDate = endDate
        newVacation.color = selectedColor.toHex()
        newVacation.userId = Auth.auth().currentUser?.uid

        do {
            try viewContext.save()
            scheduleVacationNotification(employeeName: selectedEmployee, startDate: startDate)
            self.selectedEmployee = nil
            startDate = Date()
            endDate = Date()
        } catch {
            print("Error al guardar: \(error.localizedDescription)")
        }
    }

    private func deleteVacation(at offsets: IndexSet) {
        offsets.forEach { index in
            let vacation = vacations[index]
            viewContext.delete(vacation)
        }
        do {
            try viewContext.save()
        } catch {
            print("Error al eliminar la vacación: \(error.localizedDescription)")
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func scheduleVacationNotification(employeeName: String, startDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Recordatorio de Vacaciones"
        content.body = "\(employeeName), tus vacaciones inician pronto."
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: startDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - ActivityView
// Vista para compartir archivos (PDF).
struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}
