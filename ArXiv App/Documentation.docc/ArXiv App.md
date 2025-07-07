# ArXiv App

Una aplicación SwiftUI para explorar y buscar artículos académicos del repositorio ArXiv.

@Metadata {
    @PageImage(purpose: icon, source: "app-icon")
    @PageColor(blue)
}

## Descripción General

La aplicación ArXiv proporciona una interfaz intuitiva para que investigadores y estudiantes descubran, exploren y lean artículos académicos del repositorio de preprints ArXiv. Construida con SwiftUI y siguiendo el patrón de arquitectura MVC, ofrece una experiencia de usuario limpia y responsiva optimizada para macOS.

Esta aplicación demuestra las mejores prácticas de desarrollo en SwiftUI, incluyendo:
- Arquitectura MVC bien estructurada
- Comunicación asíncrona con APIs externas
- Gestión eficiente del estado de la aplicación
- Interfaz de usuario adaptativa y accesible

## Características Principales

- **🔍 Búsqueda Inteligente**: Busca artículos por título, autor, palabras clave o categorías específicas
- **📚 Exploración por Categorías**: Navega por las diferentes disciplinas académicas de ArXiv
- **📄 Vista Detallada**: Visualiza información completa incluyendo resúmenes, autores, fechas y enlaces
- **💻 Interfaz Nativa**: Diseño SwiftUI optimizado para macOS con soporte completo para modo oscuro
- **⚡ Rendimiento Optimizado**: Carga asíncrona de datos y gestión eficiente de memoria

## Arquitectura de la Aplicación

La aplicación sigue el patrón **Modelo-Vista-Controlador (MVC)** para mantener una separación clara de responsabilidades:

### 🏗️ Componentes Principales

- **📊 Modelos**: Estructuras de datos que representan artículos de ArXiv y sus metadatos
- **🖥️ Vistas**: Componentes SwiftUI reutilizables para la interfaz de usuario
- **🎛️ Controladores**: Lógica de negocio y gestión del flujo de datos entre modelos y vistas
- **🔌 Servicios**: Comunicación con la API de ArXiv y análisis de datos XML

### 🔄 Flujo de Datos

1. **Usuario** interactúa con las **Vistas** SwiftUI
2. **Controlador** procesa las acciones del usuario
3. **Servicios** realizan peticiones a la API de ArXiv
4. **Modelos** se actualizan con los datos recibidos
5. **Vistas** se refrescan automáticamente mediante binding

## Requisitos del Sistema

- **macOS**: 12.0 o superior
- **Xcode**: 14.0 o superior
- **Swift**: 5.7 o superior
- **SwiftUI**: 4.0 o superior

## Primeros Pasos

Para comenzar con la aplicación ArXiv, explora los siguientes componentes fundamentales:

### 🎯 Componentes Clave

- ``ArXivPaper`` - El modelo de datos principal que representa un artículo académico con todos sus metadatos
- ``ArXivController`` - Controlador principal que gestiona el estado de la aplicación y coordina el flujo de datos
- ``ArXivService`` - Servicio especializado para comunicarse con la API REST de ArXiv
- ``MainView`` - El componente raíz de la interfaz de usuario que orquesta toda la experiencia

### 📚 Guía de Desarrollo

1. **Configura el Proyecto**: Clona el repositorio y abre el archivo `.xcodeproj`
2. **Explora los Modelos**: Comienza revisando ``ArXivPaper`` para entender la estructura de datos
3. **Revisa los Servicios**: Analiza ``ArXivService`` para comprender la comunicación con la API
4. **Examina las Vistas**: Estudia ``MainView`` y sus componentes relacionados
5. **Prueba la Aplicación**: Ejecuta el proyecto y experimenta con las diferentes funcionalidades

## Temas

### 📊 Modelos de Datos
- ``ArXivPaper`` - Representa un artículo académico con metadatos completos

### 🎛️ Controladores
- ``ArXivController`` - Controlador principal de la aplicación

### 🔌 Servicios y APIs
- ``ArXivService`` - Comunicación con la API de ArXiv
- ``ArXivSimpleParser`` - Análisis de respuestas XML de ArXiv

### 🖥️ Interfaz de Usuario
- ``MainView`` - Vista principal de la aplicación
- ``PapersListView`` - Lista de artículos con funcionalidad de búsqueda
- ``PaperDetailView`` - Vista detallada de un artículo específico
- ``ArXivPaperRow`` - Celda individual para mostrar información resumida
- ``SidebarView`` - Barra lateral para navegación y filtros
- ``SettingsView`` - Configuración de la aplicación

## Guías Detalladas

### 📋 Componentes Principales

Explora las guías detalladas de cada componente:

- <doc:ArXivPaper> - Modelo de datos fundamental con persistencia SwiftData
- <doc:ArXivController> - Controlador MVC con gestión de estado reactiva
- <doc:ArXivService> - Servicio de red con manejo robusto de errores
- <doc:ArXivSimpleParser> - Parser XML especializado para formato Atom
- <doc:MainView> - Vista principal con adaptación multiplataforma
- <doc:PapersListView> - Lista optimizada con búsqueda y filtros

## Guías Detalladas

### 📋 Componentes Principales

Explora las guías detalladas de cada componente:

- <doc:ArXivPaper> - Modelo de datos fundamental con persistencia SwiftData
- <doc:ArXivController> - Controlador MVC con gestión de estado reactiva
- <doc:ArXivService> - Servicio de red con manejo robusto de errores
- <doc:ArXivSimpleParser> - Parser XML especializado para formato Atom
- <doc:MainView> - Vista principal con adaptación multiplataforma
- <doc:PapersListView> - Lista optimizada con búsqueda y filtros

### 🏗️ Arquitectura y APIs

Documentación técnica completa:

- <doc:Architecture> - Arquitectura MVC detallada con patrones de diseño
- <doc:API-Guide> - Guía completa de integración con la API de ArXiv

### 🎯 Características Avanzadas

Cada componente está documentado con:
- **Patrones de diseño** utilizados
- **Mejores prácticas** implementadas
- **Ejemplos de código** completos
- **Consideraciones de rendimiento**
- **Características de accesibilidad**

## Ejemplo de Uso

```swift
// Crear una instancia del servicio ArXiv
let service = ArXivService()

// Buscar artículos relacionados con machine learning
service.searchPapers(query: "machine learning", maxResults: 10) { papers in
    // Procesar los artículos encontrados
    for paper in papers {
        print("Título: \(paper.title)")
        print("Autores: \(paper.authors.joined(separator: ", "))")
    }
}
```

## Contribuciones

Para contribuir al proyecto:

1. **Fork** el repositorio
2. **Crea** una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. **Commit** tus cambios (`git commit -am 'Añadir nueva funcionalidad'`)
4. **Push** a la rama (`git push origin feature/nueva-funcionalidad`)
5. **Crea** un Pull Request

## Recursos Adicionales

- [Documentación oficial de ArXiv API](https://arxiv.org/help/api)
- [Guía de SwiftUI](https://developer.apple.com/swiftui/)
- [Mejores prácticas de arquitectura MVC](https://developer.apple.com/documentation/swiftui/model-data)
