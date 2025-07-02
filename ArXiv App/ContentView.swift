//
//  ContentView.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import SwiftUI
import SwiftData

/// Vista principal de la aplicación ArXiv App
/// Muestra una lista de los últimos artículos científicos de ArXiv
struct ContentView: View {
    /// Acceso al contexto del modelo de datos para realizar operaciones CRUD
    /// Permite insertar, actualizar y eliminar elementos de la base de datos
    @Environment(\.modelContext) private var modelContext
    
    /// Query que obtiene todos los artículos de ArXiv ordenados por fecha de publicación
    /// Se actualiza automáticamente cuando los datos cambian
    @Query(sort: \ArXivPaper.publishedDate, order: .reverse) 
    private var papers: [ArXivPaper]
    
    /// Servicio para obtener datos de la API de ArXiv
    private let arxivService = ArXivService()
    
    /// Estado de carga para mostrar indicador de progreso
    @State private var isLoading = false
    
    /// Estado de error para mostrar mensajes al usuario
    @State private var errorMessage: String?
    
    /// Paper seleccionado en macOS para NavigationSplitView
    @State private var selectedPaper: ArXivPaper?
    
    /// Categoría actual seleccionada
    @State private var currentCategory: String = "latest"
    
    /// Estado para manejar las categorías por separado
    @State private var latestPapers: [ArXivPaper] = []
    @State private var csPapers: [ArXivPaper] = []
    @State private var mathPapers: [ArXivPaper] = []

    /// Papers filtrados según la categoría actual
    private var filteredPapers: [ArXivPaper] {
        switch currentCategory {
        case "cs":
            return csPapers
        case "math":
            return mathPapers
        default:
            return latestPapers
        }
    }

    /// Define la estructura visual de la vista principal
    var body: some View {
        #if os(macOS)
        // Diseño específico para macOS con NavigationSplitView
        NavigationSplitView {
            // Barra lateral en macOS
            SidebarView(
                currentCategory: $currentCategory,
                onLatestPapersSelected: {
                    await loadLatestPapers()
                    selectedPaper = nil // Volver a la vista principal
                },
                onComputerScienceSelected: {
                    await loadComputerSciencePapers()
                    selectedPaper = nil // Volver a la vista principal
                },
                onMathematicsSelected: {
                    await loadMathematicsPapers()
                    selectedPaper = nil // Volver a la vista principal
                }
            )
        } content: {
            // Vista principal de artículos
            PapersListView(
                papers: filteredPapers,
                isLoading: isLoading,
                errorMessage: $errorMessage,
                loadLatestPapers: loadLatestPapers,
                selectedPaper: $selectedPaper
            )
        } detail: {
            // Vista de detalle o placeholder
            if let paper = selectedPaper {
                PaperDetailView(paper: paper, onBackToList: {
                    selectedPaper = nil
                })
            } else {
                ContentUnavailableView(
                    "Selecciona un artículo",
                    systemImage: "doc.text",
                    description: Text("Elige un paper de la lista para ver los detalles")
                )
            }
        }
        .navigationTitle("ArXiv Papers")
        .task {
            // Carga inicial de artículos al aparecer la vista
            if latestPapers.isEmpty && csPapers.isEmpty && mathPapers.isEmpty {
                await loadLatestPapers()
            }
        }
        #else
        // Diseño específico para iOS con NavigationStack
        NavigationStack {
            PapersListView(
                papers: filteredPapers,
                isLoading: isLoading,
                errorMessage: $errorMessage,
                loadLatestPapers: loadLatestPapers,
                loadComputerSciencePapers: loadComputerSciencePapers,
                loadMathematicsPapers: loadMathematicsPapers
            )
            .navigationTitle("ArXiv Papers")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            // Carga inicial de artículos al aparecer la vista
            if latestPapers.isEmpty && csPapers.isEmpty && mathPapers.isEmpty {
                await loadLatestPapers()
            }
        }
        #endif
    }
    
    /// Carga los últimos artículos de ArXiv desde la API
    /// Actualiza la base de datos local con los nuevos artículos
    @MainActor
    private func loadLatestPapers() async {
        print("🚀 Starting to load latest papers...")
        isLoading = true
        errorMessage = nil
        currentCategory = "latest"
        
        // Registra el tiempo de inicio para garantizar una duración mínima de carga
        let startTime = Date()
        
        do {
            // Intenta primero con la consulta específica
            var fetchedPapers = try await arxivService.fetchLatestPapers(count: 10)
            
            // Si no obtiene resultados, intenta con la consulta simple
            if fetchedPapers.isEmpty {
                print("⚠️ No papers found with specific query, trying simple query...")
                fetchedPapers = try await arxivService.fetchRecentPapers(count: 10)
            }
            
            // Si aún no obtiene resultados, intenta con la consulta de respaldo final
            if fetchedPapers.isEmpty {
                print("⚠️ No papers found with simple query, trying fallback query...")
                fetchedPapers = try await arxivService.fetchFallbackPapers(count: 10)
            }
            
            // Actualiza solo los papers de "latest"
            latestPapers = fetchedPapers
            
            // Actualiza la base de datos solo si estamos en la categoría "latest"
            if currentCategory == "latest" {
                // Limpia artículos anteriores de la categoría latest
                for paper in papers.filter({ paper in
                    !csPapers.contains(where: { $0.id == paper.id }) &&
                    !mathPapers.contains(where: { $0.id == paper.id })
                }) {
                    modelContext.delete(paper)
                }
                
                // Añade los nuevos artículos
                for paper in fetchedPapers {
                    modelContext.insert(paper)
                }
                
                // Guarda los cambios
                do {
                    try modelContext.save()
                    print("✅ Successfully saved \(fetchedPapers.count) latest papers to database")
                } catch {
                    print("❌ Error saving to database: \(error.localizedDescription)")
                    errorMessage = "Error guardando en base de datos: \(error.localizedDescription)"
                }
            }
            
            // Asegura que la animación de carga dure al menos 1 segundo
            let elapsedTime = Date().timeIntervalSince(startTime)
            let minimumLoadingTime: TimeInterval = 1.0
            
            if elapsedTime < minimumLoadingTime {
                let remainingTime = minimumLoadingTime - elapsedTime
                try await Task.sleep(nanoseconds: UInt64(remainingTime * 1_000_000_000))
            }
            
            isLoading = false
        } catch {
            print("❌ Error loading papers: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            
            // Asegura que la animación de carga dure al menos 1 segundo incluso en caso de error
            let elapsedTime = Date().timeIntervalSince(startTime)
            let minimumLoadingTime: TimeInterval = 1.0
            
            if elapsedTime < minimumLoadingTime {
                let remainingTime = minimumLoadingTime - elapsedTime
                try? await Task.sleep(nanoseconds: UInt64(remainingTime * 1_000_000_000))
            }
            
            isLoading = false
        }
    }
    
    /// Carga artículos de Computer Science desde la API de ArXiv
    /// Actualiza la base de datos local con los nuevos artículos
    @MainActor
    private func loadComputerSciencePapers() async {
        print("🚀 Starting to load Computer Science papers...")
        isLoading = true
        errorMessage = nil
        currentCategory = "cs"
        
        // Registra el tiempo de inicio para garantizar una duración mínima de carga
        let startTime = Date()
        
        do {
            // Obtiene artículos de Computer Science
            let fetchedPapers = try await arxivService.fetchComputerSciencePapers(count: 15)
            
            // Actualiza solo los papers de CS
            csPapers = fetchedPapers
            
            // Asegura que la animación de carga dure al menos 1 segundo
            let elapsedTime = Date().timeIntervalSince(startTime)
            let minimumLoadingTime: TimeInterval = 1.0
            
            if elapsedTime < minimumLoadingTime {
                let remainingTime = minimumLoadingTime - elapsedTime
                try await Task.sleep(nanoseconds: UInt64(remainingTime * 1_000_000_000))
            }
            
            isLoading = false
        } catch {
            print("❌ Error loading Computer Science papers: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            
            // Asegura que la animación de carga dure al menos 1 segundo incluso en caso de error
            let elapsedTime = Date().timeIntervalSince(startTime)
            let minimumLoadingTime: TimeInterval = 1.0
            
            if elapsedTime < minimumLoadingTime {
                let remainingTime = minimumLoadingTime - elapsedTime
                try? await Task.sleep(nanoseconds: UInt64(remainingTime * 1_000_000_000))
            }
            
            isLoading = false
        }
    }
    
    /// Carga artículos de Mathematics desde la API de ArXiv
    /// Actualiza la base de datos local con los nuevos artículos
    @MainActor
    private func loadMathematicsPapers() async {
        print("🚀 Starting to load Mathematics papers...")
        isLoading = true
        errorMessage = nil
        currentCategory = "math"
        
        // Registra el tiempo de inicio para garantizar una duración mínima de carga
        let startTime = Date()
        
        do {
            // Obtiene artículos de Mathematics
            let fetchedPapers = try await arxivService.fetchMathematicsPapers(count: 15)
            
            // Actualiza solo los papers de Math
            mathPapers = fetchedPapers
            
            // Asegura que la animación de carga dure al menos 1 segundo
            let elapsedTime = Date().timeIntervalSince(startTime)
            let minimumLoadingTime: TimeInterval = 1.0
            
            if elapsedTime < minimumLoadingTime {
                let remainingTime = minimumLoadingTime - elapsedTime
                try await Task.sleep(nanoseconds: UInt64(remainingTime * 1_000_000_000))
            }
            
            isLoading = false
        } catch {
            print("❌ Error loading Mathematics papers: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            
            // Asegura que la animación de carga dure al menos 1 segundo incluso en caso de error
            let elapsedTime = Date().timeIntervalSince(startTime)
            let minimumLoadingTime: TimeInterval = 1.0
            
            if elapsedTime < minimumLoadingTime {
                let remainingTime = minimumLoadingTime - elapsedTime
                try? await Task.sleep(nanoseconds: UInt64(remainingTime * 1_000_000_000))
            }
            
            isLoading = false
        }
    }
}

/// Vista que representa una fila individual de artículo en la lista
/// Muestra título, autores y fecha de publicación de forma compacta
/// Adaptada para funcionar óptimamente en iOS y macOS
struct ArXivPaperRow: View {
    let paper: ArXivPaper
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Título del artículo
            Text(paper.title)
                .font(.title3)
                .fontWeight(.medium)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
            
            // Autores del artículo
            Text(paper.authors)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // Resumen del artículo (mostrar las primeras líneas)
            Text(paper.summary)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .padding(.top, 4)
            
            HStack {
                // Fechas del paper
                VStack(alignment: .leading, spacing: 2) {
                    // Fecha de publicación
                    Label(paper.publishedDate.formatted(date: .abbreviated, time: .omitted), 
                          systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Fecha de actualización (si existe y es diferente)
                    if let updatedDate = paper.updatedDate,
                       abs(updatedDate.timeIntervalSince(paper.publishedDate)) > 3600 { // Más de 1 hora de diferencia
                        Label("Actualizado: \(updatedDate.formatted(date: .abbreviated, time: .omitted))", 
                              systemImage: "arrow.clockwise")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                // Categorías
                if !paper.categories.isEmpty {
                    Text(paper.categories.components(separatedBy: " ").first ?? "")
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                }
                
                // ID del paper
                Text("ID: \(paper.id)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
            }
        }
        .padding(.vertical, 16)
        #if os(macOS)
        .padding(.horizontal, 20)
        .background(Color.clear)
        .cornerRadius(12)
        .contentShape(Rectangle())
        #endif
    }
}

/// Vista de barra lateral para macOS
/// Proporciona navegación y opciones adicionales en la interfaz de macOS
struct SidebarView: View {
    @Binding var currentCategory: String
    let onLatestPapersSelected: () async -> Void
    let onComputerScienceSelected: () async -> Void
    let onMathematicsSelected: () async -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header simplificado
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "doc.richtext")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("ArXiv")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
            }
            
            Divider()
                .padding(.horizontal, 16)
            
            // Lista de navegación simplificada
            VStack(spacing: 8) {
                sidebarButton(
                    title: "Últimos Papers",
                    icon: "doc.text",
                    isSelected: currentCategory == "latest"
                ) {
                    Task { await onLatestPapersSelected() }
                }
                
                sidebarButton(
                    title: "Computer Science",
                    icon: "laptopcomputer",
                    isSelected: currentCategory == "cs"
                ) {
                    Task { await onComputerScienceSelected() }
                }
                
                sidebarButton(
                    title: "Mathematics",
                    icon: "x.squareroot",
                    isSelected: currentCategory == "math"
                ) {
                    Task { await onMathematicsSelected() }
                }
                
                Divider()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                
                sidebarButton(
                    title: "Favoritos",
                    icon: "heart",
                    isSelected: false,
                    isEnabled: false
                ) {
                    // Funcionalidad pendiente
                }
                
                sidebarButton(
                    title: "Búsqueda",
                    icon: "magnifyingglass",
                    isSelected: false,
                    isEnabled: false
                ) {
                    // Funcionalidad pendiente
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 16)
            
            Spacer()
        }
        .frame(minWidth: 220)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    @ViewBuilder
    private func sidebarButton(
        title: String,
        icon: String,
        isSelected: Bool,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : (isEnabled ? .primary : .secondary))
                    .frame(width: 20)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : (isEnabled ? .primary : .secondary))
                
                Spacer()
                
                if !isEnabled {
                    Text("Pronto")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.secondary.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected ? Color.accentColor : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

}

/// Vista principal de la lista de papers
/// Funciona tanto en iOS como en macOS con adaptaciones específicas
struct PapersListView: View {
    let papers: [ArXivPaper]
    let isLoading: Bool
    @Binding var errorMessage: String?
    let loadLatestPapers: () async -> Void
    let loadComputerSciencePapers: (() async -> Void)?
    let loadMathematicsPapers: (() async -> Void)?
    @State private var shouldRefreshOnAppear = false
    @State private var currentCategory: String = "latest"
    
    // Parámetro opcional para macOS NavigationSplitView
    @Binding var selectedPaper: ArXivPaper?
    
    // Inicializador para iOS (sin selectedPaper)
    init(papers: [ArXivPaper], isLoading: Bool, errorMessage: Binding<String?>, loadLatestPapers: @escaping () async -> Void, loadComputerSciencePapers: (() async -> Void)? = nil, loadMathematicsPapers: (() async -> Void)? = nil) {
        self.papers = papers
        self.isLoading = isLoading
        self._errorMessage = errorMessage
        self.loadLatestPapers = loadLatestPapers
        self.loadComputerSciencePapers = loadComputerSciencePapers
        self.loadMathematicsPapers = loadMathematicsPapers
        self._selectedPaper = .constant(nil)
    }
    
    // Inicializador para macOS (con selectedPaper)
    init(papers: [ArXivPaper], isLoading: Bool, errorMessage: Binding<String?>, loadLatestPapers: @escaping () async -> Void, selectedPaper: Binding<ArXivPaper?>) {
        self.papers = papers
        self.isLoading = isLoading
        self._errorMessage = errorMessage
        self.loadLatestPapers = loadLatestPapers
        self.loadComputerSciencePapers = nil
        self.loadMathematicsPapers = nil
        self._selectedPaper = selectedPaper
    }
    
    var body: some View {
        VStack {
            if isLoading {
                // Indicador de carga mientras se obtienen los datos
                VStack(spacing: 16) {
                    ProgressView()
                        .controlSize(.regular)
                        #if os(macOS)
                        .frame(width: 32, height: 32)
                        #else
                        .scaleEffect(1.2)
                        #endif
                    Text("Cargando los últimos artículos de ArXiv...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else if let error = errorMessage {
                // Mensaje de error prominente cuando hay problemas de conexión
                ContentUnavailableView(
                    "Error al cargar artículos",
                    systemImage: "wifi.exclamationmark",
                    description: Text(error)
                )
                .overlay(alignment: .bottom) {
                    VStack(spacing: 12) {
                        Button("Reintentar") {
                            Task {
                                await loadLatestPapers()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Limpiar error") {
                            errorMessage = nil
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                }
            } else if papers.isEmpty {
                // Mensaje cuando no hay artículos disponibles pero no hay error
                ContentUnavailableView(
                    "No hay artículos disponibles",
                    systemImage: "doc.text",
                    description: Text("No se encontraron artículos. Verifica tu conexión a internet e intenta nuevamente.")
                )
                .overlay(alignment: .bottom) {
                    Button("Cargar artículos") {
                        Task {
                            await loadLatestPapers()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            } else {
                // Lista de artículos de ArXiv
                #if os(macOS)
                List(papers, id: \.id, selection: $selectedPaper) { paper in
                    ArXivPaperRow(paper: paper)
                        .tag(paper)
                }
                .listStyle(PlainListStyle())
                .frame(minWidth: 400)
                #else
                List(papers, id: \.id) { paper in
                    NavigationLink(destination: PaperDetailView(paper: paper, onBackToList: nil)) {
                        ArXivPaperRow(paper: paper)
                    }
                }
                .listStyle(DefaultListStyle())
                #endif
            }
        }
        .onAppear {
            // Recarga automáticamente cuando se vuelve a la vista principal
            if shouldRefreshOnAppear && !papers.isEmpty {
                Task {
                    await loadLatestPapers()
                }
            }
            shouldRefreshOnAppear = true
        }
        .toolbar {
            ToolbarItemGroup(placement: toolbarPlacement) {
                #if os(iOS)
                if let loadCS = loadComputerSciencePapers {
                    Button(action: {
                        Task {
                            currentCategory = "cs"
                            await loadCS()
                        }
                    }) {
                        Label("Computer Science", systemImage: "laptopcomputer")
                    }
                    .disabled(isLoading)
                }
                
                if let loadMath = loadMathematicsPapers {
                    Button(action: {
                        Task {
                            currentCategory = "math"
                            await loadMath()
                        }
                    }) {
                        Label("Mathematics", systemImage: "x.squareroot")
                    }
                    .disabled(isLoading)
                }
                #endif
                
                Button(action: {
                    Task {
                        if currentCategory == "cs", let loadCS = loadComputerSciencePapers {
                            await loadCS()
                        } else if currentCategory == "math", let loadMath = loadMathematicsPapers {
                            await loadMath()
                        } else {
                            await loadLatestPapers()
                        }
                    }
                }) {
                    Label("Actualizar", systemImage: "arrow.clockwise")
                }
                .disabled(isLoading)
                
                #if os(macOS)
                Button(action: {
                    // Acción para exportar o compartir
                }) {
                    Label("Compartir", systemImage: "square.and.arrow.up")
                }
                #endif
            }
        }
    }
    
    /// Determina la ubicación de la toolbar según la plataforma
    private var toolbarPlacement: ToolbarItemPlacement {
        #if os(macOS)
        return .automatic
        #else
        return .navigationBarTrailing
        #endif
    }
}

/// Vista de detalle para mostrar información completa de un paper
/// Se navega desde la lista principal en ambas plataformas
struct PaperDetailView: View {
    let paper: ArXivPaper
    let onBackToList: (() -> Void)?
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Título del paper
                Text(paper.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)
                
                // Información de autores y fecha
                VStack(alignment: .leading, spacing: 8) {
                    Label(paper.authors, systemImage: "person.2")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Label(paper.publishedDate.formatted(date: .abbreviated, time: .omitted), 
                          systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Fecha de actualización (si existe y es diferente)
                    if let updatedDate = paper.updatedDate,
                       abs(updatedDate.timeIntervalSince(paper.publishedDate)) > 3600 { // Más de 1 hora de diferencia
                        Label("Actualizado: \(updatedDate.formatted(date: .abbreviated, time: .omitted))", 
                              systemImage: "arrow.clockwise")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Divider()
                
                // Categorías del paper
                if !paper.categories.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Categorías")
                            .font(.headline)
                        
                        Text(paper.categories)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                    
                    Divider()
                }
                
                // Resumen del paper
                VStack(alignment: .leading, spacing: 8) {
                    Text("Resumen")
                        .font(.headline)
                    
                    Text(paper.summary)
                        .font(.body)
                        .lineSpacing(4)
                }
                
                Divider()
                
                // Enlaces de acceso
                VStack(alignment: .leading, spacing: 12) {
                    Text("Enlaces")
                        .font(.headline)
                    
                    HStack(spacing: 16) {
                        if !paper.pdfURL.isEmpty {
                            Link(destination: URL(string: paper.pdfURL)!) {
                                HStack {
                                    Image(systemName: "doc.fill")
                                    Text("Ver PDF")
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.red)
                                .cornerRadius(8)
                            }
                        }
                        
                        if !paper.linkURL.isEmpty {
                            Link(destination: URL(string: paper.linkURL)!) {
                                HStack {
                                    Image(systemName: "link")
                                    Text("Ver en ArXiv")
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .navigationTitle("Detalle del Paper")
        #if os(macOS)
        .navigationSubtitle(paper.authors)
        .frame(minWidth: 400, minHeight: 300)
        #else
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItemGroup(placement: toolbarPlacement) {
                #if os(iOS)
                // Botón de volver para iOS
                Button("Inicio") {
                    dismiss()
                }
                #endif
                
                #if os(macOS)
                
                
                Button("Compartir") {
                    // Funcionalidad de compartir para macOS
                }
                
                Button("Favorito") {
                    // Funcionalidad de favoritos
                }
                #else
                Menu("Opciones") {
                    Button("Compartir", action: {})
                    Button("Añadir a favoritos", action: {})
                    Button("Copiar enlace", action: {})
                } primaryAction: {
                    //Image(systemName: "ellipsis.circle")
                }
                #endif
            }
        }
    }
    
    /// Determina la ubicación de la toolbar según la plataforma
    private var toolbarPlacement: ToolbarItemPlacement {
        #if os(macOS)
        return .automatic
        #else
        return .navigationBarTrailing
        #endif
    }
}

/// Vista previa para el diseñador de SwiftUI
/// Permite visualizar la vista durante el desarrollo sin ejecutar toda la aplicación
#Preview {
    ContentView()
        // Configura un contenedor de modelo en memoria solo para la vista previa
        // Esto evita afectar los datos reales durante el desarrollo
        .modelContainer(for: ArXivPaper.self, inMemory: true)
}
