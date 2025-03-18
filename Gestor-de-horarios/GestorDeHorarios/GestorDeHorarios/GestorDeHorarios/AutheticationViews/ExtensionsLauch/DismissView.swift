import SwiftUI

// Vista que muestra un botón para cerrar la vista actual.
struct DismissView: View {
    // Accede al entorno para usar la acción de cierre (dismiss).
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        HStack {
            Spacer() // Empuja el botón hacia la derecha.
            
            // Botón para cerrar la vista.
            Button("Cerrar") {
                dismiss() // Ejecuta la acción de cierre.
            }
            .tint(.black) // Color del botón.
            .padding(.trailing, 12) // Espaciado a la derecha.
        }
        .buttonStyle(.bordered) // Estilo del botón.
    }
}


