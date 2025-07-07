# ArXivPaper

El modelo de datos fundamental que representa un artículo académico de ArXiv.

@Metadata {
    @DocumentationExtension(mergeBehavior: append)
}

## Descripción General

``ArXivPaper`` es la clase principal del modelo de datos que representa un artículo científico del repositorio ArXiv. Utiliza SwiftData para persistencia local y proporciona una estructura completa para almacenar todos los metadatos relevantes de un artículo académico.

Esta clase está diseñada para ser:
- **Thread-safe** mediante `@unchecked Sendable`
- **Persistente** usando SwiftData con `@Model`
- **Eficiente** con propiedades optimizadas para búsqueda y visualización

## Estructura de Datos

### 🔑 Propiedades Principales

El modelo ``ArXivPaper`` incluye las siguientes propiedades esenciales:

```swift
/// Identificador único del artículo en ArXiv (ej: "2023.12345v1")
var id: String

/// Título completo del artículo científico
var title: String

/// Resumen o abstract del artículo
var summary: String

/// Lista de autores del artículo, separados por comas
var authors: String
```

### 📅 Metadatos Temporales

```swift
/// Fecha de publicación del artículo
var publishedDate: Date

/// Fecha de última actualización del artículo (si está disponible)
var updatedDate: Date?
```

### 🏷️ Categorización y Enlaces

```swift
/// Categoría principal del artículo (ej: "cs.AI", "math.CO")
var category: String

/// URL directa al artículo en ArXiv
var link: String
```

## Funcionalidades Clave

### 🔍 Búsqueda y Filtrado

El modelo está optimizado para búsquedas eficientes:

- **Búsqueda por título**: Utilizando índices optimizados en SwiftData
- **Filtrado por categoría**: Agrupación automática por disciplinas académicas
- **Ordenamiento temporal**: Soporte para ordenar por fecha de publicación o actualización

### 💾 Persistencia Local

``ArXivPaper`` utiliza SwiftData para:

- **Almacenamiento offline**: Los artículos se guardan localmente para acceso sin conexión
- **Sincronización**: Actualización automática con los datos más recientes de ArXiv
- **Optimización de rendimiento**: Carga lazy de artículos para listas grandes

### 🔄 Integración con MVC

El modelo se integra perfectamente con el patrón MVC:

- **Modelo**: ``ArXivPaper`` encapsula todos los datos del artículo
- **Vista**: Las vistas SwiftUI se actualizan automáticamente cuando cambian los datos
- **Controlador**: ``ArXivController`` maneja las operaciones CRUD y la lógica de negocio

## Ejemplo de Uso

### Creación de un Artículo

```swift
let paper = ArXivPaper(
    id: "2023.12345v1",
    title: "Advances in Machine Learning",
    summary: "This paper presents new approaches to ML...",
    authors: "John Doe, Jane Smith",
    publishedDate: Date(),
    updatedDate: nil,
    category: "cs.AI",
    link: "https://arxiv.org/abs/2023.12345"
)
```

### Búsqueda y Filtrado

```swift
// Filtrar artículos por categoría
let aiPapers = papers.filter { $0.category.hasPrefix("cs.AI") }

// Buscar por título
let searchResults = papers.filter { 
    $0.title.localizedCaseInsensitiveContains("machine learning") 
}

// Ordenar por fecha de publicación
let sortedPapers = papers.sorted { $0.publishedDate > $1.publishedDate }
```

## Mejores Prácticas

### 🛡️ Validación de Datos

```swift
// Validar ID de ArXiv
func isValidArXivID(_ id: String) -> Bool {
    let pattern = #"^\d{4}\.\d{4,5}v\d+$"#
    return id.range(of: pattern, options: .regularExpression) != nil
}
```

### 🎯 Optimización de Rendimiento

- **Lazy Loading**: Carga solo los datos necesarios para la vista actual
- **Índices**: Utiliza índices en SwiftData para búsquedas rápidas
- **Caché**: Implementa caché en memoria para artículos frecuentemente accedidos

## Relación con Otros Componentes

### 🔗 Interacción con ArXivService

``ArXivService`` crea instancias de ``ArXivPaper`` a partir de datos XML:

```swift
// El servicio parsea XML y crea objetos ArXivPaper
let papers = try await ArXivService().fetchLatestPapers(count: 20)
```

### 🎛️ Gestión por ArXivController

``ArXivController`` maneja colecciones de ``ArXivPaper``:

```swift
// El controlador organiza los papers por categorías
@Published var latestPapers: [ArXivPaper] = []
@Published var csPapers: [ArXivPaper] = []
@Published var mathPapers: [ArXivPaper] = []
```

### 🖥️ Visualización en Views

Las vistas SwiftUI utilizan ``ArXivPaper`` para mostrar información:

```swift
// Vista de lista que muestra papers
ForEach(papers) { paper in
    ArXivPaperRow(paper: paper)
}
```

## Consideraciones de Diseño

### 🏗️ Arquitectura Thread-Safe

La clase utiliza `@unchecked Sendable` para permitir el uso en contextos concurrentes, asegurando que las operaciones de red y UI no bloqueen el hilo principal.

### 📱 Compatibilidad Multiplataforma

El modelo está diseñado para funcionar tanto en iOS como macOS, adaptándose automáticamente a las capacidades específicas de cada plataforma.

### 🔄 Extensibilidad

La estructura permite añadir fácilmente nuevas propiedades sin romper la compatibilidad existente:

```swift
// Futuras extensiones podrían incluir:
var citations: Int?
var downloadCount: Int?
var tags: [String]?
```

## Recursos Relacionados

- ``ArXivController`` - Controlador que maneja la lógica de negocio
- ``ArXivService`` - Servicio para comunicación con la API
- ``ArXivPaperRow`` - Vista para mostrar un artículo individual
- ``PaperDetailView`` - Vista detallada de un artículo
