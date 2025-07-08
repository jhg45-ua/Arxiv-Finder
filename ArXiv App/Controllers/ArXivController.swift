//
//  ArXivController.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import Foundation
import SwiftUI
import SwiftData
import UserNotifications

/// Controller que maneja la lógica de negocio de la aplicación ArXiv
/// Actúa como intermediario entre los modelos (datos) y las vistas (UI)
@MainActor
final class ArXivController: ObservableObject {
    
    // MARK: - Properties
    /// Contexto de modelo para SwiftData
    var modelContext: ModelContext?
    
    // MARK: - Published Properties
    /// Papers de la categoría "Últimos"
    @Published var latestPapers: [ArXivPaper] = []
    
    /// Papers de Computer Science
    @Published var csPapers: [ArXivPaper] = []
    
    /// Papers de Mathematics
    @Published var mathPapers: [ArXivPaper] = []
    
    /// Papers de Physics
    @Published var physicsPapers: [ArXivPaper] = []
    
    /// Papers de Quantitative Biology
    @Published var quantitativeBiologyPapers: [ArXivPaper] = []
    
    /// Papers de Quantitative Finance
    @Published var quantitativeFinancePapers: [ArXivPaper] = []
    
    /// Papers de Statistics
    @Published var statisticsPapers: [ArXivPaper] = []
    
    /// Papers de Electrical Engineering and Systems Science
    @Published var electricalEngineeringPapers: [ArXivPaper] = []
    
    /// Papers de Economics
    @Published var economicsPapers: [ArXivPaper] = []
    
    /// Papers favoritos del usuario
    @Published var favoritePapers: [ArXivPaper] = []
    
    /// Estado de carga
    @Published var isLoading = false
    
    /// Mensaje de error
    @Published var errorMessage: String?
    
    /// Categoría actual seleccionada
    @Published var currentCategory: String = "latest"
    
    // MARK: - Private Properties
    /// Servicio para obtener datos de ArXiv
    private let arxivService = ArXivService()
    
    /// Timer para actualización automática
    private var autoRefreshTimer: Timer?
    
    // MARK: - Settings Properties
    /// Número máximo de papers a obtener (configurado en Settings)
    private var maxPapers: Int {
        UserDefaults.standard.integer(forKey: "maxPapers") == 0 ? 10 : UserDefaults.standard.integer(forKey: "maxPapers")
    }
    
    /// Intervalo de actualización automática en minutos
    private var refreshInterval: Int {
        UserDefaults.standard.integer(forKey: "refreshInterval") == 0 ? 30 : UserDefaults.standard.integer(forKey: "refreshInterval")
    }
    
    /// Si la actualización automática está habilitada
    private var autoRefresh: Bool {
        UserDefaults.standard.bool(forKey: "autoRefresh")
    }
    
    /// Categoría por defecto
    private var defaultCategory: String {
        UserDefaults.standard.string(forKey: "defaultCategory") ?? "latest"
    }
    
    // MARK: - Computed Properties
    /// Papers filtrados según la categoría actual
    var filteredPapers: [ArXivPaper] {
        switch currentCategory {
        case "cs":
            return csPapers
        case "math":
            return mathPapers
        case "physics":
            return physicsPapers
        case "q-bio":
            return quantitativeBiologyPapers
        case "q-fin":
            return quantitativeFinancePapers
        case "stat":
            return statisticsPapers
        case "eess":
            return electricalEngineeringPapers
        case "econ":
            return economicsPapers
        case "favorites":
            return favoritePapers
        default:
            return latestPapers
        }
    }
    
    // MARK: - Public Methods
    
    /// Carga los últimos papers publicados de ArXiv
    /// Actualiza la propiedad `latestPapers` con los resultados
    func loadLatestPapers() async {
        print("🚀 Controller: Starting to load latest papers...")
        await loadPapers(category: "latest")
    }
    
    /// Carga papers de la categoría Computer Science
    /// Actualiza la propiedad `csPapers` con los resultados
    func loadComputerSciencePapers() async {
        print("🚀 Controller: Starting to load Computer Science papers...")
        await loadPapers(category: "cs")
    }
    
    /// Carga papers de la categoría Mathematics
    /// Actualiza la propiedad `mathPapers` con los resultados
    func loadMathematicsPapers() async {
        print("🚀 Controller: Starting to load Mathematics papers...")
        await loadPapers(category: "math")
    }
    
    /// Carga papers de la categoría Physics
    /// Actualiza la propiedad `physicsPapers` con los resultados
    func loadPhysicsPapers() async {
        print("🚀 Controller: Starting to load Physics papers...")
        await loadPapers(category: "physics")
    }
    
    /// Carga papers de la categoría Quantitative Biology
    /// Actualiza la propiedad `quantitativeBiologyPapers` con los resultados
    func loadQuantitativeBiologyPapers() async {
        print("🚀 Controller: Starting to load Quantitative Biology papers...")
        await loadPapers(category: "q-bio")
    }
    
    /// Carga papers de la categoría Quantitative Finance
    /// Actualiza la propiedad `quantitativeFinancePapers` con los resultados
    func loadQuantitativeFinancePapers() async {
        print("🚀 Controller: Starting to load Quantitative Finance papers...")
        await loadPapers(category: "q-fin")
    }
    
    /// Carga papers de la categoría Statistics
    /// Actualiza la propiedad `statisticsPapers` con los resultados
    func loadStatisticsPapers() async {
        print("🚀 Controller: Starting to load Statistics papers...")
        await loadPapers(category: "stat")
    }
    
    /// Carga papers de la categoría Electrical Engineering and Systems Science
    /// Actualiza la propiedad `electricalEngineeringPapers` con los resultados
    func loadElectricalEngineeringPapers() async {
        print("🚀 Controller: Starting to load Electrical Engineering papers...")
        await loadPapers(category: "eess")
    }
    
    /// Carga papers de la categoría Economics
    /// Actualiza la propiedad `economicsPapers` con los resultados
    func loadEconomicsPapers() async {
        print("🚀 Controller: Starting to load Economics papers...")
        await loadPapers(category: "econ")
    }
    
    /// Cambia la categoría actual y actualiza la UI
    /// - Parameter category: Nueva categoría a seleccionar ("latest", "cs", "math", "physics", "q-bio", "q-fin", "stat", "eess", "econ", "favorites")
    func changeCategory(to category: String) {
        currentCategory = category
    }
    
    // MARK: - Private Methods
    
    /// Método genérico para cargar papers según la categoría especificada
    /// Gestiona el estado de carga, errores y actualiza las propiedades correspondientes
    /// - Parameter category: Categoría de papers a cargar ("latest", "cs", "math", "physics", "q-bio", "q-fin", "stat", "eess", "econ")
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
            case "physics":
                fetchedPapers = try await fetchPhysicsPapersWithFallback()
            case "q-bio":
                fetchedPapers = try await fetchQuantitativeBiologyPapersWithFallback()
            case "q-fin":
                fetchedPapers = try await fetchQuantitativeFinancePapersWithFallback()
            case "stat":
                fetchedPapers = try await fetchStatisticsPapersWithFallback()
            case "eess":
                fetchedPapers = try await fetchElectricalEngineeringPapersWithFallback()
            case "econ":
                fetchedPapers = try await fetchEconomicsPapersWithFallback()
            case "favorites":
                // Para favoritos, no necesitamos hacer fetch, solo cargar desde memoria
                await loadFavoritePapers()
                return
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
        // Usar configuración de maxPapers
        let count = maxPapers
        
        // Intenta primero con la consulta específica
        var papers = try await arxivService.fetchLatestPapers(count: count)
        
        // Si no obtiene resultados, intenta con la consulta simple
        if papers.isEmpty {
            print("⚠️ Controller: No papers found with specific query, trying simple query...")
            papers = try await arxivService.fetchRecentPapers(count: count)
        }
        
        // Si aún no obtiene resultados, intenta con la consulta de respaldo final
        if papers.isEmpty {
            print("⚠️ Controller: No papers found with simple query, trying fallback query...")
            papers = try await arxivService.fetchFallbackPapers(count: count)
        }
        
        return papers
    }
    
    /// Obtiene papers de Computer Science con fallback
    private func fetchComputerSciencePapersWithFallback() async throws -> [ArXivPaper] {
        let papers = try await arxivService.fetchComputerSciencePapers(count: maxPapers)
        return papers
    }
    
    /// Obtiene papers de Mathematics con fallback
    private func fetchMathematicsPapersWithFallback() async throws -> [ArXivPaper] {
        let papers = try await arxivService.fetchMathematicsPapers(count: maxPapers)
        return papers
    }
    
    /// Obtiene papers de Physics con fallback
    private func fetchPhysicsPapersWithFallback() async throws -> [ArXivPaper] {
        let papers = try await arxivService.fetchPhysicsPapers(count: maxPapers)
        return papers
    }
    
    /// Obtiene papers de Quantitative Biology con fallback
    private func fetchQuantitativeBiologyPapersWithFallback() async throws -> [ArXivPaper] {
        let papers = try await arxivService.fetchQuantitativeBiologyPapers(count: maxPapers)
        return papers
    }
    
    /// Obtiene papers de Quantitative Finance con fallback
    private func fetchQuantitativeFinancePapersWithFallback() async throws -> [ArXivPaper] {
        let papers = try await arxivService.fetchQuantitativeFinancePapers(count: maxPapers)
        return papers
    }
    
    /// Obtiene papers de Statistics con fallback
    private func fetchStatisticsPapersWithFallback() async throws -> [ArXivPaper] {
        let papers = try await arxivService.fetchStatisticsPapers(count: maxPapers)
        return papers
    }
    
    /// Obtiene papers de Electrical Engineering and Systems Science con fallback
    private func fetchElectricalEngineeringPapersWithFallback() async throws -> [ArXivPaper] {
        let papers = try await arxivService.fetchElectricalEngineeringPapers(count: maxPapers)
        return papers
    }
    
    /// Obtiene papers de Economics con fallback
    private func fetchEconomicsPapersWithFallback() async throws -> [ArXivPaper] {
        let papers = try await arxivService.fetchEconomicsPapers(count: maxPapers)
        return papers
    }
    
    /// Actualiza los papers según la categoría
    private func updatePapers(_ papers: [ArXivPaper], for category: String) {
        switch category {
        case "cs":
            csPapers = papers
        case "math":
            mathPapers = papers
        case "physics":
            physicsPapers = papers
        case "q-bio":
            quantitativeBiologyPapers = papers
        case "q-fin":
            quantitativeFinancePapers = papers
        case "stat":
            statisticsPapers = papers
        case "eess":
            electricalEngineeringPapers = papers
        case "econ":
            economicsPapers = papers
        default: // "latest"
            latestPapers = papers
        }
        
        // Guardar papers en SwiftData si está disponible
        if let modelContext = modelContext {
            for paper in papers {
                modelContext.insert(paper)
            }
            
            do {
                try modelContext.save()
                print("✅ Controller: Saved \(papers.count) papers to SwiftData for category: \(category)")
            } catch {
                print("❌ Controller: Error saving papers to SwiftData: \(error)")
            }
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
    
    // MARK: - Initialization
    
    /// Inicializador del controlador que configura el estado inicial
    /// Establece la categoría por defecto, configura la actualización automática
    /// y registra observers para cambios en configuración del usuario
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        
        // Configurar categoría inicial basada en configuración del usuario
        currentCategory = defaultCategory
        
        // Configurar actualización automática si está habilitada en settings
        setupAutoRefresh()
        
        // Escuchar cambios en configuración para reaccionar dinámicamente
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsChanged(_:)),
            name: .settingsChanged,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(interfaceSettingsChanged(_:)),
            name: .interfaceSettingsChanged,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsReset),
            name: .settingsReset,
            object: nil
        )
    }
    
    deinit {
        autoRefreshTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Auto Refresh
    
    /// Configura el timer de actualización automática
    private func setupAutoRefresh() {
        autoRefreshTimer?.invalidate() // Invalida el timer anterior si existe
        
        guard autoRefresh else {
            print("🚫 Controller: Auto-refresh is disabled in settings.")
            return
        }
        
        // Configura un nuevo timer para la actualización automática
        autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(refreshInterval * 60), repeats: true) { [weak self] _ in
            Task {
                await self?.performAutoRefresh()
            }
        }
        
        print("🕒 Controller: Auto-refresh timer set up to refresh every \(refreshInterval) minutes.")
    }
    
    /// Realiza una actualización automática
    private func performAutoRefresh() async {
        guard !isLoading else { return }
        
        print("🔄 Realizando actualización automática...")
        
        // Actualizar la categoría actual
        switch currentCategory {
        case "cs":
            await loadComputerSciencePapers()
        case "math":
            await loadMathematicsPapers()
        default:
            await loadLatestPapers()
        }
        
        // Mostrar notificación si está habilitada
        if UserDefaults.standard.bool(forKey: "showNotifications") {
            showAutoRefreshNotification()
        }
    }
    
    /// Muestra una notificación de actualización automática
    private func showAutoRefreshNotification() {
        let content = UNMutableNotificationContent()
        content.title = "ArXiv App"
        content.body = "Papers actualizados automáticamente"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "autoRefresh",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error al mostrar notificación: \(error)")
            }
        }
    }
    
    /// Maneja cambios en la configuración
    @objc private func settingsChanged(_ notification: Notification) {
        print("⚙️ Configuración cambiada, actualizando...")
        
        if let userInfo = notification.userInfo,
           let setting = userInfo["setting"] as? String {
            
            switch setting {
            case "autoRefresh", "refreshInterval":
                setupAutoRefresh()
            case "maxPapers":
                print("📄 Configuración de máximo de papers actualizada")
            case "defaultCategory":
                if let newCategory = userInfo["value"] as? String {
                    currentCategory = newCategory
                }
            default:
                break
            }
        } else {
            // Fallback para UserDefaults.didChangeNotification
            setupAutoRefresh()
        }
    }
    
    /// Maneja cambios en configuración de interfaz
    @objc private func interfaceSettingsChanged(_ notification: Notification) {
        print("🖼️ Configuración de interfaz cambiada")
        // Aquí podrías actualizar la UI si fuera necesario
    }
    
    /// Maneja el restablecimiento de configuración
    @objc private func settingsReset() {
        print("🔄 Configuración restablecida, reiniciando controlador...")
        
        // Restablecer valores del controlador
        currentCategory = "latest"
        setupAutoRefresh()
        
        // Recargar datos con configuración por defecto
        Task {
            await loadPapersWithSettings()
        }
    }
    
    // MARK: - Settings Integration Methods
    
    /// Carga papers usando la configuración actual
    func loadPapersWithSettings() async {
        let category = defaultCategory
        currentCategory = category
        
        switch category {
        case "cs":
            await loadComputerSciencePapers()
        case "math":
            await loadMathematicsPapers()
        case "physics":
            await loadPhysicsPapers()
        case "q-bio":
            await loadQuantitativeBiologyPapers()
        case "q-fin":
            await loadQuantitativeFinancePapers()
        case "stat":
            await loadStatisticsPapers()
        case "eess":
            await loadElectricalEngineeringPapers()
        case "econ":
            await loadEconomicsPapers()
        case "favorites":
            await loadFavoritePapers()
        default:
            await loadLatestPapers()
        }
    }
    
    // MARK: - Favorites Management
    
    /// Carga todos los papers favoritos desde la base de datos
    func loadFavoritePapers() async {
        print("🚀 Controller: Starting to load favorite papers...")
        currentCategory = "favorites"
        isLoading = true
        
        do {
            if let modelContext = modelContext {
                // Cargar desde SwiftData
                let descriptor = FetchDescriptor<ArXivPaper>(predicate: #Predicate<ArXivPaper> { $0.isFavorite == true })
                let favoriteResults = try modelContext.fetch(descriptor)
                favoritePapers = favoriteResults.sorted { $0.favoritedDate ?? Date.distantPast > $1.favoritedDate ?? Date.distantPast }
                print("✅ Controller: Loaded \(favoritePapers.count) favorite papers from SwiftData")
            } else {
                // Fallback: cargar desde memoria
                favoritePapers = getAllPapers().filter { $0.isFavorite }
                    .sorted { $0.favoritedDate ?? Date.distantPast > $1.favoritedDate ?? Date.distantPast }
                print("✅ Controller: Loaded \(favoritePapers.count) favorite papers from memory")
            }
        } catch {
            print("❌ Controller: Error loading favorites: \(error)")
            errorMessage = "Error cargando favoritos: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Alterna el estado de favorito de un paper
    /// - Parameter paper: El paper a marcar/desmarcar como favorito
    func toggleFavorite(for paper: ArXivPaper) {
        print("🚀 Controller: Toggling favorite for paper: \(paper.title)")
        
        // Actualizar el estado del paper
        let newFavoriteState = !paper.isFavorite
        paper.setFavorite(newFavoriteState)
        
        // Guardar en SwiftData si está disponible
        if let modelContext = modelContext {
            do {
                try modelContext.save()
                print("✅ Controller: Paper favorite status saved to SwiftData")
            } catch {
                print("❌ Controller: Error saving to SwiftData: \(error)")
            }
        }
        
        // Actualizar la lista de favoritos
        if newFavoriteState {
            // Añadir a favoritos si no está ya
            if !favoritePapers.contains(where: { $0.id == paper.id }) {
                favoritePapers.append(paper)
                favoritePapers.sort { $0.favoritedDate ?? Date.distantPast > $1.favoritedDate ?? Date.distantPast }
            }
        } else {
            // Remover de favoritos
            favoritePapers.removeAll { $0.id == paper.id }
        }
        
        // Actualizar también en las otras listas de categorías
        updatePaperInAllCategories(paper)
        
        print("✅ Controller: Paper favorite status updated to: \(newFavoriteState)")
    }
    
    /// Actualiza un paper en todas las categorías donde aparece
    private func updatePaperInAllCategories(_ paper: ArXivPaper) {
        // Actualizar en todas las listas de categorías
        if let index = latestPapers.firstIndex(where: { $0.id == paper.id }) {
            latestPapers[index] = paper
        }
        if let index = csPapers.firstIndex(where: { $0.id == paper.id }) {
            csPapers[index] = paper
        }
        if let index = mathPapers.firstIndex(where: { $0.id == paper.id }) {
            mathPapers[index] = paper
        }
        if let index = physicsPapers.firstIndex(where: { $0.id == paper.id }) {
            physicsPapers[index] = paper
        }
        if let index = quantitativeBiologyPapers.firstIndex(where: { $0.id == paper.id }) {
            quantitativeBiologyPapers[index] = paper
        }
        if let index = quantitativeFinancePapers.firstIndex(where: { $0.id == paper.id }) {
            quantitativeFinancePapers[index] = paper
        }
        if let index = statisticsPapers.firstIndex(where: { $0.id == paper.id }) {
            statisticsPapers[index] = paper
        }
        if let index = electricalEngineeringPapers.firstIndex(where: { $0.id == paper.id }) {
            electricalEngineeringPapers[index] = paper
        }
        if let index = economicsPapers.firstIndex(where: { $0.id == paper.id }) {
            economicsPapers[index] = paper
        }
    }
    
    /// Obtiene todos los papers de todas las categorías (helper method)
    private func getAllPapers() -> [ArXivPaper] {
        var allPapers: [ArXivPaper] = []
        allPapers.append(contentsOf: latestPapers)
        allPapers.append(contentsOf: csPapers)
        allPapers.append(contentsOf: mathPapers)
        allPapers.append(contentsOf: physicsPapers)
        allPapers.append(contentsOf: quantitativeBiologyPapers)
        allPapers.append(contentsOf: quantitativeFinancePapers)
        allPapers.append(contentsOf: statisticsPapers)
        allPapers.append(contentsOf: electricalEngineeringPapers)
        allPapers.append(contentsOf: economicsPapers)
        
        // Remover duplicados basándose en el ID
        var uniquePapers: [ArXivPaper] = []
        var seenIDs: Set<String> = []
        
        for paper in allPapers {
            if !seenIDs.contains(paper.id) {
                uniquePapers.append(paper)
                seenIDs.insert(paper.id)
            }
        }
        
        return uniquePapers
    }
}

// MARK: - Notification Names Extension
extension Notification.Name {
    static let settingsChanged = Notification.Name("settingsChanged")
    static let interfaceSettingsChanged = Notification.Name("interfaceSettingsChanged")
    static let settingsReset = Notification.Name("settingsReset")
}
