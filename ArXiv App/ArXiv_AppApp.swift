//
//  ArXiv_AppApp.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import SwiftUI
import SwiftData

/**
 * ARQUITECTURA DE LA APLICACIÓN ARXIV APP
 * =====================================
 * 
 * Esta aplicación sigue el patrón Model-View-Controller (MVC):
 * 
 * MODELS (Modelos):
 * - ArXivPaper: Modelo de datos para artículos científicos con SwiftData
 * 
 * VIEWS (Vistas):
 * - MainView: Vista principal que coordina la navegación
 * - SidebarView: Barra lateral para macOS
 * - PapersListView: Lista de artículos con adaptaciones multiplataforma
 * - ArXivPaperRow: Fila individual de artículo
 * - PaperDetailView: Detalle completo de un artículo
 * 
 * CONTROLLERS (Controladores):
 * - ArXivController: Lógica de negocio y gestión de estado
 * 
 * SERVICES (Servicios):
 * - ArXivService: Comunicación con la API de ArXiv
 * - ArXivSimpleParser: Parser XML personalizado
 * 
 * CARACTERÍSTICAS TÉCNICAS:
 * - Multiplataforma: iOS y macOS con UI adaptativa
 * - Persistencia: SwiftData para almacenamiento local
 * - Networking: URLSession con manejo de errores robusto
 * - UI: SwiftUI con NavigationStack (iOS) y NavigationSplitView (macOS)
 * - Concurrencia: async/await con @MainActor para actualizaciones UI
 */

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
            MainView()
                .frame(minWidth: 1500, minHeight: 700)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(width: 1500, height: 700)
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
            MainView()
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
