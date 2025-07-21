# ArXivSimpleParser

Specialized XML parser for processing ArXiv API responses.

## Overview

``ArXivSimpleParser`` is a specialized component responsible for processing XML responses from the ArXiv API and converting them into usable ``ArXivPaper`` objects in the application. It implements a robust and efficient XML parser that handles the specific peculiarities of the Atom format used by ArXiv.

This class is designed following principles of:
- **Single responsibility** in XML processing
- **Robustness** in handling malformed data
- **Efficiency** in processing large volumes of data
- **Extensibility** for new ArXiv fields

## Parser Architecture

### 🔧 Technology Used

The parser uses Foundation's `XMLParser` for efficient processing:

```swift
/// XML parser specialized for ArXiv's Atom format
final class ArXivSimpleParser: NSObject, XMLParserDelegate {
    /// Papers parsed during processing
    private var papers: [ArXivPaper] = []
    
    /// Current paper being processed
    private var currentPaper: ArXivPaper?
    
    /// Current XML element
    private var currentElement: String = ""
    
    /// Content of current element
    private var currentValue: String = ""
}
```

### 🏗️ XML Data Structure

ArXiv uses Atom format with specific structure:

```xml
<feed xmlns="http://www.w3.org/2005/Atom">
    <entry>
        <id>http://arxiv.org/abs/2023.12345v1</id>
        <title>Paper title</title>
        <summary>Paper summary...</summary>
        <author>
            <name>Author name</name>
        </author>
        <published>2023-12-01T00:00:00Z</published>
        <updated>2023-12-01T00:00:00Z</updated>
        <category term="cs.AI" scheme="http://arxiv.org/schemas/atom"/>
        <link href="http://arxiv.org/abs/2023.12345v1"/>
    </entry>
</feed>
```

## Main Functionalities

### 📜 Main Parsing

```swift
/// Parses ArXiv XML data and returns array of papers
/// - Parameter data: XML data from ArXiv response
/// - Returns: Array of parsed papers
/// - Throws: Error if XML is invalid or malformed
func parse(_ data: Data) throws -> [ArXivPaper] {
    // Reset parser state
    papers.removeAll()
    currentPaper = nil
    currentElement = ""
    currentValue = ""
    
    // Create and configure XML parser
    let parser = XMLParser(data: data)
    parser.delegate = self
    
    // Execute parsing
    guard parser.parse() else {
        if let error = parser.parserError {
            throw ArXivParserError.xmlParsingFailed(error)
        }
        throw ArXivParserError.unknownError
    }
    
    return papers
}
```

### 🔍 Element Processing

```swift
/// Starts processing an XML element
func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName: String?, attributes: [String: String] = [:]) {
    currentElement = elementName
    currentValue = ""
    
    switch elementName {
    case "entry":
        // Start a new paper
        currentPaper = ArXivPaper()
    case "category":
        // Process categories with attributes
        if let term = attributes["term"] {
            currentPaper?.category = term
        }
    case "link":
        // Process links with attributes
        if let href = attributes["href"] {
            currentPaper?.link = href
        }
    default:
        break
    }
}
```

### 📝 Content Processing

```swift
/// Processes the text content of XML elements
func parser(_ parser: XMLParser, foundCharacters string: String) {
    currentValue += string.trimmingCharacters(in: .whitespacesAndNewlines)
}
```

### ✅ Element Completion

```swift
/// Completes the processing of an XML element
func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName: String?) {
    defer {
        currentElement = ""
        currentValue = ""
    }
    
    guard var paper = currentPaper else { return }
    
    switch elementName {
    case "entry":
        // Finish the current paper
        papers.append(paper)
        currentPaper = nil
    case "id":
        paper.id = extractArXivID(from: currentValue)
    case "title":
        paper.title = cleanTitle(currentValue)
    case "summary":
        paper.summary = cleanSummary(currentValue)
    case "name":
        // Process author names
        paper.authors = processAuthorName(currentValue, existing: paper.authors)
    case "published":
        paper.publishedDate = parseDate(currentValue)
    case "updated":
        paper.updatedDate = parseDate(currentValue)
    default:
        break
    }
    
    currentPaper = paper
}
```

## Specific Data Processing

### 🔗 ArXiv ID Extraction

```swift
/// Extracts the ArXiv ID from the full URL
/// - Parameter fullURL: Full article URL
/// - Returns: Clean ArXiv ID (e.g.: "2023.12345v1")
private func extractArXivID(from fullURL: String) -> String {
    // Example: "http://arxiv.org/abs/2023.12345v1" -> "2023.12345v1"
    let components = fullURL.components(separatedBy: "/")
    return components.last ?? fullURL
}
```

### 🧹 Title Cleaning

```swift
/// Cleans and formats article titles
/// - Parameter rawTitle: Raw title
/// - Returns: Clean and formatted title
private func cleanTitle(_ rawTitle: String) -> String {
    return rawTitle
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .replacingOccurrences(of: "\n", with: " ")
        .replacingOccurrences(of: "  ", with: " ")
}
```

### 📄 Summary Processing

```swift
/// Processes and cleans article summaries
/// - Parameter rawSummary: Raw summary
/// - Returns: Clean and formatted summary
private func cleanSummary(_ rawSummary: String) -> String {
    return rawSummary
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .replacingOccurrences(of: "\n", with: " ")
        .replacingOccurrences(of: "  ", with: " ")
}
```

### 👥 Author Management

```swift
/// Processes author names and concatenates them
/// - Parameters:
///   - newAuthor: New author to add
///   - existing: Existing authors
/// - Returns: String with all authors separated by commas
private func processAuthorName(_ newAuthor: String, existing: String) -> String {
    let cleanName = newAuthor.trimmingCharacters(in: .whitespacesAndNewlines)
    
    if existing.isEmpty {
        return cleanName
    } else {
        return "\(existing), \(cleanName)"
    }
}
```

### 📅 Date Parsing

```swift
/// Parses dates in ArXiv's ISO 8601 format
/// - Parameter dateString: Date as string
/// - Returns: Parsed Date object
private func parseDate(_ dateString: String) -> Date {
    let formatter = ISO8601DateFormatter()
    return formatter.date(from: dateString) ?? Date()
}
```

## Error Handling

### 🛡️ Specific Error Types

```swift
/// Specific errors for the XML parser
enum ArXivParserError: Error, LocalizedError {
    case xmlParsingFailed(Error)
    case invalidDateFormat(String)
    case missingRequiredField(String)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .xmlParsingFailed(let error):
            return "XML parsing error: \(error.localizedDescription)"
        case .invalidDateFormat(let date):
            return "Invalid date format: \(date)"
        case .missingRequiredField(let field):
            return "Missing required field: \(field)"
        case .unknownError:
            return "Unknown parser error"
        }
    }
}
```

### 🔄 Error Recovery

```swift
/// Handles errors during parsing
func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    print("❌ XML parsing error: \(parseError)")
    
    // Attempt to recover partial data
    if !papers.isEmpty {
        print("✅ Recovering \(papers.count) processed papers")
    }
}
```

## Performance Optimizations

### 🚀 Streaming Parser

```swift
/// Processes XML in streaming mode for large files
func parseStream(_ inputStream: InputStream) throws -> [ArXivPaper] {
    let parser = XMLParser(stream: inputStream)
    parser.delegate = self
    
    // Configure parser for streaming
    parser.shouldProcessNamespaces = false
    parser.shouldReportNamespacePrefixes = false
    
    guard parser.parse() else {
        throw ArXivParserError.xmlParsingFailed(parser.parserError ?? ArXivParserError.unknownError)
    }
    
    return papers
}
```

### 💾 Element Cache

```swift
/// Cache for frequently processed elements
private var elementCache: [String: String] = [:]

/// Uses cache for repetitive elements
private func getCachedElement(_ key: String) -> String? {
    return elementCache[key]
}
```

## Extensibility

### 🔧 Custom Fields

```swift
/// Protocol for custom fields
protocol ArXivCustomField {
    var fieldName: String { get }
    func process(_ value: String) -> Any?
}

/// Support for custom fields
private var customFields: [ArXivCustomField] = []

func addCustomField(_ field: ArXivCustomField) {
    customFields.append(field)
}
```

### 📊 Parsing Metrics

```swift
/// Parser performance metrics
struct ParsingMetrics {
    let totalElements: Int
    let processingTime: TimeInterval
    let successfulPapers: Int
    let failedPapers: Int
}

/// Collects metrics during parsing
private func collectMetrics() -> ParsingMetrics {
    return ParsingMetrics(
        totalElements: totalElementsProcessed,
        processingTime: processingEndTime - processingStartTime,
        successfulPapers: papers.count,
        failedPapers: failedPaperCount
    )
}
```

## Usage Example

```swift
/// Full usage example of the parser
class ParserExample {
    private let parser = ArXivSimpleParser()
    
    func processArXivResponse(_ xmlData: Data) async throws -> [ArXivPaper] {
        do {
            let papers = try parser.parse(xmlData)
            print("✅ Parsed \(papers.count) papers")
            return papers
        } catch {
            print("❌ Parsing error: \(error)")
            throw error
        }
    }
}
```

## Best Practices

### ✅ Implemented Principles

1. **Single Responsibility**: Only handles XML parsing
2. **Robustness**: Handles malformed data gracefully
3. **Efficiency**: Processes large volumes of data
4. **Extensibility**: Easy to add new fields

### 🔧 Advanced Configuration

```swift
/// Custom parser configuration
struct ParserConfig {
    let strictMode: Bool = false
    let validateDates: Bool = true
    let maxAuthorsPerPaper: Int = 50
    let trimWhitespace: Bool = true
}
```

## Related Resources

- ``ArXivService`` - Service that uses the parser
- ``ArXivPaper`` - Data model resulting from parsing
- ``ArXivController`` - Controller that coordinates parsing 