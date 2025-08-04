//
//  ArXiv_AppUITestsLaunchTests.swift
//  ArXiv AppUITests
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import XCTest

/// Suite específica de pruebas para el lanzamiento de la aplicación ArXiv Finder
/// Se enfoca en validar que la aplicación se inicie correctamente y capture evidencia visual
/// Estas pruebas son especialmente útiles para detectar problemas críticos de startup
final class ArXiv_FinderUITestsLaunchTests: XCTestCase {

    /// Indica que estas pruebas deben ejecutarse para cada configuración de UI objetivo
    /// Esto incluye diferentes orientaciones, tamaños de pantalla, y configuraciones de accesibilidad
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    /// Configuración inicial para cada prueba de lanzamiento
    /// Establece parámetros básicos para el comportamiento de las pruebas
    override func setUpWithError() throws {
        // No continuar después de fallos para obtener diagnósticos más claros
        continueAfterFailure = false
    }

    /// Prueba principal de lanzamiento que verifica que la app se inicia sin errores
    /// Captura una captura de pantalla como evidencia del estado inicial de la aplicación
    /// @MainActor garantiza que las operaciones de UI se ejecuten en el hilo principal
    @MainActor
    func testLaunch() throws {
        // Crea una instancia de la aplicación para testing
        let app = XCUIApplication()
        // Inicia la aplicación en modo de prueba
        app.launch()

        // Inserta pasos aquí para realizar después del lanzamiento de la app pero antes de tomar la captura de pantalla,
        // como iniciar sesión en una cuenta de prueba o navegar a algún lugar en la app
        // TODO: Agregar validaciones específicas del estado inicial de ArXiv Finder

        // Captura una captura de pantalla de la pantalla de lanzamiento para evidencia
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen" // Nombre descriptivo para identificar la captura
        attachment.lifetime = .keepAlways // Mantener la captura siempre, incluso en pruebas exitosas
        add(attachment) // Adjunta la captura al reporte de pruebas
    }
}
