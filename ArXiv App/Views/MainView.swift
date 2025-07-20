//
//  MainView.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import SwiftUI
import SwiftData

/// Main view of the ArXiv App application following the MVC pattern
/// Provides an adaptive interface that works on both iOS and macOS
///
/// On iOS uses NavigationStack for hierarchical navigation
/// On macOS uses NavigationSplitView for three-column navigation
///
/// MVC Architecture:
/// - View: This view handles only presentation
/// - Controller: ArXivController manages all business logic
/// - Model: ArXivPaper represents paper data
struct MainView: View {
    /// Model context for SwiftData
    @Environment(\.modelContext) private var modelContext
    
    /// Controller that handles business logic
    @StateObject private var controller = ArXivController()
    
    /// Selected paper in macOS for NavigationSplitView
    @State private var selectedPaper: ArXivPaper?

    /// Defines the visual structure of the main view
    var body: some View {
        #if os(macOS)
        // macOS-specific design with NavigationSplitView
        NavigationSplitView {
            // Sidebar in macOS
            SidebarView(
                currentCategory: .constant(controller.currentCategory),
                onLatestPapersSelected: {
                    await controller.loadLatestPapers()
                    selectedPaper = nil // Return to main view
                },
                onComputerScienceSelected: {
                    await controller.loadComputerSciencePapers()
                    selectedPaper = nil // Return to main view
                },
                onMathematicsSelected: {
                    await controller.loadMathematicsPapers()
                    selectedPaper = nil // Return to main view
                },
                onPhysicsSelected: {
                    await controller.loadPhysicsPapers()
                    selectedPaper = nil // Return to main view
                },
                onQuantitativeBiologySelected: {
                    await controller.loadQuantitativeBiologyPapers()
                    selectedPaper = nil // Return to main view
                },
                onQuantitativeFinanceSelected: {
                    await controller.loadQuantitativeFinancePapers()
                    selectedPaper = nil // Return to main view
                },
                onStatisticsSelected: {
                    await controller.loadStatisticsPapers()
                    selectedPaper = nil // Return to main view
                },
                onElectricalEngineeringSelected: {
                    await controller.loadElectricalEngineeringPapers()
                    selectedPaper = nil // Return to main view
                },
                onEconomicsSelected: {
                    await controller.loadEconomicsPapers()
                    selectedPaper = nil // Return to main view
                },
                onFavoritesSelected: {
                    await controller.loadFavoritePapers()
                    selectedPaper = nil // Return to main view
                }
            )
        } content: {
            // Main papers view
            PapersListView(
                papers: controller.filteredPapers,
                isLoading: controller.isLoading,
                errorMessage: .constant(controller.errorMessage),
                loadLatestPapers: { await controller.loadLatestPapers() },
                selectedPaper: $selectedPaper
            )
        } detail: {
            // Detail view or placeholder
            if let paper = selectedPaper {
                PaperDetailView(paper: paper, controller: controller, onBackToList: {
                    selectedPaper = nil
                })
            } else {
                ContentUnavailableView(
                    "Select a paper",
                    systemImage: "doc.text",
                    description: Text("Choose a paper from the list to view details")
                )
            }
        }
        .navigationTitle("ArXiv Papers")
        .onKeyPress(.escape) {
            print("⌨️ ESC key pressed - Deselecting paper")
            selectedPaper = nil
            return .handled
        }
        .onChange(of: selectedPaper) { oldValue, newValue in
            if let paper = newValue {
                print("📄 Paper selected: \(paper.title)")
            } else {
                print("❌ Paper deselected")
            }
        }
        .onAppear {
            // Configure the model context in the controller
            controller.modelContext = modelContext
        }
        .task {
            // Initial load using default settings
            await controller.loadPapersWithSettings()
        }
        
        #else
        // iOS design with NavigationStack
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
                // Configure the model context in the controller
                controller.modelContext = modelContext
            }
            .task {
                // Initial load using default settings
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
