import SwiftUI
import CoreData
import FirebaseAuth
import PDFKit
import UIKit

struct ContentView: View {
    @StateObject var authenticationViewModel: AuthenticationViewModel
    @Environment(\.managedObjectContext) private var viewContext

    @State private var selectedDate = Date()
    @State private var showingAddHorario = false
    @State private var showingEditHorario = false
    @State private var showingMonthlyCalendar = false
    @State private var selectedHorario: Horario? = nil
    @State private var showingAdministracionColaboradores = false
    @State private var showingLogoutConfirmation = false
    @State private var showingDeleteConfirmation = false
    @State private var horarioToDelete: Horario? = nil
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Horario.fechaInicio, ascending: true)]
    ) var horarios: FetchedResults<Horario>
    
    // MARK: - Body
    private func horariosFiltradosPorUsuario() -> [Horario] {
        guard let userId = Auth.auth().currentUser?.uid else { return [] }
        return horarios.filter { $0.userId == userId }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 16) {
                userInfoSection
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
                titleSection
                dateSection
                calendarSection
                horariosList
                vacacionesButton
                administracionColaboradoresButton
            }
            
            // Botones flotantes en la esquina inferior derecha
            HStack {
                Spacer()
                VStack {
                    // Botón de generar PDF
                    Button(action: {
                        let pdfURL = generatePDF()
                        let activityVC = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
                        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
                    }) {
                        Image(systemName: "doc.text.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding(.bottom, 10) // Ajusta este valor para mover el botón más arriba
                    
                    // Botón de añadir horario
                    addHorarioButton
                        .padding(.bottom, 126) // Mantén este padding para el botón de añadir horario
                }
                .padding(.trailing, 26)
            }
        }
        .sheet(isPresented: $showingEditHorario) {
            if let selectedHorario {
                EditHorarioView(horario: selectedHorario)
            }
        }
        .sheet(isPresented: $showingAddHorario) {
            AddHorarioView()
        }
        .sheet(isPresented: $showingMonthlyCalendar) {
            AgendarVacacionesView().environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $showingAdministracionColaboradores) {
            AdministracionColaboradoresView().environment(\.managedObjectContext, viewContext)
        }
    }
    
    // MARK: - User Info Section
    private var userInfoSection: some View {
        HStack {
            if let user = Auth.auth().currentUser {
                if let photoURL = user.photoURL {
                    AsyncImage(url: photoURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [.purple, .blue, .green]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 0)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.black)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.purple, .blue, .green]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: .purple.opacity(0.2), radius: 1, x: 0, y: 0)
                }
                
                Text(user.email ?? "Correo no disponible")
                    .font(.subheadline)
                    .foregroundColor(.gray.opacity(0.8))
                Spacer()
                logoutButton
            }
        }
        .padding(.horizontal, 10)
    }

    // Logout Button
    private var logoutButton: some View {
        Button("Salir") {
            showingLogoutConfirmation = true
        }
        .font(.system(size: 16, weight: .semibold))
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black)
        .cornerRadius(8)
        .alert("¿Estás seguro de que quieres salir?", isPresented: $showingLogoutConfirmation) {
            Button("Cancelar", role: .cancel) { }
            Button("Salir", role: .destructive) {
                authenticationViewModel.logout()
            }
        }
    }

    // MARK: - Title Section
    private var titleSection: some View {
        Text("Gestor de horarios")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding(.top, 1)
    }
    
    // Date Section
    private var dateSection: some View {
        Text(fechaActual())
            .font(.subheadline)
            .foregroundColor(.gray.opacity(0.8))
    }
    
    // MARK: - Calendar Section
    private var calendarSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(generateDatesForWeek(), id: \.self) { date in
                    VStack(spacing: 4) {
                        Text(shortWeekday(from: date))
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text(dayOfMonth(from: date))
                            .font(.body)
                            .fontWeight(selectedDate == date ? .bold : .regular)
                            .foregroundColor(selectedDate == date ? .white : .black)
                            .frame(width: 42, height: 42)
                            .background(selectedDate == date ? Color.black : Color.clear)
                            .cornerRadius(10)
                            .padding(.bottom, 10)
                            .overlay(
                                isToday(date) ? Capsule()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [.black, .black, .black]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .frame(width: 22, height: 8)
                                    .offset(y: 9) : nil
                            )
                            .onTapGesture {
                                withAnimation {
                                    selectedDate = date
                                }
                            }
                    }
                }
            }
        }
    }

    // MARK: - Horarios List
    private var horariosList: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    if horariosFiltradosPorFecha().isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "calendar")
                                .font(.system(size: 40, weight: .light))
                                .foregroundColor(.gray.opacity(0.6))
                            
                            Text("No hay registros para este día.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 50)
                    } else {
                        ForEach(horariosFiltradosPorFecha(), id: \Horario.self) { horario in
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(horario.nombreEmpleado ?? "Sin nombre")
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    HStack(spacing: 30) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Entrada:")
                                                .font(.caption2)
                                            Text(formattedTime(horario.fechaInicio))
                                                .font(.caption2)
                                                .foregroundColor(.black)
                                        }
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Comida:")
                                                .font(.caption2)
                                            Text(formattedTime(horario.fechaComida))
                                                .font(.caption2)
                                                .foregroundColor(.black)
                                        }
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Salida:")
                                                .font(.caption2)
                                            Text(formattedTime(horario.fechaFin))
                                                .font(.caption2)
                                                .foregroundColor(.black)
                                        }
                                    }
                                    Divider()
                                        .frame(height: 1)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.purple, .blue, .green]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                }
                                
                                VStack {
                                    Menu {
                                        Button(action: {
                                            selectedHorario = horario
                                            showingEditHorario = true
                                        }) {
                                            Text("Editar")
                                            Image(systemName: "pencil")
                                        }
                                        
                                        Button(action: {
                                            deleteHorario(horario)
                                        }) {
                                            Text("Eliminar")
                                            Image(systemName: "trash")
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis.circle")
                                            .foregroundColor(.gray)
                                            .font(.title2)
                                    }
                                }
                            }
                            .padding(16)
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .alert("¿Estás seguro de que quieres eliminar este horario?", isPresented: $showingDeleteConfirmation) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                confirmDeleteHorario()
            }
        }
    }
    
    // Add Horario Button
    private var addHorarioButton: some View {
        Button(action: {
            showingAddHorario = true
        }) {
            Image(systemName: "plus")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.white)
                .padding()
                .background(Color.black)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }

    // Vacaciones Button
    private var vacacionesButton: some View {
        Button(action: {
            showingMonthlyCalendar = true
        }) {
            Text("Vacaciones")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(width: 350, height: 50)
                .background(Color.black)
                .cornerRadius(10)
        }
        .background(.black)
        .cornerRadius(15)
    }
    
    // Administración Colaboradores Button
    private var administracionColaboradoresButton: some View {
        Button(action: {
            showingAdministracionColaboradores = true
        }) {
            Text("Administración de Colaboradores")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(width: 350, height: 50)
                .background(Color.black)
                .cornerRadius(10)
        }
        .background(.black)
        .cornerRadius(15)
    }
    
    // MARK: - Helper Functions
    private func generateDatesForWeek() -> [Date] {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.dateInterval(of: .weekOfMonth, for: Date())?.start else {
            return []
        }
        return (0..<15).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    private func isToday(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(date)
    }
    
    private func horariosFiltradosPorUsuario2() -> [Horario] {
        guard let userId = Auth.auth().currentUser?.uid else { return [] }
        return CoreDataManager.shared.fetchHorarios(for: userId)
    }

    private func horariosFiltradosPorFecha() -> [Horario] {
        let calendar = Calendar.current
        return horariosFiltradosPorUsuario().filter { horario in
            guard let fechaInicio = horario.fechaInicio else { return false }
            return calendar.isDate(fechaInicio, inSameDayAs: selectedDate)
        }
    }
    
    private func formattedTime(_ date: Date?) -> String {
        guard let date = date else { return "Sin hora" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a" // Formato de 12 horas con AM/PM
        formatter.locale = Locale(identifier: "es_ES") // Asegura que el formato sea en español
        return formatter.string(from: date)
    }
    
    private func shortWeekday(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
    
    private func fechaActual() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "EEEE, d 'de' MMMM 'de' yyyy"
        return formatter.string(from: Date()).capitalized
    }
    
    private func dayOfMonth(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Horario.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try PersistenceController.shared.container.viewContext.execute(deleteRequest)
            
            print("Sesión cerrada y datos locales eliminados.")
        } catch {
            print("Error al cerrar sesión: \(error.localizedDescription)")
        }
    }
    
    private func deleteHorario(_ horario: Horario) {
        horarioToDelete = horario
        showingDeleteConfirmation = true
    }

    private func confirmDeleteHorario() {
        guard let horario = horarioToDelete else { return }
        let context = PersistenceController.shared.container.viewContext
        context.delete(horario)
        do {
            try context.save()
        } catch {
            print("Error al eliminar el horario: \(error)")
        }
        horarioToDelete = nil
    }

    // MARK: - PDF Generation
    private func generatePDF() -> URL {
        let pdfMetaData = [
            kCGPDFContextCreator: "Gestor de Horarios",
            kCGPDFContextAuthor: "Tu App",
            kCGPDFContextTitle: "Horarios Semanales"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            // Título del PDF
            let titleAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
            let titleText = "Horarios de la Semana"
            let titleSize = titleText.size(withAttributes: titleAttributes)
            let titleRect = CGRect(
                x: (pageWidth - titleSize.width) / 2, // Centrar el título
                y: 30,
                width: titleSize.width,
                height: titleSize.height
            )
            titleText.draw(in: titleRect, withAttributes: titleAttributes)
            
            // Configuración de la tabla
            let calendar = Calendar.current
            let daysOfWeek = ["Nombre", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
            let columnWidth: CGFloat = 70 // Ancho de cada columna
            let rowHeight: CGFloat = 25 // Alto de cada fila
            let tableWidth = columnWidth * CGFloat(daysOfWeek.count) // Ancho total de la tabla
            let tableXPosition = (pageWidth - tableWidth) / 2 // Centrar la tabla
            var xPosition = tableXPosition
            var yPosition: CGFloat = 70 // Margen superior
            
            // Dibujar los encabezados de la tabla (Nombre y días de la semana)
            for (index, day) in daysOfWeek.enumerated() {
                let headerAttributes = [
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12),
                    NSAttributedString.Key.foregroundColor: UIColor.black
                ]
                let headerText = day
                let textRect = CGRect(x: xPosition, y: yPosition, width: columnWidth, height: rowHeight)
                headerText.draw(in: textRect, withAttributes: headerAttributes)
                
                // Dibujar líneas verticales para la cuadrícula
                context.cgContext.move(to: CGPoint(x: xPosition, y: yPosition))
                context.cgContext.addLine(to: CGPoint(x: xPosition, y: yPosition + rowHeight))
                context.cgContext.strokePath()
                
                xPosition += columnWidth
            }
            
            // Dibujar línea horizontal debajo de los encabezados
            context.cgContext.move(to: CGPoint(x: tableXPosition, y: yPosition + rowHeight))
            context.cgContext.addLine(to: CGPoint(x: tableXPosition + tableWidth, y: yPosition + rowHeight))
            context.cgContext.strokePath()
            
            yPosition += rowHeight
            
            // Agrupar horarios por colaborador
            let horariosPorUsuario = horariosFiltradosPorUsuario()
            var horariosAgrupados: [String: [Horario]] = [:]
            
            for horario in horariosPorUsuario {
                let nombre = horario.nombreEmpleado ?? "Sin nombre"
                if horariosAgrupados[nombre] == nil {
                    horariosAgrupados[nombre] = []
                }
                horariosAgrupados[nombre]?.append(horario)
            }
            
            // Dibujar los nombres y horarios en las filas siguientes
            for (nombre, horarios) in horariosAgrupados {
                xPosition = tableXPosition
                
                // Dibujar el nombre del empleado en la columna "Nombre"
                let nombreAttributes = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10),
                    NSAttributedString.Key.foregroundColor: UIColor.darkGray
                ]
                let nombreText = nombre
                let nombreRect = CGRect(x: xPosition, y: yPosition, width: columnWidth, height: rowHeight)
                nombreText.draw(in: nombreRect, withAttributes: nombreAttributes)
                
                // Dibujar línea vertical después del nombre
                context.cgContext.move(to: CGPoint(x: xPosition + columnWidth, y: yPosition))
                context.cgContext.addLine(to: CGPoint(x: xPosition + columnWidth, y: yPosition + rowHeight * 3))
                context.cgContext.strokePath()
                
                xPosition += columnWidth
                
                // Dibujar los horarios para cada día de la semana
                for (index, day) in daysOfWeek.dropFirst().enumerated() {
                    // Ajustar el índice para que coincida con el valor de `calendar.component(.weekday, from:)`
                    let weekdayIndex = index + 2 // Lunes = 2, Martes = 3, ..., Domingo = 1
                    
                    // Si es domingo, usar 1 en lugar de 8
                    let adjustedWeekdayIndex = (weekdayIndex == 8) ? 1 : weekdayIndex
                    
                    let horarioForDay = horarios.first { horario in
                        guard let fechaInicio = horario.fechaInicio else { return false }
                        return calendar.component(.weekday, from: fechaInicio) == adjustedWeekdayIndex
                    }
                    
                    if let horario = horarioForDay {
                        let entradaText = "Entrada: \(formattedTime(horario.fechaInicio))"
                        let comidaText = "Comida: \(formattedTime(horario.fechaComida))"
                        let salidaText = "Salida: \(formattedTime(horario.fechaFin))"
                        
                        let horarioText = "\(entradaText)\n\(comidaText)\n\(salidaText)"
                        let horarioAttributes = [
                            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 8),
                            NSAttributedString.Key.foregroundColor: UIColor.darkGray
                        ]
                        let horarioRect = CGRect(x: xPosition, y: yPosition, width: columnWidth, height: rowHeight * 3)
                        horarioText.draw(in: horarioRect, withAttributes: horarioAttributes)
                    } else {
                        let descansoText = "Descanso"
                        let descansoAttributes = [
                            NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 8),
                            NSAttributedString.Key.foregroundColor: UIColor.gray
                        ]
                        let descansoRect = CGRect(x: xPosition, y: yPosition, width: columnWidth, height: rowHeight)
                        descansoText.draw(in: descansoRect, withAttributes: descansoAttributes)
                    }
                    
                    // Dibujar línea vertical después de cada día
                    context.cgContext.move(to: CGPoint(x: xPosition + columnWidth, y: yPosition))
                    context.cgContext.addLine(to: CGPoint(x: xPosition + columnWidth, y: yPosition + rowHeight * 3))
                    context.cgContext.strokePath()
                    
                    xPosition += columnWidth
                }
                
                // Dibujar línea horizontal después de cada fila
                context.cgContext.move(to: CGPoint(x: tableXPosition, y: yPosition + rowHeight * 3))
                context.cgContext.addLine(to: CGPoint(x: tableXPosition + tableWidth, y: yPosition + rowHeight * 3))
                context.cgContext.strokePath()
                
                yPosition += rowHeight * 3 // Ajustar el espacio para los horarios
            }
            
            // Notas al final del PDF
            let notasAttributes = [
                NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 10),
                NSAttributedString.Key.foregroundColor: UIColor.gray
            ]
            let notasText = "Nota: No hay cambios de horarios, solo ajustes de horas."
            let notasSize = notasText.size(withAttributes: notasAttributes)
            let notasRect = CGRect(
                x: (pageWidth - notasSize.width) / 2, // Centrar la nota
                y: yPosition + 20,
                width: notasSize.width,
                height: notasSize.height
            )
            notasText.draw(in: notasRect, withAttributes: notasAttributes)
        }
        
        // Guardar el PDF en un archivo temporal
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("horarios.pdf")
        do {
            try data.write(to: tempURL)
        } catch {
            print("Error al escribir el PDF: \(error)")
        }
        
        return tempURL
    }
}
