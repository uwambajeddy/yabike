# YaBike - Personal Finance Manager

A comprehensive Flutter mobile application for tracking personal finances, managing budgets, and gaining insights into spending habits.

## 📱 Features

### Core Functionality
- **Smart Transaction Tracking**: Automatic SMS parsing for transaction detection
- **Multi-Wallet Support**: Manage multiple bank accounts and wallets
- **Budget Management**: Set spending limits and track progress by category
- **Visual Analytics**: 
  - Last 7 days income/expense bar charts
  - Category breakdown pie charts
  - Spending trends and insights
- **Transaction Filtering**: Advanced search and filter capabilities
- **Category Management**: Customizable expense and income categories

### Key Screens
- **Home Dashboard**: Net balance overview with recent transactions and weekly chart
- **Transactions**: Comprehensive transaction list with filtering and analytics
- **Budget**: Create and monitor spending budgets with visual progress indicators
- **Settings**: Manage categories, wallets, and app preferences

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Dart SDK (3.9.0 or higher)
- Android Studio / VS Code with Flutter extensions
- An Android/iOS device or emulator

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

## 🏗️ Project Structure

```
lib/
├── core/                 # Core utilities, constants, and routes
│   ├── constants/       # App colors, strings, themes
│   └── routes/          # Navigation routes
├── data/                # Data layer
│   ├── models/         # Data models (Transaction, Budget, Wallet, etc.)
│   ├── repositories/   # Data repositories (Hive-based)
│   └── services/       # Business logic services
└── features/           # Feature modules
    ├── home/           # Home dashboard
    ├── transaction/    # Transaction management
    ├── budget/         # Budget tracking
    ├── settings/       # App settings
    ├── auth/           # Authentication
    └── main/           # Main app navigation
```

## 📦 Key Dependencies

- **State Management**: `provider` (^6.1.0)
- **Local Database**: `hive` (^2.2.3) & `hive_flutter` (^1.1.0)
- **Charts**: `fl_chart` (^1.1.1)
- **SMS Parsing**: `sms_advanced` (^1.1.0)
- **Security**: `local_auth` (^2.1.7), `flutter_secure_storage` (^10.0.0)
- **UI**: `google_fonts` (^6.1.0)
- **Utilities**: `intl` (^0.20.2), `uuid` (^4.2.0)

## 🎨 Design Principles

- **Material Design 3**: Modern, intuitive UI following Material Design guidelines
- **Green Theme**: Primary color palette centered around financial growth and stability
- **Accessibility**: High contrast ratios and readable typography
- **Responsive**: Adaptive layouts for various screen sizes

## 🔐 Permissions

The app requires the following permissions:
- **SMS**: For automatic transaction detection from bank SMS messages
- **Biometric/PIN**: For secure app access (optional)

## 🛠️ Development

### Running Tests
```bash
flutter test
```

### Building for Production

**Android**
```bash
flutter build apk --release
```

**iOS**
```bash
flutter build ios --release
```

## 📝 License

This project is private and proprietary.

## 👥 Contributors

- **Eddy Uwambaje** - [@uwambajeddy](https://github.com/uwambajeddy)

## 📞 Support

For issues, questions, or contributions, please open an issue on the GitHub repository.

---

Built with ❤️ using Flutter
