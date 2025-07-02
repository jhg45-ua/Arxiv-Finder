//
//  ArXivService.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import Foundation

/// Servicio encargado de comunicarse con la API de ArXiv
/// Maneja las peticiones HTTP y el parsing de respuestas XML
final class ArXivService {
    /// URL base de la API de ArXiv (usando HTTPS para cumplir con ATS)
    private let baseURL = "https://export.arxiv.org/api/query"
    
    /// Obtiene los últimos artículos publicados en ArXiv
    /// - Parameter count: Número de artículos a obtener (por defecto 10)
    /// - Returns: Array de artículos de ArXiv
    /// - Throws: Error si falla la petición o el parsing
    func fetchLatestPapers(count: Int = 10) async throws -> [ArXivPaper] {
        // Construye la URL con parámetros para obtener los últimos artículos
        // Usa una consulta más específica que garantice resultados
        guard let url = URL(string: "\(baseURL)?search_query=cat:cs.AI&start=0&max_results=\(count)&sortBy=submittedDate&sortOrder=descending") else {
            throw ArXivError.invalidURL
        }
        
        print("🌐 Fetching from URL: \(url.absoluteString)")
        
        do {
            // Realiza la petición HTTP de forma asíncrona
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Verifica que la respuesta HTTP sea exitosa
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
                print("🔍 XML Content preview: \(String(xmlString.prefix(500)))...")
            }
            
            // Parsea la respuesta XML y convierte a objetos ArXivPaper
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
    
    /// Función alternativa para obtener los últimos artículos usando una consulta simple
    /// Útil cuando la consulta principal no funciona
    func fetchRecentPapers(count: Int = 10) async throws -> [ArXivPaper] {
        // Usa una consulta muy simple sin filtros complejos
        guard let url = URL(string: "\(baseURL)?search_query=*&start=0&max_results=\(count)") else {
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
    
    /// Parsea la respuesta XML de la API de ArXiv
    /// - Parameter data: Datos XML recibidos de la API
    /// - Returns: Array de artículos parseados
    /// - Throws: Error si falla el parsing
    private func parseArXivXML(_ data: Data) throws -> [ArXivPaper] {
        let parser = ArXivXMLParser()
        do {
            return try parser.parse(data)
        } catch {
            print("❌ XML parsing error: \(error.localizedDescription)")
            throw ArXivError.parsingError(error.localizedDescription)
        }
    }
}

/// Enumeración de errores específicos del servicio ArXiv
enum ArXivError: Error, LocalizedError {
    case invalidURL
    case networkError(String)
    case parsingError(String)
    
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
