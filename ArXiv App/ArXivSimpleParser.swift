//
//  ArXivSimpleParser.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import Foundation

/// Parser simplificado para procesar respuestas XML de la API de ArXiv
/// Utiliza expresiones regulares y parsing de strings para un enfoque más directo
final class ArXivSimpleParser: @unchecked Sendable {
    
    /// Parsea los datos XML de ArXiv y retorna un array de artículos
    /// - Parameter data: Datos XML de la respuesta de ArXiv
    /// - Returns: Array de artículos parseados
    /// - Throws: ArXivError.parsingError si falla el parsing
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
    private func parseEntry(from entryXML: String) -> ArXivPaper? {
        // Extrae campos básicos
        let id = extractValue(from: entryXML, pattern: "<id>([^<]+)</id>")
        let title = extractValue(from: entryXML, pattern: "<title>([^<]+)</title>")
        let summary = extractValue(from: entryXML, pattern: "<summary>([^<]+)</summary>")
        let publishedDateString = extractValue(from: entryXML, pattern: "<published>([^<]+)</published>")
        
        // Extrae datos complejos
        let authors = extractAuthors(from: entryXML)
        let (pdfURL, linkURL) = extractURLs(from: entryXML)
        let categories = extractCategories(from: entryXML)
        
        // Procesa datos
        let cleanId = id.components(separatedBy: "/").last ?? id
        let publishedDate = parseDate(from: publishedDateString)
        
        // Valida datos mínimos
        guard !cleanId.isEmpty, !title.isEmpty else { return nil }
        
        return ArXivPaper(
            id: cleanId,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            summary: summary.trimmingCharacters(in: .whitespacesAndNewlines),
            authors: authors,
            publishedDate: publishedDate,
            pdfURL: pdfURL,
            linkURL: linkURL,
            categories: categories
        )
    }
    
    /// Extrae un valor usando expresión regular
    private func extractValue(from xml: String, pattern: String) -> String {
        let matches = findMatches(in: xml, pattern: pattern)
        guard let match = matches.first,
              let range = Range(match.range(at: 1), in: xml) else {
            return ""
        }
        return String(xml[range])
    }
    
    /// Helper para crear y ejecutar regex
    private func findMatches(in text: String, pattern: String) -> [NSTextCheckingResult] {
        let regex = try! NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        return regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
    }
    
    /// Extrae autores del XML
    private func extractAuthors(from xml: String) -> String {
        let matches = findMatches(in: xml, pattern: "<author>.*?<name>([^<]+)</name>.*?</author>")
        let authors = matches.compactMap { match -> String? in
            guard let range = Range(match.range(at: 1), in: xml) else { return nil }
            return String(xml[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return authors.joined(separator: ", ")
    }
    
    /// Extrae URLs del PDF y enlace
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
    private func extractCategories(from xml: String) -> String {
        let matches = findMatches(in: xml, pattern: "<category\\s+[^>]*term=\"([^\"]+)\"[^>]*/?>")
        let categories = matches.compactMap { match -> String? in
            guard let range = Range(match.range(at: 1), in: xml) else { return nil }
            return String(xml[range])
        }
        return categories.joined(separator: ", ")
    }
    
    /// Convierte string de fecha a Date
    private func parseDate(from dateString: String) -> Date {
        ISO8601DateFormatter().date(from: dateString) ?? Date()
    }
}
