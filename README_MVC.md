# ArXiv App - Arquitectura MVC

## Estructura del Proyecto

La aplicación ArXiv App ha sido reorganizada siguiendo el patrón de arquitectura **Model-View-Controller (MVC)** para mejorar la separación de responsabilidades, mantenibilidad y escalabilidad del código.

### 📁 Estructura de Directorios

```
ArXiv App/
├── Models/                 # Modelos de datos (M en MVC)
│   └── ArXivPaper.swift   # Modelo principal de los papers
├── Views/                  # Vistas de la interfaz (V en MVC)
│   ├── MainView.swift     # Vista principal de la aplicación
│   ├── ArXivPaperRow.swift # Vista de fila para mostrar papers
│   ├── SidebarView.swift  # Vista de barra lateral (macOS)
│   ├── PapersListView.swift # Vista de lista de papers
│   ├── PaperDetailView.swift # Vista de detalle de un paper
│   └── ContentView_Legacy.swift # Archivo original (para referencia)
├── Controllers/            # Controladores lógica de negocio (C en MVC)
│   └── ArXivController.swift # Controlador principal
├── Services/               # Servicios auxiliares
│   ├── ArXivService.swift # Servicio de API de ArXiv
│   └── ArXivSimpleParser.swift # Parser XML
└── ArXiv_AppApp.swift     # Punto de entrada de la aplicación
```

## 🏗️ Componentes de la Arquitectura MVC

### Model (Modelos)
**Ubicación:** `Models/`
- **ArXivPaper.swift**: Define la estructura de datos de un paper científico
- Responsabilidades:
  - Estructura de datos
  - Validación de datos
  - Persistencia con SwiftData

### View (Vistas)
**Ubicación:** `Views/`
- **MainView.swift**: Vista principal que coordina la interfaz
- **ArXivPaperRow.swift**: Vista individual de cada paper en la lista
- **SidebarView.swift**: Navegación lateral para macOS
- **PapersListView.swift**: Lista de papers con estados de carga y error
- **PaperDetailView.swift**: Vista detallada de un paper seleccionado

Responsabilidades de las vistas:
- Presentación de datos
- Interacción del usuario
- Adaptación multiplataforma (iOS/macOS)

### Controller (Controladores)
**Ubicación:** `Controllers/`
- **ArXivController.swift**: Controlador principal que maneja la lógica de negocio

Responsabilidades del controlador:
- Gestión del estado de la aplicación
- Coordinación entre modelos y vistas
- Lógica de negocio (cargar papers, cambiar categorías)
- Manejo de errores y estados de carga

### Services (Servicios)
**Ubicación:** `Services/`
- **ArXivService.swift**: Servicio para comunicación con la API de ArXiv
- **ArXivSimpleParser.swift**: Parser XML para procesar respuestas de la API

## 🔄 Flujo de Datos en MVC

1. **Usuario interactúa** con la Vista (View)
2. **Vista notifica** al Controlador (Controller) sobre la acción
3. **Controlador procesa** la lógica de negocio y usa Services
4. **Controlador actualiza** el Modelo (Model) si es necesario
5. **Modelo notifica** cambios al Controlador (via @Published)
6. **Vista se actualiza** automáticamente al observar cambios del Controlador

## 🎯 Ventajas de esta Arquitectura

### ✅ Separación de Responsabilidades
- Cada componente tiene una responsabilidad específica y bien definida
- Facilita el mantenimiento y debugging

### ✅ Testabilidad
- Los controladores pueden ser testeados independientemente
- Los servicios son fáciles de mockear para testing

### ✅ Escalabilidad
- Nuevas funcionalidades se pueden agregar sin afectar componentes existentes
- Fácil agregar nuevas vistas o controladores

### ✅ Reutilización
- Las vistas son componentes reutilizables
- Los servicios pueden ser compartidos entre diferentes controladores

## 🔧 Uso del Controlador

El `ArXivController` es el núcleo de la lógica de negocio:

```swift
@StateObject private var controller = ArXivController()

// En la vista:
controller.filteredPapers  // Papers filtrados por categoría
controller.isLoading       // Estado de carga
controller.errorMessage    // Mensajes de error

// Acciones:
await controller.loadLatestPapers()
await controller.loadComputerSciencePapers()
controller.changeCategory(to: "cs")
```

## 📱 Adaptación Multiplataforma

La arquitectura MVC facilita la adaptación entre iOS y macOS:
- **Vistas**: Condicionalmente compiladas con `#if os(macOS)`
- **Controlador**: Lógica compartida entre plataformas
- **Modelos**: Completamente agnósticos a la plataforma

## 🚀 Próximos Pasos

1. **Testing**: Implementar tests unitarios para controladores y servicios
2. **Persistencia**: Mejorar el manejo de datos locales
3. **Favoritos**: Implementar funcionalidad de papers favoritos
4. **Búsqueda**: Agregar controlador de búsqueda personalizada
5. **Configuración**: Expandir opciones de configuración de usuario

Esta arquitectura MVC proporciona una base sólida para el crecimiento y mantenimiento futuro de la aplicación ArXiv App.
