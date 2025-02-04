//
//  DismissView.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 03/02/25.
//

import SwiftUI

struct DismissView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        HStack{
            Spacer()
            Button("Cerrar"){
                dismiss()
                
            }
            .tint(.black)
            .padding(.trailing, 12)
        }
        .buttonStyle(.bordered)
    }
}

#Preview {
    DismissView()
}
