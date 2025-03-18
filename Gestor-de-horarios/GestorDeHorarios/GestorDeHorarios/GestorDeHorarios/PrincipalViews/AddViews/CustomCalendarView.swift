import SwiftUI
import CoreData
import UserNotifications
import FirebaseAuth

// Vista personalizada de calendario para seleccionar días.
struct CustomCalendarView: View {
    @Binding var selectedDates: [Date]
    @State private var currentMonth = Date()
    private let calendar = Calendar.current
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            // Encabezado del calendario (mes y año)
            headerSection
            
            // Días de la semana
            let days = generateDays()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(["L", "M", "X", "J", "V", "S", "D"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Días del mes
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        let isSelected = selectedDates.contains { calendar.isDate($0, inSameDayAs: date) }
                        Text("\(calendar.component(.day, from: date))")
                            .foregroundColor(isSelected ? .white : .primary)
                            .frame(width: 35, height: 35)
                            .background(isSelected ? Color.black : Color.clear)
                            .clipShape(Circle())
                            .onTapGesture { toggleSelection(date) }
                    } else {
                        Text(" ")
                            .frame(width: 35, height: 35)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Subviews
    
    // Encabezado del calendario (mes y año).
    private var headerSection: some View {
        HStack {
            Button(action: { currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? Date() }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Text(monthYearString(for: currentMonth))
                .font(.headline)
                .frame(maxWidth: .infinity)
            
            Spacer()
            
            Button(action: { currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? Date() }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helper Functions
    
    // Genera los días del mes.
    private func generateDays() -> [Date?] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let offset = (firstWeekday + 5) % 7
        
        var days = Array(repeating: nil as Date?, count: offset)
        days.append(contentsOf: range.map { calendar.date(byAdding: .day, value: $0 - 1, to: startOfMonth)! })
        return days
    }
    
    // Formatea el mes y año.
    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    // Selecciona o deselecciona un día.
    private func toggleSelection(_ date: Date) {
        if let index = selectedDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: date) }) {
            selectedDates.remove(at: index)
        } else {
            selectedDates.append(date)
        }
    }
}
