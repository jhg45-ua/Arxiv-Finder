//
//  ArXivPaper.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import Foundation
import SwiftData

/// Modelo de datos que representa un artículo científico de ArXiv
/// Almacena la información principal de cada paper para acceso offline
@Model
final class ArXivPaper: @unchecked Sendable {
    /// Identificador único del artículo en ArXiv (ej: "2023.12345v1")
    var id: String
    
    /// Título completo del artículo científico
    var title: String
    
    /// Resumen o abstract del artículo
    var summary: String
    
    /// Lista de autores del artículo, separados por comas
    var authors: String
    
    /// Fecha de publicación del artículo
    var publishedDate: Date
    
    /// URL del PDF del artículo en ArXiv
    var pdfURL: String
    
    /// URL de la página web del artículo en ArXiv
    var linkURL: String
    
    /// Categorías científicas del artículo (ej: "cs.AI", "math.CO")
    var categories: String
    
    /// Inicializador principal para crear un nuevo artículo de ArXiv
    /// - Parameters:
    ///   - id: Identificador único del artículo
    ///   - title: Título del artículo
    ///   - summary: Resumen del artículo
    ///   - authors: Autores del artículo
    ///   - publishedDate: Fecha de publicación
    ///   - pdfURL: URL del PDF
    ///   - linkURL: URL de la página del artículo
    ///   - categories: Categorías científicas
    init(id: String, title: String, summary: String, authors: String, 
         publishedDate: Date, pdfURL: String, linkURL: String, categories: String) {
        self.id = id
        self.title = title
        self.summary = summary
        self.authors = authors
        self.publishedDate = publishedDate
        self.pdfURL = pdfURL
        self.linkURL = linkURL
        self.categories = categories
    }
}
