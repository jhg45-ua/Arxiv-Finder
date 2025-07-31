//
//  PapersListView.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import SwiftUI

/// View that shows the list of scientific papers from ArXiv
/// Designed to work on both platforms with adaptive UI
///
/// Features:
/// - Scrollable list of papers with summary information
/// - Visual states: loading, error, empty, and content
/// - Toolbar with navigation and reload actions
/// - Integrated search to filter papers
/// - Adaptive navigation (NavigationLink in iOS, binding in macOS)
///
/// MVC architecture:
/// - This view only handles the presentation of data
/// - All business logic is delegated to the ArXivController
/// - The data comes from the ArXivPaper model
struct PapersListView: View {
    /// List of papers to display
    let papers: [ArXivPaper]
    
    /// Indicates if data is being loaded
    let isLoading: Bool
    
    /// Current error message (if exists)
    @Binding var errorMessage: String?
    
    /// Controller to handle favorite logic
    let controller: ArXivController?
    
    /// Function to load the latest papers
    let loadLatestPapers: () async -> Void
    
    /// Optional function to load Computer Science papers (iOS only)
    let loadComputerSciencePapers: (() async -> Void)?
    
    /// Optional function to load Mathematics papers (iOS only)
    let loadMathematicsPapers: (() async -> Void)?
    
    /// Optional function to load Physics papers (iOS only)
    let loadPhysicsPapers: (() async -> Void)?
    
    /// Optional function to load Quantitative Biology papers (iOS only)
    let loadQuantitativeBiologyPapers: (() async -> Void)?
    
    /// Optional function to load Quantitative Finance papers (iOS only)
    let loadQuantitativeFinancePapers: (() async -> Void)?
    
    /// Optional function to load Statistics papers (iOS only)
    let loadStatisticsPapers: (() async -> Void)?
    
    /// Optional function to load Electrical Engineering papers (iOS only)
    let loadElectricalEngineeringPapers: (() async -> Void)?
    
    /// Optional function to load Economics papers (iOS only)
    let loadEconomicsPapers: (() async -> Void)?
    
    /// Internal state to control automatic reload
    @State private var shouldRefreshOnAppear = false
    
    /// Currently selected category
    @State private var currentCategory: String = "latest"
    
    /// Selected paper for macOS NavigationSplitView
    @Binding var selectedPaper: ArXivPaper?
    
    /// Initializer for iOS (without selectedPaper)
    /// Used when the view handles its own navigation with NavigationLink
    /// - Parameters:
    ///   - papers: List of papers to display
    ///   - isLoading: Loading state
    ///   - errorMessage: Binding for error messages
    ///   - controller: Optional controller to handle ArXiv operations
    ///   - loadLatestPapers: Function to load latest papers
    ///   - loadComputerSciencePapers: Optional function to load CS papers
    ///   - loadMathematicsPapers: Optional function to load Math papers
    ///   - loadPhysicsPapers: Optional function to load Physics papers
    ///   - loadQuantitativeBiologyPapers: Optional function to load Quantitative Biology papers
    ///   - loadQuantitativeFinancePapers: Optional function to load Quantitative Finance papers
    ///   - loadStatisticsPapers: Optional function to load Statistics papers
    ///   - loadElectricalEngineeringPapers: Optional function to load Electrical Engineering papers
    ///   - loadEconomicsPapers: Optional function to load Economics papers
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
    
    /// Initializer for macOS (with selectedPaper)
    /// Used with NavigationSplitView where the selection is handled externally
    /// - Parameters:
    ///   - papers: List of papers to display
    ///   - isLoading: Loading state
    ///   - errorMessage: Binding for error messages
    ///   - loadLatestPapers: Function to load latest papers
    ///   - selectedPaper: Binding for the selected paper for the detail view
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
                // Loading indicator while data is being obtained
                VStack(spacing: 16) {
                    ProgressView()
                        .controlSize(.regular)
                        #if os(macOS)
                        .frame(width: 32, height: 32)
                        #else
                        .scaleEffect(1.2)
                        #endif
                    Text("Loading the latest papers from ArXiv...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else if let error = errorMessage {
                // Error message when there are connection problems
                ContentUnavailableView(
                    "Error loading papers",
                    systemImage: "wifi.exclamationmark",
                    description: Text(error)
                )
                .overlay(alignment: .bottom) {
                    VStack(spacing: 12) {
                        Button("Retry") {
                            Task {
                                await loadLatestPapers()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Clear error") {
                            errorMessage = nil
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                }
            } else if papers.isEmpty {
                // Message when there are no papers available but no error
                ContentUnavailableView(
                    "No papers available",
                    systemImage: "doc.text",
                    description: Text("No papers found. Check your internet connection and try again.")
                )
                .overlay(alignment: .bottom) {
                    Button("Load papers") {
                        Task {
                            await loadLatestPapers()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            } else if controller?.isSearchActive == true && papers.isEmpty {
                // No search results
                ContentUnavailableView(
                    "No search results",
                    systemImage: "magnifyingglass",
                    description: Text("No papers found matching your search criteria. Try different keywords or categories.")
                )
                .overlay(alignment: .bottom) {
                    VStack(spacing: 12) {
                        Button("Try Again") {
                            // This will be handled by the search view
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Clear Search") {
                            controller?.clearSearch()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                }
            } else {
                // List of ArXiv papers
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
            // Automatically reload when returning to the main view
            if shouldRefreshOnAppear && !papers.isEmpty {
                Task {
                    await loadLatestPapers()
                }
            }
            shouldRefreshOnAppear = true
        }
        .toolbar {
            ToolbarItemGroup(placement: toolbarPlacement) {
                // Search info when search is active
                if controller?.isSearchActive == true {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                        Text("Search: \(controller?.searchQuery ?? "")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button("Clear") {
                            controller?.clearSearch()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                
                #if os(iOS)
                Menu("Categories") {
                    Button("Latest Papers") {
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
                        Button("Favorites") {
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
                    Label("Update", systemImage: "arrow.clockwise")
                }
                .disabled(isLoading)
                
                #if os(macOS)
                Button(action: {
                    // Action to export or share
                }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                #endif
            }
        }
    }
    
    /// Determine the toolbar location according to the platform
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
                title: "Example of Paper 1",
                summary: "This is an example summary",
                authors: "John Doe",
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
