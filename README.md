# ArXiv Finder

A multiplatform application (iOS and macOS) for exploring and managing scientific papers from ArXiv.

## 📋 Description

ArXiv Finder allows users to search, explore, and save scientific papers from ArXiv with a modern and native interface. The application offers search functionalities, organization by categories, and local storage for offline access.

## ✨ Features

- **Multiplatform**: Works on iOS and macOS with adaptive UI
- **Advanced search**: Search papers by title, author, keywords, or ID
- **Categories**: Organize papers by Computer Science, Mathematics, and more
- **Local storage**: Save papers for offline access with SwiftData
- **Native interface**: Design optimized for each platform
- **Notifications**: Alerts for new papers (macOS)

## 🛠 Technologies Used

- **SwiftUI**: Modern and declarative UI framework
- **SwiftData**: Modern data persistence
- **URLSession**: Communication with the ArXiv API
- **XML Parser**: Custom parser for ArXiv responses
- **Async/Await**: Modern Swift concurrency

## 📱 Architecture

The project follows the **Model-View-Controller (MVC)** pattern:

### Models
- `ArXivPaper`: Data model for scientific papers

### Views
- `MainView`: Main view with navigation
- `SidebarView`: Sidebar for macOS
- `PapersListView`: Adaptive paper list
- `PaperDetailView`: Detailed view of papers
- `SettingsView`: Application settings

### Controllers
- `ArXivController`: Business logic and state management

### Services
- `ArXivService`: Communication with the ArXiv API
- `ArXivSimpleParser`: Custom XML parser

## 📚 Documentation

For detailed information consult the integrated Xcode documentation:

- **MVC Architecture**: Check DocC documentation in Xcode for design and pattern details
- **ArXiv API**: Complete integration documentation available in DocC
- **Components**: Detailed documentation of each component available in Xcode Quick Help

To access documentation:
1. Open the project in Xcode
2. Go to `Product > Build Documentation` or press `Cmd + Shift + Control + D`
3. Explore the automatically generated documentation

## 🚀 Installation

### Requirements

- macOS 14.0+ or iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

### Installation Steps

1. **Clone the repository**:
   ```bash
   git clone <REPOSITORY_URL>
   cd "ArXiv Finder"
   ```

2. **Open the project**:
   ```bash
   open "ArXiv Finder.xcodeproj"
   ```

3. **Configure the project**:
   - Select your development team in project settings
   - Adjust Bundle Identifier if necessary

4. **Run the application**:
   - Select the desired simulator or device
   - Press `Cmd + R` to build and run

## 📖 Usage

### Main Navigation

- **iOS**: Stack navigation for a fluid mobile experience
- **macOS**: Split view with sidebar for a complete desktop experience

### Paper Search

1. Use the search bar to find papers by:
   - Title
   - Author
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
ArXiv Finder/
├── ArXiv_FinderApp.swift          # Punto de entrada principal
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
