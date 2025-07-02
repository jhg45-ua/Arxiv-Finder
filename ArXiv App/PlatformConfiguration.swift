//
//  PlatformConfiguration.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import SwiftUI

/// Configuración específica para cada plataforma
/// Proporciona valores y comportamientos adaptados a iOS y macOS
struct PlatformConfiguration {
    
    /// Configuración de la ventana principal
    static var windowConfiguration: some Scene {
        #if os(macOS)
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        #else
        WindowGroup {
            ContentView()
        }
        #endif
    }
    
    /// Estilo de lista apropiado para cada plataforma
    static var listStyle: some ListStyle {
        #if os(macOS)
        return PlainListStyle()
        #else
        return DefaultListStyle()
        #endif
    }
    
    /// Espaciado apropiado para cada plataforma
    static var defaultSpacing: CGFloat {
        #if os(macOS)
        return 12
        #else
        return 8
        #endif
    }
    
    /// Padding horizontal para contenido
    static var horizontalPadding: CGFloat {
        #if os(macOS)
        return 20
        #else
        return 16
        #endif
    }
    
    /// Tamaño de fuente para títulos principales
    static var titleFont: Font {
        #if os(macOS)
        return .title2
        #else
        return .title3
        #endif
    }
    
    /// Determina si se debe mostrar la barra lateral
    static var showsSidebar: Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }
    
    /// Configuración de toolbar específica por plataforma
    static func toolbarPlacement() -> ToolbarItemPlacement {
        #if os(macOS)
        return .automatic
        #else
        return .navigationBarTrailing
        #endif
    }
}

/// Extensión de View para aplicar configuraciones de plataforma
extension View {
    /// Aplica el padding horizontal apropiado para la plataforma
    func platformHorizontalPadding() -> some View {
        self.padding(.horizontal, PlatformConfiguration.horizontalPadding)
    }
    
    /// Aplica el espaciado apropiado para la plataforma
    func platformSpacing() -> some View {
        self.padding(PlatformConfiguration.defaultSpacing)
    }
}
