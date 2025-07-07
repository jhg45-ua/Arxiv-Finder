# Guía de la API de ArXiv

## 🌐 Visión General de la API

ArXiv proporciona una API pública RESTful para acceder a metadatos de artículos científicos. Esta guía documenta cómo ArXiv App interactúa con esta API.

## 📡 Configuración de la API

### Base URL
```
https://export.arxiv.org/api/query
```

### Endpoints Utilizados

#### 1. Search Papers
```http
GET /api/query?search_query={query}&start={start}&max_results={max_results}
```

#### 2. Get Paper by ID
```http
GET /api/query?id_list={paper_id}
```

#### 3. Latest Papers by Category
```http
GET /api/query?search_query=cat:{category}&sortBy=submittedDate&sortOrder=descending
```

## 🔧 Implementación en ArXivService

### Estructura del Servicio

```swift
final class ArXivService {
    static let shared = ArXivService()
    private let baseURL = "https://export.arxiv.org/api/query"
    private let session = URLSession.shared
    
    private init() {}
}
```

### Métodos Principales

#### Search Papers
```swift
func searchPapers(
    query: String,
    start: Int = 0,
    maxResults: Int = 20,
    category: String? = nil
) async throws -> [ArXivPaper] {
    var components = URLComponents(string: baseURL)!
    
    // Construir query
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
    
    guard let url = components.url else {
        throw ArXivError.invalidURL
    }
    
    let (data, response) = try await session.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw ArXivError.networkError
    }
    
    return try ArXivSimpleParser.parse(data: data)
}
```

#### Get Latest Papers
```swift
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
    
    guard let url = components.url else {
        throw ArXivError.invalidURL
    }
    
    let (data, _) = try await session.data(from: url)
    return try ArXivSimpleParser.parse(data: data)
}
```

## 📊 Categorías de ArXiv

### Categorías Principales

#### Computer Science (cs)
- `cs.AI` - Artificial Intelligence
- `cs.CL` - Computation and Language
- `cs.CV` - Computer Vision and Pattern Recognition
- `cs.DB` - Databases
- `cs.DS` - Data Structures and Algorithms
- `cs.LG` - Machine Learning
- `cs.SE` - Software Engineering

#### Mathematics (math)
- `math.AG` - Algebraic Geometry
- `math.AP` - Analysis of PDEs
- `math.AT` - Algebraic Topology
- `math.CA` - Classical Analysis and ODEs
- `math.CO` - Combinatorics
- `math.NT` - Number Theory
- `math.ST` - Statistics Theory

#### Physics (physics)
- `physics.ao-ph` - Atmospheric and Oceanic Physics
- `physics.atom-ph` - Atomic Physics
- `physics.bio-ph` - Biological Physics
- `physics.comp-ph` - Computational Physics

### Uso en la App
```swift
enum ArXivCategory: String, CaseIterable {
    case computerScience = "cs"
    case mathematics = "math"
    case physics = "physics"
    case quantumPhysics = "quant-ph"
    case statistics = "stat"
    
    var displayName: String {
        switch self {
        case .computerScience: return "Computer Science"
        case .mathematics: return "Mathematics"
        case .physics: return "Physics"
        case .quantumPhysics: return "Quantum Physics"
        case .statistics: return "Statistics"
        }
    }
}
```

## 🔄 Parsing de Respuestas XML

### Estructura de Respuesta
```xml
<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
    <title>ArXiv Query: search_query=all</title>
    <entry>
        <id>http://arxiv.org/abs/2023.12345v1</id>
        <title>Paper Title</title>
        <summary>Paper abstract...</summary>
        <author>
            <name>Author Name</name>
        </author>
        <published>2023-12-01T00:00:00Z</published>
        <updated>2023-12-01T00:00:00Z</updated>
        <category term="cs.AI" scheme="http://arxiv.org/schemas/atom"/>
        <link href="http://arxiv.org/abs/2023.12345v1" rel="alternate" type="text/html"/>
        <link href="http://arxiv.org/pdf/2023.12345v1" rel="related" type="application/pdf"/>
    </entry>
</feed>
```

### Parser Implementation
```swift
final class ArXivSimpleParser {
    static func parse(data: Data) throws -> [ArXivPaper] {
        let parser = XMLParser(data: data)
        let delegate = ArXivXMLParserDelegate()
        parser.delegate = delegate
        
        guard parser.parse() else {
            throw ArXivError.parsingError
        }
        
        return delegate.papers
    }
}

final class ArXivXMLParserDelegate: NSObject, XMLParserDelegate {
    var papers: [ArXivPaper] = []
    private var currentPaper: ArXivPaper?
    private var currentElement: String = ""
    private var currentText: String = ""
    
    // XMLParserDelegate methods
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        currentText = ""
        
        if elementName == "entry" {
            currentPaper = ArXivPaper(
                id: "",
                title: "",
                summary: "",
                authors: "",
                publishedDate: Date(),
                updatedDate: Date(),
                categories: [],
                pdfURL: "",
                abstractURL: ""
            )
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        defer { currentText = "" }
        
        guard var paper = currentPaper else { return }
        
        switch elementName {
        case "id":
            paper.id = extractArXivID(from: currentText)
        case "title":
            paper.title = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "summary":
            paper.summary = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "published":
            paper.publishedDate = parseDate(from: currentText)
        case "updated":
            paper.updatedDate = parseDate(from: currentText)
        case "entry":
            papers.append(paper)
            currentPaper = nil
        default:
            break
        }
        
        currentPaper = paper
    }
    
    private func extractArXivID(from urlString: String) -> String {
        // Extraer ID de ArXiv de la URL
        let components = urlString.components(separatedBy: "/")
        return components.last ?? ""
    }
    
    private func parseDate(from dateString: String) -> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString) ?? Date()
    }
}
```

## 🚨 Manejo de Errores

### Errores Personalizados
```swift
enum ArXivError: Error, LocalizedError {
    case invalidURL
    case networkError
    case parsingError
    case noResults
    case rateLimited
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .networkError:
            return "Error de red"
        case .parsingError:
            return "Error al procesar datos"
        case .noResults:
            return "No se encontraron resultados"
        case .rateLimited:
            return "Límite de requests excedido"
        case .serverError(let code):
            return "Error del servidor: \(code)"
        }
    }
}
```

### Manejo en el Controller
```swift
@MainActor
func loadLatestPapers() async {
    isLoading = true
    errorMessage = nil
    
    do {
        let papers = try await ArXivService.shared.getLatestPapers()
        self.latestPapers = papers
    } catch let error as ArXivError {
        self.errorMessage = error.localizedDescription
    } catch {
        self.errorMessage = "Error inesperado: \(error.localizedDescription)"
    }
    
    isLoading = false
}
```

## 📈 Optimización y Límites

### Rate Limiting
- **Límite**: 3 requests por segundo
- **Burst**: Hasta 10 requests en ráfaga
- **Implementación**: Queue con delay

```swift
private let requestQueue = DispatchQueue(label: "arxiv.requests", qos: .utility)
private var lastRequestTime: Date = Date.distantPast
private let minimumRequestInterval: TimeInterval = 0.334 // ~3 requests/second

private func throttledRequest<T>(
    _ request: @escaping () async throws -> T
) async throws -> T {
    return try await withCheckedThrowingContinuation { continuation in
        requestQueue.async {
            let now = Date()
            let timeSinceLastRequest = now.timeIntervalSince(self.lastRequestTime)
            
            if timeSinceLastRequest < self.minimumRequestInterval {
                Thread.sleep(forTimeInterval: self.minimumRequestInterval - timeSinceLastRequest)
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
```

### Caching Strategy
```swift
private let cache = NSCache<NSString, NSData>()
private let cacheExpirationInterval: TimeInterval = 300 // 5 minutos

func getCachedResponse(for url: URL) -> Data? {
    let key = NSString(string: url.absoluteString)
    return cache.object(forKey: key) as Data?
}

func setCachedResponse(_ data: Data, for url: URL) {
    let key = NSString(string: url.absoluteString)
    cache.setObject(data as NSData, forKey: key)
}
```

## 🔍 Búsqueda Avanzada

### Query Building
```swift
struct ArXivQuery {
    var title: String?
    var author: String?
    var abstract: String?
    var categories: [String]?
    var dateRange: DateInterval?
    
    func buildQueryString() -> String {
        var components: [String] = []
        
        if let title = title, !title.isEmpty {
            components.append("ti:\"\(title)\"")
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
        
        return components.joined(separator: " AND ")
    }
}
```

### Uso en la App
```swift
func searchPapers(with query: ArXivQuery) async throws -> [ArXivPaper] {
    let queryString = query.buildQueryString()
    return try await ArXivService.shared.searchPapers(query: queryString)
}
```

---

*Esta documentación refleja la implementación actual de la integración con la API de ArXiv.*
