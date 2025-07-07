//
//  ArXivController.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import Foundation
import SwiftUI
import UserNotifications
import UserNotifications

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
    
    /// Cambia la categoría actual y actualiza la UI
    /// - Parameter category: Nueva categoría a seleccionar ("latest", "cs", "math")
    func changeCategory(to category: String) {
        currentCategory = category
    }
    
    // MARK: - Private Methods
    
    /// Método genérico para cargar papers según la categoría especificada
    /// Gestiona el estado de carga, errores y actualiza las propiedades correspondientes
    /// - Parameter category: Categoría de papers a cargar ("latest", "cs", "math")
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
    
    // MARK: - Initialization
    
    /// Inicializador del controlador que configura el estado inicial
    /// Establece la categoría por defecto, configura la actualización automática
    /// y registra observers para cambios en configuración del usuario
    init() {
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
        default:
            await loadLatestPapers()
        }
    }
}

// MARK: - Notification Names Extension
extension Notification.Name {
    static let settingsChanged = Notification.Name("settingsChanged")
    static let interfaceSettingsChanged = Notification.Name("interfaceSettingsChanged")
    static let settingsReset = Notification.Name("settingsReset")
}
