# ArXivController

The main controller that handles the business logic of the ArXiv application.

## Overview

``ArXivController`` is the central component of the MVC pattern that acts as an intermediary between the data models (``ArXivPaper``) and SwiftUI views. It manages application state, coordinates asynchronous operations, and provides a reactive interface for the UI.

This class is designed following the principles of:
- **Separation of responsibilities** in the MVC pattern
- **Reactivity** with `@ObservableObject` and `@Published`
- **Modern concurrency** with async/await and `@MainActor`
- **Centralized and predictable** state management

## Controller Architecture

### 🎛️ Main Responsibilities

The ``ArXivController`` handles:

1. **State Management**: Maintains application state centrally
2. **Data Coordination**: Orchestrates operations between services and models
3. **Business Logic**: Implements ArXiv-specific business rules
4. **Reactive Interface**: Provides automatic binding with SwiftUI views

### 📊 State Properties

```swift
/// Papers from the "Latest" category
@Published var latestPapers: [ArXivPaper] = []

/// Computer Science papers
@Published var csPapers: [ArXivPaper] = []

/// Mathematics papers
@Published var mathPapers: [ArXivPaper] = []

/// Physics papers
@Published var physicsPapers: [ArXivPaper] = []

/// Quantitative Biology papers
@Published var quantitativeBiologyPapers: [ArXivPaper] = []

/// Quantitative Finance papers
@Published var quantitativeFinancePapers: [ArXivPaper] = []

/// Statistics papers
@Published var statisticsPapers: [ArXivPaper] = []

/// Electrical Engineering and Systems Science papers
@Published var electricalEngineeringPapers: [ArXivPaper] = []

/// Economics papers
@Published var economicsPapers: [ArXivPaper] = []

/// User's favorite papers
@Published var favoritePapers: [ArXivPaper] = []

/// Loading state
@Published var isLoading = false
```

## Key Functionalities

### 🔄 Asynchronous Data Loading

The controller manages data loading asynchronously:

```swift
/// Loads the latest papers from ArXiv
/// - Automatically updates the `latestPapers` property
/// - Handles network errors gracefully
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

### 🏷️ Category Management

Organizes papers by academic categories:

```swift
/// Loads Computer Science specific papers
func loadComputerSciencePapers() async {
    let papers = try await arXivService.fetchComputerSciencePapers()
    csPapers = papers
}

/// Loads Mathematics specific papers
func loadMathematicsPapers() async {
    let papers = try await arXivService.fetchMathematicsPapers()
    mathPapers = papers
}

/// Loads Physics specific papers
func loadPhysicsPapers() async {
    let papers = try await arXivService.fetchPhysicsPapers()
    physicsPapers = papers
}

/// Loads Quantitative Biology specific papers
func loadQuantitativeBiologyPapers() async {
    let papers = try await arXivService.fetchQuantitativeBiologyPapers()
    quantitativeBiologyPapers = papers
}

/// Loads Quantitative Finance specific papers
func loadQuantitativeFinancePapers() async {
    let papers = try await arXivService.fetchQuantitativeFinancePapers()
    quantitativeFinancePapers = papers
}

/// Loads Statistics specific papers
func loadStatisticsPapers() async {
    let papers = try await arXivService.fetchStatisticsPapers()
    statisticsPapers = papers
}

/// Loads Electrical Engineering specific papers
func loadElectricalEngineeringPapers() async {
    let papers = try await arXivService.fetchElectricalEngineeringPapers()
    electricalEngineeringPapers = papers
}

/// Loads Economics specific papers
func loadEconomicsPapers() async {
    let papers = try await arXivService.fetchEconomicsPapers()
    economicsPapers = papers
}
```

### ⭐ Favorites Management

Handles favorites functionality with persistence:

```swift
/// Loads all favorite papers from SwiftData
func loadFavoritePapers() async {
    currentCategory = "favorites"
    isLoading = true
    defer { isLoading = false }
    
    do {
        if let modelContext = modelContext {
            let descriptor = FetchDescriptor<ArXivPaper>(
                predicate: #Predicate<ArXivPaper> { $0.isFavorite == true }
            )
            let favoriteResults = try modelContext.fetch(descriptor)
            favoritePapers = favoriteResults.sorted { 
                $0.favoritedDate ?? Date.distantPast > $1.favoritedDate ?? Date.distantPast 
            }
        }
    } catch {
        handleError(error)
    }
}

/// Alterna el estado de favorito de un artículo
func toggleFavorite(for paper: ArXivPaper) {
    let newFavoriteState = !paper.isFavorite
    paper.setFavorite(newFavoriteState)
    
    // Guardar en SwiftData
    if let modelContext = modelContext {
        try? modelContext.save()
    }
    
    // Actualizar lista de favoritos
    if newFavoriteState {
        if !favoritePapers.contains(where: { $0.id == paper.id }) {
            favoritePapers.append(paper)
            favoritePapers.sort { 
                $0.favoritedDate ?? Date.distantPast > $1.favoritedDate ?? Date.distantPast 
            }
        }
    } else {
        favoritePapers.removeAll { $0.id == paper.id }
    }
    
    // Actualizar en todas las categorías
    updatePaperInAllCategories(paper)
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
