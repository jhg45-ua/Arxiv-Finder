//
//  MainView.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import SwiftUI
import SwiftData

/// Vista principal de la aplicación ArXiv App siguiendo el patrón MVC
/// Proporciona una interfaz adaptativa que funciona tanto en iOS como macOS
///
/// En iOS utiliza NavigationStack para navegación jerárquica
/// En macOS utiliza NavigationSplitView para navegación en tres columnas
///
/// Arquitectura MVC:
/// - View: Esta vista maneja solo la presentación
/// - Controller: ArXivController gestiona toda la lógica de negocio
/// - Model: ArXivPaper representa los datos de artículos
struct MainView: View {
    /// Contexto de modelo para SwiftData
    @Environment(\.modelContext) private var modelContext
    
    /// Controller que maneja la lógica de negocio
    @StateObject private var controller = ArXivController()
    
    /// Paper seleccionado en macOS para NavigationSplitView
    @State private var selectedPaper: ArXivPaper?

    /// Define la estructura visual de la vista principal
    var body: some View {
        #if os(macOS)
        // Diseño específico para macOS con NavigationSplitView
        NavigationSplitView {
            // Barra lateral en macOS
            SidebarView(
                currentCategory: .constant(controller.currentCategory),
                onLatestPapersSelected: {
                    await controller.loadLatestPapers()
                    selectedPaper = nil // Volver a la vista principal
                },
                onComputerScienceSelected: {
                    await controller.loadComputerSciencePapers()
                    selectedPaper = nil // Volver a la vista principal
                },
                onMathematicsSelected: {
                    await controller.loadMathematicsPapers()
                    selectedPaper = nil // Volver a la vista principal
                },
                onPhysicsSelected: {
                    await controller.loadPhysicsPapers()
                    selectedPaper = nil // Volver a la vista principal
                },
                onQuantitativeBiologySelected: {
                    await controller.loadQuantitativeBiologyPapers()
                    selectedPaper = nil // Volver a la vista principal
                },
                onQuantitativeFinanceSelected: {
                    await controller.loadQuantitativeFinancePapers()
                    selectedPaper = nil // Volver a la vista principal
                },
                onStatisticsSelected: {
                    await controller.loadStatisticsPapers()
                    selectedPaper = nil // Volver a la vista principal
                },
                onElectricalEngineeringSelected: {
                    await controller.loadElectricalEngineeringPapers()
                    selectedPaper = nil // Volver a la vista principal
                },
                onEconomicsSelected: {
                    await controller.loadEconomicsPapers()
                    selectedPaper = nil // Volver a la vista principal
                },
                onFavoritesSelected: {
                    await controller.loadFavoritePapers()
                    selectedPaper = nil // Volver a la vista principal
                }
            )
        } content: {
            // Vista principal de artículos
            PapersListView(
                papers: controller.filteredPapers,
                isLoading: controller.isLoading,
                errorMessage: .constant(controller.errorMessage),
                loadLatestPapers: { await controller.loadLatestPapers() },
                selectedPaper: $selectedPaper
            )
        } detail: {
            // Vista de detalle o placeholder
            if let paper = selectedPaper {
                PaperDetailView(paper: paper, controller: controller, onBackToList: {
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
        .onKeyPress(.escape) {
            print("⌨️ Tecla ESC presionada - Deseleccionando paper")
            selectedPaper = nil
            return .handled
        }
        .onChange(of: selectedPaper) { oldValue, newValue in
            if let paper = newValue {
                print("📄 Paper seleccionado: \(paper.title)")
            } else {
                print("❌ Paper deseleccionado")
            }
        }
        .onAppear {
            // Configurar el contexto del modelo en el controlador
            controller.modelContext = modelContext
        }
        .task {
            // Carga inicial usando configuración por defecto
            await controller.loadPapersWithSettings()
        }
        
        #else
        // Diseño para iOS con NavigationStack
        NavigationStack {
            PapersListView(
                papers: controller.filteredPapers,
                isLoading: controller.isLoading,
                errorMessage: .constant(controller.errorMessage),
                controller: controller,
                loadLatestPapers: { await controller.loadLatestPapers() },
                loadComputerSciencePapers: { await controller.loadComputerSciencePapers() },
                loadMathematicsPapers: { await controller.loadMathematicsPapers() },
                loadPhysicsPapers: { await controller.loadPhysicsPapers() },
                loadQuantitativeBiologyPapers: { await controller.loadQuantitativeBiologyPapers() },
                loadQuantitativeFinancePapers: { await controller.loadQuantitativeFinancePapers() },
                loadStatisticsPapers: { await controller.loadStatisticsPapers() },
                loadElectricalEngineeringPapers: { await controller.loadElectricalEngineeringPapers() },
                loadEconomicsPapers: { await controller.loadEconomicsPapers() }
            )
            .navigationTitle("ArXiv Papers")
            .onAppear {
                // Configurar el contexto del modelo en el controlador
                controller.modelContext = modelContext
            }
            .task {
                // Carga inicial usando configuración por defecto
                await controller.loadPapersWithSettings()
            }
        }
        #endif
    }
}

#Preview {
    MainView()
        .modelContainer(for: ArXivPaper.self, inMemory: true)
}
