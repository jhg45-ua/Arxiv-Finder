# ArXivService

The specialized service for communication with the ArXiv API.

## Overview

``ArXivService`` is the component responsible for all communication with the external ArXiv API. It handles HTTP requests, XML response processing, and data conversion into ``ArXivPaper`` objects. This service encapsulates all the complexity of communication with the ArXiv repository.

The class is designed following principles of:
- **Separation of responsibilities** in the service layer
- **Modern concurrency** with async/await
- **Robust error handling** with specific types
- **Thread-safety** through `@unchecked Sendable`

## Service Architecture

### 🌐 API Communication

The service manages all interactions with the ArXiv API:

```swift
/// Base URL of the ArXiv API (using HTTPS to comply with ATS)
private let baseURL = "https://export.arxiv.org/api/query"

/// HTTP session configured for optimized requests
private let session: URLSession
```

### 🔧 Network Configuration

```swift
/// Custom configuration for HTTP requests
private func configureSession() -> URLSession {
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 30.0
    config.timeoutIntervalForResource = 60.0
    return URLSession(configuration: config)
}
```

## Main Functionalities

### 📚 Fetching Recent Papers

```swift
/// Gets the latest papers published on ArXiv
/// - Parameter count: Number of papers to fetch (default 10)
/// - Returns: Array of ArXiv papers
/// - Throws: Error if request or parsing fails
nonisolated func fetchLatestPapers(count: Int = 10) async throws -> [ArXivPaper]
```

**Detailed implementation:**

```swift
func fetchLatestPapers(count: Int = 10) async throws -> [ArXivPaper] {
    // Build URL with optimized parameters
    let query = "cat:cs.*+OR+cat:stat.*+OR+cat:math.*"
    let urlString = "\(baseURL)?search_query=\(query)&start=0&max_results=\(count)&sortBy=lastUpdatedDate&sortOrder=descending"
    
    guard let url = URL(string: urlString) else {
        throw ArXivError.invalidURL
    }
    
    // Execute HTTP request
    let (data, response) = try await session.data(from: url)
    
    // Validate response
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw ArXivError.networkError
    }
    
    // Parse XML and convert to ArXivPaper objects
    return try parseXMLResponse(data)
}
```

### 🏷️ Search by Categories

```swift
/// Gets papers from a specific category
/// - Parameter category: ArXiv category (e.g.: "cs.AI", "math.CO")
/// - Returns: Array of papers from the specified category
func fetchPapersByCategory(_ category: String) async throws -> [ArXivPaper] {
    let query = "cat:\(category)"
    return try await performSearch(query: query)
}
```

### 🔬 Category-Specific Methods

The application includes specialized methods for each main category:

```swift
/// Gets Computer Science papers
func fetchComputerSciencePapers() async throws -> [ArXivPaper] {
    return try await fetchPapersByCategory("cs.*")
}

/// Gets Mathematics papers
func fetchMathematicsPapers() async throws -> [ArXivPaper] {
    return try await fetchPapersByCategory("math.*")
}

/// Gets Physics papers
func fetchPhysicsPapers() async throws -> [ArXivPaper] {
    return try await fetchPapersByCategory("physics.*")
}

/// Gets Quantitative Biology papers
func fetchQuantitativeBiologyPapers() async throws -> [ArXivPaper] {
    return try await fetchPapersByCategory("q-bio.*")
}

/// Gets Quantitative Finance papers
func fetchQuantitativeFinancePapers() async throws -> [ArXivPaper] {
    return try await fetchPapersByCategory("q-fin.*")
}

/// Gets Statistics papers
func fetchStatisticsPapers() async throws -> [ArXivPaper] {
    return try await fetchPapersByCategory("stat.*")
}

/// Gets Electrical Engineering and Systems Science papers
func fetchElectricalEngineeringPapers() async throws -> [ArXivPaper] {
    return try await fetchPapersByCategory("eess.*")
}

/// Gets Economics papers
func fetchEconomicsPapers() async throws -> [ArXivPaper] {
    return try await fetchPapersByCategory("econ.*")
}
```

**Supported Categories:**
- **Computer Science** (`cs.*`)
- **Mathematics** (`math.*`)
- **Physics** (`physics.*`)
- **Quantitative Biology** (`q-bio.*`)
- **Quantitative Finance** (`q-fin.*`)
- **Statistics** (`stat.*`)
- **Electrical Engineering** (`eess.*`)
- **Economics** (`econ.*`)

### 🔍 Advanced Search

```swift
/// Searches papers by specific terms
/// - Parameter query: Search terms
/// - Parameter maxResults: Maximum number of results
/// - Returns: Array of papers matching the search
func searchPapers(query: String, maxResults: Int = 20) async throws -> [ArXivPaper] {
    // Encode the query for URL
    let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    
    let searchQuery = "all:\(encodedQuery)"
    return try await performSearch(query: searchQuery, maxResults: maxResults)
}
```

## XML Data Processing

### 🔄 Response Parsing

The service uses ``ArXivSimpleParser`` to process XML responses:

```swift
/// Parses the XML response from ArXiv
/// - Parameter data: XML response data
/// - Returns: Array of parsed papers
private func parseXMLResponse(_ data: Data) throws -> [ArXivPaper] {
    let parser = ArXivSimpleParser()
    return try parser.parse(data)
}
```

### 📊 Data Transformation

```swift
/// Converts an XML element into an ArXivPaper object
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

## Error Handling

### 🛡️ Specific Error Types

```swift
/// Specific errors for the ArXiv service
enum ArXivError: Error, LocalizedError {
    case invalidURL
    case networkError
    case parseError
    case noData
    case rateLimited
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid ArXiv URL"
        case .networkError:
            return "Connection error with ArXiv"
        case .parseError:
            return "Error processing ArXiv response"
        case .noData:
            return "No data found"
        case .rateLimited:
            return "Request limit exceeded"
        }
    }
}
```

### 🔄 Automatic Retries

```swift
/// Executes a request with automatic retries
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

## Performance Optimizations

### 🚀 Request Cache

```swift
/// Cache to avoid duplicate requests
private var requestCache: [String: [ArXivPaper]] = [:]
private let cacheTimeout: TimeInterval = 300 // 5 minutes

/// Gets data from cache or makes a new request
private func getCachedOrFetch(url: String) async throws -> [ArXivPaper] {
    if let cached = requestCache[url] {
        return cached
    }
    
    let papers = try await performRequest(url: url)
    requestCache[url] = papers
    return papers
}
```

### 📊 Efficient Pagination

```swift
/// Gets papers with pagination
/// - Parameters:
///   - query: Search query
///   - start: Start index
///   - maxResults: Maximum number of results per page
func fetchPaginatedPapers(
    query: String,
    start: Int = 0,
    maxResults: Int = 20
) async throws -> [ArXivPaper] {
    let urlString = "\(baseURL)?search_query=\(query)&start=\(start)&max_results=\(maxResults)"
    // ... implementation
}
```

## Advanced Configuration

### ⚙️ Configuration Parameters

```swift
/// ArXiv service configuration
struct ArXivServiceConfig {
    let baseURL: String = "https://export.arxiv.org/api/query"
    let timeout: TimeInterval = 30.0
    let maxCacheSize: Int = 1000
    let defaultPageSize: Int = 20
    let maxRetries: Int = 3
}
```

### 🔧 Request Customization

```swift
/// Customize request headers
private func customizeRequest(_ request: inout URLRequest) {
    request.setValue("ArXiv-App/1.0", forHTTPHeaderField: "User-Agent")
    request.setValue("application/atom+xml", forHTTPHeaderField: "Accept")
}
```

## Controller Integration

### 🔗 Dependency Injection

```swift
// In ArXivController
private let arXivService: ArXivService

init(service: ArXivService = ArXivService()) {
    self.arXivService = service
}
```

### 📱 Usage in Views

```swift
// Direct use from a view (not recommended)
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

## Full Usage Example

```swift
// Full usage example of the service
class ExampleUsage {
    private let service = ArXivService()
    
    func demonstrateUsage() async {
        do {
            // Get recent papers
            let latest = try await service.fetchLatestPapers(count: 10)
            print("Latest papers: \(latest.count)")
            
            // Search by category
            let aiPapers = try await service.fetchPapersByCategory("cs.AI")
            print("AI papers: \(aiPapers.count)")
            
            // Search by terms
            let searchResults = try await service.searchPapers(query: "machine learning")
            print("Search results: \(searchResults.count)")
            
        } catch {
            print("Error: \(error)")
        }
    }
}
```

## Best Practices

### ✅ Implemented Principles

1. **Single Responsibility**: Only handles communication with ArXiv
2. **Abstraction**: Hides XML and HTTP complexity
3. **Reusability**: Reusable methods for different search types
4. **Robustness**: Complete error and edge case handling

### 🔧 Production Configuration

```swift
/// Optimized configuration for production
extension ArXivService {
    static func productionService() -> ArXivService {
        let config = ArXivServiceConfig()
        return ArXivService(config: config)
    }
}
```

## Related Resources

- ``ArXivSimpleParser`` - Specialized XML parser
- ``ArXivPaper`` - Result data model
- ``ArXivController`` - Controller using the service
- ``ArXivError`` - Specific service error types 