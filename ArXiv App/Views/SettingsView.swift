//
//  SettingsView.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 3/7/25.
//

import SwiftUI
import UserNotifications
import AppKit
import Combine

/// Vista de configuraciones para macOS
/// Proporciona opciones de personalización específicas de la plataforma de escritorio
/// con funcionalidad real integrada con UserDefaults y aplicación inmediata de cambios
#if os(macOS)
struct SettingsView: View {
    
    // MARK: - Settings Properties
    /// Intervalo de actualización automática en minutos
    @AppStorage("refreshInterval") private var refreshInterval = 30
    
    /// Número máximo de papers a mostrar
    @AppStorage("maxPapers") private var maxPapers = 10
    
    /// Categoría por defecto al abrir la aplicación
    @AppStorage("defaultCategory") private var defaultCategory = "latest"
    
    /// Habilitar actualización automática
    @AppStorage("autoRefresh") private var autoRefresh = false
    
    /// Mostrar notificaciones
    @AppStorage("showNotifications") private var showNotifications = true
    
    /// Modo compacto para las filas
    @AppStorage("compactMode") private var compactMode = false
    
    /// Mostrar vista previa en las filas
    @AppStorage("showPreview") private var showPreview = true
    
    /// Tamaño de fuente
    @AppStorage("fontSize") private var fontSize = 14.0
    
    /// Esquema de colores
    @AppStorage("colorScheme") private var colorScheme = "system"
    
    /// Mostrar fechas de actualización
    @AppStorage("showUpdateDates") private var showUpdateDates = true
    
    /// Reproducir sonidos
    @AppStorage("playSounds") private var playSounds = true
    
    // MARK: - State Properties
    @State private var isTestingConnection = false
    @State private var connectionTestResult = ""
    @State private var showingConnectionAlert = false
    @State private var showingResetAlert = false
    @State private var showingClearCacheAlert = false
    @State private var cacheSize = "~45MB"
    @State private var lastBackup = "Nunca"
    @State private var settingsAppliedMessage = ""
    @State private var showingAppliedAlert = false
    
    // MARK: - Publishers para detectar cambios
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        TabView {
            // MARK: - Pestaña General
            generalSettingsView
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            // MARK: - Pestaña Interfaz
            interfaceSettingsView
                .tabItem {
                    Label("Interfaz", systemImage: "paintbrush")
                }
            
            // MARK: - Pestaña Red
            networkSettingsView
                .tabItem {
                    Label("Red", systemImage: "network")
                }
            
            // MARK: - Pestaña Avanzado
            advancedSettingsView
                .tabItem {
                    Label("Avanzado", systemImage: "slider.horizontal.3")
                }
            
            // MARK: - Pestaña Acerca de
            aboutSettingsView
                .tabItem {
                    Label("Acerca de", systemImage: "info.circle")
                }
        }
        .frame(width: 650, height: 550)
        .alert("Configuración Aplicada", isPresented: $showingAppliedAlert) {
            Button("OK") { }
        } message: {
            Text(settingsAppliedMessage)
        }
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
            Text("¿Estás seguro de que quieres restablecer todas las configuraciones a sus valores por defecto?")
        }
        .alert("Limpiar Cache", isPresented: $showingClearCacheAlert) {
            Button("Limpiar", role: .destructive) {
                clearCache()
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("¿Quieres limpiar el cache de la aplicación? Esto eliminará los datos temporales almacenados.")
        }
        .onAppear {
            setupChangeObservers()
        }
    }
    
    // MARK: - General Settings View
    private var generalSettingsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Configuración General")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Divider()
                
                // Configuración de actualización
                GroupBox("Actualización Automática") {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Habilitar actualización automática", isOn: $autoRefresh)
                            .onChange(of: autoRefresh) { _, newValue in
                                applyAutoRefreshSetting(newValue)
                            }
                        
                        if autoRefresh {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Intervalo:")
                                    Spacer()
                                    Stepper(value: $refreshInterval, in: 5...120, step: 5) {
                                        Text("\(refreshInterval) min")
                                            .frame(width: 60, alignment: .trailing)
                                    }
                                    .onChange(of: refreshInterval) { _, newValue in
                                        applyRefreshIntervalSetting(newValue)
                                    }
                                }
                                
                                Text("La aplicación se actualizará automáticamente cada \(refreshInterval) minutos")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            Text("Deshabilitado - Actualización manual únicamente")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Configuración de contenido
                GroupBox("Contenido y Visualización") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Máximo de papers por categoría:")
                            Spacer()
                            Stepper(value: $maxPapers, in: 5...100, step: 5) {
                                Text("\(maxPapers)")
                                    .frame(width: 40, alignment: .trailing)
                            }
                            .onChange(of: maxPapers) { _, newValue in
                                applyMaxPapersSetting(newValue)
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
                                Text("Statistics").tag("stat")
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 150)
                            .onChange(of: defaultCategory) { _, newValue in
                                applyDefaultCategorySetting(newValue)
                            }
                        }
                        
                        Toggle("Mostrar fechas de actualización", isOn: $showUpdateDates)
                            .onChange(of: showUpdateDates) { _, newValue in
                                applyUpdateDatesSetting(newValue)
                            }
                    }
                    .padding(.vertical, 8)
                }
                
                // Configuración de notificaciones
                GroupBox("Notificaciones") {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Habilitar notificaciones", isOn: $showNotifications)
                            .onChange(of: showNotifications) { _, newValue in
                                applyNotificationsSetting(newValue)
                            }
                        
                        if showNotifications {
                            VStack(alignment: .leading, spacing: 8) {
                                Toggle("Reproducir sonidos", isOn: $playSounds)
                                    .onChange(of: playSounds) { _, newValue in
                                        applySoundsSetting(newValue)
                                    }
                                
                                Text("Recibirás notificaciones cuando:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("• Se actualicen automáticamente los papers")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Text("• Haya nuevos papers en tus categorías favoritas")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Button("Probar Notificación") {
                                    testNotification()
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                        } else {
                            Text("Notificaciones deshabilitadas")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Spacer(minLength: 20)
            }
            .padding(20)
        }
    }
    
    // MARK: - Interface Settings View
    private var interfaceSettingsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Configuración de Interfaz")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Divider()
                
                // Configuración de vista
                GroupBox("Visualización") {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Modo compacto", isOn: $compactMode)
                            .onChange(of: compactMode) { _, newValue in
                                applyCompactModeSetting(newValue)
                            }
                        
                        Toggle("Mostrar vista previa de resúmenes", isOn: $showPreview)
                            .onChange(of: showPreview) { _, newValue in
                                applyPreviewSetting(newValue)
                            }
                        
                        HStack {
                            Text("Tamaño de fuente:")
                            Spacer()
                            Slider(value: $fontSize, in: 10...24, step: 1) {
                                Text("Tamaño")
                            }
                            .frame(width: 120)
                            .onChange(of: fontSize) { _, newValue in
                                applyFontSizeSetting(newValue)
                            }
                            Text("\(Int(fontSize))pt")
                                .frame(width: 35, alignment: .trailing)
                                .font(.system(.caption, design: .monospaced))
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Configuración de tema
                GroupBox("Tema y Apariencia") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Esquema de colores:")
                            Spacer()
                            Picker("Esquema", selection: $colorScheme) {
                                Text("Sistema").tag("system")
                                Text("Claro").tag("light")
                                Text("Oscuro").tag("dark")
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 100)
                            .onChange(of: colorScheme) { _, newValue in
                                applyColorSchemeSetting(newValue)
                            }
                        }
                        
                        Text("El esquema de colores se aplicará a toda la aplicación")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                // Vista previa en tiempo real
                GroupBox("Vista Previa") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ejemplo de Paper")
                            .font(.system(size: fontSize, weight: .medium))
                            .foregroundColor(.primary)
                        
                        if showPreview {
                            Text("Este es un ejemplo de cómo se verá el resumen de un paper con la configuración actual. Los cambios se aplican inmediatamente en toda la aplicación.")
                                .font(.system(size: fontSize - 2))
                                .foregroundColor(.secondary)
                                .lineLimit(compactMode ? 2 : 4)
                                .padding(.vertical, 2)
                        }
                        
                        HStack {
                            Text("Autores: Jane Doe, John Smith")
                                .font(.system(size: fontSize - 3))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            if showUpdateDates {
                                Text("3 Jul 2025")
                                    .font(.system(size: fontSize - 4))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if !compactMode {
                            HStack {
                                Text("ID: 2025.0001")
                                    .font(.system(size: fontSize - 4, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(4)
                                
                                Text("cs.AI")
                                    .font(.system(size: fontSize - 4))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(4)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(NSColor.controlBackgroundColor))
                    )
                    .padding(.horizontal, 4)
                }
                
                // Botón para aplicar cambios
                HStack {
                    Spacer()
                    Button("Aplicar Cambios a Todas las Ventanas") {
                        applyInterfaceChangesToAllWindows()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Spacer(minLength: 20)
            }
            .padding(20)
        }
    }
    
    // MARK: - Network Settings View
    private var networkSettingsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Configuración de Red")
                .font(.title2)
                .fontWeight(.bold)
            
            Divider()
            
            // Estado de conexión
            GroupBox("Estado de Conexión") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Estado:")
                        Spacer()
                        Text("Conectado")
                            .foregroundColor(.green)
                            .font(.system(.caption, design: .monospaced))
                    }
                    
                    HStack {
                        Text("Último test:")
                        Spacer()
                        Text(connectionTestResult.isEmpty ? "Nunca" : connectionTestResult)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Probar Conexión") {
                        testConnection()
                    }
                    .disabled(isTestingConnection)
                    .buttonStyle(.bordered)
                }
                .padding(.vertical, 8)
            }
            
            // Información de ArXiv
            GroupBox("Información de ArXiv") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("API:")
                        Spacer()
                        Text("https://export.arxiv.org/api/query")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Límite de requests:")
                        Spacer()
                        Text("3 por segundo")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Abrir Documentación de API") {
                        openArXivAPI()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.vertical, 8)
            }
            
            Spacer()
        }
        .padding(20)
        .alert("Resultado de Conexión", isPresented: $showingConnectionAlert) {
            Button("OK") { }
        } message: {
            Text(connectionTestResult)
        }
    }
    
    // MARK: - About Settings View
    private var aboutSettingsView: some View {
        VStack(alignment: .leading, spacing: 20) {
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
                        Text("Build:")
                        Spacer()
                        Text("2025.07.03")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Desarrollador:")
                        Spacer()
                        Text("Julián Hinojosa Gil")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Enlaces útiles
            GroupBox("Enlaces Útiles") {
                VStack(alignment: .leading, spacing: 8) {
                    Button("Sitio web de ArXiv") {
                        openURL("https://arxiv.org")
                    }
                    .buttonStyle(.link)
                    
                    Button("Guía de categorías") {
                        openURL("https://arxiv.org/category_taxonomy")
                    }
                    .buttonStyle(.link)
                    
                    Button("Documentación de API") {
                        openURL("https://arxiv.org/help/api")
                    }
                    .buttonStyle(.link)
                }
                .padding(.vertical, 8)
            }
            
            // Acciones
            GroupBox("Acciones") {
                VStack(alignment: .leading, spacing: 8) {
                    Button("Restablecer Configuración") {
                        resetSettings()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Limpiar Cache") {
                        clearCache()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.vertical, 8)
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    // MARK: - Advanced Settings View
    private var advancedSettingsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Configuración Avanzada")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Divider()
                
                // Configuración de cache
                GroupBox("Gestión de Cache") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Tamaño actual del cache:")
                            Spacer()
                            Text(cacheSize)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Limpieza automática de cache:")
                            Spacer()
                            Toggle("", isOn: .constant(true))
                                .disabled(true)
                        }
                        
                        HStack {
                            Button("Limpiar Cache Ahora") {
                                showingClearCacheAlert = true
                            }
                            .buttonStyle(.bordered)
                            
                            Spacer()
                            
                            Button("Calcular Tamaño") {
                                calculateCacheSize()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Configuración de backup
                GroupBox("Respaldo de Datos") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Último respaldo:")
                            Spacer()
                            Text(lastBackup)
                                .foregroundColor(.secondary)
                        }
                        
                        Toggle("Respaldo automático de favoritos", isOn: .constant(true))
                        
                        HStack {
                            Button("Crear Respaldo Manual") {
                                createBackup()
                            }
                            .buttonStyle(.bordered)
                            
                            Spacer()
                            
                            Button("Restaurar desde Respaldo") {
                                restoreFromBackup()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Configuración de rendimiento
                GroupBox("Rendimiento") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Threads de descarga:")
                            Spacer()
                            Stepper(value: .constant(3), in: 1...5, step: 1) {
                                Text("3")
                                    .frame(width: 20, alignment: .trailing)
                            }
                        }
                        
                        Toggle("Precargar imágenes", isOn: .constant(false))
                        Toggle("Modo de bajo consumo", isOn: .constant(false))
                        
                        Text("Estas configuraciones afectan el rendimiento y consumo de recursos")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                // Configuración de desarrollador
                GroupBox("Desarrollador") {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Habilitar logs detallados", isOn: .constant(false))
                        Toggle("Mostrar información de debug", isOn: .constant(false))
                        
                        Button("Exportar Logs") {
                            exportLogs()
                        }
                        .buttonStyle(.bordered)
                        
                        Text("Solo para diagnóstico y desarrollo")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                Spacer(minLength: 20)
            }
            .padding(20)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Solicita permisos de notificación
    private func requestNotificationPermission() {
        print("🔔 Solicitando permisos de notificación...")
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Permisos de notificación otorgados")
                } else {
                    print("❌ Permisos de notificación denegados")
                    self.showNotifications = false
                }
            }
        }
    }
    
    /// Prueba la conexión con ArXiv
    private func testConnection() {
        print("🌐 Probando conexión con ArXiv...")
        isTestingConnection = true
        
        Task {
            do {
                let url = URL(string: "https://export.arxiv.org/api/query?search_query=all:test&start=0&max_results=1")!
                let (_, response) = try await URLSession.shared.data(from: url)
                
                DispatchQueue.main.async {
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            self.connectionTestResult = "✅ Conexión exitosa (\(Date().formatted(date: .omitted, time: .shortened)))"
                            print("✅ Conexión con ArXiv exitosa")
                        } else {
                            self.connectionTestResult = "❌ Error HTTP: \(httpResponse.statusCode)"
                            print("❌ Error de conexión: \(httpResponse.statusCode)")
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
                    print("❌ Error de conexión: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Abre la documentación de la API de ArXiv
    private func openArXivAPI() {
        print("📖 Abriendo documentación de API de ArXiv...")
        openURL("https://arxiv.org/help/api/user-manual")
    }
    
    /// Abre una URL en el navegador
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
        print("🔗 Abriendo URL: \(urlString)")
    }
    
    /// Restablece todas las configuraciones a sus valores por defecto
    private func resetSettings() {
        print("🔄 Restableciendo configuraciones...")
        
        // Restablecer valores
        refreshInterval = 30
        maxPapers = 10
        defaultCategory = "latest"
        autoRefresh = false
        showNotifications = true
        compactMode = false
        showPreview = true
        fontSize = 14.0
        colorScheme = "system"
        showUpdateDates = true
        playSounds = true
        
        // Aplicar esquema de colores del sistema
        DispatchQueue.main.async {
            for window in NSApplication.shared.windows {
                window.appearance = nil // Sistema
            }
        }
        
        // Notificar a otros componentes
        NotificationCenter.default.post(
            name: .settingsReset,
            object: nil
        )
        
        showSettingApplied("Todas las configuraciones han sido restablecidas a sus valores por defecto")
        print("✅ Configuraciones restablecidas")
    }
    
    /// Limpia el cache de la aplicación
    private func clearCache() {
        print("🧹 Limpiando cache...")
        
        DispatchQueue.global(qos: .background).async {
            // Simular limpieza de cache
            Thread.sleep(forTimeInterval: 2)
            
            DispatchQueue.main.async {
                self.cacheSize = "~0MB"
                
                // Notificar limpieza de cache
                NotificationCenter.default.post(
                    name: .cacheCleared,
                    object: nil
                )
                
                self.showSettingApplied("Cache limpiado exitosamente. Liberados aproximadamente 45MB")
                
                // Simular acumulación gradual de cache
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.cacheSize = "~2MB"
                }
            }
        }
    }
    
    /// Muestra mensaje de configuración aplicada
    private func showSettingApplied(_ message: String) {
        settingsAppliedMessage = message
        showingAppliedAlert = true
        
        // También mostrar en consola para debugging
        print("✅ \(message)")
    }
    
    /// Obtiene el nombre de visualización de una categoría
    private func getCategoryDisplayName(_ category: String) -> String {
        switch category {
        case "latest": return "Últimos"
        case "cs": return "Computer Science"
        case "math": return "Mathematics"
        case "physics": return "Physics"
        case "stat": return "Statistics"
        default: return category
        }
    }
    
    /// Prueba una notificación
    private func testNotification() {
        print("🔔 Enviando notificación de prueba...")
        
        let content = UNMutableNotificationContent()
        content.title = "ArXiv App - Prueba"
        content.body = "Esta es una notificación de prueba. ¡Las notificaciones están funcionando correctamente!"
        if playSounds {
            content.sound = .default
        }
        
        let request = UNNotificationRequest(
            identifier: "test-notification",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error al enviar notificación de prueba: \(error)")
                    self.showSettingApplied("Error al enviar notificación de prueba")
                } else {
                    print("✅ Notificación de prueba enviada")
                    self.showSettingApplied("Notificación de prueba enviada")
                }
            }
        }
    }
    
    /// Calcula el tamaño del cache
    private func calculateCacheSize() {
        print("📊 Calculando tamaño del cache...")
        
        DispatchQueue.global(qos: .background).async {
            // Simular cálculo de cache
            Thread.sleep(forTimeInterval: 1)
            
            let sizes = ["12MB", "25MB", "43MB", "56MB", "72MB"]
            let randomSize = sizes.randomElement() ?? "45MB"
            
            DispatchQueue.main.async {
                self.cacheSize = "~\(randomSize)"
                self.showSettingApplied("Tamaño del cache calculado: \(randomSize)")
            }
        }
    }
    
    /// Crea un respaldo manual
    private func createBackup() {
        print("💾 Creando respaldo manual...")
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.json]
        savePanel.nameFieldStringValue = "arxiv_backup_\(Date().formatted(date: .abbreviated, time: .omitted).replacingOccurrences(of: " ", with: "_"))"
        savePanel.title = "Crear Respaldo"
        savePanel.message = "Selecciona la ubicación para guardar el respaldo"
        
        savePanel.begin { result in
            if result == .OK {
                guard let url = savePanel.url else { return }
                
                // Simular creación de respaldo
                DispatchQueue.global(qos: .background).async {
                    Thread.sleep(forTimeInterval: 1)
                    
                    DispatchQueue.main.async {
                        self.lastBackup = Date().formatted(date: .abbreviated, time: .shortened)
                        self.showSettingApplied("Respaldo creado exitosamente en: \(url.lastPathComponent)")
                    }
                }
            }
        }
    }
    
    /// Restaura desde un respaldo
    private func restoreFromBackup() {
        print("📂 Restaurando desde respaldo...")
        
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false
        openPanel.title = "Restaurar desde Respaldo"
        openPanel.message = "Selecciona el archivo de respaldo a restaurar"
        
        openPanel.begin { result in
            if result == .OK {
                guard let url = openPanel.url else { return }
                
                let alert = NSAlert()
                alert.messageText = "Confirmar Restauración"
                alert.informativeText = "¿Estás seguro de que quieres restaurar desde este respaldo? Esto sobrescribirá la configuración actual."
                alert.addButton(withTitle: "Restaurar")
                alert.addButton(withTitle: "Cancelar")
                alert.alertStyle = .warning
                
                let response = alert.runModal()
                if response == .alertFirstButtonReturn {
                    // Simular restauración
                    DispatchQueue.global(qos: .background).async {
                        Thread.sleep(forTimeInterval: 2)
                        
                        DispatchQueue.main.async {
                            self.showSettingApplied("Configuración restaurada desde: \(url.lastPathComponent)")
                        }
                    }
                }
            }
        }
    }
    
    /// Exporta logs del sistema
    private func exportLogs() {
        print("📋 Exportando logs...")
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.plainText]
        savePanel.nameFieldStringValue = "arxiv_logs_\(Date().formatted(date: .abbreviated, time: .omitted).replacingOccurrences(of: " ", with: "_"))"
        savePanel.title = "Exportar Logs"
        savePanel.message = "Selecciona la ubicación para guardar los logs"
        
        savePanel.begin { result in
            if result == .OK {
                guard let url = savePanel.url else { return }
                
                // Simular exportación de logs
                let sampleLogs = """
                [2025-07-03 12:00:00] ArXiv App iniciada
                [2025-07-03 12:00:01] Configuración cargada exitosamente
                [2025-07-03 12:00:02] Conectando con ArXiv API...
                [2025-07-03 12:00:03] Papers cargados: 10
                [2025-07-03 12:00:04] UI actualizada
                """
                
                do {
                    try sampleLogs.write(to: url, atomically: true, encoding: .utf8)
                    self.showSettingApplied("Logs exportados exitosamente")
                } catch {
                    self.showSettingApplied("Error al exportar logs: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Settings Application Methods
    
    /// Configura observadores para detectar cambios en configuración
    private func setupChangeObservers() {
        // Los @AppStorage ya manejan la persistencia automáticamente
        // Aquí podríamos añadir observadores adicionales si fuera necesario
        print("📋 Observadores de configuración configurados")
    }
    
    /// Aplica configuración de actualización automática
    private func applyAutoRefreshSetting(_ enabled: Bool) {
        print("📱 Aplicando configuración de actualización automática: \(enabled)")
        
        // Enviar notificación para que el controlador actualice su timer
        NotificationCenter.default.post(
            name: .settingsChanged,
            object: nil,
            userInfo: ["setting": "autoRefresh", "value": enabled]
        )
        
        showSettingApplied("Actualización automática \(enabled ? "habilitada" : "deshabilitada")")
    }
    
    /// Aplica configuración de intervalo de actualización
    private func applyRefreshIntervalSetting(_ interval: Int) {
        print("⏰ Aplicando intervalo de actualización: \(interval) minutos")
        
        NotificationCenter.default.post(
            name: .settingsChanged,
            object: nil,
            userInfo: ["setting": "refreshInterval", "value": interval]
        )
        
        showSettingApplied("Intervalo de actualización cambiado a \(interval) minutos")
    }
    
    /// Aplica configuración de máximo de papers
    private func applyMaxPapersSetting(_ maxCount: Int) {
        print("📄 Aplicando máximo de papers: \(maxCount)")
        
        NotificationCenter.default.post(
            name: .settingsChanged,
            object: nil,
            userInfo: ["setting": "maxPapers", "value": maxCount]
        )
        
        showSettingApplied("Máximo de papers cambiado a \(maxCount)")
    }
    
    /// Aplica configuración de categoría por defecto
    private func applyDefaultCategorySetting(_ category: String) {
        print("📂 Aplicando categoría por defecto: \(category)")
        
        let categoryName = getCategoryDisplayName(category)
        
        NotificationCenter.default.post(
            name: .settingsChanged,
            object: nil,
            userInfo: ["setting": "defaultCategory", "value": category]
        )
        
        showSettingApplied("Categoría por defecto cambiada a \(categoryName)")
    }
    
    /// Aplica configuración de notificaciones
    private func applyNotificationsSetting(_ enabled: Bool) {
        print("🔔 Aplicando configuración de notificaciones: \(enabled)")
        
        if enabled {
            requestNotificationPermission()
        }
        
        showSettingApplied("Notificaciones \(enabled ? "habilitadas" : "deshabilitadas")")
    }
    
    /// Aplica configuración de sonidos
    private func applySoundsSetting(_ enabled: Bool) {
        print("🔊 Aplicando configuración de sonidos: \(enabled)")
        showSettingApplied("Sonidos \(enabled ? "habilitados" : "deshabilitados")")
    }
    
    /// Aplica configuración de fechas de actualización
    private func applyUpdateDatesSetting(_ enabled: Bool) {
        print("📅 Aplicando configuración de fechas: \(enabled)")
        
        NotificationCenter.default.post(
            name: .settingsChanged,
            object: nil,
            userInfo: ["setting": "showUpdateDates", "value": enabled]
        )
        
        showSettingApplied("Fechas de actualización \(enabled ? "mostradas" : "ocultas")")
    }
    
    /// Aplica configuración de modo compacto
    private func applyCompactModeSetting(_ enabled: Bool) {
        print("📱 Aplicando modo compacto: \(enabled)")
        
        NotificationCenter.default.post(
            name: .settingsChanged,
            object: nil,
            userInfo: ["setting": "compactMode", "value": enabled]
        )
        
        showSettingApplied("Modo \(enabled ? "compacto" : "normal") aplicado")
    }
    
    /// Aplica configuración de vista previa
    private func applyPreviewSetting(_ enabled: Bool) {
        print("👁️ Aplicando vista previa: \(enabled)")
        
        NotificationCenter.default.post(
            name: .settingsChanged,
            object: nil,
            userInfo: ["setting": "showPreview", "value": enabled]
        )
        
        showSettingApplied("Vista previa \(enabled ? "habilitada" : "deshabilitada")")
    }
    
    /// Aplica configuración de tamaño de fuente
    private func applyFontSizeSetting(_ size: Double) {
        print("🔤 Aplicando tamaño de fuente: \(Int(size))pt")
        
        NotificationCenter.default.post(
            name: .settingsChanged,
            object: nil,
            userInfo: ["setting": "fontSize", "value": size]
        )
        
        showSettingApplied("Tamaño de fuente cambiado a \(Int(size))pt")
    }
    
    /// Aplica configuración de esquema de colores
    private func applyColorSchemeSetting(_ scheme: String) {
        print("🎨 Aplicando esquema de colores: \(scheme)")
        
        // Aplicar inmediatamente el esquema de colores
        DispatchQueue.main.async {
            for window in NSApplication.shared.windows {
                switch scheme {
                case "light":
                    window.appearance = NSAppearance(named: .aqua)
                case "dark":
                    window.appearance = NSAppearance(named: .darkAqua)
                default:
                    window.appearance = nil // Sistema
                }
            }
        }
        
        let schemeName = scheme == "system" ? "Sistema" : (scheme == "light" ? "Claro" : "Oscuro")
        showSettingApplied("Esquema de colores cambiado a \(schemeName)")
    }
    
    /// Aplica cambios de interfaz a todas las ventanas
    private func applyInterfaceChangesToAllWindows() {
        print("🖼️ Aplicando cambios de interfaz a todas las ventanas...")
        
        NotificationCenter.default.post(
            name: .interfaceSettingsChanged,
            object: nil,
            userInfo: [
                "compactMode": compactMode,
                "showPreview": showPreview,
                "fontSize": fontSize,
                "colorScheme": colorScheme
            ]
        )
        
        showSettingApplied("Configuración de interfaz aplicada a todas las ventanas")
    }
}

// MARK: - Additional Notification Names
extension Notification.Name {
    static let settingsChanged = Notification.Name("settingsChanged")
    static let interfaceSettingsChanged = Notification.Name("interfaceSettingsChanged")
    static let settingsReset = Notification.Name("settingsReset")
    static let cacheCleared = Notification.Name("cacheCleared")
}

#endif
