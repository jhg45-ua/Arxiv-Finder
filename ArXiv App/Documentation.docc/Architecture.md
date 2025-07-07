# Arquitectura MVC

La arquitectura Model-View-Controller implementada en ArXiv App.

@Metadata {
    @DocumentationExtension(mergeBehavior: append)
}

## 🏗️ Visión General de la Arquitectura

ArXiv App implementa una arquitectura **Model-View-Controller (MVC)** moderna adaptada para SwiftUI, combinando los beneficios de la separación de responsabilidades tradicional con la reactividad nativa de SwiftUI.

Esta arquitectura proporciona:
- **Separación clara de responsabilidades**
- **Código mantenible y escalable**
- **Testabilidad mejorada**
- **Reutilización de componentes**
- **Adaptación multiplataforma**

## 📐 Principios Arquitectónicos

### 1. 🎯 Separación de Responsabilidades

Cada capa tiene responsabilidades específicas y bien definidas:

- **📊 Models**: Gestión de datos y lógica de dominio
- **🖥️ Views**: Presentación y interacción del usuario
- **🎛️ Controllers**: Coordinación y lógica de negocio
- **🔌 Services**: Comunicación externa y utilidades

### 2. 🔄 Programación Reactiva

- Uso de `@Published` para notificaciones automáticas
- `@ObservedObject` y `@StateObject` para binding reactivo
- Flujo de datos unidireccional
- Actualización automática de UI

### 3. 💉 Inyección de Dependencias

- Inyección a través del entorno SwiftUI
- Contenedores de modelo compartidos
- Servicios como singletons cuando es apropiado

## 📁 Estructura del Proyecto

```
ArXiv App/
├── Models/                    # 📊 Modelos de datos (M en MVC)
│   └── ArXivPaper.swift      # Modelo principal de papers
├── Views/                     # 🖥️ Vistas de interfaz (V en MVC)
│   ├── MainView.swift        # Vista principal de la aplicación
│   ├── ArXivPaperRow.swift   # Vista de fila individual
│   ├── SidebarView.swift     # Vista de barra lateral (macOS)
│   ├── PapersListView.swift  # Vista de lista de papers
│   ├── PaperDetailView.swift # Vista detallada de paper
│   └── SettingsView.swift    # Vista de configuración
├── Controllers/               # 🎛️ Controladores (C en MVC)
│   └── ArXivController.swift # Controlador principal
├── Services/                  # 🔌 Servicios auxiliares
│   ├── ArXivService.swift    # Servicio de API
│   └── ArXivSimpleParser.swift # Parser XML
└── ArXiv_AppApp.swift        # Punto de entrada
```

## 🏗️ Componentes de la Arquitectura

### 📊 Model (Modelos)

**Ubicación:** `Models/`

Los modelos encapsulan los datos y la lógica de dominio:

```swift
/// Modelo principal que representa un artículo de ArXiv
@Model
final class ArXivPaper: @unchecked Sendable {
    var id: String
    var title: String
    var summary: String
    var authors: String
    var publishedDate: Date
    var category: String
    var link: String
    
    // Lógica de dominio
    func isRecentlyPublished() -> Bool {
        Date().timeIntervalSince(publishedDate) < 7 * 24 * 3600
    }
}
```

**Responsabilidades:**
- ✅ Estructura de datos
- ✅ Validación de datos
- ✅ Persistencia con SwiftData
- ✅ Lógica de dominio específica

### 🖥️ View (Vistas)

**Ubicación:** `Views/`

Las vistas se encargan exclusivamente de la presentación:

```swift
/// Vista principal que coordina la interfaz
struct MainView: View {
    @StateObject private var controller = ArXivController()
    
    var body: some View {
        NavigationSplitView {
            SidebarView(controller: controller)
        } content: {
            PapersListView(controller: controller)
        } detail: {
            PaperDetailView(paper: selectedPaper)
        }
    }
}
```

**Responsabilidades:**
- ✅ Presentación de datos
- ✅ Interacción del usuario
- ✅ Adaptación multiplataforma
- ✅ Binding reactivo con controladores

### 🎛️ Controller (Controladores)

**Ubicación:** `Controllers/`

Los controladores coordinan la lógica de negocio:

```swift
/// Controlador principal que gestiona el estado y lógica
@MainActor
final class ArXivController: ObservableObject {
    @Published var latestPapers: [ArXivPaper] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let arXivService = ArXivService()
    
    func loadLatestPapers() async {
        isLoading = true
        do {
            latestPapers = try await arXivService.fetchLatestPapers()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
```

**Responsabilidades:**
- ✅ Gestión del estado de la aplicación
- ✅ Coordinación entre modelos y vistas
- ✅ Lógica de negocio
- ✅ Manejo de errores
- ✅ Comunicación con servicios

### 🔌 Services (Servicios)

**Ubicación:** `Services/`

Los servicios manejan operaciones externas y utilidades:

```swift
/// Servicio para comunicación con la API de ArXiv
final class ArXivService: @unchecked Sendable {
    private let baseURL = "https://export.arxiv.org/api/query"
    
    func fetchLatestPapers() async throws -> [ArXivPaper] {
        // Lógica de comunicación con API
        let data = try await performRequest()
        return try ArXivSimpleParser().parse(data)
    }
}
```

**Responsabilidades:**
- ✅ Comunicación con APIs externas
- ✅ Procesamiento de datos
- ✅ Utilidades compartidas
- ✅ Manejo de errores de red

## 🔄 Flujo de Datos en MVC

```mermaid
graph TB
    A[👤 Usuario] -->|Interacción| B[🖥️ Vista]
    B -->|Notifica acción| C[🎛️ Controlador]
    C -->|Solicita datos| D[🔌 Servicio]
    D -->|Petición HTTP| E[🌐 API ArXiv]
    E -->|Respuesta XML| F[🔄 Parser]
    F -->|Datos procesados| G[📊 Modelo]
    G -->|@Published| H[🎛️ Controlador]
    H -->|Estado actualizado| I[🖥️ Vista]
    I -->|UI actualizada| A
```

### Pasos del Flujo:

1. **👤 Usuario interactúa** con la Vista (tap, búsqueda, etc.)
2. **🖥️ Vista notifica** al Controlador sobre la acción
3. **🎛️ Controlador procesa** la lógica de negocio
4. **🔌 Controlador utiliza** Servicios para obtener datos
5. **🌐 Servicios realizan** peticiones a APIs externas
6. **📊 Modelos se actualizan** con los nuevos datos
7. **🔄 Controlador publica** cambios via `@Published`
8. **🖥️ Vista se actualiza** automáticamente

## 🎯 Ventajas de esta Arquitectura

### ✅ Mantenibilidad

```swift
// Fácil modificar cada componente independientemente
// Cambiar la UI sin afectar la lógica de negocio
struct NewPaperView: View {
    @ObservedObject var controller: ArXivController
    // Nueva interfaz usando el mismo controlador
}
```

### ✅ Testabilidad

```swift
// Controladores pueden ser testeados independientemente
class ArXivControllerTests: XCTestCase {
    func testLoadLatestPapers() async {
        let mockService = MockArXivService()
        let controller = ArXivController(service: mockService)
        
        await controller.loadLatestPapers()
        
        XCTAssertFalse(controller.isLoading)
        XCTAssertEqual(controller.latestPapers.count, 10)
    }
}
```

### ✅ Escalabilidad

```swift
// Agregar nuevas funcionalidades sin modificar código existente
extension ArXivController {
    func loadFavoritePapers() async {
        // Nueva funcionalidad
    }
}
```

### ✅ Reutilización

```swift
// Componentes reutilizables en diferentes contextos
struct SearchView: View {
    @ObservedObject var controller: ArXivController
    
    var body: some View {
        PapersListView(controller: controller) // Reutiliza vista existente
    }
}
```

## 📱 Adaptación Multiplataforma

### iOS Design Pattern

```swift
#if os(iOS)
struct iOSMainView: View {
    @StateObject private var controller = ArXivController()
    
    var body: some View {
        NavigationStack {
            PapersListView(controller: controller)
                .navigationTitle("ArXiv Papers")
                .navigationBarTitleDisplayMode(.large)
        }
    }
}
#endif
```

**Características iOS:**
- 📱 NavigationStack para navegación jerárquica
- 📄 Sheet/Modal para presentación de detalles
- 🔧 Toolbar con acciones contextuales
- 👆 Elementos optimizados para touch

### macOS Design Pattern

```swift
#if os(macOS)
struct macOSMainView: View {
    @StateObject private var controller = ArXivController()
    
    var body: some View {
        NavigationSplitView {
            SidebarView(controller: controller)
        } content: {
            PapersListView(controller: controller)
        } detail: {
            PaperDetailView(paper: selectedPaper)
        }
    }
}
#endif
```

**Características macOS:**
- 🖥️ NavigationSplitView para tres columnas
- 📋 Sidebar para navegación principal
- 🪟 Window management nativo
- ⌨️ Keyboard shortcuts
- 📂 Menu bar integration

## 🚀 Patrones de Diseño Implementados

### 1. 🎯 Observer Pattern

```swift
// El controlador notifica cambios automáticamente
@MainActor
class ArXivController: ObservableObject {
    @Published var papers: [ArXivPaper] = [] // Notificación automática
    
    func updatePapers() {
        // Cambio automático activa notificación
        papers = newPapers
    }
}
```

### 2. 🏭 Factory Pattern

```swift
// Factory para crear servicios según contexto
struct ServiceFactory {
    static func createArXivService() -> ArXivService {
        #if DEBUG
        return MockArXivService()
        #else
        return ArXivService()
        #endif
    }
}
```

### 3. 🔄 Command Pattern

```swift
// Comandos para operaciones asíncronas
enum ArXivCommand {
    case loadLatest
    case search(String)
    case loadCategory(String)
}

extension ArXivController {
    func execute(_ command: ArXivCommand) async {
        switch command {
        case .loadLatest:
            await loadLatestPapers()
        case .search(let query):
            await searchPapers(query: query)
        case .loadCategory(let category):
            await loadPapersByCategory(category)
        }
    }
}
```

## 🔧 Mejores Prácticas Implementadas

### 1. ✅ Responsabilidad Única

```swift
// Cada clase tiene una responsabilidad específica
class ArXivService {
    // Solo se encarga de comunicación con API
}

class ArXivController {
    // Solo coordina lógica de negocio
}

struct PapersListView {
    // Solo presenta datos
}
```

### 2. ✅ Inversión de Dependencias

```swift
// Controlador depende de abstracción, no implementación
protocol ArXivServiceProtocol {
    func fetchLatestPapers() async throws -> [ArXivPaper]
}

class ArXivController {
    private let service: ArXivServiceProtocol
    
    init(service: ArXivServiceProtocol = ArXivService()) {
        self.service = service
    }
}
```

### 3. ✅ Immutabilidad

```swift
// Estructuras inmutables para modelos
struct ArXivPaper {
    let id: String
    let title: String
    let summary: String
    // Propiedades inmutables
}
```

## 📊 Métricas de Calidad

### 🏗️ Acoplamiento Bajo

- **Vistas** no conocen implementación de servicios
- **Controladores** no dependen de detalles de UI
- **Servicios** son independientes de la lógica de negocio

### 🎯 Cohesión Alta

- Cada componente tiene responsabilidades relacionadas
- Funcionalidades agrupadas lógicamente
- Interfaces claras y específicas

### 🔄 Flexibilidad

- Fácil intercambio de implementaciones
- Modificaciones localizadas
- Extensibilidad sin romper código existente

## 🚀 Próximos Pasos Arquitectónicos

### 1. 🧪 Testing Avanzado

```swift
// Implementar tests de integración
class IntegrationTests: XCTestCase {
    func testFullWorkflow() async {
        // Test completo del flujo MVC
    }
}
```

### 2. 💾 Persistencia Mejorada

```swift
// Implementar repository pattern
protocol ArXivRepository {
    func save(_ papers: [ArXivPaper]) async throws
    func fetch() async throws -> [ArXivPaper]
}
```

### 3. 🔄 State Management

```swift
// Considerar implementación de Redux pattern
struct AppState {
    var papers: [ArXivPaper] = []
    var isLoading: Bool = false
    var currentCategory: String = "all"
}
```

### 4. 🎨 Design System

```swift
// Implementar design system reutilizable
struct ArXivDesignSystem {
    static let colors = ArXivColors()
    static let typography = ArXivTypography()
    static let spacing = ArXivSpacing()
}
```

## 📚 Recursos Relacionados

### 🔗 Componentes Principales

- ``ArXivPaper`` - Modelo de datos fundamental
- ``ArXivController`` - Controlador principal MVC
- ``ArXivService`` - Servicio de comunicación
- ``MainView`` - Vista principal de la aplicación

### 📖 Documentación Adicional

- <doc:API-Guide> - Guía de integración con la API
- <doc:ArXivService> - Documentación del servicio
- <doc:ArXivController> - Documentación del controlador

---

*Esta arquitectura MVC proporciona una base sólida para el crecimiento y mantenimiento futuro de ArXiv App, adaptándose a las necesidades cambiantes mientras mantiene la claridad y simplicidad del código.*
