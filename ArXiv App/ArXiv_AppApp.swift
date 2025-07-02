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
    /// Se configura con SwiftData para manejar el almacenamiento local de artículos de ArXiv
    var sharedModelContainer: ModelContainer = {
        // Define el esquema de datos que incluye todos los modelos de la aplicación
        let schema = Schema([
            ArXivPaper.self, // Modelo para artículos de ArXiv
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
    /// Utiliza configuraciones específicas para cada plataforma (iOS/macOS)
    var body: some Scene {
        #if os(macOS)
        // Configuración específica para macOS con ventana redimensionable
        WindowGroup {
            ContentView()
                .frame(minWidth: 600, minHeight: 900)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(width: 900, height: 1000)
        // Inyecta el contenedor de modelo compartido en el entorno de SwiftUI
        // Esto permite que todas las vistas accedan a los datos persistentes
        .modelContainer(sharedModelContainer)
        
        // Configuración adicional para macOS
        Settings {
            SettingsView()
        }
        #else
        // Configuración específica para iOS
        WindowGroup {
            ContentView()
        }
        // Inyecta el contenedor de modelo compartido en el entorno de SwiftUI
        // Esto permite que todas las vistas accedan a los datos persistentes
        .modelContainer(sharedModelContainer)
        #endif
    }
}

/// Vista de configuraciones para macOS
/// Proporciona opciones de personalización específicas de la plataforma de escritorio
#if os(macOS)
struct SettingsView: View {
    @AppStorage("refreshInterval") private var refreshInterval = 30
    @AppStorage("maxPapers") private var maxPapers = 10
    @AppStorage("defaultCategory") private var defaultCategory = "all"
    
    var body: some View {
        TabView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Configuración General")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Intervalo de actualización (minutos):")
                    Stepper(value: $refreshInterval, in: 5...120, step: 5) {
                        Text("\(refreshInterval) minutos")
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Número máximo de papers:")
                    Stepper(value: $maxPapers, in: 5...50, step: 5) {
                        Text("\(maxPapers) papers")
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Categoría por defecto:")
                    Picker("Categoría", selection: $defaultCategory) {
                        Text("Todas").tag("all")
                        Text("Computer Science").tag("cs")
                        Text("Mathematics").tag("math")
                        Text("Physics").tag("physics")
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Spacer()
            }
            .padding(20)
            .frame(width: 400, height: 300)
            .tabItem {
                Label("General", systemImage: "gear")
            }
        }
    }
}
#endif
