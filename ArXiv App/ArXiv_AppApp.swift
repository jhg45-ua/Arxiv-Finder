//
//  ArXiv_AppApp.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import SwiftUI
import SwiftData

/// Punto de entrada principal de la aplicación ArXiv App
/// Esta estructura define la configuración principal de la app y gestiona el contenedor de datos
@main
struct ArXiv_AppApp: App {
    /// Contenedor compartido de modelo de datos que gestiona la persistencia de la aplicación
    /// Se configura con SwiftData para manejar el almacenamiento local de elementos
    var sharedModelContainer: ModelContainer = {
        // Define el esquema de datos que incluye todos los modelos de la aplicación
        let schema = Schema([
            Item.self, // Modelo principal para almacenar elementos
        ])
        
        // Configura el modelo para usar almacenamiento persistente (no en memoria)
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            // Intenta crear el contenedor de modelo con la configuración especificada
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Si falla la creación del contenedor, termina la aplicación con un error fatal
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    /// Define la estructura principal de la interfaz de usuario de la aplicación
    var body: some Scene {
        WindowGroup {
            // Vista principal de la aplicación
            ContentView()
        }
        // Inyecta el contenedor de modelo compartido en el entorno de SwiftUI
        // Esto permite que todas las vistas accedan a los datos persistentes
        .modelContainer(sharedModelContainer)
    }
}
