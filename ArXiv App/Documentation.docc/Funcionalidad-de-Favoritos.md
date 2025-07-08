# Funcionalidad de Favoritos

Documentación completa de la funcionalidad de favoritos en ArXiv App.

## 🌟 Descripción General

La funcionalidad de favoritos permite a los usuarios marcar artículos de interés para lectura posterior. Esta característica proporciona:

- **Almacenamiento Persistente**: Los favoritos se guardan usando SwiftData y persisten entre sesiones de la app
- **Acceso Rápido**: Sección dedicada "Favoritos" en la navegación
- **Gestión Sencilla**: Alternancia de favoritos con un toque desde las vistas de lista y detalle
- **Retroalimentación Visual**: Iconos de corazón indican el estado de favorito

## 📱 Interfaz de Usuario

### Navegación

#### macOS
- **Barra Lateral**: Botón "Favoritos" en la barra lateral izquierda
- **Lista de Artículos**: Icono de corazón en cada fila de artículo
- **Vista de Detalle**: Icono de corazón en la barra de herramientas

#### iOS
- **Navegación por Pestañas**: "Favoritos" en el menú de navegación inferior
- **Lista de Artículos**: Icono de corazón en cada fila de artículo
- **Vista de Detalle**: Icono de corazón en la barra de navegación

### Estados Visuales

#### Estados del Botón de Favoritos
- **Corazón Vacío (♡)**: El artículo no está marcado como favorito
- **Corazón Lleno (♥)**: El artículo está marcado como favorito
- **Color**: Color de acento del sistema cuando está marcado como favorito

## 🏗️ Arquitectura

### Capa de Modelo

#### Propiedades de ArXivPaper
```swift
/// Indica si el artículo está marcado como favorito
var isFavorite: Bool = false

/// Fecha cuando se marcó como favorito (solo relevante si isFavorite es true)
var favoritedDate: Date?

/// Marca o desmarca el artículo como favorito
func setFavorite(_ favorite: Bool) {
    self.isFavorite = favorite
    self.favoritedDate = favorite ? Date() : nil
}
```

### Capa de Controlador

#### Métodos de ArXivController
```swift
/// Carga todos los artículos favoritos desde la base de datos
func loadFavoritePapers() async

/// Alterna el estado de favorito de un artículo
func toggleFavorite(for paper: ArXivPaper)

/// Actualiza un artículo en todas las listas de categorías
func updatePaperInAllCategories(_ paper: ArXivPaper)
```

### Capa de Vista

#### PaperDetailView
- Muestra el botón de favoritos en la barra de herramientas/navegación
- Llama a `controller.toggleFavorite(for: paper)` cuando se toca

#### PapersListView
- Muestra el botón de favoritos en cada fila de artículo
- Incluye "Favoritos" en el menú de navegación (iOS)

#### ArXivPaperRow
- Muestra icono de corazón que refleja el estado de favorito
- Maneja el cambio rápido de favoritos

#### SidebarView (macOS)
- Muestra el botón "Favoritos" en la barra lateral
- Llama a `onFavoritesSelected` cuando se toca

## 💾 Persistencia de Datos

### Integración con SwiftData

La funcionalidad de favoritos utiliza SwiftData para almacenamiento persistente:

```swift
/// Modelo ArXivPaper con anotación SwiftData
@Model
final class ArXivPaper: @unchecked Sendable {
    // ... otras propiedades
    
    /// Indica si el artículo está marcado como favorito
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
