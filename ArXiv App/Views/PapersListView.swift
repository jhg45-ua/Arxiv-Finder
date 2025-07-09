//
//  PapersListView.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import SwiftUI

/// Vista que muestra la lista de artículos científicos de ArXiv
/// Diseñada para funcionar en ambas plataformas con UI adaptativa
///
/// Funcionalidades:
/// - Lista scrolleable de artículos con información resumida
/// - Estados visuales: carga, error, vacío, y contenido
/// - Toolbar con acciones de navegación y recarga
/// - Búsqueda integrada para filtrar artículos
/// - Navegación adaptativa (NavigationLink en iOS, binding en macOS)
///
/// Arquitectura MVC:
/// - Esta vista solo maneja la presentación de datos
/// - Toda la lógica de negocio está delegada al ArXivController
/// - Los datos provienen del modelo ArXivPaper
struct PapersListView: View {
    /// Lista de papers a mostrar
    let papers: [ArXivPaper]
    
    /// Indica si está cargando datos
    let isLoading: Bool
    
    /// Mensaje de error actual (si existe)
    @Binding var errorMessage: String?
    
    /// Controller para manejar la lógica de favoritos
    let controller: ArXivController?
    
    /// Función para cargar los últimos papers
    let loadLatestPapers: () async -> Void
    
    /// Función opcional para cargar papers de Computer Science (solo iOS)
    let loadComputerSciencePapers: (() async -> Void)?
    
    /// Función opcional para cargar papers de Mathematics (solo iOS)
    let loadMathematicsPapers: (() async -> Void)?
    
    /// Función opcional para cargar papers de Physics (solo iOS)
    let loadPhysicsPapers: (() async -> Void)?
    
    /// Función opcional para cargar papers de Quantitative Biology (solo iOS)
    let loadQuantitativeBiologyPapers: (() async -> Void)?
    
    /// Función opcional para cargar papers de Quantitative Finance (solo iOS)
    let loadQuantitativeFinancePapers: (() async -> Void)?
    
    /// Función opcional para cargar papers de Statistics (solo iOS)
    let loadStatisticsPapers: (() async -> Void)?
    
    /// Función opcional para cargar papers de Electrical Engineering (solo iOS)
    let loadElectricalEngineeringPapers: (() async -> Void)?
    
    /// Función opcional para cargar papers de Economics (solo iOS)
    let loadEconomicsPapers: (() async -> Void)?
    
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
    ///   - controller: Controlador opcional para manejar operaciones de ArXiv
    ///   - loadLatestPapers: Función para cargar últimos papers
    ///   - loadComputerSciencePapers: Función opcional para CS papers
    ///   - loadMathematicsPapers: Función opcional para Math papers
    ///   - loadPhysicsPapers: Función opcional para Physics papers
    ///   - loadQuantitativeBiologyPapers: Función opcional para Quantitative Biology papers
    ///   - loadQuantitativeFinancePapers: Función opcional para Quantitative Finance papers
    ///   - loadStatisticsPapers: Función opcional para Statistics papers
    ///   - loadElectricalEngineeringPapers: Función opcional para Electrical Engineering papers
    ///   - loadEconomicsPapers: Función opcional para Economics papers
    init(papers: [ArXivPaper], isLoading: Bool, errorMessage: Binding<String?>, controller: ArXivController? = nil, loadLatestPapers: @escaping () async -> Void, loadComputerSciencePapers: (() async -> Void)? = nil, loadMathematicsPapers: (() async -> Void)? = nil, loadPhysicsPapers: (() async -> Void)? = nil, loadQuantitativeBiologyPapers: (() async -> Void)? = nil, loadQuantitativeFinancePapers: (() async -> Void)? = nil, loadStatisticsPapers: (() async -> Void)? = nil, loadElectricalEngineeringPapers: (() async -> Void)? = nil, loadEconomicsPapers: (() async -> Void)? = nil) {
        self.papers = papers
        self.isLoading = isLoading
        self._errorMessage = errorMessage
        self.controller = controller
        self.loadLatestPapers = loadLatestPapers
        self.loadComputerSciencePapers = loadComputerSciencePapers
        self.loadMathematicsPapers = loadMathematicsPapers
        self.loadPhysicsPapers = loadPhysicsPapers
        self.loadQuantitativeBiologyPapers = loadQuantitativeBiologyPapers
        self.loadQuantitativeFinancePapers = loadQuantitativeFinancePapers
        self.loadStatisticsPapers = loadStatisticsPapers
        self.loadElectricalEngineeringPapers = loadElectricalEngineeringPapers
        self.loadEconomicsPapers = loadEconomicsPapers
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
        self.controller = nil
        self.loadLatestPapers = loadLatestPapers
        self.loadComputerSciencePapers = nil
        self.loadMathematicsPapers = nil
        self.loadPhysicsPapers = nil
        self.loadQuantitativeBiologyPapers = nil
        self.loadQuantitativeFinancePapers = nil
        self.loadStatisticsPapers = nil
        self.loadElectricalEngineeringPapers = nil
        self.loadEconomicsPapers = nil
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
                    ArXivPaperRow(paper: paper, controller: controller)
                        .tag(paper)
                }
                .listStyle(PlainListStyle())
                .frame(minWidth: 450)
                #else
                List(papers, id: \.id) { paper in
                    NavigationLink(destination: PaperDetailView(paper: paper, controller: controller, onBackToList: nil)) {
                        ArXivPaperRow(paper: paper, controller: controller)
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
                Menu("Categorías") {
                    Button("Últimos Papers") {
                        Task {
                            currentCategory = "latest"
                            await loadLatestPapers()
                        }
                    }
                    
                    if let loadCS = loadComputerSciencePapers {
                        Button("Computer Science") {
                            Task {
                                currentCategory = "cs"
                                await loadCS()
                            }
                        }
                    }
                    
                    if let loadMath = loadMathematicsPapers {
                        Button("Mathematics") {
                            Task {
                                currentCategory = "math"
                                await loadMath()
                            }
                        }
                    }
                    
                    if let loadPhysics = loadPhysicsPapers {
                        Button("Physics") {
                            Task {
                                currentCategory = "physics"
                                await loadPhysics()
                            }
                        }
                    }
                    
                    if let loadBio = loadQuantitativeBiologyPapers {
                        Button("Quantitative Biology") {
                            Task {
                                currentCategory = "q-bio"
                                await loadBio()
                            }
                        }
                    }
                    
                    if let loadFin = loadQuantitativeFinancePapers {
                        Button("Quantitative Finance") {
                            Task {
                                currentCategory = "q-fin"
                                await loadFin()
                            }
                        }
                    }
                    
                    if let loadStats = loadStatisticsPapers {
                        Button("Statistics") {
                            Task {
                                currentCategory = "stat"
                                await loadStats()
                            }
                        }
                    }
                    
                    if let loadEE = loadElectricalEngineeringPapers {
                        Button("Electrical Engineering") {
                            Task {
                                currentCategory = "eess"
                                await loadEE()
                            }
                        }
                    }
                    
                    if let loadEcon = loadEconomicsPapers {
                        Button("Economics") {
                            Task {
                                currentCategory = "econ"
                                await loadEcon()
                            }
                        }
                    }
                    
                    Divider()
                    
                    if let controller = controller {
                        Button("Favoritos") {
                            Task {
                                currentCategory = "favorites"
                                await controller.loadFavoritePapers()
                            }
                        }
                    }
                }
                .disabled(isLoading)
                #endif
                
                Button(action: {
                    Task {
                        switch currentCategory {
                        case "cs":
                            if let loadCS = loadComputerSciencePapers {
                                await loadCS()
                            }
                        case "math":
                            if let loadMath = loadMathematicsPapers {
                                await loadMath()
                            }
                        case "physics":
                            if let loadPhysics = loadPhysicsPapers {
                                await loadPhysics()
                            }
                        case "q-bio":
                            if let loadBio = loadQuantitativeBiologyPapers {
                                await loadBio()
                            }
                        case "q-fin":
                            if let loadFin = loadQuantitativeFinancePapers {
                                await loadFin()
                            }
                        case "stat":
                            if let loadStats = loadStatisticsPapers {
                                await loadStats()
                            }
                        case "eess":
                            if let loadEE = loadElectricalEngineeringPapers {
                                await loadEE()
                            }
                        case "econ":
                            if let loadEcon = loadEconomicsPapers {
                                await loadEcon()
                            }
                        default:
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
        loadMathematicsPapers: { },
        loadPhysicsPapers: { },
        loadQuantitativeBiologyPapers: { },
        loadQuantitativeFinancePapers: { },
        loadStatisticsPapers: { },
        loadElectricalEngineeringPapers: { },
        loadEconomicsPapers: { }
    )
}
