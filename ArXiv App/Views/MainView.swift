//
//  MainView.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import SwiftUI
import SwiftData

/// Vista principal de la aplicación ArXiv App siguiendo el patrón MVC
/// Esta vista actúa como la View en el patrón MVC, delegando la lógica al Controller
struct MainView: View {
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
            // Carga inicial de papers
            await controller.loadLatestPapers()
        }
        
        #else
        // Diseño para iOS con NavigationStack
        NavigationStack {
            PapersListView(
                papers: controller.filteredPapers,
                isLoading: controller.isLoading,
                errorMessage: .constant(controller.errorMessage),
                loadLatestPapers: { await controller.loadLatestPapers() },
                loadComputerSciencePapers: { await controller.loadComputerSciencePapers() },
                loadMathematicsPapers: { await controller.loadMathematicsPapers() }
            )
            .navigationTitle("ArXiv Papers")
            .task {
                // Carga inicial de papers
                await controller.loadLatestPapers()
            }
        }
        #endif
    }
}

#Preview {
    MainView()
        .modelContainer(for: ArXivPaper.self, inMemory: true)
}
