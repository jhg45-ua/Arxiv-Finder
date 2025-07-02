//
//  CrossPlatformExtensions.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Extensiones para mejorar la compatibilidad entre iOS y macOS
/// Proporciona métodos y modificadores que funcionan en ambas plataformas

extension View {
    /// Aplica un estilo de fondo adaptativo según la plataforma
    @ViewBuilder
    func adaptiveBackground() -> some View {
        #if os(macOS)
        self.background(Color(NSColor.controlBackgroundColor))
        #else
        self.background(Color(UIColor.systemBackground))
        #endif
    }
    
    /// Aplica un color de texto secundario adaptativo
    @ViewBuilder
    func adaptiveSecondaryText() -> some View {
        #if os(macOS)
        self.foregroundColor(Color(NSColor.secondaryLabelColor))
        #else
        self.foregroundColor(Color(UIColor.secondaryLabel))
        #endif
    }
    
    /// Aplica un estilo de tarjeta adaptativo para cada plataforma
    @ViewBuilder
    func adaptiveCard() -> some View {
        #if os(macOS)
        self
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        #else
        self
            .padding(16)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        #endif
    }
    
    /// Aplica un espaciado de contenido adaptativo
    @ViewBuilder
    func adaptiveContentSpacing() -> some View {
        #if os(macOS)
        self.padding(.horizontal, 20)
        #else
        self.padding(.horizontal, 16)
        #endif
    }
}

/// Extensión para manejar URLs de forma segura en ambas plataformas
extension URL {
    /// Abre una URL de manera segura en el navegador predeterminado
    func openInBrowser() {
        #if os(macOS)
        NSWorkspace.shared.open(self)
        #else
        UIApplication.shared.open(self)
        #endif
    }
}

/// Extensión para formatear fechas de forma consistente
extension Date {
    /// Formatea la fecha para mostrar de forma amigable
    var formattedForDisplay: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    /// Formatea la fecha de forma relativa (ej: "hace 2 días")
    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

/// Extensión para manejar texto de forma más eficiente
extension String {
    /// Limpia espacios en blanco y saltos de línea excesivos
    var cleanedText: String {
        return self
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Trunca el texto a una longitud específica
    func truncated(to length: Int, trailing: String = "...") -> String {
        if self.count <= length {
            return self
        }
        return String(self.prefix(length)) + trailing
    }
    
    /// Convierte el texto a formato de cita académica
    var academicFormat: String {
        return self.cleanedText.capitalized
    }
}

/// Protocolo para manejar acciones específicas de plataforma
protocol PlatformActionHandler {
    func shareContent(_ content: String, url: URL?)
    func copyToClipboard(_ content: String)
    func showAlert(title: String, message: String)
}

/// Implementación del manejador de acciones para cada plataforma
class DefaultPlatformActionHandler: PlatformActionHandler {
    func shareContent(_ content: String, url: URL?) {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
        if let url = url {
            pasteboard.setString(url.absoluteString, forType: .URL)
        }
        #else
        // En iOS se manejaría con UIActivityViewController
        // Esta implementación se completaría según las necesidades específicas
        UIPasteboard.general.string = content
        #endif
    }
    
    func copyToClipboard(_ content: String) {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
        #else
        UIPasteboard.general.string = content
        #endif
    }
    
    func showAlert(title: String, message: String) {
        #if os(macOS)
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.runModal()
        #else
        // En iOS se manejaría con UIAlertController
        // Esta implementación se completaría según las necesidades específicas
        print("Alert: \(title) - \(message)")
        #endif
    }
}
