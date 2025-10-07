# YaBike Development Guide

## 🎯 Quick Start for Development

### Initial Setup
```bash
# 1. Install dependencies
flutter pub get

# 2. Generate Hive adapters (when models are ready)
flutter packages pub run build_runner build

# 3. Run the app
flutter run
```

## 📂 Where to Add New Code

### Adding a New Screen
1. Create screen file in appropriate feature folder:
   ```
   lib/features/<feature>/screens/<screen_name>_screen.dart
   ```

2. Add route in `core/routes/app_routes.dart`:
   ```dart
   static const String myScreen = '/my-screen';
   ```

3. Register route in `RouteGenerator.generateRoute()`:
   ```dart
   case AppRoutes.myScreen:
     return MaterialPageRoute(builder: (_) => MyScreen());
   ```

### Adding a New Model
1. Create model in `data/models/`:
   ```dart
   import 'package:uuid/uuid.dart';
   
   class MyModel {
     final String id;
     final String name;
     
     MyModel({
       String? id,
       required this.name,
     }) : id = id ?? const Uuid().v4();
     
     // Add fromJson, toJson, copyWith
   }
   ```

2. Add Hive type adapter annotation if needed:
   ```dart
   import 'package:hive/hive.dart';
   
   part 'my_model.g.dart';
   
   @HiveType(typeId: 0)
   class MyModel {
     @HiveField(0)
     final String id;
   }
   ```

3. Generate adapter:
   ```bash
   flutter packages pub run build_runner build
   ```

### Adding a New Service
1. Create service in `data/services/`:
   ```dart
   class MyService {
     static final MyService _instance = MyService._internal();
     factory MyService() => _instance;
     MyService._internal();
     
     // Service methods
   }
   ```

### Adding a New Widget
1. For feature-specific widgets:
   ```
   lib/features/<feature>/widgets/<widget_name>.dart
   ```

2. For shared widgets:
   ```
   lib/shared/widgets/<widget_name>.dart
   ```

## 🎨 Design System Usage

### Colors
```dart
import 'package:yabike/core/constants/app_colors.dart';

// Use predefined colors
Container(
  color: AppColors.primary,
  // or
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: AppColors.primaryGradient,
    ),
  ),
)
```

### Themes
```dart
import 'package:yabike/core/constants/app_themes.dart';

// Access theme
Theme.of(context).textTheme.headlineLarge
Theme.of(context).colorScheme.primary
```

### Strings
```dart
import 'package:yabike/core/constants/app_strings.dart';

Text(AppStrings.homeTitle)
```

### Assets
```dart
import 'package:yabike/core/constants/app_assets.dart';

Image.asset(AppAssets.logo)
```

## 🔧 Common Patterns

### Using Provider (State Management)
1. Create provider:
   ```dart
   class MyProvider extends ChangeNotifier {
     String _data = '';
     String get data => _data;
     
     void updateData(String newData) {
       _data = newData;
       notifyListeners();
     }
   }
   ```

2. Register in main.dart:
   ```dart
   MultiProvider(
     providers: [
       ChangeNotifierProvider(create: (_) => MyProvider()),
     ],
     child: YaBikeApp(),
   )
   ```

3. Use in widget:
   ```dart
   // Read
   final myData = context.read<MyProvider>().data;
   
   // Watch
   final myData = context.watch<MyProvider>().data;
   
   // Select
   final myData = context.select<MyProvider, String>((p) => p.data);
   ```

### Using Hive (Local Storage)
```dart
// Open box
final box = await Hive.openBox('myBox');

// Write
await box.put('key', value);

// Read
final value = box.get('key', defaultValue: 'default');

// Delete
await box.delete('key');

// Listen to changes
box.watch().listen((event) {
  print('Key: ${event.key}, Value: ${event.value}');
});
```

### Form Validation
```dart
import 'package:yabike/core/utils/validators.dart';

TextFormField(
  validator: Validators.required,
  // or
  validator: Validators.amount,
  // or
  validator: (value) => Validators.pin(value),
)
```

### Data Formatting
```dart
import 'package:yabike/core/utils/formatters.dart';

// Currency
Text(Formatters.currency(1000)) // "1,000 RWF"

// Date
Text(Formatters.date(DateTime.now())) // "07 Oct 2025"

// Relative time
Text(Formatters.relativeTime(DateTime.now())) // "Just now"
```

### Using Extensions
```dart
import 'package:yabike/shared/extensions/string_extensions.dart';
import 'package:yabike/shared/extensions/double_extensions.dart';
import 'package:yabike/shared/extensions/datetime_extensions.dart';

// String
'hello'.capitalize() // "Hello"

// Double
1000.0.toCurrency() // "1,000 RWF"
75.5.toPercentage() // "75.5%"

// DateTime
DateTime.now().isToday // true
DateTime.now().relativeTime // "Just now"
```

## 🏗️ Feature Implementation Template

### Example: Adding Transaction List Screen

1. **Create screen file**: `lib/features/transaction/screens/transactions_screen.dart`
   ```dart
   import 'package:flutter/material.dart';
   import '../../../core/constants/app_colors.dart';
   import '../../../core/constants/app_strings.dart';
   
   class TransactionsScreen extends StatelessWidget {
     const TransactionsScreen({super.key});
     
     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(
           title: const Text(AppStrings.transactionsTitle),
         ),
         body: ListView.builder(
           itemCount: 10,
           itemBuilder: (context, index) {
             return ListTile(
               title: Text('Transaction $index'),
             );
           },
         ),
       );
     }
   }
   ```

2. **Add route**: In `core/routes/app_routes.dart`
   ```dart
   static const String transactions = '/transactions';
   ```

3. **Register route**: In `RouteGenerator.generateRoute()`
   ```dart
   case AppRoutes.transactions:
     return MaterialPageRoute(
       builder: (_) => const TransactionsScreen(),
     );
   ```

4. **Navigate to screen**:
   ```dart
   Navigator.pushNamed(context, AppRoutes.transactions);
   ```

## 🧪 Testing Guidelines

### Unit Tests
```dart
// test/models/transaction_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:yabike/data/models/transaction_model.dart';

void main() {
  group('Transaction Model', () {
    test('should create transaction from JSON', () {
      final json = {
        'id': '123',
        'amount': 1000.0,
        // ...
      };
      
      final transaction = Transaction.fromJson(json);
      
      expect(transaction.id, '123');
      expect(transaction.amount, 1000.0);
    });
  });
}
```

### Widget Tests
```dart
// test/widgets/custom_button_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:yabike/shared/widgets/custom_button.dart';

void main() {
  testWidgets('CustomButton shows text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomButton(
          text: 'Click Me',
          onPressed: () {},
        ),
      ),
    );
    
    expect(find.text('Click Me'), findsOneWidget);
  });
}
```

## 📱 Android Configuration

### Permissions
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.READ_SMS" />
<uses-permission android:name="android.permission.RECEIVE_SMS" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

### Min SDK
In `android/app/build.gradle`:
```gradle
defaultConfig {
    minSdkVersion 21
    targetSdkVersion 33
}
```

## 🔐 Security Best Practices

1. **Never store PIN in plain text**:
   ```dart
   import 'package:yabike/core/utils/helpers.dart';
   
   final pinHash = Helpers.hashPin(pin);
   ```

2. **Use secure storage for sensitive data**:
   ```dart
   import 'package:flutter_secure_storage/flutter_secure_storage.dart';
   
   final storage = FlutterSecureStorage();
   await storage.write(key: 'pin_hash', value: pinHash);
   ```

3. **Validate all inputs**:
   ```dart
   import 'package:yabike/core/utils/validators.dart';
   
   final error = Validators.amount(amountText);
   if (error != null) {
     // Show error
   }
   ```

## 🐛 Debugging Tips

### View Hive Data
```dart
import 'package:hive_flutter/hive_flutter.dart';

// Print all data in a box
final box = Hive.box('wallets');
print(box.values.toList());
```

### Enable Logging
```dart
void main() {
  // Enable logging in debug mode
  if (kDebugMode) {
    print('App started in debug mode');
  }
  runApp(YaBikeApp());
}
```

### Hot Reload vs Hot Restart
- **Hot Reload** (r): Updates UI only
- **Hot Restart** (R): Restarts app, resets state
- **Full Restart**: When changing native code or dependencies

## 📚 Useful Commands

```bash
# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Outdated packages
flutter pub outdated

# Clean build
flutter clean

# Generate code (Hive adapters)
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Run on specific device
flutter run -d <device-id>

# List devices
flutter devices

# Analyze code
flutter analyze

# Format code
flutter format .
```

## 🎯 Git Workflow

```bash
# Feature branch
git checkout -b feature/transaction-list

# Commit changes
git add .
git commit -m "feat: add transaction list screen"

# Push to remote
git push origin feature/transaction-list

# Merge to main
git checkout main
git merge feature/transaction-list
```

## 📖 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Provider Package](https://pub.dev/packages/provider)
- [Hive Documentation](https://docs.hivedb.dev/)
- [Material Design](https://material.io/design)

---

**Happy Coding! 🚀**
