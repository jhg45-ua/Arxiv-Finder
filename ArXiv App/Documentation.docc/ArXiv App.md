# ArXiv App

A SwiftUI application for exploring and searching academic papers from the ArXiv repository.

@Metadata {
    @PageColor(blue)
}

## Overview

The ArXiv application provides an intuitive interface for researchers and students to discover, explore, and read academic papers from the ArXiv preprint repository. Built with SwiftUI and following the MVC architectural pattern, it offers a clean and responsive user experience optimized for macOS.

This application demonstrates SwiftUI development best practices, including:
- Well-structured MVC architecture
- Asynchronous communication with external APIs
- Efficient application state management
- Adaptive and accessible user interface

## Key Features

- **🔍 Smart Search**: Search papers by title, author, keywords, or specific categories
- **📚 Category Exploration**: Browse through 8 main academic disciplines from ArXiv
- **⭐ Favorites Management**: Mark papers as favorites for quick access and later reading
- **📄 Detailed View**: View complete information including abstracts, authors, dates, and links
- **💾 Data Persistence**: Favorites are saved using SwiftData and persist between sessions
- **💻 Native Interface**: SwiftUI design optimized for macOS with full dark mode support
- **⚡ Optimized Performance**: Asynchronous data loading and efficient memory management

### 🏷️ Supported Academic Categories

The application provides access to the following ArXiv categories:

- **💻 Computer Science** (`cs`)
- **🔢 Mathematics** (`math`)
- **⚛️ Physics** (`physics`)
- **🧬 Quantitative Biology** (`q-bio`)
- **💰 Quantitative Finance** (`q-fin`)
- **📊 Statistics** (`stat`)
- **⚡ Electrical Engineering** (`eess`)
- **💼 Economics** (`econ`)

## Application Architecture

The application follows the **Model-View-Controller (MVC)** pattern to maintain clear separation of responsibilities:

### 🏗️ Main Components

- **📊 Models**: Data structures representing ArXiv papers and their metadata
- **🖥️ Views**: Reusable SwiftUI components for the user interface
- **🎛️ Controllers**: Business logic and data flow management between models and views
- **🔌 Services**: Communication with the ArXiv API and XML data parsing

### 🔄 Data Flow

1. **User** interacts with SwiftUI **Views**
2. **Controller** processes user actions
3. **Services** make requests to the ArXiv API
4. **Models** are updated with received data
5. **Views** automatically refresh through binding

## System Requirements

- **macOS**: 12.0 or later
- **Xcode**: 14.0 or later
- **Swift**: 5.7 or later
- **SwiftUI**: 4.0 or later

## Getting Started

To get started with the ArXiv application, explore the following fundamental components:

### 🎯 Key Components

- ``ArXivPaper`` - The main data model representing an academic paper with all its metadata
- ``ArXivController`` - Main controller managing application state and coordinating data flow
- ``ArXivService`` - Specialized service for communicating with the ArXiv REST API
- ``MainView`` - The root UI component that orchestrates the entire experience

### 📚 Development Guide

1. **Set up the Project**: Clone the repository and open the `.xcodeproj` file
2. **Explore Models**: Start by reviewing ``ArXivPaper`` to understand the data structure
3. **Review Services**: Analyze ``ArXivService`` to understand API communication
4. **Examine Views**: Study ``MainView`` and its related components
5. **Test the Application**: Run the project and experiment with different functionalities

## Topics

### 📊 Data Models
- ``ArXivPaper`` - Represents an academic paper with complete metadata

### 🎛️ Controllers
- ``ArXivController`` - Main application controller

### 🔌 Services and APIs
- ``ArXivService`` - Communication with the ArXiv API
- ``ArXivSimpleParser`` - Parsing of ArXiv XML responses

### 🖥️ User Interface
- ``MainView`` - Main application view
- ``PapersListView`` - Paper list with search functionality
- ``PaperDetailView`` - Detailed view of a specific paper
- ``SidebarView`` - Side navigation with categories and favorites
- ``ArXivPaperRow`` - Individual paper component with favorites button

### ⭐ Favorites Management
- [Favorites Functionality](Funcionalidad-de-Favoritos.md) - Complete documentation of favorites functionality
- **SwiftData Integration** - Favorites persistence using SwiftData
- **UI Integration** - Heart buttons in list and detail views
- **Navigation** - Dedicated "Favorites" section in navigation
- ``ArXivPaperRow`` - Individual cell for displaying summary information
- ``SidebarView`` - Sidebar for navigation and filters
- **SettingsView** - Application settings

## Detailed Guides

### 📋 Main Components

Explore the detailed guides for each component:

- <doc:ArXivPaper> - Fundamental data model with SwiftData persistence
- <doc:ArXivController> - MVC controller with reactive state management
- <doc:ArXivService> - Network service with robust error handling
- <doc:ArXivSimpleParser> - XML parser specialized for Atom format
- <doc:MainView> - Main view with multiplatform adaptation
- <doc:PapersListView> - Optimized list with search and filters

### 🏗️ Architecture and APIs

Complete technical documentation:

- <doc:Architecture> - Detailed MVC architecture with design patterns
- <doc:API-Guide> - Complete ArXiv API integration guide

### 🎯 Advanced Features

Each component is documented with:
- **Design patterns** used
- **Best practices** implemented
- **Complete code examples**
- **Performance considerations**
- **Accessibility features**

## Usage Example

```swift
// Create an ArXiv service instance
let service = ArXivService()

// Search for machine learning related papers
service.searchPapers(query: "machine learning", maxResults: 10) { papers in
    // Process found papers
    for paper in papers {
        print("Title: \(paper.title)")
        print("Authors: \(paper.authors.joined(separator: ", "))")
    }
}
```

## Contributing

To contribute to the project:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/new-feature`)
3. **Commit** your changes (`git commit -am 'Add new feature'`)
4. **Push** to the branch (`git push origin feature/new-feature`)
5. **Create** a Pull Request

## Additional Resources

- [Official ArXiv API Documentation](https://arxiv.org/help/api)
- [SwiftUI Guide](https://developer.apple.com/swiftui/)
- [MVC Architecture Best Practices](https://developer.apple.com/documentation/swiftui/model-data) 