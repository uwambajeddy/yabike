# SMS Integration Implementation

## Overview
Implemented complete SMS-based auto-import feature for Android users, allowing automatic wallet creation and transaction import from Equity Bank and MTN Mobile Money SMS messages.

## Date
January 2025

## Features Implemented

### 1. SMS Parser Service (`lib/data/services/sms_parser_service.dart`)
**Purpose**: Extract transaction data from bank and mobile money SMS messages

**Key Components**:
- `parseEquityBankSMS()`: Parses Equity Bank transaction messages
  - Sent transactions: Amount, currency, recipient, reference, charges
  - Received transactions: Amount, currency, sender, account, reference
  
- `parseMTNMoMoSMS()`: Parses MTN Mobile Money transaction messages
  - Sent money: Amount, recipient, balance, transaction ID, fee
  - Received money: Amount, sender, balance, transaction ID
  - Airtime purchase: Amount, phone number, balance, transaction ID, fee

**Regex Patterns**:
- Equity sent: `(\d+\.?\d*)\s+(RWF|USD)\s+(?:was successfully sent|has been successfully sent)\s+to\s+(.+?)\s+(\d{10,}|4\*+\d+).*?Ref\.\s+([A-Z0-9]+).*?(?:Charges?|Transaction charge)\s+(\d+\.?\d*)\s+USD`
- Equity received: `You have received\s+(\d+\.?\d*)\s+(RWF|USD)\s+from\s+(.+?)\s+(4\*+\d+).*?Equity account\s+(4\*+\d+).*?Ref\.\s+([A-Z0-9]+)`
- MoMo sent: `You have sent\s+(\d+)\s+Rwf\s+to\s+(.+?)\s+(\d{10}).*?New balance is\s+(\d+(?:,\d+)?)\s+Rwf.*?Transaction ID[:\s]+([A-Z0-9]+).*?Fee\s+(\d+)\s+Rwf`
- MoMo received: `You have received\s+(\d+)\s+Rwf\s+from\s+(.+?)\s+(\d{10}).*?New balance.*?(\d+(?:,\d+)?)\s+Rwf.*?Transaction ID[:\s]+([A-Z0-9]+)`
- MoMo airtime: `You have bought\s+(\d+)\s+Rwf\s+airtime for\s+(\d{10}).*?New balance.*?(\d+(?:,\d+)?)\s+Rwf.*?Transaction ID[:\s]+([A-Z0-9]+).*?Fee\s+(\d+)\s+Rwf`

### 2. SMS Integration ViewModel (`lib/features/sms_integration/viewmodels/sms_integration_viewmodel.dart`)
**Purpose**: Manage SMS permission flow and auto-import process

**States**:
- `initial`: Not started
- `requestingPermission`: Requesting SMS permission
- `permissionGranted`: Permission granted, ready to scan
- `permissionDenied`: Permission denied by user
- `scanning`: Scanning SMS inbox
- `parsing`: Parsing messages into transactions
- `creatingWallets`: Creating wallets from transactions
- `completed`: Process finished successfully
- `error`: Error occurred during process

**Key Methods**:
- `requestSmsPermission(BuildContext)`: Request READ_SMS permission using permission_handler
- `scanAndImportSms()`: Main orchestrator - scan → parse → create wallets
- `_parseSmsMessages(List<SmsMessage>)`: Convert SMS messages to Transaction objects
- `_createWalletsFromTransactions()`: Group transactions by source and create wallets
  - Equity Bank: Calculate balance from transaction sum
  - MTN MoMo: Use most recent balance from messages or calculate

**Progress Tracking**:
- `totalMessages`: Total messages to process
- `processedMessages`: Messages processed so far
- `progress`: Completion percentage (0.0 to 1.0)

### 3. SMS Terms Screen (`lib/features/sms_integration/screens/sms_terms_screen.dart`)
**Purpose**: Display privacy policy and request user consent

**UI Components**:
- Title: "SMS Access Permission"
- 4 Information sections with icons:
  1. **What we access**: Explains reading financial SMS
  2. **Your privacy matters**: Local processing, no external servers
  3. **What happens next**: Steps after granting permission
  4. **You're in control**: Can revoke anytime
- Checkbox: "I agree to grant YaBike access to my SMS messages"
- Continue button (disabled until checkbox checked)

**Flow**:
1. User reads terms
2. Checks agreement checkbox
3. Taps Continue
4. ViewModel requests SMS permission
5. If granted → Navigate to loading screen
6. If denied → Show dialog with Skip/Try Again options
7. If permanently denied → Show dialog with Skip/Open Settings options

### 4. SMS Loading Screen (`lib/features/sms_integration/screens/sms_loading_screen.dart`)
**Purpose**: Show progress during SMS import

**UI Components**:
- Animated icon (message icon with scale animation)
- State-based title and description:
  - Scanning: "Scanning Messages" / "Searching for Equity Bank and MTN MoMo messages"
  - Parsing: "Processing Transactions" / "Extracting transaction details from your messages"
  - Creating Wallets: "Creating Wallets" / "Setting up your wallets and importing transactions"
  - Completed: "All Done!" / "Your wallets have been created successfully!"
- Progress indicator:
  - Linear progress bar when messages > 0
  - Progress text: "X of Y messages processed"
  - Circular spinner when scanning
- Info banner: "This may take a few moments depending on your message history"

**State Handling**:
- Listens to `SmsIntegrationViewModel` state changes
- On `completed`: Navigate to home screen
- On `error`: Show error dialog with "Continue Manually" option

### 5. Platform-Aware Routing

**Onboarding Screen** (`lib/features/onboarding/screens/onboarding_screen.dart`):
```dart
final isAndroid = defaultTargetPlatform == TargetPlatform.android;

if (isAndroid) {
  Navigator.pushReplacementNamed(context, AppRoutes.smsTerms);
} else {
  Navigator.pushReplacementNamed(context, AppRoutes.createWallet);
}
```

**App Routes** (`lib/core/routes/app_routes.dart`):
- Added `smsTerms` route: `/sms/terms`
- Added `smsLoading` route: `/sms/loading`
- Provider wrappers for SMS integration screens

## Technical Details

### Packages Used
- `permission_handler` v11.3.0: Request SMS permission
- `sms_advanced` v1.1.0: Read SMS messages
- `provider` v6.1.0: State management

### Permissions Required (Android)
```xml
<uses-permission android:name="android.permission.READ_SMS" />
```

### Data Flow
```
User completes onboarding (Android)
  ↓
SMS Terms Screen
  ↓
User agrees & taps Continue
  ↓
ViewModel requests SMS permission
  ↓
If granted → Navigate to Loading Screen
  ↓
ViewModel.scanAndImportSms()
  ↓
1. Query SMS inbox/sent (filter: EQUITY, MTNMOMO)
  ↓
2. Parse each message → Transaction objects
  ↓
3. Group transactions by source (EQUITYBANK, MTNMOMO)
  ↓
4. Create wallets:
   - Equity Bank wallet (balance = sum of transactions)
   - MTN MoMo wallet (balance = from message or sum)
  ↓
5. Assign wallet IDs to transactions
  ↓
State = completed
  ↓
Navigate to Home screen
```

### Error Handling
- Permission denied: Dialog with Skip/Try Again
- Permission permanently denied: Dialog with Skip/Open Settings
- Parse error: Skip message, continue processing
- Import error: Show error dialog, allow manual wallet creation

### Wallet Creation Logic

**Equity Bank**:
- Name: "Equity Bank"
- Type: "bank"
- Provider: "EquityBank"
- Currency: "RWF"
- Balance: Calculated by summing all transactions (credits - debits)

**MTN MoMo**:
- Name: "MTN Mobile Money"
- Type: "momo"
- Provider: "MTN"
- Currency: "RWF"
- Balance: Most recent balance from message, or calculated sum if unavailable

## Files Created

```
lib/data/services/
  └── sms_parser_service.dart

lib/features/sms_integration/
  ├── screens/
  │   ├── sms_terms_screen.dart
  │   └── sms_loading_screen.dart
  └── viewmodels/
      └── sms_integration_viewmodel.dart
```

## Files Modified

```
lib/core/routes/app_routes.dart
  - Added smsTerms and smsLoading routes
  - Added SMS integration imports

lib/features/onboarding/screens/onboarding_screen.dart
  - Added platform check
  - Route Android to smsTerms, iOS to createWallet

lib/data/services/sms_parser_service.dart
  - Fixed unused variable warnings (senderAccount, senderPhone)
```

## Design Consistency
- Uses Plus Jakarta Sans typography
- Primary green (#66BB6A) color scheme
- 4px base spacing system
- Material Design 3 components
- Animated loading states
- Comprehensive error handling

## Sample Transaction Data Supported

**Equity Bank Examples**:
- "1,000.00 RWF was successfully sent to John Doe 0788123456. MTN Ref. EQ123456. Ref. EQ123456 on 15/01/2025 at 14:30 CAT. Charges 0.00 USD"
- "You have received 5,000.00 RWF from Jane Smith 4***1234 to your Equity account 4***5678. Ref. EQ789012 on 15/01/2025 at 10:15 CAT"

**MTN MoMo Examples**:
- "You have sent 2,000 Rwf to Peter Parker 0788987654. New balance is 50,000 Rwf. Transaction ID: MM123456789. Fee 50 Rwf"
- "You have received 3,000 Rwf from Mary Jane 0788111222. New balance is 53,000 Rwf. Transaction ID: MM987654321"
- "You have bought 1,000 Rwf airtime for 0788123456. New balance is 52,000 Rwf. Transaction ID: MM111222333. Fee 0 Rwf"

## Next Steps (Not Implemented)
1. **Database Persistence**: Save wallets and transactions to Hive
2. **Home Screen**: Display created wallets with balances
3. **Transaction List**: Show imported transactions
4. **Manual Wallet Creation**: Allow adding wallets manually (iOS flow)
5. **Error Analytics**: Track parsing failures for regex improvements
6. **Multi-Currency Support**: Handle USD transactions properly (current: hardcoded 1300 conversion)
7. **Account Linking**: Allow users to link specific phone numbers to wallets

## Testing Recommendations
1. Test with real SMS samples from Equity Bank and MTN MoMo
2. Test permission denial flows
3. Test with large message histories (100+ messages)
4. Test on different Android versions (API 24+)
5. Verify balance calculations match actual wallet balances
6. Test iOS fallback to manual creation

## Known Limitations
1. Only supports Equity Bank and MTN Mobile Money
2. Regex patterns may not cover all message format variations
3. USD to RWF conversion is hardcoded (1300 rate)
4. No support for Airtel Money or other providers yet
5. Requires Android for SMS auto-import
6. No batch import UI for reviewing before saving

---

**Status**: ✅ Complete - Ready for database integration and home screen implementation
