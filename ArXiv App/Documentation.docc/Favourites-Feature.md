# Favorites Functionality

Complete documentation of the favorites functionality in ArXiv App.

## 🌟 Overview

The favorites functionality allows users to mark papers of interest for later reading. This feature provides:

- **Persistent Storage**: Favorites are saved using SwiftData and persist between app sessions
- **Quick Access**: Dedicated "Favorites" section in navigation
- **Simple Management**: Toggle favorites with a tap from list and detail views
- **Visual Feedback**: Heart icons indicate favorite status

## 📱 User Interface

### Navigation

#### macOS
- **Sidebar**: "Favorites" button in the left sidebar
- **Paper List**: Heart icon in each paper row
- **Detail View**: Heart icon in the toolbar

#### iOS
- **Tab Navigation**: "Favorites" in the bottom navigation menu
- **Paper List**: Heart icon in each paper row
- **Detail View**: Heart icon in the navigation bar

### Visual States

#### Favorites Button States
- **Empty Heart (♡)**: The paper is not marked as favorite
- **Filled Heart (♥)**: The paper is marked as favorite
- **Color**: System accent color when marked as favorite

## 🏗️ Architecture

### Model Layer

#### ArXivPaper Properties
```swift
/// Indicates if the paper is marked as favorite
var isFavorite: Bool = false

/// Date when marked as favorite (only relevant if isFavorite is true)
var favoritedDate: Date?

/// Marks or unmarks the paper as favorite
func setFavorite(_ favorite: Bool) {
    self.isFavorite = favorite
    self.favoritedDate = favorite ? Date() : nil
}
```

### Controller Layer

#### ArXivController Methods
```swift
/// Loads all favorite papers from the database
func loadFavoritePapers() async

/// Toggles the favorite status of a paper
func toggleFavorite(for paper: ArXivPaper)

/// Updates a paper in all category lists
func updatePaperInAllCategories(_ paper: ArXivPaper)
```

### View Layer

#### PaperDetailView
- Shows the favorites button in the toolbar/navigation
- Calls `controller.toggleFavorite(for: paper)` when tapped

#### PapersListView
- Shows the favorites button in each paper row
- Includes "Favorites" in the navigation menu (iOS)

#### ArXivPaperRow
- Shows heart icon reflecting favorite status
- Handles quick favorite changes

#### SidebarView (macOS)
- Shows the "Favorites" button in the sidebar
- Calls `onFavoritesSelected` when tapped

## 💾 Data Persistence

### SwiftData Integration

The favorites functionality uses SwiftData for persistent storage:

```swift
/// ArXivPaper model with SwiftData annotation
@Model
final class ArXivPaper: @unchecked Sendable {
    // ... other properties
    
    /// Indicates if the paper is marked as favorite
    var isFavorite: Bool = false
    
    /// Fecha cuando se marcó como favorito
    var favoritedDate: Date?
}
```

### Implementación del Almacenamiento

#### Cargar Favoritos
```swift
func loadFavoritePapers() async {
    if let modelContext = modelContext {
        // Cargar desde SwiftData
        let descriptor = FetchDescriptor<ArXivPaper>(
            predicate: #Predicate<ArXivPaper> { $0.isFavorite == true }
        )
        let favoriteResults = try modelContext.fetch(descriptor)
        favoritePapers = favoriteResults.sorted { 
            $0.favoritedDate ?? Date.distantPast > $1.favoritedDate ?? Date.distantPast 
        }
    }
}
```

#### Guardar Favoritos
```swift
func toggleFavorite(for paper: ArXivPaper) {
    // Actualizar estado del artículo
    paper.setFavorite(!paper.isFavorite)
    
    // Guardar en SwiftData
    if let modelContext = modelContext {
        try modelContext.save()
    }
    
    // Actualizar listas locales
    updateFavoritesList()
}
```

## 🔄 Flujo de Datos

### Agregar a Favoritos
1. El usuario toca el icono de corazón
2. Se llama a `toggleFavorite(for:)`
3. Se actualiza la propiedad `isFavorite` del artículo
4. Los cambios se guardan en SwiftData
5. Se actualiza la lista local de favoritos
6. La UI refleja el cambio

### Quitar de Favoritos
1. El usuario toca el icono de corazón lleno
2. Se llama a `toggleFavorite(for:)`
3. Se establece la propiedad `isFavorite` del artículo a false
4. Los cambios se guardan en SwiftData
5. Se elimina el artículo de la lista de favoritos
6. La UI refleja el cambio

### Cargar Favoritos
1. El usuario navega a la sección "Favoritos"
2. Se llama a `loadFavoritePapers()`
3. El descriptor de fetch de SwiftData recupera los artículos favoritos
4. Los artículos se ordenan por `favoritedDate` (más recientes primero)
5. La UI muestra los artículos favoritos

## 🎨 Componentes de UI

### Botón de Favoritos

#### Implementación
```swift
Button(action: {
    controller.toggleFavorite(for: paper)
}) {
    Image(systemName: paper.isFavorite ? "heart.fill" : "heart")
        .foregroundColor(paper.isFavorite ? .red : .primary)
}
```

#### Estados Visuales
- **Sin Favorito**: Icono `heart` en color primario
- **Favorito**: Icono `heart.fill` en color rojo
- **Animación**: Transición suave entre estados

### Integración en Fila de Artículo

Cada fila de artículo incluye:
- Título del artículo y metadatos
- Botón de favoritos (icono de corazón)
- Espaciado y alineación adecuados

### Integración en Navegación

#### Barra Lateral de macOS
- Botón "Favoritos" en la lista de categorías
- Consistente con otros botones de categoría
- Muestra estado seleccionado cuando está activo

#### Navegación por Pestañas de iOS
- "Favoritos" en el menú de navegación inferior
- Integración adecuada con la barra de pestañas
- Soporte para insignias (mejora futura)

## 📊 Consideraciones de Rendimiento

### Gestión de Memoria
- Los favoritos se cargan bajo demanda
- SwiftData maneja consultas eficientes
- No hay retención innecesaria de datos

### Optimización de Base de Datos
- Consultas indexadas para la propiedad `isFavorite`
- Descriptores de fetch eficientes
- Uso adecuado de predicados

### Respuesta de la UI
- Retroalimentación inmediata en la UI
- Operaciones de datos asíncronas
- Animaciones suaves

## 🧪 Pruebas

### Pruebas Unitarias (Futuras)
- Probar cambios de estado de favoritos
- Probar persistencia de SwiftData
- Probar actualizaciones de estado de UI

### Pruebas de Integración (Futuras)
- Probar flujo completo de favoritos
- Probar persistencia de datos entre sesiones de app
- Probar integración de UI

## 🔮 Mejoras Futuras

### Características Potenciales
- **Colecciones de Favoritos**: Organizar favoritos en colecciones personalizadas
- **Exportar Favoritos**: Exportar artículos favoritos como bibliografía
- **Sincronización de Favoritos**: Sincronizar favoritos entre dispositivos
- **Notas de Favoritos**: Añadir notas personales a artículos favoritos
- **Búsqueda de Favoritos**: Buscar dentro de los artículos favoritos
- **Estadísticas de Favoritos**: Mostrar conteos y tendencias de favoritos

### Mejoras Técnicas
- **Operaciones por Lotes**: Operaciones masivas de favoritos/desfavoritos
- **Soporte Offline**: Mejor gestión de favoritos offline
- **Rendimiento**: Optimizar para listas grandes de favoritos
- **Accesibilidad**: Características mejoradas de accesibilidad

## 🔗 Documentación Relacionada

- [ArXivController](ArXivController.md) - Detalles de implementación del controlador
- [ArXivPaper](ArXivPaper.md) - Documentación del modelo de datos
- [Architecture](Architecture.md) - Arquitectura general de la app
- [MainView](MainView.md) - Implementación de vista principal
- [PapersListView](PapersListView.md) - Implementación de vista de lista
