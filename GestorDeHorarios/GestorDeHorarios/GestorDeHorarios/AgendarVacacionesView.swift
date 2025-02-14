import SwiftUI
import CoreData
import UserNotifications

// MARK: - CalendarVacationView


struct CalendarVacationView: View {
    @Binding var vacations: [Vacation]
    @State private var currentMonth: Date = Date()
    @State private var showingEmployees = false
    @State private var selectedDate: Date? = nil
    @State private var showExportSheet = false
    @State private var pdfData: Data?
    
    let calendar = Calendar.current
    
    var daysInMonth: [Date] {
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        return range.map { calendar.date(byAdding: .day, value: $0 - 1, to: firstDayOfMonth)! }
    }

    var body: some View {
       
            VStack(spacing: 16) {
                // Encabezado del mes
                monthHeaderView()
                
                // Grid de días del mes
                calendarGridView()
                
                // Botón para exportar PDF
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
    
    // MARK: - Subviews
    
    private func monthHeaderView() -> some View {
        HStack {
            Button(action: {
                currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)!
            }) {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Spacer()
            
            Text(monthName(currentMonth))
                .font(.headline)
                .padding(.vertical, 10)
            
            Spacer()
            
            Button(action: {
                currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)!
            }) {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
    
    private func calendarGridView() -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            ForEach(daysInMonth, id: \.self) { day in
                dayCellView(day: day)
            }
        }
        .padding(.horizontal)
    }
    
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
            
            if let employeeNames = getEmployeeNamesForDay(day) {
                Text(employeeNames)
                    .font(.caption2)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .padding(2)
                    
                    .cornerRadius(4)
            }
        }
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
    
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
    
    // MARK: - Helper Functions
    
    private func monthName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func isVacationDay(_ day: Date) -> Bool {
        return vacations.contains { vacation in
            guard let startDate = vacation.startDate, let endDate = vacation.endDate else { return false }
            return day >= startDate && day <= endDate
        }
    }
    
    private func getEmployeeNamesForDay(_ day: Date) -> String? {
        let employees = vacations.filter { vacation in
            guard let startDate = vacation.startDate, let endDate = vacation.endDate else { return false }
            return day >= startDate && day <= endDate
        }
        .map { $0.employeeName ?? "Sin nombre" }
        
        return employees.joined(separator: ", ")
    }
    
    private func getColorForVacationDay(_ day: Date) -> Color {
        if let vacation = vacations.first(where: { day >= $0.startDate! && day <= $0.endDate! }),
           let colorHex = vacation.color {
            return Color(hex1: colorHex)
        }
        return Color.clear
    }
    
    private func generatePDFFromVacations() -> Data {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        
        let data = pdfRenderer.pdfData { context in
            context.beginPage()
            
            let title = "Calendario de Vacaciones"
            let titleAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)]
            let titleSize = title.size(withAttributes: titleAttributes)
            let titleRect = CGRect(x: (612 - titleSize.width) / 2, y: 50, width: titleSize.width, height: titleSize.height)
            title.draw(in: titleRect, withAttributes: titleAttributes)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM yyyy"
            
            var yOffset: CGFloat = 100
            let monthYear = dateFormatter.string(from: currentMonth)
            let monthYearAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
            let monthYearSize = monthYear.size(withAttributes: monthYearAttributes)
            let monthYearRect = CGRect(x: (612 - monthYearSize.width) / 2, y: yOffset, width: monthYearSize.width, height: monthYearSize.height)
            monthYear.draw(in: monthYearRect, withAttributes: monthYearAttributes)
            
            yOffset += monthYearSize.height + 20
            
            let daysOfWeek = ["Lun", "Mar", "Mie", "Jue", "Vie", "Sab", "Dom"]
            let dayWidth: CGFloat = 80
            let dayHeight: CGFloat = 50
            let padding: CGFloat = 5
            
            var xOffset: CGFloat = 50
            
            for day in daysOfWeek {
                let dayRect = CGRect(x: xOffset, y: yOffset, width: dayWidth, height: dayHeight)
                let dayAttributes = [
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14),
                    NSAttributedString.Key.foregroundColor: UIColor.black
                ]
                let dayText = day as NSString
                dayText.draw(in: dayRect, withAttributes: dayAttributes)
                xOffset += dayWidth + padding
            }
            
            yOffset += dayHeight + padding
            
            let daysInMonth = self.daysInMonth
            let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
            let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
            
            // Ajuste del offset para que los días de la semana se alineen correctamente
            let offset = (firstWeekday - calendar.firstWeekday + 7) % 7
            
            xOffset = 50 + CGFloat(offset) * (dayWidth + padding)
            
            for day in daysInMonth {
                let dayNumber = calendar.component(.day, from: day)
                let dayRect = CGRect(x: xOffset, y: yOffset, width: dayWidth, height: dayHeight)
                
                let dayNumberAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
                let dayNumberText = "\(dayNumber)" as NSString
                dayNumberText.draw(in: dayRect, withAttributes: dayNumberAttributes)
                
                if isVacationDay(day), let employeeNames = getEmployeeNamesForDay(day) {
                    let vacationAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10)]
                    let vacationText = employeeNames as NSString
                    let vacationRect = CGRect(x: xOffset, y: yOffset + 15, width: dayWidth, height: dayHeight - 15)
                    vacationText.draw(in: vacationRect, withAttributes: vacationAttributes)
                }
                
                xOffset += dayWidth + padding
                
                if xOffset > 612 - dayWidth {
                    xOffset = 50
                    yOffset += dayHeight + padding
                }
            }
        }
        
        return data
    }
}
// MARK: - AgendarVacacionesView

struct AgendarVacacionesView: View {
   @Environment(\.managedObjectContext) private var viewContext
   
   @FetchRequest(
          entity: Vacation.entity(),
          sortDescriptors: [NSSortDescriptor(keyPath: \Vacation.startDate, ascending: true)]
      ) var vacations: FetchedResults<Vacation>
   
   @State private var selectedEmployee: Horario?
   @State private var selectedColor: Color = .mint
   @State private var startDate = Date()
   @State private var endDate = Date()
   
   @FetchRequest(
        entity: Horario.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Horario.nombreEmpleado, ascending: true)]
    ) var horarios: FetchedResults<Horario>
   
   var body: some View {
       NavigationView {
           ScrollView {
               VStack(spacing: 16) {
                   // Formulario para agendar vacaciones
                   Form {
                       Section(header: Text("Colaborador").font(.headline)) {
                           Picker("Seleccionar colaborador", selection: $selectedEmployee) {
                               ForEach(horarios, id: \.self) { horario in
                                   Text(horario.nombreEmpleado ?? "Sin nombre")
                                       .tag(horario as Horario?)
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
                       // Calendario de vacaciones
                       
                   }
                   .frame(height:800)
                   
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
   
   // MARK: - Helper Functions
   
   private func saveVacation() {
       guard let selectedEmployee = selectedEmployee else { return }
       
       let newVacation = Vacation(context: viewContext)
       newVacation.id = UUID()
       newVacation.employeeName = selectedEmployee.nombreEmpleado
       newVacation.startDate = startDate
       newVacation.endDate = endDate
       newVacation.color = selectedColor.toHex()
       
       do {
           try viewContext.save()
           scheduleVacationNotification(employeeName: selectedEmployee.nombreEmpleado ?? "Sin nombre", startDate: startDate)
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
       try? viewContext.save()
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

struct ActivityView: UIViewControllerRepresentable {
   var activityItems: [Any]
   var applicationActivities: [UIActivity]? = nil
   
   func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
       let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
       return controller
   }
   
   func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}
