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
    
    /// Fecha de última actualización del artículo (si está disponible)
    var updatedDate: Date?
    
    /// URL del PDF del artículo en ArXiv
    var pdfURL: String
    
    /// URL de la página web del artículo en ArXiv
    var linkURL: String
    
    /// Categorías científicas del artículo (ej: "cs.AI", "math.CO")
    var categories: String
    
    /// Indica si el artículo está marcado como favorito
    var isFavorite: Bool = false
    
    /// Fecha cuando se marcó como favorito (solo relevante si isFavorite es true)
    var favoritedDate: Date?
    
    /// Inicializador principal para crear un nuevo artículo de ArXiv
    /// - Parameters:
    ///   - id: Identificador único del artículo
    ///   - title: Título del artículo
    ///   - summary: Resumen del artículo
    ///   - authors: Autores del artículo
    ///   - publishedDate: Fecha de publicación
    ///   - updatedDate: Fecha de última actualización (opcional)
    ///   - pdfURL: URL del PDF
    ///   - linkURL: URL de la página del artículo
    ///   - categories: Categorías científicas
    ///   - isFavorite: Si está marcado como favorito (por defecto false)
    init(id: String, title: String, summary: String, authors: String, 
         publishedDate: Date, updatedDate: Date? = nil, pdfURL: String, linkURL: String, categories: String, isFavorite: Bool = false) {
        self.id = id
        self.title = title
        self.summary = summary
        self.authors = authors
        self.publishedDate = publishedDate
        self.updatedDate = updatedDate
        self.pdfURL = pdfURL
        self.linkURL = linkURL
        self.categories = categories
        self.isFavorite = isFavorite
        self.favoritedDate = isFavorite ? Date() : nil
    }
    
    /// Marca o desmarca el paper como favorito
    /// - Parameter favorite: true para marcar como favorito, false para desmarcar
    func setFavorite(_ favorite: Bool) {
        self.isFavorite = favorite
        self.favoritedDate = favorite ? Date() : nil
    }
}
