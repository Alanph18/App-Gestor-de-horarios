import SwiftUI

// Extensión para crear un Color desde un valor hexadecimal.
extension Color {
    init(hex: String) {
        // Limpia el string hexadecimal (elimina "#" o espacios).
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        
        // Convierte el hexadecimal a un entero.
        Scanner(string: hex).scanHexInt64(&int)
        
        // Extrae los componentes RGB.
        if hex.count == 6 {
            let r = Double((int >> 16) & 0xFF) / 255
            let g = Double((int >> 8) & 0xFF) / 255
            let b = Double(int & 0xFF) / 255
            self = Color(red: r, green: g, blue: b)
        } else {
            // Si el formato no es válido, usa negro por defecto.
            self = .black
        }
    }
}
