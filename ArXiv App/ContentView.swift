//
//  ContentView.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import SwiftUI
import SwiftData

/// Vista principal de la aplicación ArXiv App
/// Esta vista representa la pantalla inicial que verán los usuarios al abrir la aplicación
struct ContentView: View {
    /// Acceso al contexto del modelo de datos para realizar operaciones CRUD
    /// Permite insertar, actualizar y eliminar elementos de la base de datos
    @Environment(\.modelContext) private var modelContext
    
    /// Query que obtiene automáticamente todos los elementos Item de la base de datos
    /// Se actualiza automáticamente cuando los datos cambian
    @Query private var items: [Item]

    /// Define la estructura visual de la vista principal
    var body: some View {
        VStack {
            // Texto de bienvenida placeholder
            // TODO: Reemplazar con la interfaz real de la aplicación ArXiv
            Text("Hello World!!!")
        }
    }
}

/// Vista previa para el diseñador de SwiftUI
/// Permite visualizar la vista durante el desarrollo sin ejecutar toda la aplicación
#Preview {
    ContentView()
        // Configura un contenedor de modelo en memoria solo para la vista previa
        // Esto evita afectar los datos reales durante el desarrollo
        .modelContainer(for: Item.self, inMemory: true)
}
