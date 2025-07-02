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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Título del artículo
            Text(paper.title)
                .font(.title3)
                .fontWeight(.medium)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
            
            // Autores del artículo
            Text(paper.authors)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // Resumen del artículo (mostrar las primeras líneas)
            Text(paper.summary)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .padding(.top, 4)
            
            HStack {
                // Fechas del paper
                VStack(alignment: .leading, spacing: 2) {
                    // Fecha de publicación
                    Label(paper.publishedDate.formatted(date: .abbreviated, time: .omitted), 
                          systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Fecha de actualización (si existe y es diferente)
                    if let updatedDate = paper.updatedDate,
                       abs(updatedDate.timeIntervalSince(paper.publishedDate)) > 3600 { // Más de 1 hora de diferencia
                        Label("Actualizado: \(updatedDate.formatted(date: .abbreviated, time: .omitted))", 
                              systemImage: "arrow.clockwise")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                // Categorías
                if !paper.categories.isEmpty {
                    Text(paper.categories.components(separatedBy: " ").first ?? "")
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                }
                
                // ID del paper
                Text("ID: \(paper.id)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
            }
        }
        .padding(.vertical, 16)
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
