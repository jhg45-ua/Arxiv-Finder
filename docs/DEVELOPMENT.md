# Guía de Desarrollo - ArXiv App

## 🚀 Configuración del Entorno de Desarrollo

### Requisitos del Sistema
- **macOS**: 14.0 (Sonoma) o superior
- **Xcode**: 15.0 o superior
- **Swift**: 5.9 o superior
- **iOS Simulator**: iOS 17.0+
- **Git**: Para control de versiones

### Instalación Inicial

1. **Clonar el repositorio**:
   ```bash
   git clone <URL_DEL_REPOSITORIO>
   cd "ArXiv App"
   ```

2. **Configurar Xcode**:
   ```bash
   open "ArXiv App.xcodeproj"
   ```

3. **Configurar el equipo de desarrollo**:
   - Selecciona tu Apple Developer Team
   - Configura el Bundle Identifier único
   - Habilita las capacidades necesarias

## 📝 Configuración del Proyecto

### Estructura de Desarrollo
```
ArXiv App/
├── 📁 Models/              # Modelos de datos
├── 📁 Views/               # Vistas SwiftUI
├── 📁 Controllers/         # Controladores MVC
├── 📁 Services/            # Servicios de red y utilidades
├── 📁 Resources/           # Recursos (Assets, Localización)
├── 📁 Tests/               # Tests unitarios
├── 📁 UITests/             # Tests de UI
└── 📁 Documentation/       # Documentación del proyecto
```

### Configuración de Build Settings

#### Debug Configuration
- **Optimization Level**: None (-Onone)
- **Swift Compilation Mode**: Incremental
- **Debug Information**: Yes
- **Testability**: Yes

#### Release Configuration
- **Optimization Level**: Optimize for Speed (-O)
- **Swift Compilation Mode**: Whole Module
- **Debug Information**: No
- **Testability**: No

## 🎯 Flujo de Desarrollo

### Branching Strategy
```
main
├── develop
│   ├── feature/nueva-funcionalidad
│   ├── bugfix/correccion-error
│   └── hotfix/parche-critico
└── release/v1.0.0
```

### Workflow Recomendado
1. **Crear rama desde develop**:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/nueva-funcionalidad
   ```

2. **Desarrollar y commitear**:
   ```bash
   git add .
   git commit -m "feat: agregar nueva funcionalidad"
   ```

3. **Probar localmente**:
   ```bash
   # Ejecutar tests
   cmd + U
   
   # Verificar en ambas plataformas
   # iOS Simulator
   # macOS target
   ```

4. **Crear Pull Request**:
   - Descripción detallada
   - Screenshots si aplica
   - Tests pasando
   - Revisión de código

## 🏗️ Arquitectura MVC en Desarrollo

### Creando Nuevos Modelos

```swift
// Models/NuevoModelo.swift
import Foundation
import SwiftData

@Model
final class NuevoModelo: @unchecked Sendable {
    var id: String
    var nombre: String
    var fechaCreacion: Date
    
    init(id: String, nombre: String) {
        self.id = id
        self.nombre = nombre
        self.fechaCreacion = Date()
    }
}
```

### Creando Nuevas Vistas

```swift
// Views/NuevaView.swift
import SwiftUI

struct NuevaView: View {
    @StateObject private var controller = ArXivController()
    
    var body: some View {
        NavigationStack {
            // Contenido de la vista
            VStack {
                // ...
            }
            .navigationTitle("Nueva Vista")
        }
    }
}
```

### Extendiendo Controladores

```swift
// Controllers/ArXivController.swift
extension ArXivController {
    @MainActor
    func nuevaFuncionalidad() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Lógica de negocio
            let resultado = try await servicio.obtenerDatos()
            // Actualizar estado
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

## 🔧 Herramientas de Desarrollo

### Debugging
- **Xcode Debugger**: Breakpoints y inspección
- **Console Logging**: `print()` y `os_log`
- **SwiftUI Inspector**: Inspección de vistas en tiempo real
- **Instruments**: Profiling de performance

### Code Quality
- **SwiftLint**: Linting de código Swift
- **SwiftFormat**: Formateo automático
- **SonarQube**: Análisis de calidad (opcional)

### Testing Tools
- **XCTest**: Framework de testing nativo
- **Quick/Nimble**: Framework de testing alternativo
- **Mockingbird**: Mocking framework

## 📱 Desarrollo Multiplataforma

### Compilación Condicional
```swift
#if os(iOS)
    // Código específico para iOS
    NavigationStack {
        ContentView()
    }
#elseif os(macOS)
    // Código específico para macOS
    NavigationSplitView {
        SidebarView()
    } content: {
        ContentView()
    } detail: {
        DetailView()
    }
#endif
```

### Adaptación de UI
```swift
struct AdaptiveView: View {
    var body: some View {
        VStack {
            // Contenido común
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Action") {
                    // Acción
                }
            }
        }
    }
}
```

## 🧪 Estrategias de Testing

### Unit Tests
```swift
// Tests/ArXivControllerTests.swift
@testable import ArXiv_App
import XCTest

final class ArXivControllerTests: XCTestCase {
    var controller: ArXivController!
    
    override func setUp() {
        super.setUp()
        controller = ArXivController()
    }
    
    func testLoadLatestPapers() async {
        // Arrange
        
        // Act
        await controller.loadLatestPapers()
        
        // Assert
        XCTAssertFalse(controller.latestPapers.isEmpty)
    }
}
```

### UI Tests
```swift
// UITests/ArXivAppUITests.swift
import XCTest

final class ArXivAppUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }
    
    func testMainNavigation() {
        // Test de navegación principal
        let sidebarButton = app.buttons["Sidebar"]
        sidebarButton.tap()
        
        let papersButton = app.buttons["Papers"]
        papersButton.tap()
        
        XCTAssertTrue(app.navigationBars["Papers"].exists)
    }
}
```

## 📊 Performance y Optimización

### Mejores Prácticas
1. **Lazy Loading**: Cargar contenido bajo demanda
2. **Image Caching**: Caché de imágenes
3. **Memory Management**: Gestión eficiente de memoria
4. **Network Optimization**: Optimización de requests

### Profiling
```swift
// Ejemplo de profiling
import os

let logger = Logger(subsystem: "com.app.arxiv", category: "performance")

func measurePerformance<T>(_ operation: () throws -> T) rethrows -> T {
    let startTime = CFAbsoluteTimeGetCurrent()
    let result = try operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    
    logger.info("Operation took \(timeElapsed) seconds")
    return result
}
```

## 🔍 Debugging Común

### Problemas Frecuentes

1. **SwiftData no persiste datos**:
   - Verificar configuración del ModelContainer
   - Revisar el esquema de datos
   - Confirmar que los modelos están marcados con `@Model`

2. **UI no se actualiza**:
   - Verificar `@Published` properties
   - Confirmar uso de `@MainActor`
   - Revisar binding de SwiftUI

3. **Errores de red**:
   - Verificar conectividad
   - Revisar configuración de URLSession
   - Confirmar manejo de errores

## 📋 Checklist de Desarrollo

### Antes de Commit
- [ ] Código compila sin warnings
- [ ] Tests unitarios pasan
- [ ] Tests de UI pasan
- [ ] Documentación actualizada
- [ ] Cambios probados en iOS y macOS

### Antes de Release
- [ ] Todos los tests pasan
- [ ] Performance verificada
- [ ] Documentación completa
- [ ] Changelog actualizado
- [ ] Build de release probado

## 🚀 Despliegue

### App Store Connect
1. **Archive Build**: Crear archive de release
2. **Upload**: Subir a App Store Connect
3. **TestFlight**: Probar con beta testers
4. **Review**: Enviar para revisión de Apple

### Distribución Interna
```bash
# Crear build para distribución
xcodebuild archive -scheme "ArXiv App" -configuration Release
```

---

*Esta guía se actualiza continuamente para reflejar las mejores prácticas de desarrollo.*
