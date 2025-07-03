//
//  ArXivSimpleParser.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import Foundation

/// Parser simplificado para procesar respuestas XML de la API de ArXiv
/// Utiliza expresiones regulares y parsing de strings para un enfoque más directo
/// Este parser fue diseñado como alternativa robusta a XMLParser para casos donde
/// la estructura XML es predecible y se necesita mayor control sobre el proceso
final class ArXivSimpleParser: @unchecked Sendable {
    
    /// Parsea los datos XML de ArXiv y retorna un array de artículos
    /// - Parameter data: Datos XML de la respuesta de ArXiv
    /// - Returns: Array de artículos parseados
    /// - Throws: ArXivError.parsingError si falla el parsing
    /// 
    /// Este método implementa un parser de dos etapas:
    /// 1. Extrae todas las entradas <entry> del XML usando regex
    /// 2. Procesa cada entrada individualmente para crear objetos ArXivPaper
    nonisolated func parse(_ data: Data) throws -> [ArXivPaper] {
        print("🔍 Starting XML parsing with simplified parser...")
        
        guard let xmlString = String(data: data, encoding: .utf8) else {
            throw ArXivError.parsingError("No se pudo convertir datos a string")
        }
        
        // Divide el XML en entradas individuales
        let entries = extractEntries(from: xmlString)
        print("📊 Found \(entries.count) entries in XML")
        
        // Convierte cada entrada en un ArXivPaper
        let papers = entries.compactMap { entryXML -> ArXivPaper? in
            return parseEntry(from: entryXML)
        }
        
        print("✅ XML parsing completed successfully with \(papers.count) papers")
        return papers
    }
    
    /// Extrae todas las entradas <entry> del XML
    /// Utiliza una expresión regular para encontrar todos los bloques <entry>...</entry>
    /// - Parameter xml: String XML completo de la respuesta
    /// - Returns: Array de strings, cada uno conteniendo una entrada completa
    private func extractEntries(from xml: String) -> [String] {
        let pattern = "<entry[^>]*>.*?</entry>"
        let regex = try! NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        let matches = regex.matches(in: xml, options: [], range: NSRange(location: 0, length: xml.count))
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: xml) else { return nil }
            return String(xml[range])
        }
    }
    
    /// Parsea una entrada individual del XML
    /// Extrae todos los campos necesarios para crear un ArXivPaper
    /// - Parameter entryXML: String XML de una entrada individual
    /// - Returns: ArXivPaper opcional (nil si los datos son insuficientes)
    /// 
    /// Proceso de parsing:
    /// 1. Extrae campos básicos (id, título, resumen, fechas)
    /// 2. Procesa datos complejos (autores, URLs, categorías)
    /// 3. Valida que los datos mínimos estén presentes
    /// 4. Crea y retorna el objeto ArXivPaper
    private func parseEntry(from entryXML: String) -> ArXivPaper? {
        // Extrae campos básicos
        let id = extractValue(from: entryXML, pattern: "<id>([^<]+)</id>")
        let title = extractValue(from: entryXML, pattern: "<title>([^<]+)</title>")
        let summary = extractValue(from: entryXML, pattern: "<summary>([^<]+)</summary>")
        let publishedDateString = extractValue(from: entryXML, pattern: "<published>([^<]+)</published>")
        let updatedDateString = extractValue(from: entryXML, pattern: "<updated>([^<]+)</updated>")
        
        // Extrae datos complejos
        let authors = extractAuthors(from: entryXML)
        let (pdfURL, linkURL) = extractURLs(from: entryXML)
        let categories = extractCategories(from: entryXML)
        
        // Procesa datos
        let cleanId = id.components(separatedBy: "/").last ?? id
        let publishedDate = parseDate(from: publishedDateString)
        let updatedDate = updatedDateString.isEmpty ? nil : parseDate(from: updatedDateString)
        
        // Valida datos mínimos
        guard !cleanId.isEmpty, !title.isEmpty else { return nil }
        
        return ArXivPaper(
            id: cleanId,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            summary: summary.trimmingCharacters(in: .whitespacesAndNewlines),
            authors: authors,
            publishedDate: publishedDate,
            updatedDate: updatedDate,
            pdfURL: pdfURL,
            linkURL: linkURL,
            categories: categories
        )
    }
    
    /// Extrae un valor usando expresión regular
    /// Método auxiliar para simplificar la extracción de campos del XML
    /// - Parameters:
    ///   - xml: String XML donde buscar
    ///   - pattern: Patrón de expresión regular con un grupo de captura
    /// - Returns: String extraído o vacío si no se encuentra
    private func extractValue(from xml: String, pattern: String) -> String {
        let matches = findMatches(in: xml, pattern: pattern)
        guard let match = matches.first,
              let range = Range(match.range(at: 1), in: xml) else {
            return ""
        }
        return String(xml[range])
    }
    
    /// Helper para crear y ejecutar regex
    /// Centraliza la creación de expresiones regulares para evitar duplicación
    /// - Parameters:
    ///   - text: Texto donde buscar coincidencias
    ///   - pattern: Patrón de expresión regular
    /// - Returns: Array de resultados de coincidencias
    private func findMatches(in text: String, pattern: String) -> [NSTextCheckingResult] {
        let regex = try! NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        return regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
    }
    
    /// Extrae autores del XML
    /// Los autores están anidados en elementos <author><name>...</name></author>
    /// - Parameter xml: String XML de la entrada
    /// - Returns: String con autores separados por comas
    private func extractAuthors(from xml: String) -> String {
        let matches = findMatches(in: xml, pattern: "<author>.*?<name>([^<]+)</name>.*?</author>")
        let authors = matches.compactMap { match -> String? in
            guard let range = Range(match.range(at: 1), in: xml) else { return nil }
            return String(xml[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return authors.joined(separator: ", ")
    }
    
    /// Extrae URLs del PDF y enlace
    /// ArXiv proporciona múltiples enlaces con diferentes tipos MIME
    /// - Parameter xml: String XML de la entrada
    /// - Returns: Tupla con (pdfURL, linkURL)
    /// 
    /// Busca elementos <link> con atributos href y type:
    /// - type="application/pdf" para el enlace al PDF
    /// - type="text/html" para el enlace a la página web
    private func extractURLs(from xml: String) -> (pdfURL: String, linkURL: String) {
        let matches = findMatches(in: xml, pattern: "<link\\s+[^>]*href=\"([^\"]+)\"[^>]*type=\"([^\"]+)\"[^>]*/?>")
        var pdfURL = "", linkURL = ""
        
        for match in matches {
            guard let hrefRange = Range(match.range(at: 1), in: xml),
                  let typeRange = Range(match.range(at: 2), in: xml) else { continue }
            
            let href = String(xml[hrefRange])
            let type = String(xml[typeRange])
            
            if type == "application/pdf" {
                pdfURL = href
            } else if type == "text/html" {
                linkURL = href
            }
        }
        
        return (pdfURL, linkURL)
    }
    
    /// Extrae categorías
    /// Las categorías están en elementos <category term="..."/>
    /// - Parameter xml: String XML de la entrada
    /// - Returns: String con categorías separadas por comas
    /// 
    /// Ejemplo de categorías: "cs.AI", "cs.LG", "stat.ML"
    private func extractCategories(from xml: String) -> String {
        let matches = findMatches(in: xml, pattern: "<category\\s+[^>]*term=\"([^\"]+)\"[^>]*/?>")
        let categories = matches.compactMap { match -> String? in
            guard let range = Range(match.range(at: 1), in: xml) else { return nil }
            return String(xml[range])
        }
        return categories.joined(separator: ", ")
    }
    
    /// Convierte string de fecha a Date
    /// Utiliza ISO8601DateFormatter para parsear fechas de ArXiv
    /// - Parameter dateString: String de fecha en formato ISO8601
    /// - Returns: Date parseada o Date() si falla el parsing
    /// 
    /// ArXiv usa formato: "2025-07-03T10:30:00Z"
    private func parseDate(from dateString: String) -> Date {
        ISO8601DateFormatter().date(from: dateString) ?? Date()
    }
}
