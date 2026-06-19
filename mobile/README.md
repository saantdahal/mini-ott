# DSM TV - Mobile Application

A professional Flutter application for streaming content with clean architecture, multi-flavor support, and production-ready infrastructure.

## Project Overview

The DSM TV mobile application is built with modern Flutter best practices, utilizing clean architecture principles, dependency injection, and advanced state management. The project supports multiple deployment environments (dev and prod) with centralized configuration and code generation infrastructure.

## Table of Contents

- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Setup & Installation](#setup--installation)
- [Development](#development)
- [Build & Deployment](#build--deployment)
- [Key Features](#key-features)
- [Troubleshooting](#troubleshooting)

## Architecture

The application follows Clean Architecture with clear separation of concerns:

```
Presentation Layer (UI/Screens)
        ↓
Domain Layer (Use Cases/Entities)
        ↓
Data Layer (Repositories/Data Sources)
        ↓
Core/Shared Infrastructure
```

Core layers provide:

- Dependency injection with GetIt
- Error handling and exception mapping
- Service orchestration (tokens, storage, logging, session)
- Networking with Retrofit and Dio
- State management with Riverpod
- Theme and routing configuration

## Project Structure

```
lib/
├── app
│   ├── flavor
│   │   └── app_flavor.dart                 # Flavor configuration (dev/prod)
│   ├── routes
│   │   ├── app_router.dart                 # GoRouter configuration
│   │   └── router_configuration.dart       # Route metadata and constants
│   ├── theme
│   │   └── colors.dart                     # Centralized color palette and themes
│   └── app.dart                            # Root Material app widget
│
├── core
│   ├── constants
│   │   └── images.dart                     # Image asset constants
│   │
│   ├── di
│   │   └── di.dart                         # Dependency injection setup with GetIt
│   │
│   ├── error
│   │   ├── app_exception.dart              # Custom exception hierarchy
│   │   ├── error.dart                      # Error barrel export
│   │   └── failure.dart                    # Failure domain model
│   │
│   ├── network
│   │   ├── api
│   │   │   ├── api_client.dart             # Retrofit API client (typed)
│   │   │   └── api_client.g.dart           # Generated Retrofit methods
│   │   └── interceptors
│   │       └── auth_interceptors.dart      # Authentication interceptor
│   │
│   ├── providers
│   │   └── core_providers.dart             # Core-level Riverpod providers
│   │
│   ├── services
│   │   ├── local_storage_service.dart      # SharedPreferences wrapper
│   │   ├── logging_service.dart            # Centralized logging
│   │   ├── network_status_service.dart     # Connectivity monitoring
│   │   ├── session_service.dart            # Session and token validation
│   │   ├── token_storage_service.dart      # Secure token persistence
│   │   └── services.dart                   # Services barrel export
│   │
│   └── utils
│       ├── debouncer.dart                  # Debounce utility
│       ├── extensions.dart                 # String and DateTime extensions
│       ├── formatters.dart                 # Currency, date, time formatting
│       ├── utils.dart                      # Utils barrel export
│       └── validators.dart                 # Form and input validation
│
├── features
│   ├── auth
│   │   ├── data
│   │   │   ├── datasource/                 # Remote/local data sources
│   │   │   ├── mappers/                    # DTO to entity mappers
│   │   │   ├── models/                     # JSON serializable response models
│   │   │   └── repositories/               # Repository implementations
│   │   ├── di/                             # Auth feature dependency injection
│   │   └── domain
│   │       ├── entities/                   # Core business logic entities
│   │       ├── repositories/               # Repository interfaces
│   │       └── usecases/                   # Use cases (business logic)
│   │
│   ├── common
│   │   └── presentation
│   │       └── placeholder_screen.dart     # Placeholder UI for routes
│   │
│   └── splash
│       └── [Feature structure TBD]         # Splash screen feature
│
├── shared
│   ├── models
│   │   ├── api_response.dart               # Generic API response wrapper
│   │   ├── api_response.g.dart             # Generated JSON serialization
│   │   ├── health_response.dart            # Health check response model
│   │   ├── health_response.g.dart          # Generated JSON serialization
│   │   ├── models.dart                     # Models barrel export
│   │   ├── paginated_response.dart         # Paginated list response wrapper
│   │   └── paginated_response.g.dart       # Generated JSON serialization
│   │
│   ├── providers
│   │   ├── providers.dart                  # Providers barrel export
│   │   └── shared_providers.dart           # App-level state providers
│   │
│   ├── widgets
│   │   ├── app_empty_state.dart            # Empty state UI component
│   │   ├── app_error_state.dart            # Error state UI component
│   │   ├── app_loader.dart                 # Loading spinner component
│   │   └── widgets.dart                    # Widgets barrel export
│   │
│   └── shared.dart                         # Shared layer barrel export
│
├── bootstrap.dart                          # App initialization and DI setup
├── main.dart                               # Production entry point
├── main_dev.dart                           # Development entry point
└── main_prod.dart                          # Production entry point (override)
```

### Folder Structure Details

**app/** - Application configuration and routing

- Centralizes material app setup, theme, and navigation
- Flavor-specific configuration applied at startup
- GoRouter handles all named route navigation

**core/** - Application-wide infrastructure

- Services: Reusable business logic (tokens, storage, logging, connectivity)
- Network: Retrofit API client with typed responses and interceptors
- Error: Centralized exception handling and failure mapping
- Utils: Validation, formatting, debouncing, and extensions
- DI: GetIt container for dependency injection

**features/** - Feature modules following clean architecture

- Each feature contains: data (repositories, data sources, models), domain (entities, use cases), and presentation (screens, widgets)
- Completely decoupled from other features
- Each feature manages its own dependency injection

**shared/** - Reusable components across features

- Models: Generic API response wrappers with JSON serialization
- Providers: App-level state (loading, error messages)
- Widgets: Reusable UI components (loader, empty state, error state)

## Setup & Installation

### Prerequisites

- Flutter SDK (>=3.11.1)
- Dart (>=3.1.0)
- iOS: Xcode 14+
- Android: Android Studio with SDK 34+

### Installation Steps

1. Clone the repository:

```bash
cd /path/to/mini-ott-platform/mobile
```

2. Install dependencies:

```bash
flutter pub get
```

3. Generate code (first time setup):

```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Copy environment configuration:

```bash
# Development environment is configured by default
# For switching environments, see Flavors section
```

## Development

### Running the Application

Development environment with hot reload:

```bash
flutter run --flavor dev -t lib/main_dev.dart
```

Production simulation:

```bash
flutter run --flavor prod -t lib/main_prod.dart
```

### VS Code Launch Configuration

Create `.vscode/launch.json` in the project root for streamlined debugging:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "DSM TV Dev",
      "request": "launch",
      "type": "dart",
      "program": "mobile/lib/main_dev.dart",
      "args": ["--flavor", "dev"],
      "console": "debugConsole"
    },
    {
      "name": "DSM TV Prod",
      "request": "launch",
      "type": "dart",
      "program": "mobile/lib/main_prod.dart",
      "args": ["--flavor", "prod"],
      "console": "debugConsole"
    },
    {
      "name": "DSM TV Dev (Profile)",
      "request": "launch",
      "type": "dart",
      "program": "mobile/lib/main_dev.dart",
      "args": ["--flavor", "dev"],
      "console": "debugConsole",
      "flutterMode": "profile"
    },
    {
      "name": "DSM TV Dev (Release)",
      "request": "launch",
      "type": "dart",
      "program": "mobile/lib/main_dev.dart",
      "args": ["--flavor", "dev"],
      "console": "debugConsole",
      "flutterMode": "release"
    },
    {
      "name": "DSM TV Prod (Release)",
      "request": "launch",
      "type": "dart",
      "program": "mobile/lib/main_prod.dart",
      "args": ["--flavor", "prod"],
      "console": "debugConsole",
      "flutterMode": "release"
    }
  ],
  "compounds": []
}
```

**Launch Configuration Details:**

- `DSM TV Dev` - Debug mode for development flavor with hot reload
- `DSM TV Prod` - Debug mode for production flavor
- `DSM TV Dev (Profile)` - Profile mode for performance monitoring
- `DSM TV Dev (Release)` - Release mode without debug symbols
- `DSM TV Prod (Release)` - Production release build

**Usage in VS Code:**

1. Open the Run view (Ctrl+Shift+D / Cmd+Shift+D)
2. Select desired configuration from dropdown
3. Press F5 or click Start Debugging

### Code Generation

The project uses `build_runner` for:

- JSON serialization with `json_serializable`
- Retrofit HTTP client generation
- Riverpod code generation (when using annotations)

Regenerate code after modifying:

- Model classes (add/modify fields)
- API client interface
- Riverpod providers (if using generators)

Commands:

```bash
# Generate once
dart run build_runner build --delete-conflicting-outputs

# Watch for changes and regenerate automatically
dart run build_runner watch
```

### Flavor Configuration

The application supports two flavors for environment isolation:

**Development Flavor (dev)**

- Package: `com.himalayancodeworks.miniott.dev`
- Base URL: Development API endpoint
- App Name: DSM TV Dev
- Run: `flutter run --flavor dev -t lib/main_dev.dart`

**Production Flavor (prod)**

- Package: `com.himalayancodeworks.miniott`
- Base URL: Production API endpoint
- App Name: DSM TV
- Run: `flutter run --flavor prod -t lib/main_prod.dart`

Flavor configuration is centralized in `lib/app/flavor/app_flavor.dart`:

```dart
class AppFlavor {
  static final current = /* set at startup */;
  static final values = FlavorValues(
    appName: '...',
    baseUrl: '...',
    packageName: '...',
  );
}
```

### State Management with Riverpod

Riverpod is used for dependency management and reactive state:

**Provider for simple dependencies:**

```dart
final dioProvider = Provider((ref) => Dio());
```

**NotifierProvider for mutable state:**

```dart
class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state++;
}

final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);
```

**Usage in widgets:**

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Text('Count: $count');
  }
}
```

### API Integration with Retrofit

API client is type-safe with Retrofit and Dio:

**Define endpoints in `api_client.dart`:**

```dart
@GET('/health')
Future<HealthResponse> health();
```

**Create typed response models:**

```dart
@JsonSerializable()
class HealthResponse {
  final String status;

  factory HealthResponse.fromJson(Map<String, dynamic> json) =>
    _$HealthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HealthResponseToJson(this);
}
```

**Usage in repositories:**

```dart
final response = await getIt<ApiClient>().health();
```

### Error Handling

Custom exception hierarchy enables centralized error mapping:

```dart
try {
  await repository.login(email, password);
} on NetworkException catch (e) {
  // Handle network errors
} on UnauthorizedException catch (e) {
  // Handle auth errors
} on AppException catch (e) {
  // Handle generic errors
}
```

Repositories convert exceptions to Failure objects for use cases:

```dart
Future<Either<Failure, User>> login(String email, String password) async {
  try {
    return Right(await _apiClient.login(email, password));
  } on AppException catch (e) {
    return Left(Failure(e.message));
  }
}
```

### Services and Utilities

**Token Storage Service**

- Securely stores access/refresh tokens using flutter_secure_storage
- Available globally via `getIt<TokenStorageService>()`

**Local Storage Service**

- Stores app preferences using shared_preferences
- Available globally via `getIt<LocalStorageService>()`

**Logging Service**

- Centralized application logging
- Supports log levels and filtering

**Network Status Service**

- Monitors device connectivity
- Supports connection change callbacks

**Session Service**

- Validates JWT token expiration
- Orchestrates token refresh flows

**Validators**

- Email validation
- Password strength checking
- Empty field validation
- Minimum length validation

**Formatters**

- Currency formatting
- Date/time formatting
- String case conversion

## Build & Deployment

### Android Build

**Development APK:**

```bash
flutter build apk --flavor dev -t lib/main_dev.dart
```

**Production APK:**

```bash
flutter build apk --flavor prod -t lib/main_prod.dart
```

**Release App Bundle:**

```bash
flutter build appbundle --flavor prod -t lib/main_prod.dart
```

### iOS Build

**Development:**

```bash
flutter build ios --flavor dev -t lib/main_dev.dart
```

**Production:**

```bash
flutter build ios --flavor prod -t lib/main_prod.dart
```

### Launcher Icons

Generate app icons for all platforms from source image:

```bash
# Production icons
dart run flutter_launcher_icons -f flutter_launcher_icons-prod.yaml

# Development icons
dart run flutter_launcher_icons -f flutter_launcher_icons-dev.yaml
```

Provide high-resolution image (1024x1024+) as `assets/images/image.png`.

## Key Features

- **Multi-Flavor Support**: Isolated dev and prod environments with separate configurations
- **Type-Safe Networking**: Retrofit with typed response models and JSON serialization
- **Clean Architecture**: Clear separation of presentation, domain, and data layers
- **Dependency Injection**: GetIt service locator for loose coupling
- **Reactive State Management**: Riverpod providers at app and feature levels
- **Comprehensive Error Handling**: Custom exception hierarchy and failure mapping
- **Secure Token Storage**: flutter_secure_storage integration
- **Responsive Design**: flutter_screenutil for cross-device support
- **Centralized Theming**: Material3 theme with unified color palette
- **Code Generation**: Automated JSON serialization and API client generation

## Dependencies

### Core Framework

- `flutter` - UI framework
- `flutter_riverpod` (^3.1.0) - State management and DI
- `go_router` (^17.1.0) - Routing and navigation

### Networking

- `retrofit` (^4.4.1) - RESTful API client
- `dio` (^5.7.0) - HTTP client
- `json_annotation` (^4.9.0) - JSON serialization annotation
- `pretty_dio_logger` - HTTP request logging

### Storage

- `flutter_secure_storage` - Secure token storage
- `shared_preferences` - App settings storage

### Utilities

- `flutter_screenutil` (^5.9.3) - Responsive design
- `logger` - Application logging
- `intl` - Internationalization and formatting

### State Management

- `riverpod_annotation` - Riverpod annotations (when using generators)

### Build Tools

- `build_runner` - Code generation runner
- `json_serializable` (^6.8.0) - JSON serialization generator
- `retrofit_generator` - Retrofit code generator
- `flutter_launcher_icons` - Icon generation

## Troubleshooting

### Build Runner Issues

**Conflict errors during generation:**

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Cache issues:**

```bash
flutter clean
dart pub cache clean
flutter pub get
dart run build_runner build
```

### Missing Generated Files

After modifying models or API client:

```bash
dart run build_runner watch
# Keep this running while developing
```

### Flavor Issues

Verify flavor is set correctly:

```bash
flutter run --flavor dev -t lib/main_dev.dart -v
```

For iOS, create Xcode schemes matching `dev` and `prod` flavor names.

### Network Connection Issues

Check `NetworkStatusService` logs to verify device connectivity monitoring is working.

### Code Generation Not Updating

Clear build artifacts and regenerate:

```bash
rm -rf .dart_tool/
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Contributing

When adding new features:

1. Create feature folder in `features/` following clean architecture
2. Implement data, domain, and presentation layers
3. Add feature-specific dependency injection in `feature/di/`
4. Update feature barrel exports
5. Generate code after model changes using `build_runner`
6. Test across both flavors

## Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [Riverpod Documentation](https://riverpod.dev)
- [Retrofit Documentation](https://pub.dev/packages/retrofit)
- [Go Router Documentation](https://pub.dev/packages/go_router)
- [Clean Architecture in Flutter](https://resocoder.com/articles/flutter-clean-architecture-tdd)

## License

This project is developed as part of my Final Year Project.
