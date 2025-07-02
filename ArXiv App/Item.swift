//
//  Item.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import Foundation
import SwiftData

/// Modelo de datos principal para representar elementos en la aplicación ArXiv
/// Esta clase define la estructura de datos que se almacena persistentemente usando SwiftData
/// 
/// @Model: Macro que convierte automáticamente la clase en un modelo de SwiftData
/// final: Previene que otras clases hereden de esta, optimizando el rendimiento
@Model
final class Item {
    /// Marca de tiempo que registra cuándo fue creado o modificado el elemento
    /// Se usa para ordenar elementos cronológicamente o para auditoría
    var timestamp: Date
    
    /// Inicializador principal del modelo Item
    /// 
    /// - Parameter timestamp: Fecha y hora de creación del elemento
    ///   Por defecto se puede usar Date() para el momento actual
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
