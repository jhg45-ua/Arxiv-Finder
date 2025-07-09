# MainView

The main view of the ArXiv application implementing the MVC pattern.

## Overview

``MainView`` is the central user interface component that acts as the main view in the MVC pattern. It provides an adaptive experience that works on both iOS and macOS, using native design best practices for each platform.

This view is designed following principles of:
- **Separation of responsibilities** in the MVC pattern
- **Multiplatform adaptability** with conditional code
- **Reactivity** through binding with ``ArXivController``
- **Accessibility** with full support for assistive technologies

## View Architecture

### 🎭 MVC Pattern Implementation

The view strictly implements the MVC pattern:

```swift
/// MVC Architecture:
/// - View: This view handles only presentation
/// - Controller: ArXivController manages all business logic
/// - Model: ArXivPaper represents paper data
struct MainView: View {
    /// Controller that handles business logic
    @StateObject private var controller = ArXivController()
    
    /// Selected paper in macOS for NavigationSplitView
    @State private var selectedPaper: ArXivPaper?
}
```

### 📱 Multiplatform Adaptation

The view automatically adapts to each platform:

```swift
var body: some View {
    #if os(macOS)
    macOSInterface
    #else
    iOSInterface
    #endif
}
```

## macOS Interface

### 🖥️ NavigationSplitView

For macOS, it uses a three-column design:

```swift
/// Interface optimized for macOS with NavigationSplitView
private var macOSInterface: some View {
    NavigationSplitView {
        // Sidebar with categories
        SidebarView(controller: controller)
    } content: {
        // Paper list
        PapersListView(controller: controller, selectedPaper: $selectedPaper)
    } detail: {
        // Detailed view of selected paper
        if let paper = selectedPaper {
            PaperDetailView(paper: paper)
        } else {
            placeholderView
        }
    }
}
```

### 🎨 macOS Features

- **Three-column navigation**: Sidebar, List, Detail
- **Persistent selection**: Maintains selected paper
- **Window optimization**: Takes advantage of large screen space
- **Native controls**: Uses macOS-specific controls

### 📚 Supported Categories

The application supports the following academic categories:

```swift
/// Categories available in the sidebar
private let availableCategories = [
    "latest": "Latest Papers",
    "cs": "Computer Science",
    "math": "Mathematics", 
    "physics": "Physics",
    "q-bio": "Quantitative Biology",
    "q-fin": "Quantitative Finance",
    "stat": "Statistics",
    "eess": "Electrical Engineering",
    "econ": "Economics"
]
```

**Funcionalidades por categoría:**
- **Navegación**: Cada categoría tiene su propio botón en la barra lateral
- **Estado independiente**: Cada categoría mantiene su propio estado de carga
- **Datos persistentes**: Los papers se mantienen en caché por categoría
- **Configuración**: El usuario puede seleccionar una categoría por defecto

## Interfaz de iOS

### 📱 NavigationStack

Para iOS, utiliza navegación jerárquica:

```swift
/// Interfaz optimizada para iOS con NavigationStack
private var iOSInterface: some View {
    NavigationStack {
        PapersListView(controller: controller, selectedPaper: .constant(nil))
            .navigationTitle("ArXiv Papers")
            .navigationBarTitleDisplayMode(.large)
    }
}
```

### 🎯 Características de iOS

- **Navegación jerárquica**: Stack de navegación tradicional
- **Títulos grandes**: Aprovecha el espacio disponible
- **Gestos nativos**: Swipe back y otros gestos iOS
- **Adaptación a tamaño**: Responsive design para diferentes tamaños

## Componentes Integrados

### 🔗 Integración con Controlador

La vista se integra perfectamente con el controlador:

```swift
/// Binding reactivo con el controlador
@StateObject private var controller = ArXivController()

/// Actualización automática cuando cambian los datos
var body: some View {
    // La vista se actualiza automáticamente cuando
    // cambian las propiedades @Published del controlador
    List(controller.latestPapers) { paper in
        ArXivPaperRow(paper: paper)
    }
}
```

### 📊 Gestión de Estado

```swift
/// Estado local específico de la vista
@State private var selectedPaper: ArXivPaper?
@State private var isShowingSettings = false
@State private var searchText = ""

/// Computed properties para estado derivado
private var filteredPapers: [ArXivPaper] {
    guard !searchText.isEmpty else { return controller.latestPapers }
    return controller.latestPapers.filter { 
        $0.title.localizedCaseInsensitiveContains(searchText) 
    }
}
```

## Características de Accesibilidad

### ♿ Soporte para Tecnologías Asistivas

```swift
/// Etiquetas de accesibilidad
.accessibilityLabel("Lista de artículos de ArXiv")
.accessibilityHint("Desliza para ver más artículos")

/// Navegación por teclado
.focusable(true)
.onMoveCommand { direction in
    handleKeyboardNavigation(direction)
}
```

### 🔍 Soporte para Dynamic Type

```swift
/// Texto que se adapta al tamaño preferido del usuario
Text(paper.title)
    .font(.headline)
    .lineLimit(nil)
    .fixedSize(horizontal: false, vertical: true)
```

## Características de Rendimiento

### 🚀 Optimización de Listas

```swift
/// Lista optimizada con lazy loading
LazyVStack(spacing: 8) {
    ForEach(controller.latestPapers) { paper in
        ArXivPaperRow(paper: paper)
            .onAppear {
                // Carga más datos cuando se acerca al final
                if paper == controller.latestPapers.last {
                    Task {
                        await controller.loadMorePapers()
                    }
                }
            }
    }
}
```

### 💾 Gestión de Memoria

```swift
/// Configuración de memoria para listas grandes
.onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
    controller.clearCache()
}
```

## Personalización Visual

### 🎨 Theming

```swift
/// Soporte para tema claro/oscuro
@Environment(\.colorScheme) var colorScheme

private var backgroundColor: Color {
    colorScheme == .dark ? .black : .white
}

private var textColor: Color {
    colorScheme == .dark ? .white : .black
}
```

### 🖼️ Recursos Visuales

```swift
/// Uso de recursos gráficos
Image(systemName: "doc.text.magnifyingglass")
    .foregroundColor(.accentColor)
    .imageScale(.large)
```

## Ejemplo de Uso Completo

```swift
/// Ejemplo de implementación completa
struct ContentView: View {
    var body: some View {
        MainView()
            .onAppear {
                // Configuración inicial
                setupAppearance()
            }
    }
    
    private func setupAppearance() {
        // Configuración de apariencia global
        UINavigationBar.appearance().prefersLargeTitles = true
    }
}
```

## Estados de la Vista

### 🔄 Estados de Carga

```swift
/// Diferentes estados de la vista
enum ViewState {
    case loading
    case loaded([ArXivPaper])
    case error(Error)
    case empty
}

@State private var viewState: ViewState = .loading

/// Vista que se adapta al estado actual
@ViewBuilder
private var contentView: some View {
    switch viewState {
    case .loading:
        ProgressView("Cargando artículos...")
    case .loaded(let papers):
        List(papers) { paper in
            ArXivPaperRow(paper: paper)
        }
    case .error(let error):
        ErrorView(error: error) {
            Task {
                await loadPapers()
            }
        }
    case .empty:
        EmptyStateView()
    }
}
```

## Navegación Avanzada

### 🔗 Deep Linking

```swift
/// Soporte para deep linking
.onOpenURL { url in
    if let paperID = extractPaperID(from: url) {
        navigateToPaper(id: paperID)
    }
}

/// Navegación programática
private func navigateToPaper(id: String) {
    if let paper = controller.findPaper(id: id) {
        selectedPaper = paper
    }
}
```

### 📱 Handoff

```swift
/// Soporte para Handoff entre dispositivos
.userActivity("com.arxivapp.viewpaper") { activity in
    if let paper = selectedPaper {
        activity.title = paper.title
        activity.userInfo = ["paperID": paper.id]
    }
}
```

## Mejores Prácticas

### ✅ Principios Implementados

1. **Separación de Responsabilidades**: Solo maneja presentación
2. **Reactividad**: Responde automáticamente a cambios de datos
3. **Adaptabilidad**: Funciona en múltiples plataformas
4. **Accesibilidad**: Soporte completo para todos los usuarios

### 🔧 Configuración Avanzada

```swift
/// Configuración personalizada de la vista
struct MainViewConfig {
    let enablePullToRefresh: Bool = true
    let enableInfiniteScroll: Bool = true
    let cacheSize: Int = 100
    let animationDuration: Double = 0.3
}
```

## Recursos Relacionados

- ``ArXivController`` - Controlador principal de la aplicación
- ``SidebarView`` - Barra lateral de navegación
- ``PapersListView`` - Lista de artículos
- ``PaperDetailView`` - Vista detallada de artículos
- ``ArXivPaperRow`` - Fila individual de artículo
