//
//  SettingsView.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 3/7/25.
//

import SwiftUI
import UserNotifications
import AppKit

/// Vista de configuraciones simplificada para la app de ArXiv
/// Proporciona opciones esenciales con aplicación inmediata de cambios
#if os(macOS)
struct SettingsView: View {
    
    // MARK: - Settings Properties
    @AppStorage("refreshInterval") private var refreshInterval = 30
    @AppStorage("maxPapers") private var maxPapers = 10
    @AppStorage("defaultCategory") private var defaultCategory = "latest"
    @AppStorage("autoRefresh") private var autoRefresh = false
    @AppStorage("showNotifications") private var showNotifications = true
    @AppStorage("compactMode") private var compactMode = false
    @AppStorage("showPreview") private var showPreview = true
    @AppStorage("fontSize") private var fontSize = 14.0
    
    // MARK: - State Properties
    @State private var isTestingConnection = false
    @State private var connectionTestResult = ""
    @State private var showingConnectionAlert = false
    @State private var showingResetAlert = false
    
    var body: some View {
        TabView {
            generalSettingsView
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            interfaceSettingsView
                .tabItem {
                    Label("Interfaz", systemImage: "paintbrush")
                }
            
            aboutSettingsView
                .tabItem {
                    Label("Acerca de", systemImage: "info.circle")
                }
        }
        .frame(width: 600, height: 500)
        .alert("Resultado de Conexión", isPresented: $showingConnectionAlert) {
            Button("OK") { }
        } message: {
            Text(connectionTestResult)
        }
        .alert("Restablecer Configuración", isPresented: $showingResetAlert) {
            Button("Restablecer", role: .destructive) {
                resetSettings()
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("¿Estás seguro de que quieres restablecer todas las configuraciones?")
        }
    }
    
    // MARK: - General Settings View
    private var generalSettingsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Configuración General")
                .font(.title2)
                .fontWeight(.bold)
            
            Divider()
            
            // Configuración de contenido
            GroupBox("Contenido") {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Máximo de papers:")
                        Spacer()
                        Stepper(value: $maxPapers, in: 5...50, step: 5) {
                            Text("\(maxPapers)")
                                .frame(width: 30, alignment: .trailing)
                        }
                        .onChange(of: maxPapers) { _, _ in
                            notifySettingsChanged()
                        }
                    }
                    
                    HStack {
                        Text("Categoría por defecto:")
                        Spacer()
                        Picker("Categoría", selection: $defaultCategory) {
                            Text("Últimos").tag("latest")
                            Text("Computer Science").tag("cs")
                            Text("Mathematics").tag("math")
                            Text("Physics").tag("physics")
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 150)
                        .onChange(of: defaultCategory) { _, _ in
                            notifySettingsChanged()
                        }
                    }
                }
                .padding(.vertical, 6)
            }
            
            // Configuración de actualización
            GroupBox("Actualización") {
                VStack(alignment: .leading, spacing: 10) {
                    Toggle("Actualización automática", isOn: $autoRefresh)
                        .onChange(of: autoRefresh) { _, _ in
                            notifySettingsChanged()
                        }
                    
                    if autoRefresh {
                        HStack {
                            Text("Intervalo:")
                            Spacer()
                            Stepper(value: $refreshInterval, in: 5...120, step: 5) {
                                Text("\(refreshInterval) min")
                                    .frame(width: 60, alignment: .trailing)
                            }
                            .onChange(of: refreshInterval) { _, _ in
                                notifySettingsChanged()
                            }
                        }
                    }
                }
                .padding(.vertical, 6)
            }
            
            // Configuración de notificaciones
            GroupBox("Notificaciones") {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Mostrar notificaciones", isOn: $showNotifications)
                        .onChange(of: showNotifications) { _, newValue in
                            if newValue {
                                requestNotificationPermission()
                            }
                        }
                    
                    if showNotifications {
                        Button("Probar Notificación") {
                            testNotification()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                .padding(.vertical, 6)
            }
            
            Spacer()
        }
        .padding(18)
    }
    
    // MARK: - Interface Settings View
    private var interfaceSettingsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Configuración de Interfaz")
                .font(.title2)
                .fontWeight(.bold)
            
            Divider()
            
            // Configuración de vista
            GroupBox("Visualización") {
                VStack(alignment: .leading, spacing: 10) {
                    Toggle("Modo compacto", isOn: $compactMode)
                        .onChange(of: compactMode) { _, _ in
                            notifySettingsChanged()
                        }
                    
                    Toggle("Mostrar vista previa", isOn: $showPreview)
                        .onChange(of: showPreview) { _, _ in
                            notifySettingsChanged()
                        }
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Tamaño de fuente:")
                                .fontWeight(.medium)
                            Spacer()
                        }
                        
                        VStack(spacing: 10) {
                            // Etiqueta del valor actual con vista previa
                            HStack {
                                Text("Aa")
                                    .font(.system(size: fontSize))
                                    .fontWeight(.medium)
                                Text("\(Int(fontSize))pt")
                                    .font(.system(.body, design: .monospaced))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                                    .frame(width: 35, alignment: .center)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                            
                            // Slider con etiquetas y estilo mejorado - MÁS ANCHO
                            VStack(spacing: 6) {
                                HStack {
                                    Text("Pequeña")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("Grande")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                Slider(value: $fontSize, in: 10...20, step: 1) {
                                    Text("Tamaño de fuente")
                                } minimumValueLabel: {
                                    Image(systemName: "textformat.size.smaller")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 14))
                                } maximumValueLabel: {
                                    Image(systemName: "textformat.size.larger")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 14))
                                }
                                .tint(.blue)
                                .controlSize(.large)
                                .onChange(of: fontSize) { _, _ in
                                    notifySettingsChanged()
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 6)
            }
            
            // Vista previa
            GroupBox("Vista Previa") {
                VStack(alignment: .leading, spacing: compactMode ? 6 : 10) {
                    Text("Quantum Computing and Machine Learning")
                        .font(.system(size: fontSize, weight: .medium))
                        .lineLimit(compactMode ? 2 : 4)
                    
                    if !compactMode {
                        Text("John Smith, Alice Johnson, Robert Brown")
                            .font(.system(size: fontSize - 2))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    if showPreview {
                        Text("Este artículo presenta un nuevo enfoque para la integración de computación cuántica con algoritmos de aprendizaje automático, demostrando mejoras significativas en la eficiencia computacional para problemas de optimización complejos.")
                            .font(.system(size: fontSize - 4))
                            .foregroundColor(.secondary)
                            .lineLimit(compactMode ? 1 : 3)
                    }
                    
                    HStack {
                        Label("3 Jul 2025", systemImage: "calendar")
                            .font(.system(size: fontSize - 6))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("cs.AI")
                            .font(.system(size: fontSize - 6))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                        
                        if !compactMode {
                            Text("ID: 2025.0123")
                                .font(.system(size: fontSize - 8))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(6)
                        }
                    }
                }
                .padding(.vertical, compactMode ? 8 : 12)
                .padding(.horizontal, 8)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding(18)
    }
     // MARK: - About Settings View
    private var aboutSettingsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Acerca de ArXiv App")
                .font(.title2)
                .fontWeight(.bold)
            
            Divider()
            
            // Información de la aplicación
            GroupBox("Información") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Versión:")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Desarrollador:")
                        Spacer()
                        Text("Julián Hinojosa Gil")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 6)
            }
            
            // Test de conexión
            GroupBox("Conexión") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Estado:")
                        Spacer()
                        Text("Conectado")
                            .foregroundColor(.green)
                    }
                    
                    Button("Probar Conexión") {
                        testConnection()
                    }
                    .disabled(isTestingConnection)
                    .buttonStyle(.bordered)
                }
                .padding(.vertical, 6)
            }
            
            // Enlaces útiles
            GroupBox("Enlaces") {
                VStack(alignment: .leading, spacing: 6) {
                    Button("Sitio web de ArXiv") {
                        openURL("https://arxiv.org")
                    }
                    .buttonStyle(.link)
                    
                    Button("Documentación de API") {
                        openURL("https://arxiv.org/help/api")
                    }
                    .buttonStyle(.link)
                }
                .padding(.vertical, 6)
            }
            
            // Acciones
            GroupBox("Acciones") {
                Button("Restablecer Configuración") {
                    showingResetAlert = true
                }
                .buttonStyle(.bordered)
                .padding(.vertical, 6)
            }
            
            Spacer()
        }
        .padding(18)
    }
    
    // MARK: - Helper Methods
    
    /// Notifica cambios en la configuración al controlador
    private func notifySettingsChanged() {
        NotificationCenter.default.post(
            name: .settingsChanged,
            object: nil
        )
    }
    
    /// Solicita permisos de notificación
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if !granted {
                    self.showNotifications = false
                }
            }
        }
    }
    
    /// Envía una notificación de prueba
    private func testNotification() {
        let content = UNMutableNotificationContent()
        content.title = "ArXiv App - Prueba"
        content.body = "Las notificaciones están funcionando correctamente."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "test-notification",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error al enviar notificación: \(error)")
            }
        }
    }
    
    /// Prueba la conexión con ArXiv
    private func testConnection() {
        isTestingConnection = true
        
        Task {
            do {
                let url = URL(string: "https://export.arxiv.org/api/query?search_query=all:test&start=0&max_results=1")!
                let (_, response) = try await URLSession.shared.data(from: url)
                
                DispatchQueue.main.async {
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            self.connectionTestResult = "✅ Conexión exitosa"
                        } else {
                            self.connectionTestResult = "❌ Error HTTP: \(httpResponse.statusCode)"
                        }
                    }
                    self.isTestingConnection = false
                    self.showingConnectionAlert = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.connectionTestResult = "❌ Error: \(error.localizedDescription)"
                    self.isTestingConnection = false
                    self.showingConnectionAlert = true
                }
            }
        }
    }
    
    /// Abre una URL en el navegador
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }
    
    /// Restablece todas las configuraciones a sus valores por defecto
    private func resetSettings() {
        refreshInterval = 30
        maxPapers = 10
        defaultCategory = "latest"
        autoRefresh = false
        showNotifications = true
        compactMode = false
        showPreview = true
        fontSize = 14.0
        
        // Notificar cambios
        notifySettingsChanged()
    }
}

#endif
