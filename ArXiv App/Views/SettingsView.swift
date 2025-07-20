//
//  SettingsView.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 3/7/25.
//

import SwiftUI
import UserNotifications
#if os(macOS)
import AppKit
#endif

/// Simplified settings view for the ArXiv app
/// Provides essential options with immediate application of changes
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
                    Label("Interface", systemImage: "paintbrush")
                }
            
            aboutSettingsView
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 600, height: 500)
        .alert("Connection Result", isPresented: $showingConnectionAlert) {
            Button("OK") { }
        } message: {
            Text(connectionTestResult)
        }
        .alert("Reset Settings", isPresented: $showingResetAlert) {
            Button("Reset", role: .destructive) {
                resetSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to reset all settings?")
        }
    }
    
    // MARK: - General Settings View
    private var generalSettingsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("General Settings")
                .font(.title2)
                .fontWeight(.bold)
            
            Divider()
            
            // Content settings
            GroupBox("Content") {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Maximum papers:")
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
                        Text("Default category:")
                        Spacer()
                        Picker("Category", selection: $defaultCategory) {
                            Text("Latest").tag("latest")
                            Text("Computer Science").tag("cs")
                            Text("Mathematics").tag("math")
                            Text("Physics").tag("physics")
                            Text("Quantitative Biology").tag("q-bio")
                            Text("Quantitative Finance").tag("q-fin")
                            Text("Statistics").tag("stat")
                            Text("Electrical Engineering").tag("eess")
                            Text("Economics").tag("econ")
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 200)
                        .onChange(of: defaultCategory) { _, _ in
                            notifySettingsChanged()
                        }
                    }
                }
                .padding(.vertical, 6)
            }
            
            // Update settings
            GroupBox("Update") {
                VStack(alignment: .leading, spacing: 10) {
                    Toggle("Automatic update", isOn: $autoRefresh)
                        .onChange(of: autoRefresh) { _, _ in
                            notifySettingsChanged()
                        }
                    
                    if autoRefresh {
                        HStack {
                            Text("Interval:")
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
            
            // Notification settings
            GroupBox("Notifications") {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Show notifications", isOn: $showNotifications)
                        .onChange(of: showNotifications) { _, newValue in
                            if newValue {
                                requestNotificationPermission()
                            }
                        }
                    
                    if showNotifications {
                        Button("Test Notification") {
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
            Text("Interface Settings")
                .font(.title2)
                .fontWeight(.bold)
            
            Divider()
            
            // View settings
            GroupBox("Visualization") {
                VStack(alignment: .leading, spacing: 10) {
                    Toggle("Compact mode", isOn: $compactMode)
                        .onChange(of: compactMode) { _, _ in
                            notifySettingsChanged()
                        }
                    
                    Toggle("Show preview", isOn: $showPreview)
                        .onChange(of: showPreview) { _, _ in
                            notifySettingsChanged()
                        }
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Font size:")
                                .fontWeight(.medium)
                            Spacer()
                        }
                        
                        VStack(spacing: 10) {
                            // Current value label with preview
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
                            
                            // Slider with labels and improved style - MORE WIDE
                            VStack(spacing: 6) {
                                HStack {
                                    Text("Small")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("Large")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                Slider(value: $fontSize, in: 10...20, step: 1) {
                                    Text("Font size")
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
            
            // Preview
            GroupBox("Preview") {
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
            Text("About ArXiv App")
                .font(.title2)
                .fontWeight(.bold)
            
            Divider()
            
            // Application information
            GroupBox("Information") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Version:")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Developer:")
                        Spacer()
                        Text("Julián Hinojosa Gil")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 6)
            }
            
            // Connection test
            GroupBox("Connection") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Status:")
                        Spacer()
                        Text("Connected")
                            .foregroundColor(.green)
                    }
                    
                    Button("Test Connection") {
                        testConnection()
                    }
                    .disabled(isTestingConnection)
                    .buttonStyle(.bordered)
                }
                .padding(.vertical, 6)
            }
            
            // Useful links
            GroupBox("Links") {
                VStack(alignment: .leading, spacing: 6) {
                    Button("ArXiv website") {
                        openURL("https://arxiv.org")
                    }
                    .buttonStyle(.link)
                    
                    Button("API documentation") {
                        openURL("https://arxiv.org/help/api")
                    }
                    .buttonStyle(.link)
                }
                .padding(.vertical, 6)
            }
            
            // Actions
            GroupBox("Actions") {
                Button("Reset Settings") {
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
    
    /// Notify changes in the configuration to the controller
    private func notifySettingsChanged() {
        NotificationCenter.default.post(
            name: .settingsChanged,
            object: nil
        )
    }
    
    /// Request notification permissions
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if !granted {
                    self.showNotifications = false
                }
            }
        }
    }
    
    /// Send a test notification
    private func testNotification() {
        let content = UNMutableNotificationContent()
        content.title = "ArXiv App - Prueba"
        content.body = "The notifications are working correctly."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "test-notification",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error)")
            }
        }
    }
    
    /// Test the connection with ArXiv
    private func testConnection() {
        isTestingConnection = true
        
        Task {
            do {
                let url = URL(string: "https://export.arxiv.org/api/query?search_query=all:test&start=0&max_results=1")!
                let (_, response) = try await URLSession.shared.data(from: url)
                
                DispatchQueue.main.async {
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            self.connectionTestResult = "✅ Successful connection"
                        } else {
                            self.connectionTestResult = "❌ HTTP Error: \(httpResponse.statusCode)"
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
    
    /// Open a URL in the browser
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }
    
    /// Reset all settings to their default values
    private func resetSettings() {
        refreshInterval = 30
        maxPapers = 10
        defaultCategory = "latest"
        autoRefresh = false
        showNotifications = true
        compactMode = false
        showPreview = true
        fontSize = 14.0
        
        // Notify changes
        notifySettingsChanged()
    }
}

#endif
