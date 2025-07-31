//
//  ArXivSimpleParser.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import Foundation

/// Simplified parser to process XML responses from the ArXiv API
/// Uses regular expressions and string parsing for a more direct approach
/// This parser was designed as a robust alternative to XMLParser for cases where
/// the XML structure is predictable and more control over the parsing process is needed
final class ArXivSimpleParser: @unchecked Sendable {
    
    /// Parses the XML data from ArXiv and returns an array of papers
    /// - Parameter data: XML data from the ArXiv response
    /// - Returns: Array of parsed papers
    /// - Throws: ArXivError.parsingError if parsing fails
    /// 
    /// This method implements a two-stage parser:
    /// 1. Extracts all <entry> elements from the XML using regex
    /// 2. Processes each entry individually to create ArXivPaper objects
    nonisolated func parse(_ data: Data) throws -> [ArXivPaper] {
        print("🔍 Starting XML parsing with simplified parser...")
        
        guard let xmlString = String(data: data, encoding: .utf8) else {
            throw ArXivError.parsingError("No se pudo convertir datos a string")
        }
        
        // Divide the XML into individual entries
        let entries = extractEntries(from: xmlString)
        print("📊 Found \(entries.count) entries in XML")
        
        // Convert each entry into an ArXivPaper
        let papers = entries.compactMap { entryXML -> ArXivPaper? in
            return parseEntry(from: entryXML)
        }
        
        print("✅ XML parsing completed successfully with \(papers.count) papers")
        return papers
    }
    
    /// Extracts all <entry> elements from the XML
    /// Uses a regular expression to find all <entry>...</entry> blocks
    /// - Parameter xml: String XML of the full response
    /// - Returns: Array of strings, each containing a complete entry
    private func extractEntries(from xml: String) -> [String] {
        let pattern = "<entry[^>]*>.*?</entry>"
        let regex = try! NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        let matches = regex.matches(in: xml, options: [], range: NSRange(location: 0, length: xml.count))
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: xml) else { return nil }
            return String(xml[range])
        }
    }
    
    /// Parses an individual entry from the XML
    /// Extracts all necessary fields to create an ArXivPaper
    /// - Parameter entryXML: String XML of an individual entry
    /// - Returns: Optional ArXivPaper (nil if data is insufficient)
    /// 
    /// Proceso de parsing:
    /// 1. Extracts basic fields (id, title, summary, dates)
    /// 2. Processes complex data (authors, URLs, categories)
    /// 3. Validates that the minimum data is present
    /// 4. Creates and returns the ArXivPaper object
    private func parseEntry(from entryXML: String) -> ArXivPaper? {
        // Extracts basic fields
        let id = extractValue(from: entryXML, pattern: "<id>([^<]+)</id>")
        let title = extractValue(from: entryXML, pattern: "<title>([^<]+)</title>")
        let summary = extractValue(from: entryXML, pattern: "<summary>([^<]+)</summary>")
        let publishedDateString = extractValue(from: entryXML, pattern: "<published>([^<]+)</published>")
        let updatedDateString = extractValue(from: entryXML, pattern: "<updated>([^<]+)</updated>")
        
        // Extracts complex data
        let authors = extractAuthors(from: entryXML)
        let (pdfURL, linkURL) = extractURLs(from: entryXML)
        let categories = extractCategories(from: entryXML)
        
        // Processes data
        let cleanId = id.components(separatedBy: "/").last ?? id
        let publishedDate = parseDate(from: publishedDateString)
        let updatedDate = updatedDateString.isEmpty ? nil : parseDate(from: updatedDateString)
        
        // Validates minimum data
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
    
    /// Extracts a value using a regular expression
    /// Helper method to simplify the extraction of fields from the XML
    /// - Parameters:
    ///   - xml: String XML to search
    ///   - pattern: Regular expression pattern with a capture group
    /// - Returns: Extracted string or empty if not found
    private func extractValue(from xml: String, pattern: String) -> String {
        let matches = findMatches(in: xml, pattern: pattern)
        guard let match = matches.first,
              let range = Range(match.range(at: 1), in: xml) else {
            return ""
        }
        return String(xml[range])
    }
    
    /// Helper to create and execute regex
    /// Centralizes the creation of regular expressions to avoid duplication
    /// - Parameters:
    ///   - text: Text to search for matches
    ///   - pattern: Regular expression pattern
    /// - Returns: Array of match results
    private func findMatches(in text: String, pattern: String) -> [NSTextCheckingResult] {
        let regex = try! NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        return regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
    }
    
    /// Extracts authors from the XML
    /// Authors are nested in <author><name>...</name></author> elements
    /// - Parameter xml: String XML of the entry
    /// - Returns: String with authors separated by commas
    private func extractAuthors(from xml: String) -> String {
        let matches = findMatches(in: xml, pattern: "<author>.*?<name>([^<]+)</name>.*?</author>")
        let authors = matches.compactMap { match -> String? in
            guard let range = Range(match.range(at: 1), in: xml) else { return nil }
            return String(xml[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return authors.joined(separator: ", ")
    }
    
    /// Extracts URLs from the PDF and link
    /// ArXiv provides multiple links with different MIME types
    /// - Parameter xml: String XML of the entry
    /// - Returns: Tuple with (pdfURL, linkURL)
    /// 
    /// Searches for <link> elements with href and type attributes:
    /// - type="application/pdf" for the link to the PDF
    /// - type="text/html" for the link to the web page
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
    
    /// Extracts categories
    /// Categories are in <category term="..."/> elements
    /// - Parameter xml: String XML of the entry
    /// - Returns: String with categories separated by commas
    /// 
    /// Example of categories: "cs.AI", "cs.LG", "stat.ML"
    private func extractCategories(from xml: String) -> String {
        let matches = findMatches(in: xml, pattern: "<category\\s+[^>]*term=\"([^\"]+)\"[^>]*/?>")
        let categories = matches.compactMap { match -> String? in
            guard let range = Range(match.range(at: 1), in: xml) else { return nil }
            return String(xml[range])
        }
        return categories.joined(separator: ", ")
    }
    
    /// Converts string of date to Date
    /// Uses ISO8601DateFormatter to parse dates from ArXiv
    /// - Parameter dateString: String of date in ISO8601 format
    /// - Returns: Parsed Date or Date() if parsing fails
    /// 
    /// ArXiv uses format: "2025-07-03T10:30:00Z"
    private func parseDate(from dateString: String) -> Date {
        ISO8601DateFormatter().date(from: dateString) ?? Date()
    }
}
