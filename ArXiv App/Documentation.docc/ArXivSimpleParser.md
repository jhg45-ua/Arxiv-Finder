# ArXivSimpleParser

Parser XML especializado para procesar respuestas de la API de ArXiv.

## Descripción General

``ArXivSimpleParser`` es un componente especializado que se encarga de procesar las respuestas XML de la API de ArXiv y convertirlas en objetos ``ArXivPaper`` utilizables en la aplicación. Implementa un parser XML robusto y eficiente que maneja las peculiaridades específicas del formato Atom utilizado por ArXiv.

Esta clase está diseñada siguiendo principios de:
- **Responsabilidad única** en el procesamiento de XML
- **Robustez** en el manejo de datos malformados
- **Eficiencia** en el procesamiento de grandes volúmenes de datos
- **Extensibilidad** para nuevos campos de ArXiv

## Arquitectura del Parser

### 🔧 Tecnología Utilizada

El parser utiliza `XMLParser` de Foundation para un procesamiento eficiente:

```swift
/// Parser XML especializado para el formato Atom de ArXiv
final class ArXivSimpleParser: NSObject, XMLParserDelegate {
    /// Artículos parseados durante el procesamiento
    private var papers: [ArXivPaper] = []
    
    /// Artículo actual siendo procesado
    private var currentPaper: ArXivPaper?
    
    /// Elemento XML actual
    private var currentElement: String = ""
    
    /// Contenido del elemento actual
    private var currentValue: String = ""
}
```

### 🏗️ Estructura de Datos XML

ArXiv utiliza formato Atom con estructura específica:

```xml
<feed xmlns="http://www.w3.org/2005/Atom">
    <entry>
        <id>http://arxiv.org/abs/2023.12345v1</id>
        <title>Título del artículo</title>
        <summary>Resumen del artículo...</summary>
        <author>
            <name>Nombre del autor</name>
        </author>
        <published>2023-12-01T00:00:00Z</published>
        <updated>2023-12-01T00:00:00Z</updated>
        <category term="cs.AI" scheme="http://arxiv.org/schemas/atom"/>
        <link href="http://arxiv.org/abs/2023.12345v1"/>
    </entry>
</feed>
```

## Funcionalidades Principales

### 📜 Parsing Principal

```swift
/// Parsea datos XML de ArXiv y devuelve array de artículos
/// - Parameter data: Datos XML de la respuesta de ArXiv
/// - Returns: Array de artículos parseados
/// - Throws: Error si el XML es inválido o malformado
func parse(_ data: Data) throws -> [ArXivPaper] {
    // Reinicia el estado del parser
    papers.removeAll()
    currentPaper = nil
    currentElement = ""
    currentValue = ""
    
    // Crea y configura el parser XML
    let parser = XMLParser(data: data)
    parser.delegate = self
    
    // Ejecuta el parsing
    guard parser.parse() else {
        if let error = parser.parserError {
            throw ArXivParserError.xmlParsingFailed(error)
        }
        throw ArXivParserError.unknownError
    }
    
    return papers
}
```

### 🔍 Procesamiento de Elementos

```swift
/// Inicia el procesamiento de un elemento XML
func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName: String?, attributes: [String: String] = [:]) {
    currentElement = elementName
    currentValue = ""
    
    switch elementName {
    case "entry":
        // Inicia un nuevo artículo
        currentPaper = ArXivPaper()
    case "category":
        // Procesa categorías con atributos
        if let term = attributes["term"] {
            currentPaper?.category = term
        }
    case "link":
        // Procesa enlaces con atributos
        if let href = attributes["href"] {
            currentPaper?.link = href
        }
    default:
        break
    }
}
```

### 📝 Procesamiento de Contenido

```swift
/// Procesa el contenido de texto de elementos XML
func parser(_ parser: XMLParser, foundCharacters string: String) {
    currentValue += string.trimmingCharacters(in: .whitespacesAndNewlines)
}
```

### ✅ Finalización de Elementos

```swift
/// Finaliza el procesamiento de un elemento XML
func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName: String?) {
    defer {
        currentElement = ""
        currentValue = ""
    }
    
    guard var paper = currentPaper else { return }
    
    switch elementName {
    case "entry":
        // Finaliza el artículo actual
        papers.append(paper)
        currentPaper = nil
    case "id":
        paper.id = extractArXivID(from: currentValue)
    case "title":
        paper.title = cleanTitle(currentValue)
    case "summary":
        paper.summary = cleanSummary(currentValue)
    case "name":
        // Procesa nombres de autores
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

## Procesamiento de Datos Específicos

### 🔗 Extracción de ID de ArXiv

```swift
/// Extrae el ID de ArXiv de la URL completa
/// - Parameter fullURL: URL completa del artículo
/// - Returns: ID limpio de ArXiv (ej: "2023.12345v1")
private func extractArXivID(from fullURL: String) -> String {
    // Ejemplo: "http://arxiv.org/abs/2023.12345v1" -> "2023.12345v1"
    let components = fullURL.components(separatedBy: "/")
    return components.last ?? fullURL
}
```

### 🧹 Limpieza de Títulos

```swift
/// Limpia y formatea títulos de artículos
/// - Parameter rawTitle: Título sin procesar
/// - Returns: Título limpio y formateado
private func cleanTitle(_ rawTitle: String) -> String {
    return rawTitle
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .replacingOccurrences(of: "\n", with: " ")
        .replacingOccurrences(of: "  ", with: " ")
}
```

### 📄 Procesamiento de Resúmenes

```swift
/// Procesa y limpia resúmenes de artículos
/// - Parameter rawSummary: Resumen sin procesar
/// - Returns: Resumen limpio y formateado
private func cleanSummary(_ rawSummary: String) -> String {
    return rawSummary
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .replacingOccurrences(of: "\n", with: " ")
        .replacingOccurrences(of: "  ", with: " ")
}
```

### 👥 Gestión de Autores

```swift
/// Procesa nombres de autores y los concatena
/// - Parameters:
///   - newAuthor: Nuevo autor a agregar
///   - existing: Autores existentes
/// - Returns: String con todos los autores separados por comas
private func processAuthorName(_ newAuthor: String, existing: String) -> String {
    let cleanName = newAuthor.trimmingCharacters(in: .whitespacesAndNewlines)
    
    if existing.isEmpty {
        return cleanName
    } else {
        return "\(existing), \(cleanName)"
    }
}
```

### 📅 Parsing de Fechas

```swift
/// Parsea fechas en formato ISO 8601 de ArXiv
/// - Parameter dateString: Fecha en formato string
/// - Returns: Objeto Date parseado
private func parseDate(_ dateString: String) -> Date {
    let formatter = ISO8601DateFormatter()
    return formatter.date(from: dateString) ?? Date()
}
```

## Manejo de Errores

### 🛡️ Tipos de Error Específicos

```swift
/// Errores específicos del parser XML
enum ArXivParserError: Error, LocalizedError {
    case xmlParsingFailed(Error)
    case invalidDateFormat(String)
    case missingRequiredField(String)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .xmlParsingFailed(let error):
            return "Error al parsear XML: \(error.localizedDescription)"
        case .invalidDateFormat(let date):
            return "Formato de fecha inválido: \(date)"
        case .missingRequiredField(let field):
            return "Campo requerido faltante: \(field)"
        case .unknownError:
            return "Error desconocido en el parser"
        }
    }
}
```

### 🔄 Recuperación de Errores

```swift
/// Maneja errores durante el parsing
func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    print("❌ Error de parsing XML: \(parseError)")
    
    // Intenta recuperar datos parciales
    if !papers.isEmpty {
        print("✅ Recuperando \(papers.count) artículos procesados")
    }
}
```

## Optimizaciones de Rendimiento

### 🚀 Streaming Parser

```swift
/// Procesa XML de forma streaming para archivos grandes
func parseStream(_ inputStream: InputStream) throws -> [ArXivPaper] {
    let parser = XMLParser(stream: inputStream)
    parser.delegate = self
    
    // Configura parser para streaming
    parser.shouldProcessNamespaces = false
    parser.shouldReportNamespacePrefixes = false
    
    guard parser.parse() else {
        throw ArXivParserError.xmlParsingFailed(parser.parserError ?? ArXivParserError.unknownError)
    }
    
    return papers
}
```

### 💾 Caché de Elementos

```swift
/// Caché para elementos frecuentemente procesados
private var elementCache: [String: String] = [:]

/// Utiliza caché para elementos repetitivos
private func getCachedElement(_ key: String) -> String? {
    return elementCache[key]
}
```

## Extensibilidad

### 🔧 Campos Personalizados

```swift
/// Protocolo para campos personalizados
protocol ArXivCustomField {
    var fieldName: String { get }
    func process(_ value: String) -> Any?
}

/// Soporte para campos personalizados
private var customFields: [ArXivCustomField] = []

func addCustomField(_ field: ArXivCustomField) {
    customFields.append(field)
}
```

### 📊 Métricas de Parsing

```swift
/// Métricas de rendimiento del parser
struct ParsingMetrics {
    let totalElements: Int
    let processingTime: TimeInterval
    let successfulPapers: Int
    let failedPapers: Int
}

/// Recopila métricas durante el parsing
private func collectMetrics() -> ParsingMetrics {
    return ParsingMetrics(
        totalElements: totalElementsProcessed,
        processingTime: processingEndTime - processingStartTime,
        successfulPapers: papers.count,
        failedPapers: failedPaperCount
    )
}
```

## Ejemplo de Uso

```swift
/// Ejemplo de uso completo del parser
class ParserExample {
    private let parser = ArXivSimpleParser()
    
    func processArXivResponse(_ xmlData: Data) async throws -> [ArXivPaper] {
        do {
            let papers = try parser.parse(xmlData)
            print("✅ Parseados \(papers.count) artículos")
            return papers
        } catch {
            print("❌ Error en parsing: \(error)")
            throw error
        }
    }
}
```

## Mejores Prácticas

### ✅ Principios Implementados

1. **Responsabilidad Única**: Solo maneja parsing de XML
2. **Robustez**: Maneja datos malformados gracefully
3. **Eficiencia**: Procesa grandes volúmenes de datos
4. **Extensibilidad**: Fácil agregar nuevos campos

### 🔧 Configuración Avanzada

```swift
/// Configuración personalizada del parser
struct ParserConfig {
    let strictMode: Bool = false
    let validateDates: Bool = true
    let maxAuthorsPerPaper: Int = 50
    let trimWhitespace: Bool = true
}
```

## Recursos Relacionados

- ``ArXivService`` - Servicio que utiliza el parser
- ``ArXivPaper`` - Modelo de datos resultado del parsing
- ``ArXivController`` - Controlador que coordina el parsing
