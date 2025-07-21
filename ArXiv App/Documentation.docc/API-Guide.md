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
- `cs.SE` - Software Engineering

#### 🔢 Mathematics (math)
- `math.AG` - Algebraic Geometry
- `math.AP` - Analysis of PDEs
- `math.AT` - Algebraic Topology
- `math.CA` - Classical Analysis
- `math.CO` - Combinatorics
- `math.NT` - Number Theory
- `math.ST` - Statistical Theory

#### ⚛️ Physics (physics)
- `physics.ao-ph` - Atmospheric and Oceanic Physics
- `physics.atom-ph` - Atomic Physics
- `physics.bio-ph` - Biophysics
- `physics.comp-ph` - Computational Physics
- `physics.chem-ph` - Chemical Physics
- `physics.class-ph` - Classical Physics
- `physics.data-an` - Data Analysis

#### 🧬 Quantitative Biology (q-bio)
- `q-bio.BM` - Biomolecules
- `q-bio.CB` - Cell Biology
- `q-bio.GN` - Genomics
- `q-bio.MN` - Molecular Networks
- `q-bio.NC` - Computational Neuroscience
- `q-bio.PE` - Population Evolution
- `q-bio.QM` - Quantitative Methods
- `q-bio.SC` - Subcellular Cells
- `q-bio.TO` - Tissues and Organs

#### 💰 Quantitative Finance (q-fin)
- `q-fin.CP` - Computational Pricing
- `q-fin.EC` - Economics
- `q-fin.GN` - General Finance
- `q-fin.MF` - Mathematical Finance
- `q-fin.PM` - Portfolio Management
- `q-fin.PR` - Risk Management
- `q-fin.RM` - Risk Management
- `q-fin.ST` - Statistical Trading
- `q-fin.TR` - Trading and Microstructure

#### 📊 Statistics (stat)
- `stat.AP` - Applications
- `stat.CO` - Computation
- `stat.ME` - Methodology
- `stat.ML` - Machine Learning
- `stat.OT` - Other Topics
- `stat.TH` - Theory

#### ⚡ Electrical Engineering and Systems Science (eess)
- `eess.AS` - Audio and Speech Processing
- `eess.IV` - Image and Video Processing
- `eess.SP` - Signal Processing
- `eess.SY` - Systems and Control

#### 💼 Economics (econ)
- `econ.EM` - Econometrics
- `econ.GN` - General Economics
- `econ.TH` - Economic Theory

### Category Enumeration

```swift
/// Main ArXiv categories
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

## 🔄 XML Response Processing

### Atom Response Structure

ArXiv returns responses in Atom XML format:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
    <title>ArXiv Query: search_query=all</title>
    <entry>
        <id>http://arxiv.org/abs/2023.12345v1</id>
        <title>Article Title</title>
        <summary>Article summary...</summary>
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

### Integration with Parser

The service uses ``ArXivSimpleParser`` to process responses:

```swift
/// Processes XML response and returns articles
private func performRequest(url: URL) async throws -> [ArXivPaper] {
    let (data, response) = try await session.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw ArXivError.networkError
    }
    
    // Uses the specialized parser
    return try ArXivSimpleParser().parse(data)
}
```

## 🚨 Error Handling

### ArXiv-Specific Errors

```swift
/// ArXiv API specific errors
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
            return "Invalid ArXiv URL"
        case .networkError:
            return "Connection error with ArXiv"
        case .parsingError:
            return "Error processing XML response"
        case .noResults:
            return "No results found"
        case .rateLimited:
            return "Request limit exceeded"
        case .serverError(let code):
            return "ArXiv server error: \(code)"
        case .invalidQuery:
            return "Invalid search query"
        case .timeout:
            return "Timeout expired"
        }
    }
}
```

### Handling in the Controller

```swift
/// Error handling in ArXivController
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
        self.errorMessage = "Unexpected error: \(error.localizedDescription)"
    }
    
    isLoading = false
}

private func handleSpecificError(_ error: ArXivError) {
    switch error {
    case .rateLimited:
        // Implement retry with backoff
        scheduleRetry()
    case .networkError:
        // Show connectivity options
        showNetworkOptions()
    case .noResults:
        // Suggest alternative searches
        showSearchSuggestions()
    default:
        break
    }
}
```

## 📈 Optimization and Performance

### 🕒 Rate Limiting

ArXiv limits requests to 3 per second:

```swift
/// Rate limiting manager
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

### 💾 Cache Strategy

```swift
/// Cache for API responses
private class APICache {
    private let cache = NSCache<NSString, CachedResponse>()
    private let expirationInterval: TimeInterval = 300 // 5 minutes
    
    struct CachedResponse {
        let data: Data
        let timestamp: Date
    }
    
    func get(for url: URL) -> Data? {
        let key = NSString(string: url.absoluteString)
        
        guard let cached = cache.object(forKey: key) else {
            return nil
        }
        
        // Check if expired
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

## 🔍 Advanced Search

### Query Builder

```swift
/// Builder for complex ArXiv queries
struct ArXivQuery {
    var title: String?
    var author: String?
    var abstract: String?
    var categories: [String]?
    var dateRange: DateInterval?
    var exactMatch: Bool = false
    
    /// Builds the query for the API
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

### Usage in the Application

```swift
/// Example of advanced search
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

## 🔗 Integration with MVC Pattern

### Data Flow

1. **View** requests data from the **Controller**
2. **Controller** uses **ArXivService** to get data
3. **ArXivService** makes HTTP request to the API
4. **ArXivSimpleParser** processes XML response
5. **Controller** updates `@Published` properties
6. **View** updates automatically

### Integration Example

```swift
/// Full integration in the controller
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

## 📚 Additional Resources

### Useful Links

- [Official ArXiv API Documentation](https://arxiv.org/help/api)
- [ArXiv Category Guide](https://arxiv.org/category_taxonomy)
- [Atom RSS Format](https://tools.ietf.org/html/rfc4287)

### Related Components

- ``ArXivService`` - Service implementation
- ``ArXivSimpleParser`` - Specialized XML parser
- ``ArXivController`` - Controller using the API
- ``ArXivPaper`` - Result data model

---

*This documentation reflects the current implementation of the ArXiv API integration and is continuously updated.* 