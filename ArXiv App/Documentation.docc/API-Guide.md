# ArXiv API Guide

Complete documentation of ArXiv API integration.

## 🌐 API Overview

ArXiv provides a public RESTful API for accessing scientific paper metadata. This guide documents how ArXiv App interacts with this API to retrieve, search, and process academic papers.

The API uses:
- **Protocol**: HTTPS for security
- **Format**: XML (Atom feed)
- **Authentication**: Not required
- **Rate Limiting**: 3 requests per second

## 📡 API Configuration

### Base URL
```
https://export.arxiv.org/api/query
```

### Main Endpoints

#### 1. 🔍 Paper Search
```http
GET /api/query?search_query={query}&start={start}&max_results={max_results}
```

**Parameters:**
- `search_query`: Search query
- `start`: Start index (pagination)
- `max_results`: Maximum number of results

#### 2. 📄 Get Paper by ID
```http
GET /api/query?id_list={paper_id}
```

**Parameters:**
- `id_list`: Comma-separated list of paper IDs

#### 3. 📚 Latest Papers by Category
```http
GET /api/query?search_query=cat:{category}&sortBy=submittedDate&sortOrder=descending
```

**Parameters:**
- `category`: ArXiv category (e.g.: cs.AI, math.CO)
- `sortBy`: Sort field
- `sortOrder`: Ascending/descending order

## 🔧 Implementation in ArXivService

### Service Structure

The ``ArXivService`` service encapsulates all API communication:

```swift
/// Main service for ArXiv communication
final class ArXivService {
    /// API base URL
    private let baseURL = "https://export.arxiv.org/api/query"
    
    /// Configured HTTP session
    private let session: URLSession
    
    /// Initialization with custom configuration
    init(configuration: URLSessionConfiguration = .default) {
        self.session = URLSession(configuration: configuration)
    }
}
```

### Search Methods

#### 🔍 General Search
```swift
/// Searches papers by general query
/// - Parameters:
///   - query: Search terms
///   - start: Starting index for pagination
///   - maxResults: Maximum number of results
///   - category: Optional category filter
/// - Returns: Array of found papers
func searchPapers(
    query: String,
    start: Int = 0,
    maxResults: Int = 20,
    category: String? = nil
) async throws -> [ArXivPaper] {
    var components = URLComponents(string: baseURL)!
    
    // Build query with filters
    var searchQuery = query
    if let category = category {
        searchQuery = "cat:\(category) AND (\(query))"
    }
    
    components.queryItems = [
        URLQueryItem(name: "search_query", value: searchQuery),
        URLQueryItem(name: "start", value: "\(start)"),
        URLQueryItem(name: "max_results", value: "\(maxResults)"),
        URLQueryItem(name: "sortBy", value: "relevance"),
        URLQueryItem(name: "sortOrder", value: "descending")
    ]
    
    return try await performRequest(url: components.url!)
}
```

#### 📈 Latest Papers
```swift
/// Gets the most recent papers
/// - Parameters:
///   - category: Optional category filter
///   - maxResults: Maximum number of results
/// - Returns: Array of recent papers
func getLatestPapers(
    category: String? = nil,
    maxResults: Int = 50
) async throws -> [ArXivPaper] {
    var components = URLComponents(string: baseURL)!
    
    var searchQuery = "all"
    if let category = category {
        searchQuery = "cat:\(category)"
    }
    
    components.queryItems = [
        URLQueryItem(name: "search_query", value: searchQuery),
        URLQueryItem(name: "start", value: "0"),
        URLQueryItem(name: "max_results", value: "\(maxResults)"),
        URLQueryItem(name: "sortBy", value: "submittedDate"),
        URLQueryItem(name: "sortOrder", value: "descending")
    ]
    
    return try await performRequest(url: components.url!)
}
```

## 📊 ArXiv Categories

### Main Categories

#### 💻 Computer Science (cs)
- `cs.AI` - Artificial Intelligence
- `cs.CL` - Computation and Language
- `cs.CV` - Computer Vision
- `cs.DB` - Databases
- `cs.DS` - Data Structures and Algorithms
- `cs.LG` - Machine Learning
- `cs.SE` - Ingeniería de Software

#### 🔢 Mathematics (math)
- `math.AG` - Geometría Algebraica
- `math.AP` - Análisis de EDPs
- `math.AT` - Topología Algebraica
- `math.CA` - Análisis Clásico
- `math.CO` - Combinatoria
- `math.NT` - Teoría de Números
- `math.ST` - Teoría Estadística

#### ⚛️ Physics (physics)
- `physics.ao-ph` - Física Atmosférica y Oceánica
- `physics.atom-ph` - Física Atómica
- `physics.bio-ph` - Biofísica
- `physics.comp-ph` - Física Computacional
- `physics.chem-ph` - Física Química
- `physics.class-ph` - Física Clásica
- `physics.data-an` - Análisis de Datos

#### 🧬 Quantitative Biology (q-bio)
- `q-bio.BM` - Biomoléculas
- `q-bio.CB` - Biología Celular
- `q-bio.GN` - Genómica
- `q-bio.MN` - Redes Moleculares
- `q-bio.NC` - Neurociencia Computacional
- `q-bio.PE` - Evolución Poblacional
- `q-bio.QM` - Métodos Cuantitativos
- `q-bio.SC` - Células Subceleulares
- `q-bio.TO` - Tejidos y Órganos

#### 💰 Quantitative Finance (q-fin)
- `q-fin.CP` - Precios Computacionales
- `q-fin.EC` - Economía
- `q-fin.GN` - Finanzas Generales
- `q-fin.MF` - Finanzas Matemáticas
- `q-fin.PM` - Gestión de Portafolios
- `q-fin.PR` - Gestión de Riesgos
- `q-fin.RM` - Gestión de Riesgos
- `q-fin.ST` - Trading Estadístico
- `q-fin.TR` - Trading y Microestructura

#### 📊 Statistics (stat)
- `stat.AP` - Aplicaciones
- `stat.CO` - Computación
- `stat.ME` - Metodología
- `stat.ML` - Machine Learning
- `stat.OT` - Otros Temas
- `stat.TH` - Teoría

#### ⚡ Electrical Engineering and Systems Science (eess)
- `eess.AS` - Procesamiento de Audio y Voz
- `eess.IV` - Procesamiento de Imágenes y Video
- `eess.SP` - Procesamiento de Señales
- `eess.SY` - Sistemas y Control

#### 💼 Economics (econ)
- `econ.EM` - Econometría
- `econ.GN` - Economía General
- `econ.TH` - Teoría Económica

### Enumeración de Categorías

```swift
/// Categorías principales de ArXiv
enum ArXivCategory: String, CaseIterable {
    case computerScience = "cs"
    case mathematics = "math"
    case physics = "physics"
    case quantitativeBiology = "q-bio"
    case quantitativeFinance = "q-fin"
    case statistics = "stat"
    case electricalEngineering = "eess"
    case economics = "econ"
    
    var displayName: String {
        switch self {
        case .computerScience: return "Computer Science"
        case .mathematics: return "Mathematics"
        case .physics: return "Physics"
        case .quantitativeBiology: return "Quantitative Biology"
        case .quantitativeFinance: return "Quantitative Finance"
        case .statistics: return "Statistics"
        case .electricalEngineering: return "Electrical Engineering"
        case .economics: return "Economics"
        }
    }
    
    var subcategories: [String] {
        switch self {
        case .computerScience:
            return ["cs.AI", "cs.CL", "cs.CV", "cs.DB", "cs.DS", "cs.LG", "cs.SE"]
        case .mathematics:
            return ["math.AG", "math.AP", "math.AT", "math.CA", "math.CO", "math.NT", "math.ST"]
        case .physics:
            return ["physics.ao-ph", "physics.atom-ph", "physics.bio-ph", "physics.comp-ph"]
        case .quantitativeBiology:
            return ["q-bio.BM", "q-bio.CB", "q-bio.GN", "q-bio.MN", "q-bio.NC", "q-bio.PE", "q-bio.QM", "q-bio.SC", "q-bio.TO"]
        case .quantitativeFinance:
            return ["q-fin.CP", "q-fin.EC", "q-fin.GN", "q-fin.MF", "q-fin.PM", "q-fin.PR", "q-fin.RM", "q-fin.ST", "q-fin.TR"]
        case .statistics:
            return ["stat.AP", "stat.CO", "stat.ME", "stat.ML", "stat.OT", "stat.TH"]
        case .electricalEngineering:
            return ["eess.AS", "eess.IV", "eess.SP", "eess.SY"]
        case .economics:
            return ["econ.EM", "econ.GN", "econ.TH"]
        }
    }
}
```
            return ["stat.AP", "stat.CO", "stat.ME", "stat.ML", "stat.TH"]
        }
    }
}
```

## 🔄 Procesamiento de Respuestas XML

### Estructura de Respuesta Atom

ArXiv devuelve respuestas en formato Atom XML:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
    <title>ArXiv Query: search_query=all</title>
    <entry>
        <id>http://arxiv.org/abs/2023.12345v1</id>
        <title>Título del Artículo</title>
        <summary>Resumen del artículo...</summary>
        <author>
            <name>Nombre del Autor</name>
        </author>
        <published>2023-12-01T00:00:00Z</published>
        <updated>2023-12-01T00:00:00Z</updated>
        <category term="cs.AI" scheme="http://arxiv.org/schemas/atom"/>
        <link href="http://arxiv.org/abs/2023.12345v1" rel="alternate" type="text/html"/>
        <link href="http://arxiv.org/pdf/2023.12345v1" rel="related" type="application/pdf"/>
    </entry>
</feed>
```

### Integración con Parser

El servicio utiliza ``ArXivSimpleParser`` para procesar las respuestas:

```swift
/// Procesa respuesta XML y devuelve artículos
private func performRequest(url: URL) async throws -> [ArXivPaper] {
    let (data, response) = try await session.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw ArXivError.networkError
    }
    
    // Utiliza el parser especializado
    return try ArXivSimpleParser().parse(data)
}
```

## 🚨 Manejo de Errores

### Errores Específicos de ArXiv

```swift
/// Errores específicos de la API de ArXiv
enum ArXivError: Error, LocalizedError {
    case invalidURL
    case networkError
    case parsingError
    case noResults
    case rateLimited
    case serverError(Int)
    case invalidQuery
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL de ArXiv inválida"
        case .networkError:
            return "Error de conexión con ArXiv"
        case .parsingError:
            return "Error al procesar respuesta XML"
        case .noResults:
            return "No se encontraron resultados"
        case .rateLimited:
            return "Límite de peticiones excedido"
        case .serverError(let code):
            return "Error del servidor ArXiv: \(code)"
        case .invalidQuery:
            return "Consulta de búsqueda inválida"
        case .timeout:
            return "Tiempo de espera agotado"
        }
    }
}
```

### Manejo en el Controlador

```swift
/// Manejo de errores en ArXivController
/// @MainActor
func loadLatestPapers() async {
    isLoading = true
    errorMessage = nil
    
    do {
        let papers = try await arXivService.getLatestPapers()
        self.latestPapers = papers
    } catch let error as ArXivError {
        self.errorMessage = error.localizedDescription
        handleSpecificError(error)
    } catch {
        self.errorMessage = "Error inesperado: \(error.localizedDescription)"
    }
    
    isLoading = false
}

private func handleSpecificError(_ error: ArXivError) {
    switch error {
    case .rateLimited:
        // Implementar retry con backoff
        scheduleRetry()
    case .networkError:
        // Mostrar opciones de conectividad
        showNetworkOptions()
    case .noResults:
        // Sugerir búsquedas alternativas
        showSearchSuggestions()
    default:
        break
    }
}
```

## 📈 Optimización y Rendimiento

### 🕒 Rate Limiting

ArXiv limita las peticiones a 3 por segundo:

```swift
/// Gestor de rate limiting
private class RateLimiter {
    private let queue = DispatchQueue(label: "arxiv.requests", qos: .utility)
    private var lastRequestTime: Date = Date.distantPast
    private let minimumInterval: TimeInterval = 0.334 // ~3 requests/second
    
    func throttledRequest<T>(
        _ request: @escaping () async throws -> T
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                let now = Date()
                let elapsed = now.timeIntervalSince(self.lastRequestTime)
                
                if elapsed < self.minimumInterval {
                    Thread.sleep(forTimeInterval: self.minimumInterval - elapsed)
                }
                
                self.lastRequestTime = Date()
                
                Task {
                    do {
                        let result = try await request()
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
```

### 💾 Estrategia de Caché

```swift
/// Caché para respuestas de la API
private class APICache {
    private let cache = NSCache<NSString, CachedResponse>()
    private let expirationInterval: TimeInterval = 300 // 5 minutos
    
    struct CachedResponse {
        let data: Data
        let timestamp: Date
    }
    
    func get(for url: URL) -> Data? {
        let key = NSString(string: url.absoluteString)
        
        guard let cached = cache.object(forKey: key) else {
            return nil
        }
        
        // Verificar si ha expirado
        if Date().timeIntervalSince(cached.timestamp) > expirationInterval {
            cache.removeObject(forKey: key)
            return nil
        }
        
        return cached.data
    }
    
    func set(_ data: Data, for url: URL) {
        let key = NSString(string: url.absoluteString)
        let cached = CachedResponse(data: data, timestamp: Date())
        cache.setObject(cached, forKey: key)
    }
}
```

## 🔍 Búsqueda Avanzada

### Constructor de Consultas

```swift
/// Constructor para consultas complejas de ArXiv
struct ArXivQuery {
    var title: String?
    var author: String?
    var abstract: String?
    var categories: [String]?
    var dateRange: DateInterval?
    var exactMatch: Bool = false
    
    /// Construye la consulta para la API
    func buildQueryString() -> String {
        var components: [String] = []
        
        if let title = title, !title.isEmpty {
            let prefix = exactMatch ? "ti:" : "ti:"
            components.append("\(prefix)\"\(title)\"")
        }
        
        if let author = author, !author.isEmpty {
            components.append("au:\"\(author)\"")
        }
        
        if let abstract = abstract, !abstract.isEmpty {
            components.append("abs:\"\(abstract)\"")
        }
        
        if let categories = categories, !categories.isEmpty {
            let categoryQuery = categories.map { "cat:\($0)" }.joined(separator: " OR ")
            components.append("(\(categoryQuery))")
        }
        
        if let dateRange = dateRange {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let startDate = formatter.string(from: dateRange.start)
            let endDate = formatter.string(from: dateRange.end)
            components.append("submittedDate:[\(startDate) TO \(endDate)]")
        }
        
        return components.joined(separator: " AND ")
    }
}
```

### Uso en la Aplicación

```swift
/// Ejemplo de búsqueda avanzada
func performAdvancedSearch() async throws -> [ArXivPaper] {
    let query = ArXivQuery(
        title: "machine learning",
        author: "Hinton",
        categories: ["cs.AI", "cs.LG"],
        dateRange: DateInterval(start: Date().addingTimeInterval(-365*24*3600), end: Date())
    )
    
    let queryString = query.buildQueryString()
    return try await arXivService.searchPapers(query: queryString)
}
```

## 🔗 Integración con el Patrón MVC

### Flujo de Datos

1. **Vista** solicita datos al **Controlador**
2. **Controlador** utiliza **ArXivService** para obtener datos
3. **ArXivService** realiza petición HTTP a la API
4. **ArXivSimpleParser** procesa respuesta XML
5. **Controlador** actualiza propiedades `@Published`
6. **Vista** se actualiza automáticamente

### Ejemplo de Integración

```swift
/// Integración completa en el controlador
/// @MainActor
class ArXivController: ObservableObject {
    @Published var papers: [ArXivPaper] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service = ArXivService()
    
    func searchPapers(query: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let results = try await service.searchPapers(query: query)
            self.papers = results
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
```

## 📚 Recursos Adicionales

### Enlaces Útiles

- [Documentación oficial de ArXiv API](https://arxiv.org/help/api)
- [Guía de categorías de ArXiv](https://arxiv.org/category_taxonomy)
- [Formato Atom RSS](https://tools.ietf.org/html/rfc4287)

### Componentes Relacionados

- ``ArXivService`` - Implementación del servicio
- ``ArXivSimpleParser`` - Parser XML especializado
- ``ArXivController`` - Controlador que utiliza la API
- ``ArXivPaper`` - Modelo de datos resultado

---

*Esta documentación refleja la implementación actual de la integración con la API de ArXiv y se actualiza continuamente.*
