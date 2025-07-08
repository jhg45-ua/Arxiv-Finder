# ArXivController

El controlador principal que maneja la lógica de negocio de la aplicación ArXiv.

## Descripción General

``ArXivController`` es el componente central del patrón MVC que actúa como intermediario entre los modelos de datos (``ArXivPaper``) y las vistas SwiftUI. Gestiona el estado de la aplicación, coordina las operaciones asíncronas y proporciona una interfaz reactiva para la UI.

Esta clase está diseñada siguiendo los principios de:
- **Separación de responsabilidades** en el patrón MVC
- **Reactividad** con `@ObservableObject` y `@Published`
- **Concurrencia moderna** con async/await y `@MainActor`
- **Gestión de estado** centralizada y predecible

## Arquitectura del Controlador

### 🎛️ Responsabilidades Principales

El ``ArXivController`` maneja:

1. **Gestión de Estado**: Mantiene el estado de la aplicación de forma centralizada
2. **Coordinación de Datos**: Orquesta las operaciones entre servicios y modelos
3. **Lógica de Negocio**: Implementa las reglas de negocio específicas de ArXiv
4. **Interfaz Reactiva**: Proporciona binding automático con las vistas SwiftUI

### 📊 Propiedades del Estado

```swift
/// Papers de la categoría "Últimos"
@Published var latestPapers: [ArXivPaper] = []

/// Papers de Computer Science
@Published var csPapers: [ArXivPaper] = []

/// Papers de Mathematics
@Published var mathPapers: [ArXivPaper] = []

/// Papers de Physics
@Published var physicsPapers: [ArXivPaper] = []

/// Papers de Quantitative Biology
@Published var quantitativeBiologyPapers: [ArXivPaper] = []

/// Papers de Quantitative Finance
@Published var quantitativeFinancePapers: [ArXivPaper] = []

/// Papers de Statistics
@Published var statisticsPapers: [ArXivPaper] = []

/// Papers de Electrical Engineering and Systems Science
@Published var electricalEngineeringPapers: [ArXivPaper] = []

/// Papers de Economics
@Published var economicsPapers: [ArXivPaper] = []

/// Estado de carga
@Published var isLoading = false
```

## Funcionalidades Clave

### 🔄 Carga de Datos Asíncrona

El controlador gestiona la carga de datos de forma asíncrona:

```swift
/// Carga los artículos más recientes de ArXiv
/// - Actualiza automáticamente la propiedad `latestPapers`
/// - Maneja errores de red de forma elegante
@MainActor
func loadLatestPapers() async {
    isLoading = true
    defer { isLoading = false }
    
    do {
        let papers = try await arXivService.fetchLatestPapers(count: 20)
        latestPapers = papers
    } catch {
        handleError(error)
    }
}
```

### 🏷️ Gestión por Categorías

Organiza los artículos por categorías académicas:

```swift
/// Carga artículos específicos de Computer Science
func loadComputerSciencePapers() async {
    let papers = try await arXivService.fetchComputerSciencePapers()
    csPapers = papers
}

/// Carga artículos específicos de Mathematics
func loadMathematicsPapers() async {
    let papers = try await arXivService.fetchMathematicsPapers()
    mathPapers = papers
}

/// Carga artículos específicos de Physics
func loadPhysicsPapers() async {
    let papers = try await arXivService.fetchPhysicsPapers()
    physicsPapers = papers
}

/// Carga artículos específicos de Quantitative Biology
func loadQuantitativeBiologyPapers() async {
    let papers = try await arXivService.fetchQuantitativeBiologyPapers()
    quantitativeBiologyPapers = papers
}

/// Carga artículos específicos de Quantitative Finance
func loadQuantitativeFinancePapers() async {
    let papers = try await arXivService.fetchQuantitativeFinancePapers()
    quantitativeFinancePapers = papers
}

/// Carga artículos específicos de Statistics
func loadStatisticsPapers() async {
    let papers = try await arXivService.fetchStatisticsPapers()
    statisticsPapers = papers
}

/// Carga artículos específicos de Electrical Engineering
func loadElectricalEngineeringPapers() async {
    let papers = try await arXivService.fetchElectricalEngineeringPapers()
    electricalEngineeringPapers = papers
}

/// Carga artículos específicos de Economics
func loadEconomicsPapers() async {
    let papers = try await arXivService.fetchEconomicsPapers()
    economicsPapers = papers
}
```

### 🔍 Búsqueda y Filtrado

Proporciona funcionalidades avanzadas de búsqueda:

```swift
/// Busca artículos por términos específicos
/// - Parameter query: Términos de búsqueda
/// - Returns: Artículos que coinciden con la consulta
@Published var searchResults: [ArXivPaper] = []

func searchPapers(query: String) async {
    guard !query.isEmpty else { return }
    
    isLoading = true
    defer { isLoading = false }
    
    do {
        let results = try await arXivService.searchPapers(query: query)
        searchResults = results
    } catch {
        handleError(error)
    }
}
```

## Patrones de Diseño Implementados

### 🎯 Patrón MVC

El controlador implementa el patrón MVC de forma estricta:

- **Modelo**: ``ArXivPaper`` - Datos puros sin lógica de negocio
- **Vista**: Vistas SwiftUI - Solo presentación, sin lógica de negocio
- **Controlador**: ``ArXivController`` - Toda la lógica de negocio y coordinación

### 🔄 Patrón Observer

Utiliza el patrón Observer a través de `@ObservableObject`:

```swift
// Las vistas se suscriben automáticamente a cambios
@StateObject private var controller = ArXivController()

// Actualización automática cuando cambian los datos
List(controller.latestPapers) { paper in
    ArXivPaperRow(paper: paper)
}
```

### ⚡ Patrón Command

Implementa operaciones como comandos asíncronos:

```swift
/// Comando para refrescar todos los datos
func refreshAllData() async {
    await withTaskGroup(of: Void.self) { group in
        group.addTask { await self.loadLatestPapers() }
        group.addTask { await self.loadComputerSciencePapers() }
        group.addTask { await self.loadMathematicsPapers() }
    }
}
```

## Gestión de Errores

### 🛡️ Manejo Robusto de Errores

```swift
/// Maneja errores de forma centralizada
private func handleError(_ error: Error) {
    print("❌ Error en ArXivController: \(error)")
    
    // Aquí podrías implementar:
    // - Logging estructurado
    // - Notificaciones al usuario
    // - Reintento automático
    // - Fallback a datos en caché
}
```

### 📊 Estados de Error

```swift
/// Estados posibles del controlador
enum ControllerState {
    case idle
    case loading
    case success
    case error(Error)
}

@Published var state: ControllerState = .idle
```

## Optimizaciones de Rendimiento

### 🚀 Carga Lazy

```swift
/// Carga artículos bajo demanda
private var loadedCategories: Set<String> = []

func loadCategoryIfNeeded(_ category: String) async {
    guard !loadedCategories.contains(category) else { return }
    
    loadedCategories.insert(category)
    // Cargar datos...
}
```

### 💾 Caché Inteligente

```swift
/// Caché en memoria para artículos frecuentemente accedidos
private var paperCache: [String: ArXivPaper] = [:]

func getCachedPaper(id: String) -> ArXivPaper? {
    return paperCache[id]
}
```

## Integración con SwiftUI

### 🔗 Binding Automático

El controlador se integra perfectamente con SwiftUI:

```swift
struct PapersListView: View {
    @ObservedObject var controller: ArXivController
    
    var body: some View {
        List(controller.latestPapers) { paper in
            ArXivPaperRow(paper: paper)
        }
        .refreshable {
            await controller.loadLatestPapers()
        }
    }
}
```

### 📱 Adaptación Multiplataforma

```swift
// Comportamiento específico para cada plataforma
#if os(macOS)
func handleMacOSSpecificLogic() {
    // Lógica específica de macOS
}
#elseif os(iOS)
func handleiOSSpecificLogic() {
    // Lógica específica de iOS
}
#endif
```

## Ciclo de Vida del Controlador

### 🌱 Inicialización

```swift
init() {
    // Configuración inicial
    Task {
        await loadLatestPapers()
    }
}
```

### 🔄 Actualización Periódica

```swift
/// Timer para actualización automática
private var refreshTimer: Timer?

func startPeriodicRefresh() {
    refreshTimer = Timer.scheduledTimer(withTimeInterval: 300) { _ in
        Task {
            await self.loadLatestPapers()
        }
    }
}
```

## Ejemplo de Uso Completo

```swift
// En una vista SwiftUI
struct ContentView: View {
    @StateObject private var controller = ArXivController()
    
    var body: some View {
        NavigationView {
            VStack {
                if controller.isLoading {
                    ProgressView("Cargando artículos...")
                } else {
                    List(controller.latestPapers) { paper in
                        ArXivPaperRow(paper: paper)
                    }
                }
            }
            .onAppear {
                Task {
                    await controller.loadLatestPapers()
                }
            }
        }
    }
}
```

## Mejores Prácticas

### ✅ Principios Seguidos

1. **Responsabilidad Única**: Cada método tiene una responsabilidad específica
2. **Inmutabilidad**: Los datos se actualizan de forma controlada
3. **Testabilidad**: Fácil de probar mediante inyección de dependencias
4. **Escalabilidad**: Estructura que permite agregar nuevas funcionalidades

### 🔧 Configuración Avanzada

```swift
/// Configuración personalizada del controlador
struct ArXivControllerConfig {
    let maxCacheSize: Int = 1000
    let refreshInterval: TimeInterval = 300
    let defaultPageSize: Int = 20
}
```

## Recursos Relacionados

- ``ArXivPaper`` - Modelo de datos principal
- ``ArXivService`` - Servicio para comunicación con la API
- ``MainView`` - Vista principal que utiliza el controlador
- ``PapersListView`` - Vista de lista gestionada por el controlador
