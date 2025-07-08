//
//  ArXivPaperRow.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import SwiftUI

/// Vista reutilizable que representa una fila individual de artículo en la lista
/// Muestra información resumida del paper con diseño adaptativo
///
/// Características:
/// - Título del artículo con truncado inteligente
/// - Lista de autores (oculta en modo compacto)
/// - Fecha de publicación formateada
/// - Vista previa del resumen (opcional)
/// - Categorías del artículo como badges
/// - Configuración personalizable via AppStorage
///
/// Configuraciones soportadas:
/// - Tamaño de fuente adjustable
/// - Modo compacto para mostrar más elementos
/// - Toggle para mostrar/ocultar vista previa del resumen
struct ArXivPaperRow: View {
    /// El artículo a mostrar en esta fila
    let paper: ArXivPaper
    
    /// Controller para manejar la lógica de favoritos
    let controller: ArXivController?
    
    // MARK: - Settings from AppStorage
    @AppStorage("fontSize") private var fontSize = 14.0
    @AppStorage("compactMode") private var compactMode = false
    @AppStorage("showPreview") private var showPreview = true
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: compactMode ? 8 : 12) {
                // Título del artículo
                Text(paper.title)
                    .font(.system(size: fontSize, weight: .medium))
                    .lineLimit(compactMode ? 2 : 4)
                    .multilineTextAlignment(.leading)
                
                // Autores del artículo (solo si no está en modo compacto)
                if !compactMode {
                    Text(paper.authors)
                        .font(.system(size: fontSize - 2))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Resumen del artículo (solo si la vista previa está habilitada)
                if showPreview {
                    Text(paper.summary)
                        .font(.system(size: fontSize - 4))
                        .foregroundColor(.secondary)
                        .lineLimit(compactMode ? 1 : 2)
                        .padding(.top, 2)
                }
                
                HStack {
                    // Fechas del paper
                    VStack(alignment: .leading, spacing: 2) {
                        // Fecha de publicación
                        Label(paper.publishedDate.formatted(date: .abbreviated, time: .omitted), 
                              systemImage: "calendar")
                            .font(.system(size: fontSize - 6))
                            .foregroundColor(.secondary)
                        
                        // Fecha de actualización (si existe, es diferente y no estamos en modo compacto)
                        if !compactMode,
                           let updatedDate = paper.updatedDate,
                           abs(updatedDate.timeIntervalSince(paper.publishedDate)) > 3600 { // Más de 1 hora de diferencia
                            Label("Actualizado: \(updatedDate.formatted(date: .abbreviated, time: .omitted))", 
                                  systemImage: "arrow.clockwise")
                                .font(.system(size: fontSize - 8))
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Spacer()
                    
                    // Categorías del artículo
                    if !compactMode && !paper.categories.isEmpty {
                        let categories = paper.categories.split(separator: " ").map(String.init)
                        HStack(spacing: 4) {
                            ForEach(categories.prefix(2), id: \.self) { category in
                                Text(category)
                                    .font(.system(size: fontSize - 8))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
            
            // Botón de favorito (si el controller está disponible)
            if let controller = controller {
                Button(action: {
                    controller.toggleFavorite(for: paper)
                }) {
                    Image(systemName: paper.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(paper.isFavorite ? .red : .gray)
                        .font(.system(size: fontSize))
                }
                .buttonStyle(PlainButtonStyle())
                .help(paper.isFavorite ? "Quitar de favoritos" : "Añadir a favoritos")
            }
        }
        .padding(.vertical, compactMode ? 12 : 16)
        #if os(macOS)
        .padding(.horizontal, 20)
        .background(Color.clear)
        .cornerRadius(12)
        .contentShape(Rectangle())
        #endif
    }
}

#Preview {
    ArXivPaperRow(
        paper: ArXivPaper(
            id: "2025.0001",
            title: "Ejemplo de Paper de ArXiv",
            summary: "Este es un resumen de ejemplo de un paper científico que muestra cómo se vería en la aplicación.",
            authors: "Juan Pérez, María González",
            publishedDate: Date(),
            updatedDate: Date(),
            pdfURL: "https://arxiv.org/pdf/2025.0001.pdf",
            linkURL: "https://arxiv.org/abs/2025.0001",
            categories: "cs.AI cs.LG"
        ),
        controller: nil
    )
    .padding()
}
