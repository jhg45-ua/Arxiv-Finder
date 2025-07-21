# MainView

The main view of the ArXiv application implementing the MVC pattern.

## Overview

``MainView`` is the central user interface component that acts as the main view in the MVC pattern. It provides an adaptive experience that works on both iOS and macOS, using native design best practices for each platform.

This view is designed following principles of:
- **Separation of responsibilities** in the MVC pattern
- **Multiplatform adaptability** with conditional code
- **Reactivity** through binding with ``ArXivController``
- **Accessibility** with full support for assistive technologies

## View Architecture

### 🎭 MVC Pattern Implementation

The view strictly implements the MVC pattern:

```swift
/// MVC Architecture:
/// - View: This view handles only presentation
/// - Controller: ArXivController manages all business logic
/// - Model: ArXivPaper represents paper data
struct MainView: View {
    /// Controller that handles business logic
    @StateObject private var controller = ArXivController()
    
    /// Selected paper in macOS for NavigationSplitView
    @State private var selectedPaper: ArXivPaper?
}
```

### 📱 Multiplatform Adaptation

The view automatically adapts to each platform:

```swift
var body: some View {
    #if os(macOS)
    macOSInterface
    #else
    iOSInterface
    #endif
}
```

## macOS Interface

### 🖥️ NavigationSplitView

For macOS, it uses a three-column design:

```swift
/// Interface optimized for macOS with NavigationSplitView
private var macOSInterface: some View {
    NavigationSplitView {
        // Sidebar with categories
        SidebarView(controller: controller)
    } content: {
        // Paper list
        PapersListView(controller: controller, selectedPaper: $selectedPaper)
    } detail: {
        // Detailed view of selected paper
        if let paper = selectedPaper {
            PaperDetailView(paper: paper)
        } else {
            placeholderView
        }
    }
}
```

### 🎨 macOS Features

- **Three-column navigation**: Sidebar, List, Detail
- **Persistent selection**: Maintains selected paper
- **Window optimization**: Takes advantage of large screen space
- **Native controls**: Uses macOS-specific controls

### 📚 Supported Categories

The application supports the following academic categories:

```swift
/// Categories available in the sidebar
private let availableCategories = [
    "latest": "Latest Papers",
    "cs": "Computer Science",
    "math": "Mathematics", 
    "physics": "Physics",
    "q-bio": "Quantitative Biology",
    "q-fin": "Quantitative Finance",
    "stat": "Statistics",
    "eess": "Electrical Engineering",
    "econ": "Economics"
]
```

**Category functionalities:**
- **Navigation**: Each category has its own button in the sidebar
- **Independent state**: Each category maintains its own loading state
- **Persistent data**: Papers are cached by category
- **Configuration**: User can select a default category

## iOS Interface

### 📱 NavigationStack

For iOS, it uses hierarchical navigation:

```swift
/// Interface optimized for iOS with NavigationStack
private var iOSInterface: some View {
    NavigationStack {
        PapersListView(controller: controller, selectedPaper: .constant(nil))
            .navigationTitle("ArXiv Papers")
            .navigationBarTitleDisplayMode(.large)
    }
}
```

### 🎯 iOS Features

- **Hierarchical navigation**: Traditional navigation stack
- **Large titles**: Takes advantage of available space
- **Native gestures**: Swipe back and other iOS gestures
- **Size adaptation**: Responsive design for different sizes

## Integrated Components

### 🔗 Controller Integration

The view integrates seamlessly with the controller:

```swift
/// Reactive binding with the controller
@StateObject private var controller = ArXivController()

/// Automatic update when data changes
var body: some View {
    // The view automatically updates when
    // the controller's @Published properties change
    List(controller.latestPapers) { paper in
        ArXivPaperRow(paper: paper)
    }
}
```

### 📊 State Management

```swift
/// View-specific local state
@State private var selectedPaper: ArXivPaper?
@State private var isShowingSettings = false
@State private var searchText = ""

/// Computed properties for derived state
private var filteredPapers: [ArXivPaper] {
    guard !searchText.isEmpty else { return controller.latestPapers }
    return controller.latestPapers.filter { 
        $0.title.localizedCaseInsensitiveContains(searchText) 
    }
}
```

## Accessibility Features

### ♿ Assistive Technology Support

```swift
/// Accessibility labels
.accessibilityLabel("ArXiv articles list")
.accessibilityHint("Swipe to see more articles")

/// Keyboard navigation
.focusable(true)
.onMoveCommand { direction in
    handleKeyboardNavigation(direction)
}
```

### 🔍 Dynamic Type Support

```swift
/// Text adapts to user's preferred size
Text(paper.title)
    .font(.headline)
    .lineLimit(nil)
    .fixedSize(horizontal: false, vertical: true)
```

## Performance Features

### 🚀 List Optimization

```swift
/// Optimized list with lazy loading
LazyVStack(spacing: 8) {
    ForEach(controller.latestPapers) { paper in
        ArXivPaperRow(paper: paper)
            .onAppear {
                // Load more data when nearing the end
                if paper == controller.latestPapers.last {
                    Task {
                        await controller.loadMorePapers()
                    }
                }
            }
    }
}
```

### 💾 Memory Management

```swift
/// Memory configuration for large lists
.onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
    controller.clearCache()
}
```

## Visual Customization

### 🎨 Theming

```swift
/// Light/dark theme support
@Environment(\.colorScheme) var colorScheme

private var backgroundColor: Color {
    colorScheme == .dark ? .black : .white
}

private var textColor: Color {
    colorScheme == .dark ? .white : .black
}
```

### 🖼️ Visual Resources

```swift
/// Use of graphic resources
Image(systemName: "doc.text.magnifyingglass")
    .foregroundColor(.accentColor)
    .imageScale(.large)
```

## Full Usage Example

```swift
/// Full implementation example
struct ContentView: View {
    var body: some View {
        MainView()
            .onAppear {
                // Initial setup
                setupAppearance()
            }
    }
    
    private func setupAppearance() {
        // Global appearance configuration
        UINavigationBar.appearance().prefersLargeTitles = true
    }
}
```

## View States

### 🔄 Loading States

```swift
/// Different view states
enum ViewState {
    case loading
    case loaded([ArXivPaper])
    case error(Error)
    case empty
}

@State private var viewState: ViewState = .loading

/// View that adapts to the current state
@ViewBuilder
private var contentView: some View {
    switch viewState {
    case .loading:
        ProgressView("Loading articles...")
    case .loaded(let papers):
        List(papers) { paper in
            ArXivPaperRow(paper: paper)
        }
    case .error(let error):
        ErrorView(error: error) {
            Task {
                await loadPapers()
            }
        }
    case .empty:
        EmptyStateView()
    }
}
```

## Advanced Navigation

### 🔗 Deep Linking

```swift
/// Deep linking support
.onOpenURL { url in
    if let paperID = extractPaperID(from: url) {
        navigateToPaper(id: paperID)
    }
}

/// Programmatic navigation
private func navigateToPaper(id: String) {
    if let paper = controller.findPaper(id: id) {
        selectedPaper = paper
    }
}
```

### 📱 Handoff

```swift
/// Handoff support between devices
.userActivity("com.arxivapp.viewpaper") { activity in
    if let paper = selectedPaper {
        activity.title = paper.title
        activity.userInfo = ["paperID": paper.id]
    }
}
```

## Best Practices

### ✅ Implemented Principles

1. **Separation of Responsibilities**: Only handles presentation
2. **Reactivity**: Automatically responds to data changes
3. **Adaptability**: Works on multiple platforms
4. **Accessibility**: Full support for all users

### 🔧 Advanced Configuration

```swift
/// Custom view configuration
struct MainViewConfig {
    let enablePullToRefresh: Bool = true
    let enableInfiniteScroll: Bool = true
    let cacheSize: Int = 100
    let animationDuration: Double = 0.3
}
```

## Related Resources

- ``ArXivController`` - Main application controller
- ``SidebarView`` - Navigation sidebar
- ``PapersListView`` - Article list
- ``PaperDetailView`` - Article detail view
- ``ArXivPaperRow`` - Individual article row 