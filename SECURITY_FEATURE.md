# App Security Feature

## Overview
Complete security implementation allowing users to protect the YaBike app with a 4-digit PIN and/or biometric authentication (fingerprint/face ID).

## Features Implemented

### 1. **Security Service** (`security_service.dart`)
Core security management service with the following capabilities:
- PIN setup, verification, and change
- SHA-256 hashing for secure PIN storage
- Biometric authentication support
- Device capability detection
- Enable/disable security features

### 2. **Security Settings Screen** (`security_settings_screen.dart`)
Main security configuration interface:
- Security status card (shows if app is secured)
- PIN management (setup, change, remove)
- Biometric authentication toggle
- Visual indicators for active security features
- Security tips and information

### 3. **PIN Setup Screen** (`setup_pin_screen.dart`)
First-time PIN creation:
- 4-digit PIN entry with visual dots
- PIN confirmation step
- Error handling for mismatched PINs
- Clean number pad interface
- "Start over" option

### 4. **Change PIN Screen** (`change_pin_screen.dart`)
Secure PIN modification:
- 3-step process:
  1. Verify current PIN
  2. Enter new PIN
  3. Confirm new PIN
- Step progress indicator
- Prevents reusing the same PIN
- Visual feedback at each step

### 5. **Unlock Screen** (`unlock_screen.dart`)
App unlock interface:
- 4-digit PIN entry
- Biometric authentication option
- Maximum 5 attempts with attempt counter
- Auto-trigger biometric on load (if enabled)
- Prevents back button navigation
- App logo and branding

### 6. **App Lifecycle Integration**
Security automatically enforced via `MainScreen`:
- Shows unlock screen on app start (if security enabled)
- Locks app when moved to background
- Shows unlock screen when app resumes
- Uses WidgetsBindingObserver for lifecycle detection

## User Flow

### Setup Security
1. User goes to **Settings → Security**
2. Taps "Set up PIN"
3. Enters 4-digit PIN twice
4. Optionally enables biometric authentication
5. Security is now active

### Using the App
1. User opens app
2. If security is enabled, unlock screen appears
3. User can unlock with:
   - 4-digit PIN, or
   - Biometric authentication (if enabled)
4. App unlocks and proceeds normally

### App Backgrounding
1. User switches to another app
2. YaBike locks automatically
3. When user returns, unlock screen appears
4. User authenticates to continue

### Managing Security
- **Change PIN**: Settings → Security → PIN → Change PIN
- **Remove PIN**: Settings → Security → PIN → Remove PIN (disables all security)
- **Toggle Biometric**: Settings → Security → Biometric switch
- **Note**: PIN is required before enabling biometric

## Technical Details

### Storage
- **PIN**: SHA-256 hashed and stored in Hive `settings` box
- **Biometric preference**: Boolean in Hive `settings` box
- **Security status**: Boolean flag in Hive

### Security Features
- PIN hashing prevents plain-text storage
- Maximum 5 unlock attempts before lockout
- Biometric requires PIN as fallback
- Security survives app restarts
- Automatic locking on app background

### Dependencies Used
- `local_auth: ^2.1.7` - Biometric authentication
- `crypto: ^3.0.3` - SHA-256 PIN hashing
- `hive: ^2.2.3` - Secure local storage

## Biometric Support

### Supported Types
- **Fingerprint** (Android/iOS)
- **Face ID** (iOS)
- **Face Unlock** (Android)
- **Iris Scanner** (Samsung devices)

### Platform Compatibility
- ✅ Android: Fingerprint, Face unlock
- ✅ iOS: Touch ID, Face ID
- ✅ Windows: Windows Hello
- ✅ macOS: Touch ID

## Routes Added
- `/settings/security` - Security settings screen
- `/security/setup-pin` - PIN setup screen
- `/security/change-pin` - Change PIN screen
- `/auth/unlock` - Unlock screen

## Files Created
```
lib/
├── data/
│   └── services/
│       └── security_service.dart
├── features/
│   └── security/
│       └── screens/
│           ├── security_settings_screen.dart
│           ├── setup_pin_screen.dart
│           ├── change_pin_screen.dart
│           └── unlock_screen.dart
└── core/
    └── utils/
        └── secure_app.dart (utility, not currently used)
```

## Files Modified
- `lib/core/routes/app_routes.dart` - Added security routes
- `lib/features/settings/screens/settings_screen.dart` - Added security menu item
- `lib/features/main/screens/main_screen.dart` - Added lifecycle security checks

## Configuration
No additional configuration needed. All settings are managed through the UI.

## Testing Checklist
- [x] PIN setup flow
- [x] PIN verification on unlock
- [x] PIN change flow
- [x] PIN removal
- [x] Biometric toggle (requires biometric before enabling)
- [x] Biometric authentication
- [x] App locks on background
- [x] Unlock screen on resume
- [x] Unlock screen on app start
- [x] Maximum attempts enforcement
- [x] Error messages for incorrect PIN
- [x] Prevent same PIN when changing

## Security Notes
⚠️ **Important Security Considerations:**
1. PIN is hashed with SHA-256 before storage
2. Cannot recover forgotten PIN (must remove and reset)
3. Biometric requires PIN as fallback
4. Maximum 5 attempts prevents brute force
5. App must be restarted after lockout

## Future Enhancements (Optional)
- [ ] Auto-lock timer (lock after X minutes of inactivity)
- [ ] 6-digit PIN option
- [ ] Pattern lock option
- [ ] Face recognition (custom ML implementation)
- [ ] Emergency PIN for data wipe
- [ ] Failed attempt notifications

## ✅ Feature Complete!
All security features are fully implemented and tested!
