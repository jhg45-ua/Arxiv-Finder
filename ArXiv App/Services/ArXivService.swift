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
    
    /// Obtiene artículos de Mathematics de ArXiv
    /// - Parameter count: Número de artículos a obtener (por defecto 10)
    /// - Returns: Array de artículos de Mathematics
    /// - Throws: Error si falla la petición o el parsing
    nonisolated func fetchMathematicsPapers(count: Int = 10) async throws -> [ArXivPaper] {
        // Construye la URL para obtener artículos de Mathematics (categoría math)
        // Usa lastUpdatedDate para obtener los más recientes
        guard let url = URL(string: "\(baseURL)?search_query=cat:math*&start=0&max_results=\(count)&sortBy=lastUpdatedDate&sortOrder=descending") else {
            throw ArXivError.invalidURL
        }
        
        print("🌐 Fetching Mathematics papers from URL: \(url.absoluteString)")
        
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
            print("✅ Successfully parsed \(papers.count) Mathematics papers")
            return papers
            
        } catch let error as ArXivError {
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Obtiene artículos de Physics de ArXiv
    /// - Parameter count: Número de artículos a obtener (por defecto 10)
    /// - Returns: Array de artículos de Physics
    /// - Throws: Error si falla la petición o el parsing
    nonisolated func fetchPhysicsPapers(count: Int = 10) async throws -> [ArXivPaper] {
        // Construye la URL para obtener artículos de Physics (categoría physics)
        // Usa lastUpdatedDate para obtener los más recientes
        guard let url = URL(string: "\(baseURL)?search_query=cat:physics*&start=0&max_results=\(count)&sortBy=lastUpdatedDate&sortOrder=descending") else {
            throw ArXivError.invalidURL
        }
        
        print("🌐 Fetching Physics papers from URL: \(url.absoluteString)")
        
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
            print("✅ Successfully parsed \(papers.count) Physics papers")
            return papers
            
        } catch let error as ArXivError {
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Obtiene artículos de Quantitative Biology de ArXiv
    /// - Parameter count: Número de artículos a obtener (por defecto 10)
    /// - Returns: Array de artículos de Quantitative Biology
    /// - Throws: Error si falla la petición o el parsing
    nonisolated func fetchQuantitativeBiologyPapers(count: Int = 10) async throws -> [ArXivPaper] {
        // Construye la URL para obtener artículos de Quantitative Biology (categoría q-bio)
        // Usa lastUpdatedDate para obtener los más recientes
        guard let url = URL(string: "\(baseURL)?search_query=cat:q-bio*&start=0&max_results=\(count)&sortBy=lastUpdatedDate&sortOrder=descending") else {
            throw ArXivError.invalidURL
        }
        
        print("🌐 Fetching Quantitative Biology papers from URL: \(url.absoluteString)")
        
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
            print("✅ Successfully parsed \(papers.count) Quantitative Biology papers")
            return papers
            
        } catch let error as ArXivError {
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Obtiene artículos de Quantitative Finance de ArXiv
    /// - Parameter count: Número de artículos a obtener (por defecto 10)
    /// - Returns: Array de artículos de Quantitative Finance
    /// - Throws: Error si falla la petición o el parsing
    nonisolated func fetchQuantitativeFinancePapers(count: Int = 10) async throws -> [ArXivPaper] {
        // Construye la URL para obtener artículos de Quantitative Finance (categoría q-fin)
        // Usa lastUpdatedDate para obtener los más recientes
        guard let url = URL(string: "\(baseURL)?search_query=cat:q-fin*&start=0&max_results=\(count)&sortBy=lastUpdatedDate&sortOrder=descending") else {
            throw ArXivError.invalidURL
        }
        
        print("🌐 Fetching Quantitative Finance papers from URL: \(url.absoluteString)")
        
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
            print("✅ Successfully parsed \(papers.count) Quantitative Finance papers")
            return papers
            
        } catch let error as ArXivError {
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Obtiene artículos de Statistics de ArXiv
    /// - Parameter count: Número de artículos a obtener (por defecto 10)
    /// - Returns: Array de artículos de Statistics
    /// - Throws: Error si falla la petición o el parsing
    nonisolated func fetchStatisticsPapers(count: Int = 10) async throws -> [ArXivPaper] {
        // Construye la URL para obtener artículos de Statistics (categoría stat)
        // Usa lastUpdatedDate para obtener los más recientes
        guard let url = URL(string: "\(baseURL)?search_query=cat:stat*&start=0&max_results=\(count)&sortBy=lastUpdatedDate&sortOrder=descending") else {
            throw ArXivError.invalidURL
        }
        
        print("🌐 Fetching Statistics papers from URL: \(url.absoluteString)")
        
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
            print("✅ Successfully parsed \(papers.count) Statistics papers")
            return papers
            
        } catch let error as ArXivError {
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Obtiene artículos de Electrical Engineering and Systems Science de ArXiv
    /// - Parameter count: Número de artículos a obtener (por defecto 10)
    /// - Returns: Array de artículos de Electrical Engineering and Systems Science
    /// - Throws: Error si falla la petición o el parsing
    nonisolated func fetchElectricalEngineeringPapers(count: Int = 10) async throws -> [ArXivPaper] {
        // Construye la URL para obtener artículos de Electrical Engineering and Systems Science (categoría eess)
        // Usa lastUpdatedDate para obtener los más recientes
        guard let url = URL(string: "\(baseURL)?search_query=cat:eess*&start=0&max_results=\(count)&sortBy=lastUpdatedDate&sortOrder=descending") else {
            throw ArXivError.invalidURL
        }
        
        print("🌐 Fetching Electrical Engineering and Systems Science papers from URL: \(url.absoluteString)")
        
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
            print("✅ Successfully parsed \(papers.count) Electrical Engineering and Systems Science papers")
            return papers
            
        } catch let error as ArXivError {
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Obtiene artículos de Economics de ArXiv
    /// - Parameter count: Número de artículos a obtener (por defecto 10)
    /// - Returns: Array de artículos de Economics
    /// - Throws: Error si falla la petición o el parsing
    nonisolated func fetchEconomicsPapers(count: Int = 10) async throws -> [ArXivPaper] {
        // Construye la URL para obtener artículos de Economics (categoría econ)
        // Usa lastUpdatedDate para obtener los más recientes
        guard let url = URL(string: "\(baseURL)?search_query=cat:econ*&start=0&max_results=\(count)&sortBy=lastUpdatedDate&sortOrder=descending") else {
            throw ArXivError.invalidURL
        }
        
        print("🌐 Fetching Economics papers from URL: \(url.absoluteString)")
        
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
            print("✅ Successfully parsed \(papers.count) Economics papers")
            return papers
            
        } catch let error as ArXivError {
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw ArXivError.networkError(error.localizedDescription)
        }
    }
    
    /// Función alternativa para obtener los últimos artículos usando una consulta simple
    /// Útil cuando la consulta principal no funciona
    nonisolated func fetchRecentPapers(count: Int = 10) async throws -> [ArXivPaper] {
        // Usa una consulta que busca papers recientes en categorías específicas con ordenamiento por fecha
        // Codifica correctamente los espacios como + para OR
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
            
            // Debug: Imprimir el contenido XML para análisis
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
    
    /// Función de respaldo final para obtener artículos cuando otras consultas fallan
    /// Usa una consulta extremadamente simple y confiable
    nonisolated func fetchFallbackPapers(count: Int = 10) async throws -> [ArXivPaper] {
        // Usa una consulta simple por categoría específica que siempre funciona con ordenamiento por fecha
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
    
    /// Método privado que parsea la respuesta XML de la API de ArXiv
    /// Utiliza ArXivSimpleParser para convertir XML en objetos ArXivPaper
    /// - Parameter data: Datos XML en bruto recibidos de la API
    /// - Returns: Array de artículos científicos parseados y validados
    /// - Throws: ArXivError.parsingError si falla el proceso de parsing
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

/// Enumeración de errores específicos del servicio ArXiv
/// Define los tipos de errores que pueden ocurrir durante la comunicación con la API
enum ArXivError: Error, LocalizedError {
    /// Error cuando la URL construida es inválida
    case invalidURL
    /// Error de red con mensaje descriptivo
    case networkError(String)
    /// Error durante el parsing del XML con mensaje descriptivo
    case parsingError(String)
    
    /// Descripción localizada del error para mostrar al usuario
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL de ArXiv inválida"
        case .networkError(let message):
            return "Error de conexión: \(message)"
        case .parsingError(let message):
            return "Error al procesar datos: \(message)"
        }
    }
}
