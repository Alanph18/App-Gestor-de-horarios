import Foundation

// Extensión para Date
extension Date {
    // Método para formatear la fecha en el formato que necesitas
    func formattedDate() -> (day: String, fullDate: String) {
        let formatter = DateFormatter()
        
        // Formato para solo el día (día numérico)
        formatter.dateFormat = "d"
        let day = formatter.string(from: self)
        
        // Formato completo (mes, día, año)
        formatter.dateFormat = "MMMM dd, yyyy"
        let fullDate = formatter.string(from: self)
        
        return (day, fullDate)
    }
}
