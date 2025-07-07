# PapersListView

Vista especializada para mostrar listas de artículos de ArXiv con funcionalidades de búsqueda y filtrado.

@Metadata {
    @DocumentationExtension(mergeBehavior: append)
}

## Descripción General

``PapersListView`` es una vista SwiftUI especializada que muestra listas de artículos de ArXiv con funcionalidades avanzadas de búsqueda, filtrado y navegación. Forma parte del patrón MVC como una vista que se comunica exclusivamente con ``ArXivController`` para obtener datos y notificar acciones del usuario.

Esta vista está diseñada siguiendo principios de:
- **Reutilización** en múltiples contextos de la aplicación
- **Rendimiento optimizado** para listas grandes
- **Experiencia de usuario** intuitiva y responsive
- **Accesibilidad** completa para todos los usuarios

## Arquitectura de la Vista

### 🏗️ Estructura Modular

La vista se compone de múltiples componentes especializados:

```swift
/// Vista principal de lista de artículos
struct PapersListView: View {
    /// Controlador que proporciona los datos
    @ObservedObject var controller: ArXivController
    
    /// Artículo seleccionado para navegación
    @Binding var selectedPaper: ArXivPaper?
    
    /// Texto de búsqueda
    @State private var searchText = ""
    
    /// Filtros activos
    @State private var activeFilters: Set<String> = []
}
```

### 🎯 Responsabilidades Principales

1. **Visualización de listas**: Muestra artículos en formato lista optimizado
2. **Búsqueda en tiempo real**: Filtrado instantáneo mientras el usuario escribe
3. **Selección de artículos**: Gestiona la selección para navegación
4. **Carga dinámica**: Implementa infinite scroll para listas grandes
5. **Estados de UI**: Maneja loading, error y empty states

## Funcionalidades de Búsqueda

### 🔍 Búsqueda en Tiempo Real

```swift
/// Computed property para artículos filtrados
private var filteredPapers: [ArXivPaper] {
    guard !searchText.isEmpty else { 
        return controller.currentPapers 
    }
    
    return controller.currentPapers.filter { paper in
        paper.title.localizedCaseInsensitiveContains(searchText) ||
        paper.authors.localizedCaseInsensitiveContains(searchText) ||
        paper.summary.localizedCaseInsensitiveContains(searchText)
    }
}

/// Barra de búsqueda integrada
private var searchBar: some View {
    HStack {
        Image(systemName: "magnifyingglass")
            .foregroundColor(.secondary)
        
        TextField("Buscar artículos, autores o palabras clave...", text: $searchText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .onSubmit {
                performSearch()
            }
        
        if !searchText.isEmpty {
            Button("Limpiar") {
                searchText = ""
            }
        }
    }
    .padding(.horizontal)
}
```

### 🏷️ Filtros por Categoría

```swift
/// Filtros de categoría disponibles
private let availableCategories = [
    "cs.AI": "Inteligencia Artificial",
    "cs.LG": "Machine Learning",
    "math.CO": "Combinatoria",
    "stat.ML": "Estadística ML",
    "physics.gen-ph": "Física General"
]

/// Vista de filtros
private var filtersView: some View {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack {
            ForEach(availableCategories.sorted(by: { $0.key < $1.key }), id: \.key) { category, name in
                FilterChip(
                    title: name,
                    isSelected: activeFilters.contains(category),
                    action: { toggleFilter(category) }
                )
            }
        }
        .padding(.horizontal)
    }
}

/// Alternar filtro de categoría
private func toggleFilter(_ category: String) {
    if activeFilters.contains(category) {
        activeFilters.remove(category)
    } else {
        activeFilters.insert(category)
    }
}
```

## Estructura de la Lista

### 📝 Lista Principal

```swift
/// Lista principal de artículos
private var papersList: some View {
    List(filteredPapers) { paper in
        ArXivPaperRow(paper: paper)
            .onTapGesture {
                selectedPaper = paper
            }
            .contextMenu {
                contextMenuItems(for: paper)
            }
            .swipeActions(edge: .trailing) {
                swipeActions(for: paper)
            }
            .onAppear {
                loadMoreIfNeeded(paper)
            }
    }
    .listStyle(PlainListStyle())
    .refreshable {
        await refreshData()
    }
}
```

### 📱 Acciones de Contexto

```swift
/// Menú contextual para cada artículo
@ViewBuilder
private func contextMenuItems(for paper: ArXivPaper) -> some View {
    Button(action: { sharePaper(paper) }) {
        Label("Compartir", systemImage: "square.and.arrow.up")
    }
    
    Button(action: { copyLink(paper) }) {
        Label("Copiar Enlace", systemImage: "link")
    }
    
    Button(action: { savePaper(paper) }) {
        Label("Guardar", systemImage: "bookmark")
    }
    
    Divider()
    
    Button(action: { reportPaper(paper) }) {
        Label("Reportar", systemImage: "exclamationmark.triangle")
    }
}

/// Acciones de swipe
@ViewBuilder
private func swipeActions(for paper: ArXivPaper) -> some View {
    Button(action: { savePaper(paper) }) {
        Label("Guardar", systemImage: "bookmark")
    }
    .tint(.blue)
    
    Button(action: { sharePaper(paper) }) {
        Label("Compartir", systemImage: "square.and.arrow.up")
    }
    .tint(.green)
}
```

## Estados de la Vista

### 🔄 Loading State

```swift
/// Vista de carga
private var loadingView: some View {
    VStack(spacing: 20) {
        ProgressView()
            .scaleEffect(1.5)
        
        Text("Cargando artículos...")
            .font(.headline)
            .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemBackground))
}
```

### 📭 Empty State

```swift
/// Vista de estado vacío
private var emptyStateView: some View {
    VStack(spacing: 24) {
        Image(systemName: "doc.text.magnifyingglass")
            .font(.system(size: 64))
            .foregroundColor(.secondary)
        
        VStack(spacing: 12) {
            Text("No se encontraron artículos")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Intenta ajustar tus filtros de búsqueda o explora diferentes categorías")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        
        Button("Explorar Categorías") {
            showCategoryBrowser()
        }
        .buttonStyle(.borderedProminent)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
```

### ❌ Error State

```swift
/// Vista de error
private var errorView: some View {
    VStack(spacing: 24) {
        Image(systemName: "wifi.slash")
            .font(.system(size: 64))
            .foregroundColor(.red)
        
        VStack(spacing: 12) {
            Text("Error de Conexión")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("No se pudieron cargar los artículos. Verifica tu conexión a internet.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        
        Button("Reintentar") {
            Task {
                await controller.loadLatestPapers()
            }
        }
        .buttonStyle(.borderedProminent)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
```

## Optimizaciones de Rendimiento

### 🚀 Lazy Loading

```swift
/// Carga más datos cuando se acerca al final de la lista
private func loadMoreIfNeeded(_ paper: ArXivPaper) {
    guard let lastPaper = filteredPapers.last else { return }
    
    if paper.id == lastPaper.id {
        Task {
            await controller.loadMorePapers()
        }
    }
}

/// Implementación de infinite scroll
@State private var isLoadingMore = false

private var loadMoreIndicator: some View {
    HStack {
        if isLoadingMore {
            ProgressView()
                .scaleEffect(0.8)
        }
        Text("Cargando más artículos...")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    .padding()
}
```

### 💾 Gestión de Memoria

```swift
/// Limpia recursos cuando la vista desaparece
.onDisappear {
    searchText = ""
    activeFilters.removeAll()
}

/// Configura limits de memoria
private let maxVisibleItems = 100

private var limitedPapers: [ArXivPaper] {
    Array(filteredPapers.prefix(maxVisibleItems))
}
```

## Características de Accesibilidad

### ♿ Soporte para VoiceOver

```swift
/// Configuración de accesibilidad
.accessibilityElement(children: .combine)
.accessibilityLabel("Lista de artículos de ArXiv")
.accessibilityHint("Toca un artículo para ver más detalles")
.accessibilityAction(.escape) {
    // Acción de escape para navegación
}
```

### ⌨️ Navegación por Teclado

```swift
/// Soporte para navegación por teclado
.focusable(true)
.onMoveCommand { direction in
    handleKeyboardNavigation(direction)
}

private func handleKeyboardNavigation(_ direction: MoveCommandDirection) {
    switch direction {
    case .up:
        selectPreviousPaper()
    case .down:
        selectNextPaper()
    default:
        break
    }
}
```

## Personalización Visual

### 🎨 Theming

```swift
/// Configuración de tema
@Environment(\.colorScheme) var colorScheme

private var listBackgroundColor: Color {
    colorScheme == .dark ? .black : .white
}

private var separatorColor: Color {
    Color(.separator)
}
```

### 📐 Layout Adaptativo

```swift
/// Configuración de layout para diferentes tamaños de pantalla
@Environment(\.horizontalSizeClass) var horizontalSizeClass

private var columns: [GridItem] {
    switch horizontalSizeClass {
    case .compact:
        return [GridItem(.flexible())]
    case .regular:
        return [GridItem(.flexible()), GridItem(.flexible())]
    default:
        return [GridItem(.flexible())]
    }
}
```

## Integración con Otras Vistas

### 🔗 Comunicación con MainView

```swift
/// Binding para comunicación con vista padre
@Binding var selectedPaper: ArXivPaper?

/// Notifica selección a vista padre
private func selectPaper(_ paper: ArXivPaper) {
    selectedPaper = paper
    
    // Opcional: Analytics
    trackPaperSelection(paper)
}
```

### 📊 Métricas de Uso

```swift
/// Tracking de métricas de uso
private func trackPaperSelection(_ paper: ArXivPaper) {
    // Implementar analytics
    Analytics.track("paper_selected", properties: [
        "paper_id": paper.id,
        "category": paper.category,
        "search_query": searchText
    ])
}
```

## Ejemplo de Uso Completo

```swift
/// Ejemplo de integración completa
struct ExampleListView: View {
    @StateObject private var controller = ArXivController()
    @State private var selectedPaper: ArXivPaper?
    
    var body: some View {
        NavigationView {
            PapersListView(
                controller: controller,
                selectedPaper: $selectedPaper
            )
            .navigationTitle("Artículos ArXiv")
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

### ✅ Principios Implementados

1. **Responsabilidad Única**: Solo maneja visualización de listas
2. **Reactividad**: Responde a cambios de datos automáticamente
3. **Rendimiento**: Optimizada para listas grandes
4. **Accesibilidad**: Soporte completo para todos los usuarios

### 🔧 Configuración Avanzada

```swift
/// Configuración personalizable
struct PapersListConfig {
    let enableSearch: Bool = true
    let enableFilters: Bool = true
    let enableInfiniteScroll: Bool = true
    let pageSize: Int = 20
    let cacheSize: Int = 100
}
```

## Recursos Relacionados

- ``ArXivController`` - Controlador que proporciona los datos
- ``ArXivPaperRow`` - Componente individual de cada artículo
- ``MainView`` - Vista principal que contiene la lista
- ``PaperDetailView`` - Vista de detalle para artículos seleccionados
- ``SidebarView`` - Vista lateral para navegación por categorías
