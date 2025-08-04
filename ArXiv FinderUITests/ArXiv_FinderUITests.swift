//
//  ArXiv_AppUITests.swift
//  ArXiv AppUITests
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import XCTest

/// Suite de pruebas de interfaz de usuario para la aplicación ArXiv Finder
/// Utiliza XCTest para automatizar interacciones con la UI y validar comportamientos
/// Las pruebas UI simulan acciones del usuario como toques, deslizamientos y navegación
final class ArXiv_FinderUITests: XCTestCase {

    /// Método de configuración que se ejecuta antes de cada prueba individual
    /// Establece el estado inicial necesario para las pruebas de UI
    override func setUpWithError() throws {
        // Código de configuración aquí. Este método se llama antes de la invocación de cada método de prueba en la clase.

        // En las pruebas de UI generalmente es mejor detenerse inmediatamente cuando ocurre un fallo
        // Esto evita que errores cascada enmascaren el problema real
        continueAfterFailure = false

        // En las pruebas de UI es importante establecer el estado inicial - como la orientación de la interfaz -
        // requerido para las pruebas antes de que se ejecuten. El método setUp es un buen lugar para hacer esto.
    }

    /// Método de limpieza que se ejecuta después de cada prueba individual
    /// Usado para resetear estados o liberar recursos utilizados durante la prueba
    override func tearDownWithError() throws {
        // Código de limpieza aquí. Este método se llama después de la invocación de cada método de prueba en la clase.
    }

    /// Prueba de ejemplo que demuestra cómo lanzar y probar la aplicación
    /// @MainActor asegura que la prueba se ejecute en el hilo principal (requerido para UI)
    @MainActor
    func testExample() throws {
        // Las pruebas de UI deben lanzar la aplicación que están probando
        let app = XCUIApplication()
        app.launch()

        // Usa XCTAssert y funciones relacionadas para verificar que las pruebas produzcan los resultados correctos
        // Ejemplo: XCTAssertTrue(app.staticTexts["Hello World!!!"].exists)
        // TODO: Implementar pruebas específicas para la funcionalidad de ArXiv
    }

    /// Prueba de rendimiento que mide el tiempo de lanzamiento de la aplicación
    /// Útil para detectar regresiones de rendimiento en el startup de la app
    @MainActor
    func testLaunchPerformance() throws {
        // Esto mide cuánto tiempo tarda en lanzarse la aplicación
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    /// Prueba básica para verificar que la vista principal de la aplicación se carga correctamente
    func testMainViewLoads() {
        let app = XCUIApplication()
        app.launch()

        // Verifica que la vista principal esté visible
        XCTAssertTrue(app.otherElements["MainView"].exists, "La vista principal no se cargó correctamente.")
    }
}
