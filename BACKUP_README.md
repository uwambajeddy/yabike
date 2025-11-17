# YaBike Backup System 🚀

## WhatsApp-like Backup Implementation

This backup system provides secure cloud storage for user data including wallets, transactions, budgets, and settings using Supabase backend.

## 🛠️ Setup Instructions

### 1. Supabase Configuration

First, you need to set up your Supabase project:

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Get your project URL and anon key from Settings > API
3. Update `main.dart` with your credentials:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',        // Replace with your actual URL
  anonKey: 'YOUR_SUPABASE_ANON_KEY', // Replace with your actual anon key
);
```

### 2. Database Schema

Create the backup table in your Supabase database by running this SQL:

```sql
CREATE TABLE user_backups (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  backup_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  data_size BIGINT NOT NULL DEFAULT 0,
  version INTEGER NOT NULL DEFAULT 1,
  wallets_data JSONB,
  transactions_data JSONB,
  budgets_data JSONB,
  settings_data JSONB,
  encryption_key TEXT,
  checksum TEXT
);

-- Add indexes for better performance
CREATE INDEX idx_user_backups_user_id ON user_backups(user_id);
CREATE INDEX idx_user_backups_created_at ON user_backups(created_at);

-- Add RLS (Row Level Security) policies
ALTER TABLE user_backups ENABLE ROW LEVEL SECURITY;

-- Allow users to only access their own backups
CREATE POLICY "Users can view own backups" ON user_backups
  FOR SELECT USING (auth.uid()::text = user_id);

CREATE POLICY "Users can insert own backups" ON user_backups
  FOR INSERT WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can update own backups" ON user_backups
  FOR UPDATE USING (auth.uid()::text = user_id);

CREATE POLICY "Users can delete own backups" ON user_backups
  FOR DELETE USING (auth.uid()::text = user_id);
```

### 3. Storage Bucket (Optional)

If you plan to store large backup files, create a storage bucket:

```sql
-- Create backup storage bucket
INSERT INTO storage.buckets (id, name, public) VALUES ('backup-storage', 'backup-storage', false);

-- Add storage policies
CREATE POLICY "Users can upload own backups" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'backup-storage' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can view own backups" ON storage.objects
  FOR SELECT USING (bucket_id = 'backup-storage' AND auth.uid()::text = (storage.foldername(name))[1]);
```

## 🎯 Features

### ✅ Core Functionality
- **Secure Backup**: Encrypt user data before storing in cloud
- **Auto Backup**: Daily automatic backups (configurable)
- **Manual Backup**: On-demand backup creation
- **Restore**: Full data restoration from any backup
- **Backup Management**: View, delete, and manage backup history
- **Progress Tracking**: Real-time backup/restore progress
- **Size Management**: Track backup sizes and enforce limits

### ✅ UI Components
- **Backup Screen**: WhatsApp-like interface for backup management
- **Onboarding Screen**: Introduction to backup features
- **Settings Integration**: Backup tile in settings with status
- **Progress Indicators**: Visual feedback for operations

### ✅ Security
- **Data Encryption**: All sensitive data encrypted before storage
- **User Authentication**: Row-level security ensuring data privacy
- **Checksum Validation**: Data integrity verification

## 📱 User Flow

### First Time Setup
1. User opens Settings → sees "Chat Backup" option
2. Taps backup tile → sees onboarding screen if no backups exist
3. Taps "Get Started" → navigates to backup management screen
4. Creates first backup manually or enables auto-backup

### Regular Usage
1. User can view backup status in settings
2. Manual backup creation with progress tracking
3. Restore from any previous backup
4. Auto-backup runs daily in background
5. Manage backup history (view/delete old backups)

## 🔧 Technical Architecture

### Components Structure
```
features/backup/
├── models/
│   └── backup_model.dart          # Data models
├── services/
│   └── backup_service.dart        # Core backup logic
├── screens/
│   ├── backup_screen.dart         # Main backup UI
│   └── backup_onboarding_screen.dart
└── widgets/
    └── backup_menu_tile.dart      # Settings integration
```

### Key Classes
- **BackupService**: Handles all backup operations (create/restore/delete)
- **BackupData**: Data model for backup structure
- **BackupScreen**: Main UI for backup management
- **BackupMenuTile**: Settings integration widget

## 🎨 UI Design

The backup system follows WhatsApp's design patterns:
- Clean, intuitive interface
- Progress indicators for operations
- Status indicators (last backup time, size, count)
- Auto-backup toggle
- Backup history with options to restore/delete

## 🚀 Usage Examples

### Initialize Backup Service
```dart
// Already set up in app.dart with Provider
final backupService = context.read<BackupService>();
```

### Create Manual Backup
```dart
final success = await backupService.createBackup();
if (success) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Backup created successfully!')),
  );
}
```

### Enable Auto Backup
```dart
await backupService.enableAutoBackup();
```

### Restore from Latest Backup
```dart
final success = await backupService.restoreFromLatestBackup();
```

### Navigate to Backup Screen
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => BackupScreen()),
);
```

## 🛡️ Security Considerations

1. **Data Encryption**: All sensitive data is encrypted before cloud storage
2. **User Authentication**: Supabase handles user authentication and authorization
3. **Row Level Security**: Database policies ensure users only access their own data
4. **Checksum Validation**: Backup integrity verification
5. **Size Limits**: Prevent excessive storage usage

## 📊 Monitoring & Analytics

The backup service tracks:
- Backup creation/restoration success rates
- Data sizes and growth trends
- Auto-backup frequency and reliability
- User engagement with backup features

## 🔧 Configuration

Key settings in `backup_constants.dart`:
- `autoBackupInterval`: How often auto-backup runs (default: 24 hours)
- `maxBackupsPerUser`: Maximum backups per user (default: 10)
- `maxBackupSizeMB`: Size limit per backup (default: 100 MB)

## 🎯 Next Steps

1. **Update Supabase credentials** in `main.dart`
2. **Create database table** using the SQL schema above
3. **Test backup functionality** in the app
4. **Customize UI colors/styling** to match your app theme
5. **Add authentication** if not already implemented
6. **Configure auto-backup settings** based on your needs

## 📞 Support

For issues or questions about the backup system:
1. Check the error messages in `BackupErrors` class
2. Verify Supabase configuration and database schema
3. Ensure proper authentication is set up
4. Check console logs for detailed error information

The backup system is designed to be robust, secure, and user-friendly, following WhatsApp's proven UX patterns for data backup and restoration.