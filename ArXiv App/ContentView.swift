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

    /// Define la estructura visual de la vista principal
    var body: some View {
        #if os(macOS)
        // Diseño específico para macOS con NavigationSplitView
        NavigationSplitView {
            // Barra lateral en macOS
            SidebarView()
        } detail: {
            // Vista principal de artículos
            PapersListView(
                papers: papers,
                isLoading: isLoading,
                errorMessage: $errorMessage,
                loadLatestPapers: loadLatestPapers,
                loadMockPapers: loadMockPapers
            )
        }
        .navigationTitle("ArXiv Papers")
        .task {
            // Carga inicial de artículos al aparecer la vista
            if papers.isEmpty {
                await loadLatestPapers()
            }
        }
        #else
        // Diseño específico para iOS con NavigationStack
        NavigationStack {
            PapersListView(
                papers: papers,
                isLoading: isLoading,
                errorMessage: $errorMessage,
                loadLatestPapers: loadLatestPapers,
                loadMockPapers: loadMockPapers
            )
            .navigationTitle("ArXiv Papers")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            // Carga inicial de artículos al aparecer la vista
            if papers.isEmpty {
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
        
        do {
            // Intenta primero con la consulta específica
            var latestPapers = try await arxivService.fetchLatestPapers(count: 10)
            
            // Si no obtiene resultados, intenta con la consulta simple
            if latestPapers.isEmpty {
                print("⚠️ No papers found with specific query, trying simple query...")
                latestPapers = try await arxivService.fetchRecentPapers(count: 10)
            }
            
            // Actualiza la base de datos
            // Limpia artículos anteriores para evitar duplicados
            for paper in papers {
                modelContext.delete(paper)
            }
            
            // Añade los nuevos artículos
            for paper in latestPapers {
                modelContext.insert(paper)
            }
            
            // Guarda los cambios
            do {
                try modelContext.save()
                print("✅ Successfully saved \(latestPapers.count) papers to database")
            } catch {
                print("❌ Error saving to database: \(error.localizedDescription)")
                errorMessage = "Error guardando en base de datos: \(error.localizedDescription)"
            }
            
            isLoading = false
        } catch {
            print("❌ Error loading papers: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    /// Carga datos de prueba cuando la API no está disponible
    /// Útil para desarrollo y testing sin conexión
    @MainActor
    private func loadMockPapers() {
        let mockPapers = [
            ArXivPaper(
                id: "2024.01001",
                title: "Advanced Machine Learning Techniques for Scientific Computing",
                summary: "This paper presents novel approaches to applying machine learning in scientific computing contexts, with particular focus on optimization and prediction tasks.",
                authors: "Smith, J., Johnson, A., Williams, R.",
                publishedDate: Date(),
                pdfURL: "https://arxiv.org/pdf/2024.01001.pdf",
                linkURL: "https://arxiv.org/abs/2024.01001",
                categories: "cs.LG, cs.SC"
            ),
            ArXivPaper(
                id: "2024.01002",
                title: "Quantum Computing Applications in Cryptography",
                summary: "An exploration of quantum computing methodologies and their implications for modern cryptographic systems.",
                authors: "Brown, K., Davis, M.",
                publishedDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                pdfURL: "https://arxiv.org/pdf/2024.01002.pdf",
                linkURL: "https://arxiv.org/abs/2024.01002",
                categories: "quant-ph, cs.CR"
            ),
            ArXivPaper(
                id: "2024.01003",
                title: "Neural Networks for Natural Language Processing",
                summary: "A comprehensive study of neural network architectures designed for natural language understanding and generation tasks.",
                authors: "Garcia, L., Martinez, C., Rodriguez, P.",
                publishedDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                pdfURL: "https://arxiv.org/pdf/2024.01003.pdf",
                linkURL: "https://arxiv.org/abs/2024.01003",
                categories: "cs.CL, cs.AI"
            )
        ]
        
        // Añade los papers mock a la base de datos
        for paper in mockPapers {
            modelContext.insert(paper)
        }
        
        try? modelContext.save()
        print("📝 Loaded \(mockPapers.count) mock papers for testing")
    }
}

/// Vista que representa una fila individual de artículo en la lista
/// Muestra título, autores y fecha de publicación de forma compacta
/// Adaptada para funcionar óptimamente en iOS y macOS
struct ArXivPaperRow: View {
    let paper: ArXivPaper
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Título del artículo
            Text(paper.title)
                .font(.headline)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            // Autores del artículo
            Text(paper.authors)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                // Fecha de publicación
                Text(paper.publishedDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // ID del paper
                Text("ID: \(paper.id)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 8)
        #if os(macOS)
        .padding(.horizontal, 12)
        .background(Color.clear)
        .cornerRadius(8)
        .contentShape(Rectangle())
        #endif
    }
}

/// Vista de barra lateral para macOS
/// Proporciona navegación y opciones adicionales en la interfaz de macOS
struct SidebarView: View {
    var body: some View {
        List {
            NavigationLink(destination: EmptyView()) {
                Label("Últimos Papers", systemImage: "doc.text")
            }
            
            NavigationLink(destination: EmptyView()) {
                Label("Favoritos", systemImage: "heart")
            }
            
            NavigationLink(destination: EmptyView()) {
                Label("Búsqueda", systemImage: "magnifyingglass")
            }
            
            Section("Categorías") {
                NavigationLink(destination: EmptyView()) {
                    Label("Computer Science", systemImage: "laptopcomputer")
                }
                NavigationLink(destination: EmptyView()) {
                    Label("Mathematics", systemImage: "function")
                }
                NavigationLink(destination: EmptyView()) {
                    Label("Physics", systemImage: "atom")
                }
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("ArXiv")
    }
}

/// Vista principal de la lista de papers
/// Funciona tanto en iOS como en macOS con adaptaciones específicas
struct PapersListView: View {
    let papers: [ArXivPaper]
    let isLoading: Bool
    @Binding var errorMessage: String?
    let loadLatestPapers: () async -> Void
    let loadMockPapers: () -> Void
    
    var body: some View {
        VStack {
            if isLoading {
                // Indicador de carga mientras se obtienen los datos
                ProgressView("Cargando artículos...")
                    .padding()
            } else if papers.isEmpty {
                // Mensaje cuando no hay artículos disponibles
                ContentUnavailableView(
                    "No hay artículos disponibles",
                    systemImage: "doc.text",
                    description: Text("Presiona actualizar para cargar los últimos papers de ArXiv")
                )
            } else {
                // Lista de artículos de ArXiv
                List(papers, id: \.id) { paper in
                    NavigationLink(destination: PaperDetailView(paper: paper)) {
                        ArXivPaperRow(paper: paper)
                    }
                    #if os(macOS)
                    .listRowSeparator(.hidden)
                    #endif
                }
                #if os(macOS)
                .listStyle(PlainListStyle())
                .frame(minWidth: 400)
                #else
                .listStyle(DefaultListStyle())
                #endif
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: toolbarPlacement) {
                Button(action: {
                    Task {
                        await loadLatestPapers()
                    }
                }) {
                    Label("Actualizar", systemImage: "arrow.clockwise")
                }
                .disabled(isLoading)
                
                // Botón para cargar datos de prueba en caso de problemas de conexión
                Button(action: {
                    loadMockPapers()
                }) {
                    Label("Datos de Prueba", systemImage: "doc.text.fill")
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
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
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
                }
                
                Divider()
                
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
                    
                    if !paper.pdfURL.isEmpty {
                        Link(destination: URL(string: paper.pdfURL)!) {
                            Label("Ver PDF", systemImage: "doc.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if !paper.linkURL.isEmpty {
                        Link(destination: URL(string: paper.linkURL)!) {
                            Label("Ver en ArXiv", systemImage: "link")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer()
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
                } label: {
                    Image(systemName: "ellipsis.circle")
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
