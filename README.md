# ArXiv App

Una aplicación multiplataforma (iOS y macOS) para explorar y gestionar artículos científicos de ArXiv.

## 📋 Descripción

ArXiv App permite a los usuarios buscar, explorar y guardar artículos científicos de ArXiv con una interfaz nativa y moderna. La aplicación ofrece funcionalidades de búsqueda, organización por categorías, y almacenamiento local para acceso offline.

## ✨ Características

- **Multiplataforma**: Funciona en iOS y macOS con UI adaptativa
- **Búsqueda avanzada**: Busca artículos por título, autor, palabras clave o ID
- **Categorías**: Organiza artículos por Computer Science, Mathematics, y más
- **Almacenamiento local**: Guarda artículos para acceso offline con SwiftData
- **Interface nativa**: Diseño optimizado para cada plataforma
- **Notificaciones**: Alertas para nuevos artículos (macOS)

## 🛠 Tecnologías Utilizadas

- **SwiftUI**: Framework de UI moderno y declarativo
- **SwiftData**: Persistencia de datos moderna
- **URLSession**: Comunicación con la API de ArXiv
- **XML Parser**: Parser personalizado para respuestas de ArXiv
- **Async/Await**: Concurrencia moderna de Swift

## 📱 Arquitectura

El proyecto sigue el patrón **Model-View-Controller (MVC)**:

### Models
- `ArXivPaper`: Modelo de datos para artículos científicos

### Views
- `MainView`: Vista principal con navegación
- `SidebarView`: Barra lateral para macOS
- `PapersListView`: Lista de artículos adaptativa
- `PaperDetailView`: Vista detallada de artículos
- `SettingsView`: Configuración de la aplicación

### Controllers
- `ArXivController`: Lógica de negocio y gestión de estado

### Services
- `ArXivService`: Comunicación con la API de ArXiv
- `ArXivSimpleParser`: Parser XML personalizado

## 📚 Documentación Completa

Para información detallada sobre el proyecto, consulta nuestra documentación completa:

### 📋 Documentación Principal
- [📖 Índice de Documentación](DOCUMENTATION.md) - Navegación completa de la documentación
- [🏗️ Arquitectura MVC](README_MVC.md) - Detalles de la arquitectura implementada
- [🔧 Arquitectura Técnica](docs/ARCHITECTURE.md) - Documentación técnica profunda
- [🌐 Guía de API](docs/API_GUIDE.md) - Integración con ArXiv API

### 🛠 Para Desarrolladores
- [💻 Guía de Desarrollo](docs/DEVELOPMENT.md) - Configuración y flujo de desarrollo
- [🤝 Guía de Contribución](docs/CONTRIBUTING.md) - Cómo contribuir al proyecto
- [📝 Registro de Cambios](docs/CHANGELOG.md) - Historial de versiones

### 👥 Para Usuarios
- [📱 Guía del Usuario](docs/USER_GUIDE.md) - Cómo usar la aplicación

## 🚀 Instalación

### Requisitos

- macOS 14.0+ o iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

### Pasos de instalación

1. **Clonar el repositorio**:
   ```bash
   git clone <URL_DEL_REPOSITORIO>
   cd "ArXiv App"
   ```

2. **Abrir el proyecto**:
   ```bash
   open "ArXiv App.xcodeproj"
   ```

3. **Configurar el proyecto**:
   - Selecciona tu equipo de desarrollo en la configuración del proyecto
   - Ajusta el Bundle Identifier si es necesario

4. **Ejecutar la aplicación**:
   - Selecciona el simulador o dispositivo deseado
   - Presiona `Cmd + R` para compilar y ejecutar

## 📖 Uso

### Navegación Principal

- **iOS**: Navegación con stack para una experiencia móvil fluida
- **macOS**: Split view con sidebar para una experiencia de escritorio completa

### Búsqueda de Artículos

1. Usa la barra de búsqueda para encontrar artículos por:
   - Título
   - Autor
   - Palabras clave
   - ID de ArXiv

2. Filtra por categorías:
   - Computer Science
   - Mathematics
   - Physics
   - Y más...

### Gestión de Artículos

- **Guardar**: Los artículos se guardan automáticamente para acceso offline
- **Favoritos**: Marca artículos importantes
- **Compartir**: Comparte artículos con otros usuarios

## 🔧 Configuración

### Ajustes de la Aplicación

- **Categorías predeterminadas**: Configura las categorías que más te interesan
- **Notificaciones**: Activa alertas para nuevos artículos
- **Sincronización**: Configura la frecuencia de actualización

## 📁 Estructura del Proyecto

```
ArXiv App/
├── ArXiv_AppApp.swift          # Punto de entrada principal
├── Models/
│   └── ArXivPaper.swift        # Modelo de datos
├── Views/
│   ├── MainView.swift          # Vista principal
│   ├── SidebarView.swift       # Barra lateral (macOS)
│   ├── PapersListView.swift    # Lista de artículos
│   ├── PaperDetailView.swift   # Detalle de artículo
│   └── SettingsView.swift      # Configuración
├── Controllers/
│   └── ArXivController.swift   # Lógica de negocio
├── Services/
│   ├── ArXivService.swift      # API de ArXiv
│   └── ArXivSimpleParser.swift # Parser XML
└── Assets.xcassets/            # Recursos gráficos
```

## 🧪 Testing

El proyecto incluye pruebas unitarias y de UI:

```bash
# Ejecutar todas las pruebas
Cmd + U

# Ejecutar pruebas específicas
Cmd + Control + U
```

## 📝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 👨‍💻 Autor

**Julián Hinojosa Gil**

## 🔗 Enlaces Útiles

- [ArXiv API Documentation](https://arxiv.org/help/api)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
