import SwiftUI

// Vista para mostrar los empleados de vacaciones en una fecha específica.
struct EmployeesOnVacationView: View {
    let date: Date // Fecha seleccionada.
    let vacations: [Vacation] // Lista de vacaciones.
    
    // Filtra los empleados que están de vacaciones en la fecha seleccionada.
    var employeesOnVacation: [String] {
        vacations.filter { vacation in
            guard let startDate = vacation.startDate, let endDate = vacation.endDate else { return false }
            return date >= startDate && date <= endDate
        }
        .map { $0.employeeName ?? "Sin nombre" }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Encabezado con la fecha
                headerSection
                
                // Lista de empleados de vacaciones
                if employeesOnVacation.isEmpty {
                    emptyStateView
                } else {
                    employeesList
                }
            }
            .navigationTitle("Vacaciones")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        }
    }
    
    // MARK: - Subviews
    
    // Encabezado con la fecha seleccionada.
    private var headerSection: some View {
        VStack {
            Text("Colaboradores que descansan el ")
                .font(.headline)
                .foregroundColor(.secondary)
            Text(formatDate(date))
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        .padding(.horizontal)
        .padding(.top, 20)
    }
    
    // Divider personalizado con gradiente.
    private var customDivider: some View {
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
    }
    
    // Vista cuando no hay empleados de vacaciones.
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Text("No hay empleados de vacaciones este día.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding()
            customDivider
            Spacer()
        }
    }
    
    // Lista de empleados de vacaciones.
    private var employeesList: some View {
        List {
            ForEach(employeesOnVacation, id: \.self) { name in
                HStack {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.black)
                        .font(.title2)
                    Text(name)
                        .font(.body)
                        .padding(.vertical, 8)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    // MARK: - Helper Functions
    
    // Formatea la fecha en un formato legible.
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}
