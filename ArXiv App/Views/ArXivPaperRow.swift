//
//  ArXivPaperRow.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import SwiftUI

/// Vista de fila para mostrar un paper de ArXiv
/// Representa la presentación visual de un paper individual en la lista
struct ArXivPaperRow: View {
    let paper: ArXivPaper
    
    // MARK: - Settings from AppStorage
    @AppStorage("fontSize") private var fontSize = 14.0
    @AppStorage("compactMode") private var compactMode = false
    @AppStorage("showPreview") private var showPreview = true
    
    var body: some View {
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
                
                // Categorías
                if !paper.categories.isEmpty {
                    Text(paper.categories.components(separatedBy: " ").first ?? "")
                        .font(.system(size: fontSize - 6))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                }
                
                // ID del paper (solo si no está en modo compacto)
                if !compactMode {
                    Text("ID: \(paper.id)")
                        .font(.system(size: fontSize - 8))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                }
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
    ArXivPaperRow(paper: ArXivPaper(
        id: "2025.0001",
        title: "Ejemplo de Paper de ArXiv",
        summary: "Este es un resumen de ejemplo de un paper científico que muestra cómo se vería en la aplicación.",
        authors: "Juan Pérez, María González",
        publishedDate: Date(),
        updatedDate: Date(),
        pdfURL: "https://arxiv.org/pdf/2025.0001.pdf",
        linkURL: "https://arxiv.org/abs/2025.0001",
        categories: "cs.AI cs.LG"
    ))
    .padding()
}
