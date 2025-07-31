//
//  ArXivService.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import Foundation

/// Service responsible for communicating with the ArXiv API
/// Handles HTTP requests and XML response parsing
final class ArXivService: @unchecked Sendable {
    /// Base URL of the ArXiv API (using HTTPS to comply with ATS)
    private let baseURL = "https://export.arxiv.org/api/query"
    
    /// Gets the latest papers published on ArXiv
    /// - Parameter count: Number of papers to fetch (default 10)
    /// - Returns: Array of ArXiv papers
    /// - Throws: Error if request or parsing fails
    nonisolated func fetchLatestPapers(count: Int = 10) async throws -> [ArXivPaper] {
        // Build URL to get latest papers from most active categories
        // Uses sortBy=lastUpdatedDate and sortOrder=descending to get the most recent
        // Properly encodes spaces as + for OR
        guard let url = URL(string: "\(baseURL)?search_query=cat:cs.*+OR+cat:stat.*+OR+cat:math.*&start=0&max_results=\(count)&sortBy=lastUpdatedDate&sortOrder=descending") else {
            throw ArXivError.invalidURL
        }
        
        print("🌐 Fetching from URL: \(url.absoluteString)")
        
        do {
            // Perform HTTP request asynchronously
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Verify that HTTP response is successful
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ArXivError.networkError("Invalid server response")
            }
            
            print("📡 HTTP Status: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                throw ArXivError.networkError("HTTP Error: \(httpResponse.statusCode)")
            }
            
            print("📄 Data received: \(data.count) bytes")
            
            // Debug: Print XML content for analysis
            if let xmlString = String(data: data, encoding: .utf8) {
                print("🔍 XML Content preview: \(String(xmlString.prefix(500)))...")
            }
            
            // Parse XML response and convert to ArXivPaper objects
            let papers = try parseArXivXML(data)
            print("✅ Successfully parsed \(papers.count) papers")
            return papers
            
        } catch let error as ArXivError {
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Gets Computer Science papers from ArXiv
    /// - Parameter count: Number of papers to fetch (default 10)
    /// - Returns: Array of Computer Science papers
    /// - Throws: Error if request or parsing fails
    nonisolated func fetchComputerSciencePapers(count: Int = 10) async throws -> [ArXivPaper] {
        // Build URL to get Computer Science papers (cs category)
        // Uses lastUpdatedDate to get the most recent
        guard let url = URL(string: "\(baseURL)?search_query=cat:cs*&start=0&max_results=\(count)&sortBy=lastUpdatedDate&sortOrder=descending") else {
            throw ArXivError.invalidURL
        }
        
        print("🌐 Fetching Computer Science papers from URL: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ArXivError.networkError("Invalid server response")
            }
            
            print("📡 HTTP Status: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                throw ArXivError.networkError("HTTP Error: \(httpResponse.statusCode)")
            }
            
            print("📄 Data received: \(data.count) bytes")
            
            let papers = try parseArXivXML(data)
            print("✅ Successfully parsed \(papers.count) Computer Science papers")
            return papers
            
        } catch let error as ArXivError {
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Gets papers from Mathematics from ArXiv
    /// - Parameter count: Number of papers to fetch (default 10)
    /// - Returns: Array of papers from Mathematics
    /// - Throws: Error if the request or parsing fails
    nonisolated func fetchMathematicsPapers(count: Int = 10) async throws -> [ArXivPaper] {
        // Build the URL to get papers from Mathematics (category math)
        // Uses lastUpdatedDate to get the most recent
        guard let url = URL(string: "\(baseURL)?search_query=cat:math*&start=0&max_results=\(count)&sortBy=lastUpdatedDate&sortOrder=descending") else {
            throw ArXivError.invalidURL
        }
        
        print("🌐 Fetching Mathematics papers from URL: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ArXivError.networkError("Invalid server response")
            }
            
            print("📡 HTTP Status: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                throw ArXivError.networkError("Error HTTP: \(httpResponse.statusCode)")
            }
            
            print("📄 Data received: \(data.count) bytes")
            
            let papers = try parseArXivXML(data)
            print("✅ Successfully parsed \(papers.count) Mathematics papers")
            return papers
            
        } catch let error as ArXivError {
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Gets papers from Physics from ArXiv
    /// - Parameter count: Number of papers to fetch (default 10)
    /// - Returns: Array of papers from Physics
    /// - Throws: Error if the request or parsing fails
    nonisolated func fetchPhysicsPapers(count: Int = 10) async throws -> [ArXivPaper] {
        // Build the URL to get papers from Physics (category physics)
        // Uses lastUpdatedDate to get the most recent
        guard let url = URL(string: "\(baseURL)?search_query=cat:physics*&start=0&max_results=\(count)&sortBy=lastUpdatedDate&sortOrder=descending") else {
            throw ArXivError.invalidURL
        }
        
        print("🌐 Fetching Physics papers from URL: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ArXivError.networkError("Invalid server response")
            }
            
            print("📡 HTTP Status: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                throw ArXivError.networkError("Error HTTP: \(httpResponse.statusCode)")
            }
            
            print("📄 Data received: \(data.count) bytes")
            
            let papers = try parseArXivXML(data)
            print("✅ Successfully parsed \(papers.count) Physics papers")
            return papers
            
        } catch let error as ArXivError {
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Gets papers from Quantitative Biology from ArXiv
    /// - Parameter count: Number of papers to fetch (default 10)
    /// - Returns: Array of papers from Quantitative Biology
    /// - Throws: Error if the request or parsing fails
    nonisolated func fetchQuantitativeBiologyPapers(count: Int = 10) async throws -> [ArXivPaper] {
        // Build the URL to get papers from Quantitative Biology (category q-bio)
        // Uses lastUpdatedDate to get the most recent
        guard let url = URL(string: "\(baseURL)?search_query=cat:q-bio*&start=0&max_results=\(count)&sortBy=lastUpdatedDate&sortOrder=descending") else {
            throw ArXivError.invalidURL
        }
        
        print("🌐 Fetching Quantitative Biology papers from URL: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ArXivError.networkError("Invalid server response")
            }
            
            print("📡 HTTP Status: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                throw ArXivError.networkError("Error HTTP: \(httpResponse.statusCode)")
            }
            
            print("📄 Data received: \(data.count) bytes")
            
            let papers = try parseArXivXML(data)
            print("✅ Successfully parsed \(papers.count) Quantitative Biology papers")
            return papers
            
        } catch let error as ArXivError {
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Gets papers from Quantitative Finance from ArXiv
    /// - Parameter count: Number of papers to fetch (default 10)
    /// - Returns: Array of papers from Quantitative Finance
    /// - Throws: Error if the request or parsing fails
    nonisolated func fetchQuantitativeFinancePapers(count: Int = 10) async throws -> [ArXivPaper] {
        // Build the URL to get papers from Quantitative Finance (category q-fin)
        // Uses lastUpdatedDate to get the most recent
        guard let url = URL(string: "\(baseURL)?search_query=cat:q-fin*&start=0&max_results=\(count)&sortBy=lastUpdatedDate&sortOrder=descending") else {
            throw ArXivError.invalidURL
        }
        
        print("🌐 Fetching Quantitative Finance papers from URL: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ArXivError.networkError("Invalid server response")
            }
            
            print("📡 HTTP Status: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                throw ArXivError.networkError("Error HTTP: \(httpResponse.statusCode)")
            }
            
            print("📄 Data received: \(data.count) bytes")
            
            let papers = try parseArXivXML(data)
            print("✅ Successfully parsed \(papers.count) Quantitative Finance papers")
            return papers
            
        } catch let error as ArXivError {
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Gets papers from Statistics from ArXiv
    /// - Parameter count: Number of papers to fetch (default 10)
    /// - Returns: Array of papers from Statistics
    /// - Throws: Error if the request or parsing fails
    nonisolated func fetchStatisticsPapers(count: Int = 10) async throws -> [ArXivPaper] {
        // Build the URL to get papers from Statistics (category stat)
        // Uses lastUpdatedDate to get the most recent
        guard let url = URL(string: "\(baseURL)?search_query=cat:stat*&start=0&max_results=\(count)&sortBy=lastUpdatedDate&sortOrder=descending") else {
            throw ArXivError.invalidURL
        }
        
        print("🌐 Fetching Statistics papers from URL: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ArXivError.networkError("Invalid server response")
            }
            
            print("📡 HTTP Status: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                throw ArXivError.networkError("Error HTTP: \(httpResponse.statusCode)")
            }
            
            print("📄 Data received: \(data.count) bytes")
            
            let papers = try parseArXivXML(data)
            print("✅ Successfully parsed \(papers.count) Statistics papers")
            return papers
            
        } catch let error as ArXivError {
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Gets papers from Electrical Engineering and Systems Science from ArXiv
    /// - Parameter count: Number of papers to fetch (default 10)
    /// - Returns: Array of papers from Electrical Engineering and Systems Science
    /// - Throws: Error if the request or parsing fails
    nonisolated func fetchElectricalEngineeringPapers(count: Int = 10) async throws -> [ArXivPaper] {
        // Build the URL to get papers from Electrical Engineering and Systems Science (category eess)
        // Uses lastUpdatedDate to get the most recent
        guard let url = URL(string: "\(baseURL)?search_query=cat:eess*&start=0&max_results=\(count)&sortBy=lastUpdatedDate&sortOrder=descending") else {
            throw ArXivError.invalidURL
        }
        
        print("🌐 Fetching Electrical Engineering and Systems Science papers from URL: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ArXivError.networkError("Invalid server response")
            }
            
            print("📡 HTTP Status: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                throw ArXivError.networkError("Error HTTP: \(httpResponse.statusCode)")
            }
            
            print("📄 Data received: \(data.count) bytes")
            
            let papers = try parseArXivXML(data)
            print("✅ Successfully parsed \(papers.count) Electrical Engineering and Systems Science papers")
            return papers
            
        } catch let error as ArXivError {
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Gets papers from Economics from ArXiv
    /// - Parameter count: Number of papers to fetch (default 10)
    /// - Returns: Array of papers from Economics
    /// - Throws: Error if the request or parsing fails
    nonisolated func fetchEconomicsPapers(count: Int = 10) async throws -> [ArXivPaper] {
        // Build the URL to get papers from Economics (category econ)
        // Uses lastUpdatedDate to get the most recent
        guard let url = URL(string: "\(baseURL)?search_query=cat:econ*&start=0&max_results=\(count)&sortBy=lastUpdatedDate&sortOrder=descending") else {
            throw ArXivError.invalidURL
        }
        
        print("🌐 Fetching Economics papers from URL: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ArXivError.networkError("Invalid server response")
            }
            
            print("📡 HTTP Status: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                throw ArXivError.networkError("Error HTTP: \(httpResponse.statusCode)")
            }
            
            print("📄 Data received: \(data.count) bytes")
            
            let papers = try parseArXivXML(data)
            print("✅ Successfully parsed \(papers.count) Economics papers")
            return papers
            
        } catch let error as ArXivError {
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Search papers in ArXiv using search terms
    /// - Parameters:
    ///   - query: Search terms (title, author, summary)
    ///   - count: Maximum number of results (default 20)
    ///   - category: Optional category to filter (e.g.: "cs", "math", "physics")
    /// - Returns: Array of papers that match the search
    /// - Throws: Error if the request or parsing fails
    nonisolated func searchPapers(query: String, count: Int = 20, category: String? = nil) async throws -> [ArXivPaper] {
        // Build the search query
        var searchQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If a category is specified, add it to the filter
        if let category = category, !category.isEmpty {
            searchQuery = "all:\(searchQuery)+AND+cat:\(category)*"
        } else {
            searchQuery = "all:\(searchQuery)"
        }
        
        // Encode the query for URL
        guard let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw ArXivError.invalidURL
        }
        
        // Build the search URL
        guard let url = URL(string: "\(baseURL)?search_query=\(encodedQuery)&start=0&max_results=\(count)&sortBy=lastUpdatedDate&sortOrder=descending") else {
            throw ArXivError.invalidURL
        }
        
        print("🔍 Searching papers with query: \(searchQuery)")
        print("🌐 Search URL: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ArXivError.networkError("Respuesta inválida del servidor")
            }
            
            print("📡 HTTP Status: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                throw ArXivError.networkError("Error HTTP: \(httpResponse.statusCode)")
            }
            
            print("📄 Data received: \(data.count) bytes")
            
            // Debug: Print the XML content for analysis
            if let xmlString = String(data: data, encoding: .utf8) {
                print("🔍 XML Content preview: \(String(xmlString.prefix(500)))...")
            }
            
            let papers = try parseArXivXML(data)
            print("✅ Successfully found \(papers.count) papers for query: \(query)")
            return papers
            
        } catch let error as ArXivError {
            throw error
        } catch {
            print("❌ Search error: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Alternative function to get the latest papers using a simple query
    /// Useful when the main query doesn't work
    nonisolated func fetchRecentPapers(count: Int = 10) async throws -> [ArXivPaper] {
        // Use a query that searches for recent papers in specific categories with date sorting
        // Encode spaces correctly as + for OR
        guard let url = URL(string: "\(baseURL)?search_query=cat:cs.LG+OR+cat:cs.AI+OR+cat:cs.CV&start=0&max_results=\(count)&sortBy=lastUpdatedDate&sortOrder=descending") else {
            throw ArXivError.invalidURL
        }
        
        print("🌐 Fetching from simple URL: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ArXivError.networkError("Respuesta inválida del servidor")
            }
            
            print("📡 HTTP Status: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                throw ArXivError.networkError("Error HTTP: \(httpResponse.statusCode)")
            }
            
            print("📄 Data received: \(data.count) bytes")
            
            // Debug: Print the XML content for analysis
            if let xmlString = String(data: data, encoding: .utf8) {
                print("🔍 XML Content preview: \(String(xmlString.prefix(800)))...")
            }
            
            let papers = try parseArXivXML(data)
            print("✅ Successfully parsed \(papers.count) papers")
            return papers
            
        } catch let error as ArXivError {
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Final backup function to get papers when other queries fail
    /// Uses an extremely simple and reliable query
    nonisolated func fetchFallbackPapers(count: Int = 10) async throws -> [ArXivPaper] {
        // Use a simple query by specific category that always works with date sorting
        guard let url = URL(string: "\(baseURL)?search_query=cat:cs.LG&start=0&max_results=\(count)&sortBy=lastUpdatedDate&sortOrder=descending") else {
            throw ArXivError.invalidURL
        }
        
        print("🌐 Fetching from fallback URL: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ArXivError.networkError("Respuesta inválida del servidor")
            }
            
            print("📡 HTTP Status: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                throw ArXivError.networkError("Error HTTP: \(httpResponse.statusCode)")
            }
            
            print("📄 Data received: \(data.count) bytes")
            
            let papers = try parseArXivXML(data)
            print("✅ Successfully parsed \(papers.count) fallback papers")
            return papers
            
        } catch let error as ArXivError {
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Private method to parse the XML response from the ArXiv API
    /// Uses ArXivSimpleParser to convert XML into ArXivPaper objects
    /// - Parameter data: Raw XML data received from the API
    /// - Returns: Array of parsed and validated scientific papers
    /// - Throws: ArXivError.parsingError if the parsing process fails
    private func parseArXivXML(_ data: Data) throws -> [ArXivPaper] {
        let parser = ArXivSimpleParser()
        do {
            return try parser.parse(data)
        } catch {
            print("❌ XML parsing error: \(error.localizedDescription)")
            throw ArXivError.parsingError(error.localizedDescription)
        }
    }
}

/// Enumeration of specific errors for the ArXiv service
/// Defines the types of errors that can occur during communication with the API
enum ArXivError: Error, LocalizedError {
    /// Error when the constructed URL is invalid
    case invalidURL
    /// Network error with descriptive message
    case networkError(String)
    /// Error during XML parsing with descriptive message
    case parsingError(String)
    
    /// Localized error description for display to the user
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid ArXiv URL"
        case .networkError(let message):
            return "Connection error: \(message)"
        case .parsingError(let message):
            return "Error processing data: \(message)"
        }
    }
}
