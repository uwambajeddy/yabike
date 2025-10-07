# SMS Integration Navigation Fix

## Issue
After user accepts SMS permission on the Terms screen, the app was trying to navigate to `/smsLoading` route but getting an error because the route couldn't access the `SmsIntegrationViewModel` instance.

## Root Cause
The `SmsIntegrationViewModel` was created in the `SmsTermsScreen` route with `ChangeNotifierProvider`, but when navigating to `SmsLoadingScreen`, a new route was created without access to the same viewModel instance. This caused:
1. The loading screen couldn't access the viewModel state
2. The SMS scanning wouldn't start because the viewModel instance was lost
3. Navigation would fail or show a blank screen

## Solution Implemented

### 1. Pass ViewModel Through Navigation Arguments
**File: `lib/features/sms_integration/viewmodels/sms_integration_viewmodel.dart`**

Changed navigation to pass the viewModel instance:
```dart
if (context.mounted) {
  Navigator.pushReplacementNamed(
    context,
    '/smsLoading',
    arguments: this, // Pass the viewModel instance
  );
}
```

### 2. Update Route Generator to Accept ViewModel
**File: `lib/core/routes/app_routes.dart`**

Updated the `smsLoading` route case to extract and use the passed viewModel:
```dart
case AppRoutes.smsLoading:
  // Extract the viewModel from arguments if passed
  final viewModel = settings.arguments as SmsIntegrationViewModel?;
  
  return MaterialPageRoute(
    builder: (_) => viewModel != null
        ? ChangeNotifierProvider.value(
            value: viewModel,
            child: const SmsLoadingScreen(),
          )
        : ChangeNotifierProvider(
            create: (_) => SmsIntegrationViewModel(),
            child: const SmsLoadingScreen(),
          ),
    settings: settings,
  );
```

**Key Points:**
- Uses `ChangeNotifierProvider.value()` when viewModel is passed (preserves existing instance)
- Falls back to creating new instance if no argument passed (defensive programming)
- Maintains state across screen transitions

## How It Works Now

### Complete Flow:
```
1. User completes onboarding (Android)
   ↓
2. Navigate to SMS Terms (/smsTerms)
   - Creates new SmsIntegrationViewModel instance
   ↓
3. User accepts terms and taps Continue
   ↓
4. ViewModel.requestSmsPermission() is called
   ↓
5. Permission granted
   ↓
6. Navigate to Loading Screen (/smsLoading)
   - Passes viewModel instance as argument
   - Uses ChangeNotifierProvider.value() to preserve instance
   ↓
7. Loading Screen accesses same viewModel instance
   - Listens to state changes
   - Shows scanning/parsing/creating progress
   ↓
8. ViewModel.scanAndImportSms() executes
   - Scans SMS messages
   - Parses transactions
   - Creates wallets
   ↓
9. State changes to 'completed'
   ↓
10. Navigate to Home Screen
```

## Provider Pattern Used

### Creating New Instance:
```dart
ChangeNotifierProvider(
  create: (_) => SmsIntegrationViewModel(),
  child: const SmsTermsScreen(),
)
```

### Passing Existing Instance:
```dart
ChangeNotifierProvider.value(
  value: viewModel, // Existing instance
  child: const SmsLoadingScreen(),
)
```

## Benefits
✅ State is maintained across navigation
✅ SMS scanning starts immediately after permission granted
✅ Loading screen shows real-time progress
✅ No duplicate viewModel instances
✅ Proper cleanup when screens are disposed

## Testing
To test the fix:
1. Run the app on Android device/emulator
2. Complete onboarding
3. Accept SMS terms
4. Grant SMS permission when prompted
5. Verify you see the loading screen with progress
6. Verify navigation to home screen when complete

---

**Status**: ✅ Fixed - Navigation now properly maintains ViewModel state across screens
