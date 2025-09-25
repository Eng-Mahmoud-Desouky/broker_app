# AI Agent Instructions for broker_app

This document outlines key patterns and workflows for AI agents working with the broker_app Flutter project.

## Project Architecture

### Clean Architecture Implementation
- Project follows Clean Architecture with three layers:
  - **Presentation**: BLoC pattern (`lib/features/*/presentation/bloc/`)
  - **Domain**: Entities, repositories interfaces, use cases (`lib/features/*/domain/`)
  - **Data**: Models, repository implementations, data sources (`lib/features/*/data/`)

### Core Components
- `lib/core/` contains project-wide utilities and configurations:
  - Dependency injection using GetIt (`core/di/injection_container.dart`)
  - Error handling (`core/error/`)
  - Theme configuration (`core/theme/`)
  - Navigation using go_router (`core/router/`)

### Feature Organization
Each feature follows identical structure:
```
features/feature_name/
  ├── data/
  │   ├── datasources/
  │   ├── models/
  │   └── repositories/
  ├── domain/
  │   ├── entities/
  │   ├── repositories/
  │   └── usecases/
  └── presentation/
      ├── bloc/
      ├── pages/
      └── widgets/
```

## Key Development Patterns

### State Management
- Uses BLoC pattern with flutter_bloc package
- Each feature has its own BLoC with corresponding events and states
- Example: See `features/authentication/presentation/bloc/auth_bloc.dart`

### Data Layer
- Supabase for backend integration (`supabase_flutter` package)
- Local storage using `flutter_secure_storage` and `shared_preferences`
- Network connectivity handling with `connectivity_plus`

### Authentication Flow
- Phone number based authentication with OTP verification
- See `features/authentication/domain/usecases/` for auth workflows

## Common Development Tasks

### Adding a New Feature
1. Create feature directory structure following the pattern above
2. Define entities in domain layer
3. Create repository interface and use cases
4. Implement data sources and repository
5. Create BLoC and UI components
6. Register dependencies in `core/di/injection_container.dart`

### Working with BLoCs
- Each BLoC should have corresponding event and state classes
- Follow naming convention: `FeatureBloc`, `FeatureEvent`, `FeatureState`
- Register BLoCs in dependency injection container

### Localization
- Uses Flutter's built-in localization
- Strings defined in `lib/core/localization/`

### Styling
- Theme configuration in `lib/core/theme/`
- Use predefined colors from `app_colors.dart`
- Follow text styles defined in `app_text_styles.dart`

## External Dependencies
- Backend: Supabase
- State Management: flutter_bloc
- Navigation: go_router
- Dependency Injection: get_it
- Storage: flutter_secure_storage, shared_preferences
- Network: connectivity_plus, dio

Reference the `pubspec.yaml` for complete dependency list and versions.