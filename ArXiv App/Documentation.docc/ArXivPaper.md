# ArXivPaper

The fundamental data model representing an ArXiv academic paper.

## Overview

``ArXivPaper`` is the main data model class that represents a scientific paper from the ArXiv repository. It uses SwiftData for local persistence and provides a complete structure for storing all relevant metadata of an academic paper.

This class is designed to be:
- **Thread-safe** through `@unchecked Sendable`
- **Persistent** using SwiftData with `@Model`
- **Efficient** with properties optimized for search and display

## Data Structure

### 🔑 Main Properties

The ``ArXivPaper`` model includes the following essential properties:

```swift
/// Unique identifier of the paper in ArXiv (e.g.: "2023.12345v1")
var id: String

/// Complete title of the scientific paper
var title: String

/// Abstract or summary of the paper
var summary: String

/// List of paper authors, comma-separated
var authors: String
```

### 📅 Temporal Metadata

```swift
/// Publication date of the paper
var publishedDate: Date

/// Last update date of the paper (if available)
var updatedDate: Date?
```

### 🏷️ Categorization and Links

```swift
/// Main category of the paper (e.g.: "cs.AI", "math.CO")
var category: String

/// Direct URL to the paper on ArXiv
var link: String
```

## Key Functionalities

### 🔍 Search and Filtering

The model is optimized for efficient searches:

- **Title search**: Using optimized indexes in SwiftData
- **Category filtering**: Automatic grouping by academic disciplines
- **Temporal sorting**: Support for sorting by publication or update date

### 💾 Local Persistence

``ArXivPaper`` uses SwiftData for:

- **Offline storage**: Papers are saved locally for offline access
- **Synchronization**: Automatic updates with the latest ArXiv data
- **Performance optimization**: Lazy loading of papers for large lists

### 🔄 MVC Integration

The model integrates seamlessly with the MVC pattern:

- **Model**: ``ArXivPaper`` encapsulates all paper data
- **View**: SwiftUI views automatically update when data changes
- **Controller**: ``ArXivController`` handles CRUD operations and business logic

## Usage Example

### Creating a Paper

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

### Search and Filtering

```swift
// Filter papers by category
let aiPapers = papers.filter { $0.category.hasPrefix("cs.AI") }

// Search by title
let searchResults = papers.filter { 
    $0.title.localizedCaseInsensitiveContains("machine learning") 
}

// Sort by publication date
let sortedPapers = papers.sorted { $0.publishedDate > $1.publishedDate }
```

## Best Practices

### 🛡️ Data Validation

```swift
// Validate ArXiv ID
func isValidArXivID(_ id: String) -> Bool {
    let pattern = #"^\d{4}\.\d{4,5}v\d+$"#
    return id.range(of: pattern, options: .regularExpression) != nil
}
```

### 🎯 Performance Optimization

- **Lazy Loading**: Only loads data necessary for the current view
- **Indexes**: Uses SwiftData indexes for fast searches
- **Cache**: Implements in-memory cache for frequently accessed papers

## Relationship with Other Components

### 🔗 Interaction with ArXivService

``ArXivService`` creates ``ArXivPaper`` instances from XML data:

```swift
// Service parses XML and creates ArXivPaper objects
let papers = try await ArXivService().fetchLatestPapers(count: 20)
```

### 🎛️ Management by ArXivController

``ArXivController`` handles ``ArXivPaper`` collections:

```swift
// Controller organizes papers by categories
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
