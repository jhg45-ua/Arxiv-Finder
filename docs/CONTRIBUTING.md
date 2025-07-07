# Guía de Contribución - ArXiv App

## 🤝 Bienvenido a la Comunidad

¡Gracias por tu interés en contribuir a ArXiv App! Este proyecto es open source y valoramos todas las contribuciones, desde reportes de bugs hasta nuevas funcionalidades.

## 🎯 Tipos de Contribuciones

### 🐛 Reportes de Bugs
- Problemas de funcionamiento
- Errores en la UI
- Comportamientos inesperados
- Problemas de rendimiento

### ✨ Nuevas Funcionalidades
- Mejoras en la búsqueda
- Nuevas vistas y layouts
- Integración con otros servicios
- Funcionalidades de productividad

### 📝 Documentación
- Correcciones en la documentación
- Nuevas guías y tutoriales
- Traducción a otros idiomas
- Ejemplos de código

### 🎨 Diseño y UX
- Mejoras en la interfaz
- Iconos y recursos gráficos
- Experiencia de usuario
- Accesibilidad

## 🚀 Cómo Contribuir

### 1. Preparación
```bash
# Fork el repositorio
git clone https://github.com/tu-usuario/arxiv-app.git
cd arxiv-app

# Crear rama para tu contribución
git checkout -b feature/nueva-funcionalidad
```

### 2. Configuración del Entorno
- Instala Xcode 15.0+
- Configura tu equipo de desarrollo
- Ejecuta tests para verificar que todo funciona

### 3. Desarrollo
- Sigue las guías de estilo del proyecto
- Escribe tests para tu código
- Documenta los cambios
- Verifica compatibilidad multiplataforma

### 4. Commit y Push
```bash
# Commits semánticos
git add .
git commit -m "feat: agregar funcionalidad de búsqueda avanzada"
git push origin feature/nueva-funcionalidad
```

### 5. Pull Request
- Crea un PR con descripción detallada
- Incluye screenshots si es relevante
- Referencia issues relacionados
- Espera revisión del equipo

## 📋 Guías de Estilo

### Código Swift
```swift
// Usar PascalCase para tipos
struct ArXivPaper {
    // Usar camelCase para propiedades
    var paperTitle: String
    var authorNames: [String]
    
    // Documentar funciones públicas
    /// Busca papers por categoría
    /// - Parameter category: Categoría de ArXiv
    /// - Returns: Array de papers encontrados
    func searchByCategory(_ category: String) -> [ArXivPaper] {
        // Implementación
    }
}
```

### SwiftUI
```swift
// Extraer vistas complejas en componentes
struct PaperRowView: View {
    let paper: ArXivPaper
    
    var body: some View {
        HStack {
            // Contenido de la vista
        }
        .accessibilityLabel("Paper: \(paper.title)")
    }
}
```

### Commits Semánticos
```bash
# Tipos de commits
feat: nueva funcionalidad
fix: corrección de bug
docs: cambios en documentación
style: formateo de código
refactor: refactorización
test: agregar tests
chore: tareas de mantenimiento

# Ejemplos
feat: agregar filtros por fecha
fix: corregir error de parsing XML
docs: actualizar README con nuevas funcionalidades
```

## 🧪 Testing

### Tests Unitarios
```swift
import XCTest
@testable import ArXiv_App

final class ArXivServiceTests: XCTestCase {
    func testSearchPapers() async throws {
        // Arrange
        let service = ArXivService.shared
        
        // Act
        let papers = try await service.searchPapers(query: "machine learning")
        
        // Assert
        XCTAssertFalse(papers.isEmpty)
        XCTAssertTrue(papers.allSatisfy { !$0.title.isEmpty })
    }
}
```

### Tests de UI
```swift
import XCTest

final class ArXivAppUITests: XCTestCase {
    func testSearchFlow() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Tocar barra de búsqueda
        app.searchFields.firstMatch.tap()
        
        // Escribir query
        app.typeText("quantum computing")
        
        // Buscar
        app.keyboards.buttons["Search"].tap()
        
        // Verificar resultados
        XCTAssertTrue(app.tables.cells.count > 0)
    }
}
```

## 🏗️ Arquitectura y Patrones

### Principios a Seguir
1. **Single Responsibility**: Cada clase/método una responsabilidad
2. **Open/Closed**: Abierto para extensión, cerrado para modificación
3. **Dependency Injection**: Inyectar dependencias
4. **Testability**: Código fácil de testear

### Patrón MVC
```swift
// Model: Solo datos y lógica de dominio
@Model
final class ArXivPaper {
    var id: String
    var title: String
    // Sin lógica de UI
}

// View: Solo presentación
struct PaperListView: View {
    @StateObject private var controller = ArXivController()
    
    var body: some View {
        // Solo UI, sin lógica de negocio
    }
}

// Controller: Lógica de negocio
@MainActor
final class ArXivController: ObservableObject {
    @Published var papers: [ArXivPaper] = []
    
    func loadPapers() async {
        // Lógica de negocio
    }
}
```

## 🔍 Proceso de Revisión

### Checklist para PRs
- [ ] Código compila sin warnings
- [ ] Tests pasan en iOS y macOS
- [ ] Documentación actualizada
- [ ] Screenshots incluidos (si aplica)
- [ ] Cambios probados manualmente
- [ ] Código sigue las guías de estilo

### Criterios de Aceptación
1. **Funcionalidad**: Hace lo que promete
2. **Calidad**: Código limpio y mantenible
3. **Tests**: Cobertura adecuada
4. **Documentación**: Cambios documentados
5. **Compatibilidad**: Funciona en ambas plataformas

## 🐛 Reportar Bugs

### Información Necesaria
```markdown
**Descripción del Bug**
Descripción clara del problema

**Pasos para Reproducir**
1. Ir a '...'
2. Hacer click en '...'
3. Observar error

**Comportamiento Esperado**
Qué esperabas que pasara

**Comportamiento Actual**
Qué pasó realmente

**Screenshots**
Si aplica, agregar screenshots

**Entorno**
- iOS/macOS version
- Versión de la app
- Modelo de dispositivo

**Información Adicional**
Contexto adicional del problema
```

## 💡 Solicitar Funcionalidades

### Template para Feature Requests
```markdown
**Funcionalidad Deseada**
Descripción clara de la funcionalidad

**Problema que Resuelve**
¿Qué problema actual resuelve?

**Solución Propuesta**
Describe la solución que te gustaría

**Alternativas Consideradas**
Otras soluciones que consideraste

**Contexto Adicional**
Screenshots, mockups, etc.
```

## 🏆 Reconocimientos

### Contribuidores
Todos los contribuidores son reconocidos en:
- README del proyecto
- Página de créditos en la app
- Releases notes

### Tipos de Contribución
- 🐛 Bug fixes
- ✨ New features
- 📝 Documentation
- 🎨 Design
- 🌐 Translation
- 📊 Testing

## 📚 Recursos Adicionales

### Documentación
- [README_MVC.md](../README_MVC.md) - Arquitectura MVC
- [DEVELOPMENT.md](DEVELOPMENT.md) - Guía de desarrollo
- [ARCHITECTURE.md](ARCHITECTURE.md) - Arquitectura técnica

### Herramientas
- [SwiftLint](https://github.com/realm/SwiftLint) - Linting
- [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) - Formateo
- [Xcode](https://developer.apple.com/xcode/) - IDE

### Comunidad
- GitHub Discussions
- Issues del proyecto
- Pull Requests

## 🤔 Preguntas Frecuentes

### ¿Cómo empiezo?
1. Revisa los issues marcados como "good first issue"
2. Familiarízate con la arquitectura del proyecto
3. Configura tu entorno de desarrollo
4. Comienza con pequeñas contribuciones

### ¿Qué puedo contribuir sin ser programador?
- Reportar bugs
- Mejorar documentación
- Traducir la app
- Mejorar UX/UI
- Testear nuevas funcionalidades

### ¿Cuánto tiempo toma la revisión?
- Bugs críticos: 24-48 horas
- Funcionalidades: 1-2 semanas
- Documentación: Pocos días

## 📞 Contacto

### Equipo de Desarrollo
- **Maintainer**: Julián Hinojosa Gil
- **Email**: julian@arxivapp.com
- **GitHub**: [@julianhinojosagil](https://github.com/julianhinojosagil)

### Canales de Comunicación
- **GitHub Issues**: Para bugs y features
- **GitHub Discussions**: Para discusiones generales
- **Email**: Para temas sensibles

---

*¡Esperamos tus contribuciones! Juntos podemos hacer que ArXiv App sea aún mejor.*
