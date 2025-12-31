# 🛒 POS App (Point of Sale)

Welcome to the **POS App**, a cutting-edge Point of Sale solution designed to streamline retail operations. Built with efficiency and scalability in mind, this application leverages the power of **Flutter** and **Clean Architecture** to deliver a robust, maintainable, and high-performance experience.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)

---

## 🚀 Features

The application is modularized into several key features to ensure a seamless workflow:

### 🔐 **Authentication & Security**

- **Secure Login & Registration**: User authentication powered by secure standards.
- **OTP Verification**: Added layer of security for user validation.
- **Splash Screen**: Professional onboarding experience.

### 🛍️ **Point of Sale (POS)**

- **Fast Checkout**: User-friendly product selection and checkout flow.
- **Cart Management**: Add, remove, and adjust quantities in real-time.
- **Transaction History**: View past successful transactions.

### 📦 **Inventory & Product Management**

- **Product Catalog**: Manage products with images, prices, and stock levels.
- **Stock Tracking**: Visualize stock status (e.g., "SOLD OUT" indicators).
- **Supplier Management**: Organize supplier details.

### 👥 **Admin & User Management**

- **Cashier Management**: Create and oversee cashier accounts.
- **Profile Settings**: View and update user profile information.

### 🧾 **Purchases**

- **Purchase Management**: Track incoming stock/purchases.

---

## 🛠️ Technology Stack

This project uses a modern tech stack to ensure reliability and ease of development:

- **Framework**: [Flutter](https://flutter.dev/) (SDK ^3.10.1)
- **Language**: [Dart](https://dart.dev/)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) (BLoC Pattern)
- **Navigation**: [go_router](https://pub.dev/packages/go_router)
- **Networking**: [dio](https://pub.dev/packages/dio)
- **Dependency Injection**: [get_it](https://pub.dev/packages/get_it)
- **Functional Programming**: [dartz](https://pub.dev/packages/dartz)
- **Local Storage**: [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
- **UI Utils**: [focus_detector](https://pub.dev/packages/focus_detector), [cached_network_image](https://pub.dev/packages/cached_network_image)

---

## 🏗️ Architecture

This project follows **Clean Architecture** principles to ensure separation of concerns and testability.

```
lib/
├── core/           # Common utilities, widgets, network clients, errors
├── features/       # Feature-based modules
│   ├── auth/       # Authentication (Data, Domain, Presentation)
│   ├── pos/        # Point of Sale logic
│   ├── inventory/  # Inventory management
│   └── ...
├── app/            # App configuration, theme, routes
└── main.dart       # Entry point
```

Each feature is divided into:

- **Domain**: Entities, Use Cases, Repository Interfaces (Pure Dart, no Flutter dependencies).
- **Data**: Models, Data Sources (API/Local), Repository Implementations.
- **Presentation**: BLoCs/Cubits, Pages, Widgets.

---

## 🏁 Getting Started

Follow these steps to set up the project locally.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- An IDE (VS Code or Android Studio) with Flutter extensions.
- Android Emulator or iOS Simulator.

### Installation

1.  **Clone the repository**:

    ```bash
    git clone https://github.com/your-username/pos_app.git
    cd pos_app
    ```

2.  **Install dependencies**:

    ```bash
    flutter pub get
    ```

3.  **Run the application**:
    ```bash
    flutter run
    ```

---

## 🧪 Testing

To run unit and widget tests:

```bash
flutter test
```

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
