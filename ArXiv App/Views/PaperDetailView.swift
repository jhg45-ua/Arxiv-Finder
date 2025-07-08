//
//  PaperDetailView.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import SwiftUI

/// Vista detallada que muestra toda la información de un artículo científico
/// Pantalla de destino cuando el usuario selecciona un paper de la lista
///
/// Información mostrada:
/// - Título completo del artículo
/// - Lista completa de autores
/// - Fechas de publicación y actualización
/// - Resumen/abstract completo del paper
/// - Categorías científicas como badges
/// - Enlaces para abrir el PDF y la página web del artículo
/// - Acciones de compartir (iOS) o menús contextuales (macOS)
///
/// Navegación:
/// - iOS: Modal o push navigation con botón de regreso
/// - macOS: Panel de detalle en NavigationSplitView
/// - Botones de acción adaptativos según la plataforma
struct PaperDetailView: View {
    /// El artículo a mostrar en detalle
    let paper: ArXivPaper
    
    /// Controller para manejar la lógica de favoritos
    let controller: ArXivController?
    
    /// Callback opcional para regresar a la lista (usado en algunos flujos de navegación)
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
                
                // Botón de favorito para ambas plataformas
                if let controller = controller {
                    Button(action: {
                        controller.toggleFavorite(for: paper)
                    }) {
                        Image(systemName: paper.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(paper.isFavorite ? .red : .primary)
                    }
                    .help(paper.isFavorite ? "Quitar de favoritos" : "Añadir a favoritos")
                }
                
                #if os(macOS)
                Button("Compartir") {
                    // Funcionalidad de compartir para macOS
                }
                #else
                Menu("Opciones") {
                    Button("Compartir", action: {})
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

#Preview {
    NavigationView {
        PaperDetailView(
            paper: ArXivPaper(
                id: "2025.0001",
                title: "Ejemplo de Paper de ArXiv para Vista de Detalle",
                summary: "Este es un resumen más extenso de ejemplo de un paper científico que muestra cómo se vería en la vista de detalle de la aplicación. Incluye información técnica detallada y múltiples párrafos para demostrar el formato.",
                authors: "Juan Pérez, María González, Carlos López",
                publishedDate: Date(),
                updatedDate: Date(),
                pdfURL: "https://arxiv.org/pdf/2025.0001.pdf",
                linkURL: "https://arxiv.org/abs/2025.0001",
                categories: "cs.AI cs.LG stat.ML"
            ),
            controller: nil,
            onBackToList: nil
        )
    }
}
