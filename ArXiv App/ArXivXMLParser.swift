//
//  ArXivXMLParser.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import Foundation

/// Parser especializado para procesar respuestas XML de la API de ArXiv
/// Implementa XMLParserDelegate para manejar el parsing evento por evento
final class ArXivXMLParser: NSObject, XMLParserDelegate {
    /// Array que almacena los artículos parseados
    private var papers: [ArXivPaper] = []
    
    /// Artículo actual siendo procesado durante el parsing
    private var currentPaper: ArXivPaperBuilder?
    
    /// Contenido del elemento XML actual
    private var currentElement = ""
    
    /// Indica si estamos dentro de un elemento 'entry' (artículo)
    private var isParsingEntry = false
    
    /// Parsea los datos XML de ArXiv y retorna un array de artículos
    /// - Parameter data: Datos XML de la respuesta de ArXiv
    /// - Returns: Array de artículos parseados
    /// - Throws: ArXivError.parsingError si falla el parsing
    func parse(_ data: Data) throws -> [ArXivPaper] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        
        print("🔍 Starting XML parsing...")
        
        if parser.parse() {
            print("✅ XML parsing completed successfully with \(papers.count) papers")
            return papers
        } else {
            let errorString = parser.parserError?.localizedDescription ?? "Unknown parsing error"
            print("❌ XML parsing failed: \(errorString)")
            throw ArXivError.parsingError(errorString)
        }
    }
    
    // MARK: - XMLParserDelegate Methods
    
    /// Se ejecuta al encontrar el inicio de un elemento XML
    func parser(_ parser: XMLParser, didStartElement elementName: String, 
                namespaceURI: String?, qualifiedName qName: String?, 
                attributes attributeDict: [String : String] = [:]) {
        
        currentElement = ""
        
        if elementName == "entry" {
            // Inicia un nuevo artículo
            isParsingEntry = true
            currentPaper = ArXivPaperBuilder()
            print("📝 Starting new paper entry")
        } else if elementName == "link" && isParsingEntry {
            // Procesa los enlaces (PDF y página web)
            if let href = attributeDict["href"], let rel = attributeDict["rel"] {
                if rel == "alternate" {
                    currentPaper?.linkURL = href
                } else if href.contains(".pdf") {
                    currentPaper?.pdfURL = href
                }
            }
        } else if elementName == "category" && isParsingEntry {
            // Procesa las categorías del artículo
            if let term = attributeDict["term"] {
                if currentPaper?.categories.isEmpty == true {
                    currentPaper?.categories = term
                } else {
                    currentPaper?.categories += ", " + term
                }
            }
        }
    }
    
    /// Se ejecuta al encontrar contenido de texto dentro de un elemento
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentElement += string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Se ejecuta al encontrar el final de un elemento XML
    func parser(_ parser: XMLParser, didEndElement elementName: String, 
                namespaceURI: String?, qualifiedName qName: String?) {
        
        guard isParsingEntry, let builder = currentPaper else { return }
        
        let cleanedContent = currentElement.trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch elementName {
        case "entry":
            // Termina el artículo actual y lo añade a la lista
            if let paper = builder.build() {
                papers.append(paper)
                print("✅ Added paper: \(paper.title)")
            } else {
                print("❌ Failed to build paper - missing required fields")
            }
            isParsingEntry = false
            currentPaper = nil
            
        case "id":
            // Extrae el ID del artículo de la URL completa
            builder.id = extractArXivID(from: cleanedContent)
            
        case "title":
            builder.title = cleanedContent
            
        case "summary":
            builder.summary = cleanedContent
            
        case "name":
            // Concatena múltiples autores
            if builder.authors.isEmpty {
                builder.authors = cleanedContent
            } else {
                builder.authors += ", " + cleanedContent
            }
            
        case "published":
            builder.publishedDate = parseDate(from: cleanedContent)
            
        default:
            break
        }
        
        currentElement = ""
    }
    
    // MARK: - Helper Methods
    
    /// Extrae el ID de ArXiv de una URL completa
    /// - Parameter urlString: URL completa del artículo
    /// - Returns: ID limpio del artículo
    private func extractArXivID(from urlString: String) -> String {
        if let url = URL(string: urlString) {
            return url.lastPathComponent
        }
        return urlString
    }
    
    /// Convierte una fecha en formato ISO8601 a objeto Date
    /// - Parameter dateString: Fecha en formato string
    /// - Returns: Objeto Date o fecha actual si falla el parsing
    private func parseDate(from dateString: String) -> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString) ?? Date()
    }
}

/// Builder para construir objetos ArXivPaper durante el parsing
/// Permite ir acumulando datos antes de crear el objeto final
class ArXivPaperBuilder {
    var id = ""
    var title = ""
    var summary = ""
    var authors = ""
    var publishedDate = Date()
    var pdfURL = ""
    var linkURL = ""
    var categories = ""
    
    /// Construye el objeto ArXivPaper final
    /// - Returns: ArXivPaper si todos los campos obligatorios están presentes, nil en caso contrario
    func build() -> ArXivPaper? {
        // Requiere al menos ID y título para ser válido
        guard !id.isEmpty, !title.isEmpty else {
            return nil
        }
        
        return ArXivPaper(
            id: id,
            title: title,
            summary: summary,
            authors: authors.isEmpty ? "Unknown" : authors,
            publishedDate: publishedDate,
            pdfURL: pdfURL,
            linkURL: linkURL,
            categories: categories
        )
    }
}
