# YaBike - Personal Finance Management App

A privacy-first, offline personal finance management application built with Flutter. Automatically track income and expenses from SMS transactions, manage multiple wallets, create budgets, and gain insights into your spending patterns.

## 🎯 Features

- **SMS Transaction Import**: Automatically parse and import transactions from MTN MoMo, banks, and other financial SMS
- **Multi-Wallet Management**: Create and manage wallets for different payment sources
- **Budget Tracking**: Set category-based budgets with visual progress indicators
- **Transaction Management**: View, edit, categorize, and reassign transactions
- **Dashboard Analytics**: Visual charts and summaries of your financial data
- **Offline-First**: All data stored locally with no cloud dependency
- **Secure**: PIN and biometric authentication to protect your financial data

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # App configuration
│
├── core/                              # Core app configurations
│   ├── constants/
│   │   ├── app_colors.dart           # Color palette
│   │   ├── app_strings.dart          # String constants
│   │   ├── app_themes.dart           # Light/dark themes
│   │   └── app_assets.dart           # Asset paths
│   ├── utils/
│   │   ├── validators.dart           # Input validators
│   │   ├── formatters.dart           # Data formatters
│   │   └── helpers.dart              # Helper functions
│   ├── routes/
│   │   └── app_routes.dart           # Route definitions
│   └── config/
│       └── app_config.dart           # App configuration
│
├── data/                              # Data layer
│   ├── models/
│   │   ├── user_model.dart           # User data model
│   │   ├── wallet_model.dart         # Wallet data model
│   │   ├── transaction_model.dart    # Transaction data model
│   │   └── budget_model.dart         # Budget data model
│   ├── repositories/                  # To be implemented
│   │   ├── auth_repository.dart
│   │   ├── wallet_repository.dart
│   │   ├── transaction_repository.dart
│   │   └── budget_repository.dart
│   └── services/                      # To be implemented
│       ├── sms_service.dart
│       ├── local_storage_service.dart
│       ├── biometric_service.dart
│       └── notification_service.dart
│
├── features/                          # Feature modules
│   ├── splash/
│   │   └── screens/
│   │       └── splash_screen.dart
│   ├── auth/                          # To be implemented
│   ├── home/
│   │   └── screens/
│   │       └── home_screen.dart
│   ├── wallet/                        # To be implemented
│   ├── transaction/                   # To be implemented
│   ├── budget/                        # To be implemented
│   └── settings/                      # To be implemented
│
└── shared/                            # Shared components
    ├── widgets/
    │   ├── custom_button.dart
    │   └── custom_app_bar.dart
    └── extensions/
        ├── string_extensions.dart
        ├── double_extensions.dart
        └── datetime_extensions.dart
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>= 3.9.0)
- Dart SDK (>= 3.9.0)
- Android Studio / VS Code
- Android device or emulator (for SMS features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/uwambajeddy/yabike.git
   cd yabike
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Dependencies

### Core Dependencies
- **provider**: State management
- **hive** & **hive_flutter**: Local database
- **telephony**: SMS reading and parsing
- **permission_handler**: Runtime permissions
- **local_auth**: Biometric authentication
- **crypto**: PIN hashing
- **flutter_secure_storage**: Secure key storage

### UI & Utilities
- **fl_chart**: Charts and graphs
- **intl**: Date/number formatting
- **google_fonts**: Custom fonts
- **uuid**: Unique ID generation
- **path_provider**: File system paths
- **shared_preferences**: Simple key-value storage

### Optional
- **flutter_local_notifications**: Local notifications
- **share_plus**: Data export/sharing
- **image_picker**: Profile picture

## 🏗️ Architecture

The app follows the **MVVM (Model-View-ViewModel)** architecture pattern:

- **Model**: Data models and business logic (`data/models/`, `data/repositories/`)
- **View**: UI screens and widgets (`features/*/screens/`, `features/*/widgets/`)
- **ViewModel**: State management (`features/*/providers/`)

### Key Design Principles

1. **Feature-based organization**: Each feature is self-contained
2. **Separation of concerns**: Clear boundaries between layers
3. **Offline-first**: All operations work without internet
4. **Privacy-focused**: No external authentication or cloud sync
5. **Scalable**: Easy to add new features

## 🔐 Security

- PIN authentication (4-6 digits)
- Biometric authentication support
- Local data encryption
- Auto-lock after inactivity
- Secure storage for sensitive data

## 📱 Screens Overview

Based on the design files in the `Designs/` folder:

### 1. Splash & Onboarding
- Splash Screen
- Onboarding 1, 2, 3

### 2. Sign Up & Wallet Creation
- Create New Wallet
- Select Currency
- Set Wallet Balance
- SMS Integration Setup
- Success Screen

### 3. Home
- Dashboard with total balance
- Recent transactions
- Quick actions

### 4. Transactions
- Transaction list
- Transaction detail
- Add/Edit transaction
- Filter transactions
- Scan receipt (future)

### 5. Budget
- Budget list
- Budget details
- Add/Edit budget
- Budget progress tracking

### 6. Settings
- Profile settings
- Security settings
- Currency settings
- Integration settings
- Data management

## 🛠️ Development Setup

### Generate Hive Adapters (when needed)
```bash
flutter packages pub run build_runner build
```

### Run with specific device
```bash
flutter run -d <device_id>
```

### Build APK
```bash
flutter build apk --release
```

## 📝 TODO

### Phase 1: Core Setup ✅
- [x] Project structure
- [x] Core constants and themes
- [x] Data models
- [x] Dependencies setup

### Phase 2: Authentication (Next)
- [ ] PIN creation and verification
- [ ] Biometric setup
- [ ] Unlock screen
- [ ] First-time setup flow

### Phase 3: Data Layer
- [ ] Hive adapters for models
- [ ] Repository implementations
- [ ] SMS parsing service
- [ ] Local storage service

### Phase 4: Features
- [ ] Wallet management
- [ ] Transaction management
- [ ] Budget management
- [ ] Dashboard and analytics
- [ ] Settings

### Phase 5: Polish
- [ ] Error handling
- [ ] Loading states
- [ ] Empty states
- [ ] Animations
- [ ] Testing

## 🤝 Contributing

This is a personal project, but contributions are welcome! Please feel free to submit issues or pull requests.

## 📄 License

This project is private and not licensed for public use.

## 👨‍💻 Author

**Eddy UWAMBAJE**
- GitHub: [@uwambajeddy](https://github.com/uwambajeddy)

## 📞 Support

For questions or support, please open an issue in the GitHub repository.

---

**Note**: This is a work in progress. Check the SRS document (`Flutter_Personal_Finance_Tracker_SRS.md`) for complete requirements and specifications.
