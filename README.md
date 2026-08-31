# Zaid Express (Broker App)

## 📌 Project Overview
Zaid Express is an enterprise-grade mobile application designed to streamline broker operations, enhance client communication, and provide a seamless, performant digital experience. By leveraging a robust, scalable architecture, this platform resolves critical bottlenecks in the brokerage workflow, reducing operational friction and empowering users with real-time, reliable data.

## 🛠 Tech Stack
This repository is engineered with state-of-the-art mobile technologies to guarantee performance, scalability, and maintainability:

* **Framework:** Flutter / Dart (v3.7+)
* **State Management:** BLoC (Business Logic Component) via `flutter_bloc` & `equatable`
* **Backend & Database:** Supabase (PostgreSQL, Real-time APIs, Authentication)
* **Routing:** `go_router` for robust, declarative navigation
* **Dependency Injection:** `get_it` and `injectable` for decoupled module management
* **Network / API:** `dio` for high-performance HTTP networking
* **Push Notifications:** Firebase Cloud Messaging (FCM) via `firebase_messaging`
* **Local Storage:** `shared_preferences` & `flutter_secure_storage`

## 🏗 Architecture (Clean Architecture)
This project rigorously adheres to **Clean Architecture** principles, effectively separating concerns to ensure **zero technical debt**, high testability, and enterprise-grade maintainability. The source code is organized into distinct, decoupled layers:

### 1. Presentation Layer (`lib/presentation` & Features)
Handles the UI and State Management. Widgets communicate solely with BLoCs/Cubits to react to state changes. Business logic is completely abstracted away from the UI, ensuring that visual components remain lightweight and declarative.

### 2. Domain Layer
The core of the application. It contains the fundamental business rules and enterprise logic, including Entities and abstract Repository Interfaces. This layer is completely independent of the external world (no UI, no database dependencies).

### 3. Data Layer
Responsible for data retrieval and persistence. It implements the repository interfaces defined in the Domain layer and acts as a boundary between the application and external data sources (Supabase, local storage, external APIs).
* **Data Sources:** Divided into Remote (Supabase/Dio) and Local sources.
* **Models:** Data Transfer Objects (DTOs) that serialize/deserialize raw JSON into Domain Entities.

*By enforcing this separation, any underlying technology (e.g., swapping a database or networking client) can be replaced without affecting the core business logic.*

## ✨ Key Features
* **Real-time Synchronization:** Seamless real-time updates powered by Supabase.
* **Scalable State Management:** Predictable, easily testable state flows using BLoC.
* **Decoupled Navigation:** Deep-linking and advanced routing managed by GoRouter.
* **Secure Data Handling:** Encrypted local storage and secure authentication flows.
* **Responsive UI:** Fully responsive design system utilizing a unified theme and custom typography (Cairo font).
* **Automated Code Generation:** Leveraging `build_runner` and `injectable` for boilerplate-free dependency injection.

## 🚀 Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.7.2 or higher)
* Dart SDK
* An IDE (VS Code or Android Studio) with Flutter extensions installed.

### Setup Instructions
1. **Clone the repository**
   ```bash
   git clone <repository_url>
   cd broker_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run code generation (for Dependency Injection & Routing)**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

---
*Built with excellence for scalable mobile solutions.*
