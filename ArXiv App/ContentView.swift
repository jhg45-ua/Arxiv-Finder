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
            SidebarView(onLatestPapersSelected: loadLatestPapers)
        } detail: {
            // Vista principal de artículos
            PapersListView(
                papers: papers,
                isLoading: isLoading,
                errorMessage: $errorMessage,
                loadLatestPapers: loadLatestPapers
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
                loadLatestPapers: loadLatestPapers
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
    let onLatestPapersSelected: () async -> Void
    
    var body: some View {
        List {
            Button(action: {
                Task {
                    await onLatestPapersSelected()
                }
            }) {
                Label("Últimos Papers", systemImage: "doc.text")
                    .foregroundColor(.primary)
            }
            .buttonStyle(PlainButtonStyle())
            
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
    @State private var shouldRefreshOnAppear = false
    
    var body: some View {
        VStack {
            if isLoading {
                // Indicador de carga mientras se obtienen los datos
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
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
                Button(action: {
                    Task {
                        await loadLatestPapers()
                    }
                }) {
                    Label("Actualizar", systemImage: "arrow.clockwise")
                }
                .disabled(isLoading)
                
                #if os(iOS)
                Button(action: {
                    Task {
                        await loadLatestPapers()
                    }
                }) {
                    Label("Inicio", systemImage: "house")
                }
                .disabled(isLoading)
                #endif
                
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
                
                Divider()
                
                // Botón para volver al inicio en iOS
                #if os(iOS)
                VStack(spacing: 12) {
                    Text("Navegación")
                        .font(.headline)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("Volver a Últimos Papers")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                }
                #endif
                
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
