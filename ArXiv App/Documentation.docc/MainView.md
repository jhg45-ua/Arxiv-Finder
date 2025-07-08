# MainView

La vista principal de la aplicación ArXiv que implementa el patrón MVC.

## Descripción General

``MainView`` es el componente central de la interfaz de usuario que actúa como la vista principal en el patrón MVC. Proporciona una experiencia adaptativa que funciona tanto en iOS como macOS, utilizando las mejores prácticas de diseño nativo para cada plataforma.

Esta vista está diseñada siguiendo principios de:
- **Separación de responsabilidades** en el patrón MVC
- **Adaptabilidad multiplataforma** con código condicional
- **Reactividad** mediante binding con ``ArXivController``
- **Accesibilidad** con soporte completo para tecnologías asistivas

## Arquitectura de la Vista

### 🎭 Implementación del Patrón MVC

La vista implementa estrictamente el patrón MVC:

```swift
/// Arquitectura MVC:
/// - View: Esta vista maneja solo la presentación
/// - Controller: ArXivController gestiona toda la lógica de negocio
/// - Model: ArXivPaper representa los datos de artículos
struct MainView: View {
    /// Controller que maneja la lógica de negocio
    @StateObject private var controller = ArXivController()
    
    /// Paper seleccionado en macOS para NavigationSplitView
    @State private var selectedPaper: ArXivPaper?
}
```

### 📱 Adaptación Multiplataforma

La vista se adapta automáticamente a cada plataforma:

```swift
var body: some View {
    #if os(macOS)
    macOSInterface
    #else
    iOSInterface
    #endif
}
```

## Interfaz de macOS

### 🖥️ NavigationSplitView

Para macOS, utiliza un diseño de tres columnas:

```swift
/// Interfaz optimizada para macOS con NavigationSplitView
private var macOSInterface: some View {
    NavigationSplitView {
        // Barra lateral con categorías
        SidebarView(controller: controller)
    } content: {
        // Lista de artículos
        PapersListView(controller: controller, selectedPaper: $selectedPaper)
    } detail: {
        // Vista detallada del artículo seleccionado
        if let paper = selectedPaper {
            PaperDetailView(paper: paper)
        } else {
            placeholderView
        }
    }
}
```

### 🎨 Características de macOS

- **Navegación en tres columnas**: Sidebar, Lista, Detalle
- **Selección persistente**: Mantiene el artículo seleccionado
- **Optimización de ventana**: Aprovecha el espacio de pantalla grande
- **Controles nativos**: Utiliza controles específicos de macOS

### 📚 Categorías Soportadas

La aplicación soporta las siguientes categorías académicas:

```swift
/// Categorías disponibles en la barra lateral
private let availableCategories = [
    "latest": "Últimos Papers",
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
