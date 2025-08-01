# ArXivController

The main controller that handles the business logic of the ArXiv Finder application.

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

/// Toggles the favorite state of a paper
func toggleFavorite(for paper: ArXivPaper) {
    let newFavoriteState = !paper.isFavorite
    paper.setFavorite(newFavoriteState)
    
    // Save in SwiftData
    if let modelContext = modelContext {
        try? modelContext.save()
    }
    
    // Update favorites list
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
    
    // Update in all categories
    updatePaperInAllCategories(paper)
}
```

### 🔍 Search and Filtering

Provides advanced search functionalities:

```swift
/// Searches papers by specific terms
/// - Parameter query: Search terms
/// - Returns: Papers matching the query
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

## Implemented Design Patterns

### 🎯 MVC Pattern

The controller strictly implements the MVC pattern:

- **Model**: ``ArXivPaper`` - Pure data without business logic
- **View**: SwiftUI Views - Only presentation, no business logic
- **Controller**: ``ArXivController`` - All business logic and coordination

### 🔄 Observer Pattern

Uses the Observer pattern via `@ObservableObject`:

```swift
// Views automatically subscribe to changes
@StateObject private var controller = ArXivController()

// Automatic update when data changes
List(controller.latestPapers) { paper in
    ArXivPaperRow(paper: paper)
}
```

### ⚡ Command Pattern

Implements operations as asynchronous commands:

```swift
/// Command to refresh all data
func refreshAllData() async {
    await withTaskGroup(of: Void.self) { group in
        group.addTask { await self.loadLatestPapers() }
        group.addTask { await self.loadComputerSciencePapers() }
        group.addTask { await self.loadMathematicsPapers() }
    }
}
```

## Error Management

### 🛡️ Robust Error Handling

```swift
/// Handles errors centrally
private func handleError(_ error: Error) {
    print("❌ Error in ArXivController: \(error)")
    
    // Here you could implement:
    // - Structured logging
    // - User notifications
    // - Automatic retry
    // - Fallback to cached data
}
```

### 📊 Error States

```swift
/// Possible controller states
enum ControllerState {
    case idle
    case loading
    case success
    case error(Error)
}

@Published var state: ControllerState = .idle
```

## Performance Optimizations

### 🚀 Lazy Loading

```swift
/// Loads papers on demand
private var loadedCategories: Set<String> = []

func loadCategoryIfNeeded(_ category: String) async {
    guard !loadedCategories.contains(category) else { return }
    
    loadedCategories.insert(category)
    // Load data...
}
```

### 💾 Smart Cache

```swift
/// In-memory cache for frequently accessed papers
private var paperCache: [String: ArXivPaper] = [:]

func getCachedPaper(id: String) -> ArXivPaper? {
    return paperCache[id]
}
```

## SwiftUI Integration

### 🔗 Automatic Binding

The controller integrates seamlessly with SwiftUI:

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

### 📱 Multiplatform Adaptation

```swift
// Platform-specific behavior
#if os(macOS)
func handleMacOSSpecificLogic() {
    // macOS-specific logic
}
#elseif os(iOS)
func handleiOSSpecificLogic() {
    // iOS-specific logic
}
#endif
```

## Controller Lifecycle

### 🌱 Initialization

```swift
init() {
    // Initial setup
    Task {
        await loadLatestPapers()
    }
}
```

### 🔄 Periodic Update

```swift
/// Timer for automatic refresh
private var refreshTimer: Timer?

func startPeriodicRefresh() {
    refreshTimer = Timer.scheduledTimer(withTimeInterval: 300) { _ in
        Task {
            await self.loadLatestPapers()
        }
    }
}
```

## Full Usage Example

```swift
// In a SwiftUI view
struct ContentView: View {
    @StateObject private var controller = ArXivController()
    
    var body: some View {
        NavigationView {
            VStack {
                if controller.isLoading {
                    ProgressView("Loading papers...")
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

## Best Practices

### ✅ Followed Principles

1. **Single Responsibility**: Each method has a specific responsibility
2. **Immutability**: Data is updated in a controlled way
3. **Testability**: Easy to test via dependency injection
4. **Scalability**: Structure allows adding new features

### 🔧 Advanced Configuration

```swift
/// Custom controller configuration
struct ArXivControllerConfig {
    let maxCacheSize: Int = 1000
    let refreshInterval: TimeInterval = 300
    let defaultPageSize: Int = 20
}
```

## Related Resources

- ``ArXivPaper`` - Main data model
- ``ArXivService`` - Service for API communication
- ``MainView`` - Main view using the controller
- ``PapersListView`` - List view managed by the controller 