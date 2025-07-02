//
//  ArXivController.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import Foundation
import SwiftUI

/// Controller que maneja la lógica de negocio de la aplicación ArXiv
/// Actúa como intermediario entre los modelos (datos) y las vistas (UI)
@MainActor
final class ArXivController: ObservableObject {
    
    // MARK: - Published Properties
    /// Papers de la categoría "Últimos"
    @Published var latestPapers: [ArXivPaper] = []
    
    /// Papers de Computer Science
    @Published var csPapers: [ArXivPaper] = []
    
    /// Papers de Mathematics
    @Published var mathPapers: [ArXivPaper] = []
    
    /// Estado de carga
    @Published var isLoading = false
    
    /// Mensaje de error
    @Published var errorMessage: String?
    
    /// Categoría actual seleccionada
    @Published var currentCategory: String = "latest"
    
    // MARK: - Private Properties
    /// Servicio para obtener datos de ArXiv
    private let arxivService = ArXivService()
    
    // MARK: - Computed Properties
    /// Papers filtrados según la categoría actual
    var filteredPapers: [ArXivPaper] {
        switch currentCategory {
        case "cs":
            return csPapers
        case "math":
            return mathPapers
        default:
            return latestPapers
        }
    }
    
    // MARK: - Public Methods
    
    /// Carga los últimos papers publicados
    func loadLatestPapers() async {
        print("🚀 Controller: Starting to load latest papers...")
        await loadPapers(category: "latest")
    }
    
    /// Carga papers de Computer Science
    func loadComputerSciencePapers() async {
        print("🚀 Controller: Starting to load Computer Science papers...")
        await loadPapers(category: "cs")
    }
    
    /// Carga papers de Mathematics
    func loadMathematicsPapers() async {
        print("🚀 Controller: Starting to load Mathematics papers...")
        await loadPapers(category: "math")
    }
    
    /// Cambia la categoría actual
    func changeCategory(to category: String) {
        currentCategory = category
    }
    
    // MARK: - Private Methods
    
    /// Método genérico para cargar papers según la categoría
    private func loadPapers(category: String) async {
        isLoading = true
        errorMessage = nil
        currentCategory = category
        
        // Registra el tiempo de inicio para garantizar una duración mínima de carga
        let startTime = Date()
        
        do {
            var fetchedPapers: [ArXivPaper] = []
            
            // Obtiene papers según la categoría
            switch category {
            case "cs":
                fetchedPapers = try await fetchComputerSciencePapersWithFallback()
            case "math":
                fetchedPapers = try await fetchMathematicsPapersWithFallback()
            default: // "latest"
                fetchedPapers = try await fetchLatestPapersWithFallback()
            }
            
            // Actualiza los papers según la categoría
            updatePapers(fetchedPapers, for: category)
            
            // Asegura que la animación de carga dure al menos 1 segundo
            await ensureMinimumLoadingTime(startTime: startTime)
            
            isLoading = false
            print("✅ Controller: Successfully loaded \(fetchedPapers.count) papers for category: \(category)")
            
        } catch {
            print("❌ Controller: Error loading papers: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            
            // Asegura que la animación de carga dure al menos 1 segundo incluso en caso de error
            await ensureMinimumLoadingTime(startTime: startTime)
            isLoading = false
        }
    }
    
    /// Obtiene los últimos papers con fallback
    private func fetchLatestPapersWithFallback() async throws -> [ArXivPaper] {
        // Intenta primero con la consulta específica
        var papers = try await arxivService.fetchLatestPapers(count: 10)
        
        // Si no obtiene resultados, intenta con la consulta simple
        if papers.isEmpty {
            print("⚠️ Controller: No papers found with specific query, trying simple query...")
            papers = try await arxivService.fetchRecentPapers(count: 10)
        }
        
        // Si aún no obtiene resultados, intenta con la consulta de respaldo final
        if papers.isEmpty {
            print("⚠️ Controller: No papers found with simple query, trying fallback query...")
            papers = try await arxivService.fetchFallbackPapers(count: 10)
        }
        
        return papers
    }
    
    /// Obtiene papers de Computer Science con fallback
    private func fetchComputerSciencePapersWithFallback() async throws -> [ArXivPaper] {
        let papers = try await arxivService.fetchComputerSciencePapers(count: 10)
        return papers
    }
    
    /// Obtiene papers de Mathematics con fallback
    private func fetchMathematicsPapersWithFallback() async throws -> [ArXivPaper] {
        let papers = try await arxivService.fetchMathematicsPapers(count: 10)
        return papers
    }
    
    /// Actualiza los papers según la categoría
    private func updatePapers(_ papers: [ArXivPaper], for category: String) {
        switch category {
        case "cs":
            csPapers = papers
        case "math":
            mathPapers = papers
        default: // "latest"
            latestPapers = papers
        }
    }
    
    /// Asegura que la carga dure al menos 1 segundo para una mejor UX
    private func ensureMinimumLoadingTime(startTime: Date) async {
        let elapsedTime = Date().timeIntervalSince(startTime)
        let minimumLoadingTime: TimeInterval = 1.0
        
        if elapsedTime < minimumLoadingTime {
            let remainingTime = minimumLoadingTime - elapsedTime
            try? await Task.sleep(nanoseconds: UInt64(remainingTime * 1_000_000_000))
        }
    }
}
