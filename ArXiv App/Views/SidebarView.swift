//
//  SidebarView.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import SwiftUI

/// Vista de barra lateral para macOS
/// Proporciona navegación y opciones adicionales en la interfaz de macOS
struct SidebarView: View {
    @Binding var currentCategory: String
    let onLatestPapersSelected: () async -> Void
    let onComputerScienceSelected: () async -> Void
    let onMathematicsSelected: () async -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header simplificado
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "doc.richtext")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("ArXiv")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
            }
            
            Divider()
                .padding(.horizontal, 16)
            
            // Lista de navegación simplificada
            VStack(spacing: 8) {
                sidebarButton(
                    title: "Últimos Papers",
                    icon: "doc.text",
                    isSelected: currentCategory == "latest"
                ) {
                    Task { await onLatestPapersSelected() }
                }
                
                sidebarButton(
                    title: "Computer Science",
                    icon: "laptopcomputer",
                    isSelected: currentCategory == "cs"
                ) {
                    Task { await onComputerScienceSelected() }
                }
                
                sidebarButton(
                    title: "Mathematics",
                    icon: "x.squareroot",
                    isSelected: currentCategory == "math"
                ) {
                    Task { await onMathematicsSelected() }
                }
                
                Divider()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                
                sidebarButton(
                    title: "Favoritos",
                    icon: "heart",
                    isSelected: false,
                    isEnabled: false
                ) {
                    // Funcionalidad pendiente
                }
                
                sidebarButton(
                    title: "Búsqueda",
                    icon: "magnifyingglass",
                    isSelected: false,
                    isEnabled: false
                ) {
                    // Funcionalidad pendiente
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 16)
            
            Spacer()
        }
        .frame(minWidth: 250)
        #if os(macOS)
        .background(Color(NSColor.controlBackgroundColor))
        #else
        .background(Color(UIColor.systemBackground))
        #endif
    }
    
    @ViewBuilder
    private func sidebarButton(
        title: String,
        icon: String,
        isSelected: Bool,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : (isEnabled ? .primary : .secondary))
                    .frame(width: 20)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : (isEnabled ? .primary : .secondary))
                
                Spacer()
                
                if !isEnabled {
                    Text("Pronto")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.secondary.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected ? Color.accentColor : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    SidebarView(
        currentCategory: .constant("latest"),
        onLatestPapersSelected: { },
        onComputerScienceSelected: { },
        onMathematicsSelected: { }
    )
    .frame(width: 320, height: 500)
}
