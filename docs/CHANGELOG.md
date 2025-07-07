# Registro de Cambios - ArXiv App

Todos los cambios notables de este proyecto se documentan en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto se adhiere al [Semantic Versioning](https://semver.org/lang/es/).

## [No Publicado]

### Agregado
- Funcionalidad de favoritos (en desarrollo)
- Búsqueda avanzada con filtros
- Notificaciones push para iOS
- Soporte para múltiples idiomas

### Cambiado
- Mejoras en el rendimiento de la búsqueda
- UI optimizada para iPad
- Actualización de dependencias

### Corregido
- Corrección en el parsing de fechas
- Mejoras en el manejo de errores de red
- Correcciones en la UI para modo oscuro

## [1.0.0] - 2025-07-07

### Agregado
- **Arquitectura MVC**: Implementación completa del patrón Model-View-Controller
- **Multiplataforma**: Soporte para iOS 17.0+ y macOS 14.0+
- **Búsqueda de artículos**: Búsqueda por título, autor, palabras clave
- **Categorías**: Organización por Computer Science, Mathematics, Physics
- **Almacenamiento local**: Persistencia con SwiftData
- **Navegación adaptativa**: NavigationStack (iOS) y NavigationSplitView (macOS)
- **API de ArXiv**: Integración completa con la API pública
- **Parser XML**: Parser personalizado para respuestas de ArXiv
- **Estados de carga**: Indicadores de carga y manejo de errores
- **UI nativa**: Diseño adaptado para cada plataforma

### Funcionalidades Principales
- **MainView**: Vista principal con navegación
- **SidebarView**: Barra lateral para macOS
- **PapersListView**: Lista de artículos con estados
- **PaperDetailView**: Vista detallada de artículos
- **ArXivController**: Controlador principal con lógica de negocio
- **ArXivService**: Servicio de comunicación con API
- **ArXivPaper**: Modelo de datos con SwiftData

### Componentes Técnicos
- **Concurrencia**: Uso de async/await y @MainActor
- **Reactive UI**: @Published properties para actualizaciones automáticas
- **Error Handling**: Manejo robusto de errores de red y parsing
- **Networking**: URLSession con configuración optimizada
- **Data Persistence**: SwiftData para almacenamiento local

### Plataformas Soportadas
- **iOS**: 17.0+ con UI optimizada para móviles
- **macOS**: 14.0+ con UI de escritorio completa
- **iPadOS**: Soporte completo con adaptación de interfaz

---

## Tipos de Cambios

### Agregado
- Nuevas funcionalidades
- Nuevas APIs
- Nuevos archivos o recursos

### Cambiado
- Cambios en funcionalidades existentes
- Actualizaciones de dependencias
- Mejoras en el rendimiento

### Obsoleto
- Funcionalidades que serán removidas
- APIs deprecadas
- Warnings de depreciación

### Removido
- Funcionalidades eliminadas
- APIs removidas
- Archivos eliminados

### Corregido
- Correcciones de bugs
- Parches de seguridad
- Correcciones de documentación

### Seguridad
- Mejoras de seguridad
- Vulnerabilidades corregidas
- Actualizaciones de seguridad

---

## Versionado Semántico

Este proyecto sigue [Semantic Versioning](https://semver.org/lang/es/):

- **MAJOR**: Cambios incompatibles en la API
- **MINOR**: Nueva funcionalidad compatible con versiones anteriores
- **PATCH**: Correcciones de bugs compatibles

### Formato de Versiones
```
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]
```

### Ejemplos
- `1.0.0`: Release inicial
- `1.1.0`: Nueva funcionalidad
- `1.1.1`: Corrección de bug
- `2.0.0`: Cambio mayor incompatible
- `1.2.0-beta.1`: Versión beta
- `1.2.0+20250707`: Build específico

---

## Notas de Desarrollo

### Versión 1.0.0
Esta versión representa el primer release completo de ArXiv App con:

#### Arquitectura
- Implementación completa del patrón MVC
- Separación clara de responsabilidades
- Código mantenible y escalable

#### Funcionalidades Core
- Búsqueda y exploración de artículos científicos
- Categorización por campos de estudio
- Almacenamiento local para uso offline
- Sincronización con ArXiv

#### Calidad
- Cobertura de tests unitarios
- Tests de UI para flujos principales
- Documentación completa del proyecto
- Guías de desarrollo y contribución

#### Rendimiento
- Optimización de requests a la API
- Caché inteligente de respuestas
- UI responsiva en ambas plataformas
- Manejo eficiente de memoria

---

## Próximas Versiones

### v1.1.0 (Planificada)
- Funcionalidad de favoritos
- Búsqueda avanzada con filtros
- Mejoras en la UI
- Soporte para shortcuts de teclado

### v1.2.0 (Planificada)
- Notificaciones push
- Integración con servicios de terceros
- Exportación de artículos
- Configuración avanzada

### v2.0.0 (Futuro)
- Migración a arquitectura moderna
- Soporte para múltiples fuentes
- Funcionalidades colaborativas
- AI-powered recommendations

---

## Contribuciones

### Reconocimientos
- **Julián Hinojosa Gil**: Desarrollo principal y arquitectura
- **Comunidad**: Reportes de bugs y sugerencias
- **Beta Testers**: Pruebas y feedback

### Cómo Contribuir
Ver [CONTRIBUTING.md](CONTRIBUTING.md) para detalles sobre cómo contribuir al proyecto.

---

*Para más información sobre releases, visita [GitHub Releases](https://github.com/usuario/arxiv-app/releases)*
