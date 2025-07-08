# ArXivService

El servicio especializado para la comunicación con la API de ArXiv.

## Descripción General

``ArXivService`` es el componente responsable de toda la comunicación con la API externa de ArXiv. Maneja las peticiones HTTP, el procesamiento de respuestas XML y la conversión de datos en objetos ``ArXivPaper``. Este servicio encapsula toda la complejidad de la comunicación con el repositorio ArXiv.

La clase está diseñada siguiendo principios de:
- **Separación de responsabilidades** en la capa de servicios
- **Concurrencia moderna** con async/await
- **Manejo robusto de errores** con tipos específicos
- **Thread-safety** mediante `@unchecked Sendable`

## Arquitectura del Servicio

### 🌐 Comunicación con API

El servicio gestiona todas las interacciones con la API de ArXiv:

```swift
/// URL base de la API de ArXiv (usando HTTPS para cumplir con ATS)
private let baseURL = "https://export.arxiv.org/api/query"

/// Sesión HTTP configurada para peticiones optimizadas
private let session: URLSession
```

### 🔧 Configuración de Red

```swift
/// Configuración personalizada para peticiones HTTP
private func configureSession() -> URLSession {
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 30.0
    config.timeoutIntervalForResource = 60.0
    return URLSession(configuration: config)
}
```

## Funcionalidades Principales

### 📚 Obtención de Artículos Recientes

```swift
/// Obtiene los últimos artículos publicados en ArXiv
/// - Parameter count: Número de artículos a obtener (por defecto 10)
/// - Returns: Array de artículos de ArXiv
/// - Throws: Error si falla la petición o el parsing
nonisolated func fetchLatestPapers(count: Int = 10) async throws -> [ArXivPaper]
```

**Implementación detallada:**

```swift
func fetchLatestPapers(count: Int = 10) async throws -> [ArXivPaper] {
    // Construye URL con parámetros optimizados
    let query = "cat:cs.*+OR+cat:stat.*+OR+cat:math.*"
    let urlString = "\(baseURL)?search_query=\(query)&start=0&max_results=\(count)&sortBy=lastUpdatedDate&sortOrder=descending"
    
    guard let url = URL(string: urlString) else {
        throw ArXivError.invalidURL
    }
    
    // Ejecuta petición HTTP
    let (data, response) = try await session.data(from: url)
    
    // Valida respuesta
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw ArXivError.networkError
    }
    
    // Parsea XML y convierte a objetos ArXivPaper
    return try parseXMLResponse(data)
}
```

### 🏷️ Búsqueda por Categorías

```swift
/// Obtiene artículos de una categoría específica
/// - Parameter category: Categoría de ArXiv (ej: "cs.AI", "math.CO")
/// - Returns: Array de artículos de la categoría especificada
func fetchPapersByCategory(_ category: String) async throws -> [ArXivPaper] {
    let query = "cat:\(category)"
    return try await performSearch(query: query)
}
```

### 🔬 Métodos Específicos por Categoría

La aplicación incluye métodos especializados para cada categoría principal:

```swift
/// Obtiene artículos de Computer Science
func fetchComputerSciencePapers() async throws -> [ArXivPaper] {
    return try await fetchPapersByCategory("cs.*")
}

/// Obtiene artículos de Mathematics
func fetchMathematicsPapers() async throws -> [ArXivPaper] {
    return try await fetchPapersByCategory("math.*")
}

/// Obtiene artículos de Physics
func fetchPhysicsPapers() async throws -> [ArXivPaper] {
    return try await fetchPapersByCategory("physics.*")
}

/// Obtiene artículos de Quantitative Biology
func fetchQuantitativeBiologyPapers() async throws -> [ArXivPaper] {
    return try await fetchPapersByCategory("q-bio.*")
}

/// Obtiene artículos de Quantitative Finance
func fetchQuantitativeFinancePapers() async throws -> [ArXivPaper] {
    return try await fetchPapersByCategory("q-fin.*")
}

/// Obtiene artículos de Statistics
func fetchStatisticsPapers() async throws -> [ArXivPaper] {
    return try await fetchPapersByCategory("stat.*")
}

/// Obtiene artículos de Electrical Engineering and Systems Science
func fetchElectricalEngineeringPapers() async throws -> [ArXivPaper] {
    return try await fetchPapersByCategory("eess.*")
}

/// Obtiene artículos de Economics
func fetchEconomicsPapers() async throws -> [ArXivPaper] {
    return try await fetchPapersByCategory("econ.*")
}
```

**Categorías Soportadas:**
- **Computer Science** (`cs.*`) - Ciencias de la Computación
- **Mathematics** (`math.*`) - Matemáticas
- **Physics** (`physics.*`) - Física
- **Quantitative Biology** (`q-bio.*`) - Biología Cuantitativa
- **Quantitative Finance** (`q-fin.*`) - Finanzas Cuantitativas
- **Statistics** (`stat.*`) - Estadística
- **Electrical Engineering** (`eess.*`) - Ingeniería Eléctrica y Sistemas
- **Economics** (`econ.*`) - Economía

### 🔍 Búsqueda Avanzada

```swift
/// Busca artículos por términos específicos
/// - Parameter query: Términos de búsqueda
/// - Parameter maxResults: Máximo número de resultados
/// - Returns: Array de artículos que coinciden con la búsqueda
func searchPapers(query: String, maxResults: Int = 20) async throws -> [ArXivPaper] {
    // Codifica la consulta para URL
    let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    
    let searchQuery = "all:\(encodedQuery)"
    return try await performSearch(query: searchQuery, maxResults: maxResults)
}
```

## Procesamiento de Datos XML

### 🔄 Parsing de Respuestas

El servicio utiliza ``ArXivSimpleParser`` para procesar las respuestas XML:

```swift
/// Parsea la respuesta XML de ArXiv
/// - Parameter data: Datos XML de la respuesta
/// - Returns: Array de artículos parseados
private func parseXMLResponse(_ data: Data) throws -> [ArXivPaper] {
    let parser = ArXivSimpleParser()
    return try parser.parse(data)
}
```

### 📊 Transformación de Datos

```swift
/// Convierte un elemento XML en un objeto ArXivPaper
private func transformXMLToArXivPaper(_ element: XMLElement) -> ArXivPaper {
    return ArXivPaper(
        id: extractID(from: element),
        title: extractTitle(from: element),
        summary: extractSummary(from: element),
        authors: extractAuthors(from: element),
        publishedDate: extractPublishDate(from: element),
        updatedDate: extractUpdateDate(from: element),
        category: extractCategory(from: element),
        link: extractLink(from: element)
    )
}
```

## Manejo de Errores

### 🛡️ Tipos de Error Específicos

```swift
/// Errores específicos del servicio ArXiv
enum ArXivError: Error, LocalizedError {
    case invalidURL
    case networkError
    case parseError
    case noData
    case rateLimited
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL de ArXiv inválida"
        case .networkError:
            return "Error de conexión con ArXiv"
        case .parseError:
            return "Error al procesar respuesta de ArXiv"
        case .noData:
            return "No se encontraron datos"
        case .rateLimited:
            return "Límite de peticiones excedido"
        }
    }
}
```

### 🔄 Reintentos Automáticos

```swift
/// Ejecuta una petición con reintentos automáticos
private func performRequestWithRetry<T>(
    _ operation: @escaping () async throws -> T,
    maxRetries: Int = 3
) async throws -> T {
    var lastError: Error?
    
    for attempt in 0..<maxRetries {
        do {
            return try await operation()
        } catch {
            lastError = error
            if attempt < maxRetries - 1 {
                try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt))) * 1_000_000_000)
            }
        }
    }
    
    throw lastError ?? ArXivError.networkError
}
```

## Optimizaciones de Rendimiento

### 🚀 Caché de Peticiones

```swift
/// Caché para evitar peticiones duplicadas
private var requestCache: [String: [ArXivPaper]] = [:]
private let cacheTimeout: TimeInterval = 300 // 5 minutos

/// Obtiene datos del caché o realiza nueva petición
private func getCachedOrFetch(url: String) async throws -> [ArXivPaper] {
    if let cached = requestCache[url] {
        return cached
    }
    
    let papers = try await performRequest(url: url)
    requestCache[url] = papers
    return papers
}
```

### 📊 Paginación Eficiente

```swift
/// Obtiene artículos con paginación
/// - Parameters:
///   - query: Consulta de búsqueda
///   - start: Índice inicial
///   - maxResults: Máximo número de resultados por página
func fetchPaginatedPapers(
    query: String,
    start: Int = 0,
    maxResults: Int = 20
) async throws -> [ArXivPaper] {
    let urlString = "\(baseURL)?search_query=\(query)&start=\(start)&max_results=\(maxResults)"
    // ... implementación
}
```

## Configuración Avanzada

### ⚙️ Parámetros de Configuración

```swift
/// Configuración del servicio ArXiv
struct ArXivServiceConfig {
    let baseURL: String = "https://export.arxiv.org/api/query"
    let timeout: TimeInterval = 30.0
    let maxCacheSize: Int = 1000
    let defaultPageSize: Int = 20
    let maxRetries: Int = 3
}
```

### 🔧 Personalización de Peticiones

```swift
/// Personaliza los headers de las peticiones
private func customizeRequest(_ request: inout URLRequest) {
    request.setValue("ArXiv-App/1.0", forHTTPHeaderField: "User-Agent")
    request.setValue("application/atom+xml", forHTTPHeaderField: "Accept")
}
```

## Integración con el Controlador

### 🔗 Inyección de Dependencias

```swift
// En ArXivController
private let arXivService: ArXivService

init(service: ArXivService = ArXivService()) {
    self.arXivService = service
}
```

### 📱 Uso en Vistas

```swift
// Uso directo desde una vista (no recomendado)
struct DirectServiceView: View {
    @State private var papers: [ArXivPaper] = []
    private let service = ArXivService()
    
    var body: some View {
        List(papers, id: \.id) { paper in
            Text(paper.title)
        }
        .onAppear {
            Task {
                do {
                    papers = try await service.fetchLatestPapers()
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }
}
```

## Ejemplo de Uso Completo

```swift
// Ejemplo de uso completo del servicio
class ExampleUsage {
    private let service = ArXivService()
    
    func demonstrateUsage() async {
        do {
            // Obtener artículos recientes
            let latest = try await service.fetchLatestPapers(count: 10)
            print("Últimos artículos: \(latest.count)")
            
            // Buscar por categoría
            let aiPapers = try await service.fetchPapersByCategory("cs.AI")
            print("Artículos de IA: \(aiPapers.count)")
            
            // Búsqueda por términos
            let searchResults = try await service.searchPapers(query: "machine learning")
            print("Resultados de búsqueda: \(searchResults.count)")
            
        } catch {
            print("Error: \(error)")
        }
    }
}
```

## Mejores Prácticas

### ✅ Principios Implementados

1. **Responsabilidad Única**: Solo maneja comunicación con ArXiv
2. **Abstracción**: Oculta complejidad de XML y HTTP
3. **Reutilización**: Métodos reutilizables para diferentes tipos de búsqueda
4. **Robustez**: Manejo completo de errores y casos edge

### 🔧 Configuración de Producción

```swift
/// Configuración optimizada para producción
extension ArXivService {
    static func productionService() -> ArXivService {
        let config = ArXivServiceConfig()
        return ArXivService(config: config)
    }
}
```

## Recursos Relacionados

- ``ArXivSimpleParser`` - Parser XML especializado
- ``ArXivPaper`` - Modelo de datos resultado
- ``ArXivController`` - Controlador que usa el servicio
- ``ArXivError`` - Tipos de error específicos del servicio
