# Flutter Customer App - Quick Setup

## Before Running

1. **Get Supabase Credentials**
   - Go to your Supabase project dashboard
   - Navigate to Settings > API
   - Copy your `Project URL` and `anon/public key`

2. **Update Credentials**
   Edit `lib/main.dart` (lines 12-14):
   ```dart
   await SupabaseService.initialize(
     url: 'https://your-project.supabase.co',
     anonKey: 'your-anon-key-here',
   );
   ```

3. **Get Business ID**
   - Run this SQL in Supabase SQL Editor:
   ```sql
   SELECT id FROM businesses LIMIT 1;
   ```
   - Copy the UUID
   - Update in `lib/screens/home_screen.dart` (line 20):
   ```dart
   final String _defaultBusinessId = 'paste-uuid-here';
   ```

4. **Install and Run**
   ```bash
   cd flutter_customer
   flutter pub get
   flutter run
   ```

## Testing the App

1. **Join Queue Manually**
   - Enter name and phone
   - Click "Join Queue"
   - See real-time position updates

2. **Test QR Scanner**
   - Tap the violet QR button
   - Grant camera permissions
   - Point at a QR code with business ID

3. **USSD Demo**
   - Long-press on "SmartQueue v1.0" text
   - Navigate retro menu with keypad
   - Great for presentations!

## Common Issues

- **Can't connect**: Check Supabase credentials in main.dart
- **No camera**: Grant camera permissions in device settings
- **Wrong business**: Update _defaultBusinessId in home_screen.dart
