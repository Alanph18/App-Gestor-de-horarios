import SwiftUI
import CoreData
import UserNotifications
import FirebaseAuth

// Fila personalizada para seleccionar una hora con un DatePicker.
struct DatePickerRow: View {
    let title: String // Título de la fila.
    @Binding var selection: Date // Hora seleccionada.
    
    // MARK: - Body
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            DatePicker("", selection: $selection, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(CompactDatePickerStyle())
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
