# MVC Architecture

The Model-View-Controller architecture implemented in ArXiv App.

## 🏗️ Architecture Overview

ArXiv App implements a modern **Model-View-Controller (MVC)** architecture adapted for SwiftUI, combining the benefits of traditional separation of responsibilities with SwiftUI's native reactivity.

This architecture provides:
- **Clear separation of responsibilities**
- **Maintainable and scalable code**
- **Improved testability**
- **Component reusability**
- **Multiplatform adaptation**

## 📐 Architectural Principles

### 1. 🎯 Separation of Responsibilities

Each layer has specific and well-defined responsibilities:

- **📊 Models**: Data management and domain logic
- **🖥️ Views**: Presentation and user interaction
- **🎛️ Controllers**: Coordination and business logic
- **🔌 Services**: External communication and utilities

### 2. 🔄 Reactive Programming

- Use of `@Published` for automatic notifications
- `@ObservedObject` and `@StateObject` for reactive binding
- Unidirectional data flow
- Automatic UI updates

### 3. 💉 Dependency Injection

- Injection through SwiftUI environment
- Shared model containers
- Services as singletons when appropriate

## 📁 Project Structure

```
ArXiv App/
├── Models/                    # 📊 Data models (M in MVC)
│   └── ArXivPaper.swift      # Main paper model
├── Views/                     # 🖥️ Interface views (V in MVC)
│   ├── MainView.swift        # Main application view
│   ├── ArXivPaperRow.swift   # Individual row view
│   ├── SidebarView.swift     # Sidebar view (macOS)
│   ├── PapersListView.swift  # Paper list view
│   ├── PaperDetailView.swift # Detailed paper view
│   └── SettingsView.swift    # Settings view
├── Controllers/               # 🎛️ Controllers (C in MVC)
│   └── ArXivController.swift # Main controller
├── Services/                  # 🔌 Auxiliary services
│   ├── ArXivService.swift    # API service
│   └── ArXivSimpleParser.swift # XML parser
└── ArXiv_AppApp.swift        # Entry point
```

## 🏗️ Architecture Components

### 📊 Model (Models)

**Location:** `Models/`

Models encapsulate data and domain logic:

```swift
/// Main model representing an ArXiv paper
@Model
final class ArXivPaper: @unchecked Sendable {
    var id: String
    var title: String
    var summary: String
    var authors: String
    var publishedDate: Date
    var category: String
    var link: String
    
    // Domain logic
    func isRecentlyPublished() -> Bool {
        Date().timeIntervalSince(publishedDate) < 7 * 24 * 3600
    }
}
```

**Responsibilities:**
- ✅ Data structure
- ✅ Data validation
- ✅ SwiftData persistence
- ✅ Specific domain logic

### 🖥️ View (Views)

**Location:** `Views/`

Views are exclusively responsible for presentation:

```swift
/// Main view that coordinates the interface
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

**Responsibilities:**
- ✅ Data presentation
- ✅ User interaction
- ✅ Multiplatform adaptation
- ✅ Reactive binding with controllers

### 🎛️ Controller (Controllers)

**Location:** `Controllers/`

Controllers coordinate business logic:

```swift
/// Main controller managing state and logic
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

**Responsibilities:**
- ✅ Application state management
- ✅ Coordination between models and views
- ✅ Business logic
- ✅ Error handling
- ✅ Service communication

### 🔌 Services (Services)

**Location:** `Services/`

Services handle external operations and utilities:

```swift
/// Service for communication with the ArXiv API
final class ArXivService: @unchecked Sendable {
    private let baseURL = "https://export.arxiv.org/api/query"
    
    func fetchLatestPapers() async throws -> [ArXivPaper] {
        // API communication logic
        let data = try await performRequest()
        return try ArXivSimpleParser().parse(data)
    }
}
```

**Responsibilities:**
- ✅ Communication with external APIs
- ✅ Data processing
- ✅ Shared utilities
- ✅ Network error handling

## 🔄 Data Flow in MVC

```mermaid
graph TB
    A[👤 User] -->|Interaction| B[🖥️ View]
    B -->|Notifies action| C[🎛️ Controller]
    C -->|Requests data| D[🔌 Service]
    D -->|HTTP Request| E[🌐 ArXiv API]
    E -->|XML Response| F[🔄 Parser]
    F -->|Processed data| G[📊 Model]
    G -->|@Published| H[🎛️ Controller]
    H -->|Updated state| I[🖥️ View]
    I -->|UI updated| A
```

### Flow Steps:

1. **👤 User interacts** with the View (tap, search, etc.)
2. **🖥️ View notifies** the Controller about the action
3. **🎛️ Controller processes** the business logic
4. **🔌 Controller uses** Services to obtain data
5. **🌐 Services make** requests to external APIs
6. **📊 Models are updated** with new data
7. **🔄 Controller publishes** changes via `@Published`
8. **🖥️ View updates** automatically

## 🎯 Advantages of this Architecture

### ✅ Maintainability

```swift
// Easy to modify each component independently
// Change UI without affecting business logic
struct NewPaperView: View {
    @ObservedObject var controller: ArXivController
    // New interface using the same controller
}
```

### ✅ Testability

```swift
// Controllers can be tested independently
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

### ✅ Scalability

```swift
// Add new functionalities without modifying existing code
extension ArXivController {
    func loadFavoritePapers() async {
        // New functionality
    }
}
```

### ✅ Reusability

```swift
// Reusable components in different contexts
struct SearchView: View {
    @ObservedObject var controller: ArXivController
    
    var body: some View {
        PapersListView(controller: controller) // Reuses existing view
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
