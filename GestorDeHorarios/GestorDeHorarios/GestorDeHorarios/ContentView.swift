//
//  ContentView.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 14/01/25.
import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var authenticationViewModel: AuthenticationViewModel
    
    @State private var selectedDate = Date()
    @State private var showingAddHorario = false
    @State private var showingEditHorario = false
    @State private var showingMonthlyCalendar = false
    @State private var selectedHorario: Horario? = nil
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Horario.fechaInicio, ascending: true)]
    ) var horarios: FetchedResults<Horario>
    
    var body: some View {
        VStack(spacing: 16) {
            Button("Salir"){
                authenticationViewModel.logout()
            }
            
            Text("Gestor de horarios")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
            Text(fechaActual())
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    calendarBar
                        .frame(maxWidth: .infinity, alignment: .center)
                        .animation(.easeInOut(duration: 0.3), value: selectedDate)
                    
                    ForEach(horariosFiltradosPorFecha(), id: \Horario.self) { horario in
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(horario.nombreEmpleado ?? "Sin nombre")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack(spacing: 8) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Entrada:")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                        Text(formattedTime(horario.fechaInicio))
                                            .font(.caption2)
                                            .foregroundColor(.black)
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Comida:")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                        Text(formattedTime(horario.fechaComida))
                                            .font(.caption2)
                                            .foregroundColor(.black)
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Salida:")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                        Text(formattedTime(horario.fechaFin))
                                            .font(.caption2)
                                            .foregroundColor(.black)
                                    }
                                }
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
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.systemGray6))
                        )
                    }
                }
                .padding(.horizontal, 8)
            }
            
            VStack {
              
                Button(action: {
                    showingAddHorario = true
                }){
                    VStack(spacing: 4) {
                        Text("Agregar un horario")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 350, height:100)
                            .background(Color.black)
                            .cornerRadius(10)
                    }
                }
            }
        }
        
        VStack {
            Button(action: {
                showingMonthlyCalendar = true
            }) {
                VStack(spacing: 4) {
                    Text("Vacaciones")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 350, height: 50)
                        .background(Color.black)
                        .cornerRadius(10)
                }
            }
        }
        .background(.black)
        .cornerRadius(15)
        
        .sheet(isPresented: $showingEditHorario) {
            if let selectedHorario {
                EditHorarioView(horario: selectedHorario)
            }
        }
        .sheet(isPresented: $showingAddHorario) {
            AddHorarioView(horario: nil)
        }

        .sheet(isPresented: $showingMonthlyCalendar) {
            CalendarView(horarios: horarios)
        }
    }


    // Diseño del calendario horizontal
    var calendarBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(generateDatesForWeek(), id: \.self) { date in
                    VStack(spacing: 2) {
                        Text(shortWeekday(from: date))
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text(dayOfMonth(from: date))
                            .font(.body)
                            .fontWeight(selectedDate == date ? .bold : .regular)
                            .foregroundColor(selectedDate == date ? .white : .black)
                            .frame(width: 42, height: 42)
                            .background(selectedDate == date ? Color.black : Color.clear)
                            .cornerRadius(16)
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
    // Funciones utilizadas
    
    // Genera un arreglo de fechas correspondientes a la semana actual (de domingo a jueves)
    private func generateDatesForWeek() -> [Date] {
        let calendar = Calendar.current
        // Obtiene el inicio de la semana actual
        guard let startOfWeek = calendar.dateInterval(of: .weekOfMonth, for: Date())?.start else {
            return []
        }
        // Devuelve un arreglo de fechas sumando días al inicio de la semana
        return (0..<15).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    // Filtra los horarios para mostrar solo los que coinciden con la fecha seleccionada
    private func horariosFiltradosPorFecha() -> [Horario] {
        let calendar = Calendar.current
        // Filtra los horarios cuyo inicio es en el mismo día que la fecha seleccionada
        return horarios.filter { horario in
            guard let fechaInicio = horario.fechaInicio else { return false }
            return calendar.isDate(fechaInicio, inSameDayAs: selectedDate)
        }
    }
    
    // Formatea la fecha (hora) a un formato corto
    private func formattedTime(_ date: Date?) -> String {
        guard let date = date else { return "Sin hora" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_ES")
        // Devuelve la hora formateada
        return formatter.string(from: date)
    }
    
    // Obtiene el nombre corto del día de la semana
    private func shortWeekday(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "es_ES")
        // Devuelve el nombre corto del día
        return formatter.string(from: date)
    }
    
    // Formatea la fecha actual a un formato largo
    private func fechaActual() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "EEEE, d 'de' MMMM 'de' yyyy"
        // Devuelve la fecha actual formateada
        return formatter.string(from: Date()).capitalized
    }
    
    // Obtiene el día del mes de una fecha
    private func dayOfMonth(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.locale = Locale(identifier: "es_ES")
        // Devuelve el día del mes
        return formatter.string(from: date)
    }
    
    // Elimina un horario del contexto de datos
    private func deleteHorario(_ horario: Horario) {
        let context = PersistenceController.shared.container.viewContext
        context.delete(horario)
        do {
            // Intenta guardar los cambios en el contexto
            try context.save()
        } catch {
            print("Error al eliminar el horario: \(error)")
        }
    }
}

