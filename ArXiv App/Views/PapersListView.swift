//
//  PapersListView.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import SwiftUI

/// Vista principal de la lista de papers
/// Funciona tanto en iOS como en macOS con adaptaciones específicas
///
/// Características multiplataforma:
/// - iOS: Usa NavigationStack con NavigationLink para navegación
/// - macOS: Compatible con NavigationSplitView usando selectedPaper binding
/// - Estados: Carga, error, vacío y contenido con datos
/// - Toolbar adaptativo según la plataforma
struct PapersListView: View {
    /// Lista de papers a mostrar
    let papers: [ArXivPaper]
    
    /// Indica si está cargando datos
    let isLoading: Bool
    
    /// Mensaje de error actual (si existe)
    @Binding var errorMessage: String?
    
    /// Función para cargar los últimos papers
    let loadLatestPapers: () async -> Void
    
    /// Función opcional para cargar papers de Computer Science (solo iOS)
    let loadComputerSciencePapers: (() async -> Void)?
    
    /// Función opcional para cargar papers de Mathematics (solo iOS)
    let loadMathematicsPapers: (() async -> Void)?
    
    /// Estado interno para controlar la recarga automática
    @State private var shouldRefreshOnAppear = false
    
    /// Categoría actualmente seleccionada
    @State private var currentCategory: String = "latest"
    
    /// Paper seleccionado para macOS NavigationSplitView
    @Binding var selectedPaper: ArXivPaper?
    
    /// Inicializador para iOS (sin selectedPaper)
    /// Usado cuando la vista maneja su propia navegación con NavigationLink
    /// - Parameters:
    ///   - papers: Lista de papers a mostrar
    ///   - isLoading: Estado de carga
    ///   - errorMessage: Binding para mensajes de error
    ///   - loadLatestPapers: Función para cargar últimos papers
    ///   - loadComputerSciencePapers: Función opcional para CS papers
    ///   - loadMathematicsPapers: Función opcional para Math papers
    init(papers: [ArXivPaper], isLoading: Bool, errorMessage: Binding<String?>, loadLatestPapers: @escaping () async -> Void, loadComputerSciencePapers: (() async -> Void)? = nil, loadMathematicsPapers: (() async -> Void)? = nil) {
        self.papers = papers
        self.isLoading = isLoading
        self._errorMessage = errorMessage
        self.loadLatestPapers = loadLatestPapers
        self.loadComputerSciencePapers = loadComputerSciencePapers
        self.loadMathematicsPapers = loadMathematicsPapers
        self._selectedPaper = .constant(nil)
    }
    
    /// Inicializador para macOS (con selectedPaper)
    /// Usado con NavigationSplitView donde la selección se maneja externamente
    /// - Parameters:
    ///   - papers: Lista de papers a mostrar
    ///   - isLoading: Estado de carga
    ///   - errorMessage: Binding para mensajes de error
    ///   - loadLatestPapers: Función para cargar últimos papers
    ///   - selectedPaper: Binding del paper seleccionado para el detail view
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
                .frame(minWidth: 450)
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

#Preview {
    PapersListView(
        papers: [
            ArXivPaper(
                id: "2025.0001",
                title: "Ejemplo de Paper 1",
                summary: "Este es un resumen de ejemplo",
                authors: "Juan Pérez",
                publishedDate: Date(),
                updatedDate: Date(),
                pdfURL: "https://arxiv.org/pdf/2025.0001.pdf",
                linkURL: "https://arxiv.org/abs/2025.0001",
                categories: "cs.AI"
            )
        ],
        isLoading: false,
        errorMessage: .constant(nil),
        loadLatestPapers: { },
        loadComputerSciencePapers: { },
        loadMathematicsPapers: { }
    )
}
