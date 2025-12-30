# SmartQueue Customer App

Flutter mobile application for SmartQueue virtual queue management system.

## Features

- 🎨 Modern violet/white theme
- 📱 QR Code scanning for quick check-in
- ✍️ Manual queue joining with name and phone
- ⏱️ Real-time queue position and wait time updates
- 📊 Live status tracking using Supabase streams
- 📞 Hidden USSD simulator for demo purposes

## Setup Instructions

### 1. Install Dependencies

```bash
cd flutter_customer
flutter pub get
```

### 2. Configure Supabase

Edit `lib/main.dart` and replace the placeholders with your Supabase credentials:

```dart
await SupabaseService.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

You can find these in your Supabase project settings under **Project Settings > API**.

### 3. Update Business ID (Optional)

In `lib/screens/home_screen.dart`, update the default business ID:

```dart
final String _defaultBusinessId = 'YOUR_BUSINESS_ID_HERE';
```

Or the app will automatically use the first business from your database.

### 4. Run the App

```bash
flutter run
```

## Project Structure

```
flutter_customer/
├── lib/
│   ├── config/
│   │   └── theme.dart                 # App theme configuration
│   ├── screens/
│   │   ├── home_screen.dart          # Main screen with QR & manual join
│   │   ├── queue_screen.dart         # Real-time queue status
│   │   └── ussd_screen.dart          # USSD simulator
│   ├── services/
│   │   └── supabase_service.dart     # Supabase API integration
│   └── main.dart                      # App entry point & routing
├── pubspec.yaml                       # Dependencies
└── README.md
```

## Screens

### Home Screen (`/`)
- Large QR scan button with gradient design
- Manual join form with name and phone fields
- Input validation
- Long-press on version text to access USSD simulator

### Queue Screen (`/queue/:queueId`)
- Real-time position tracking with animated pulsing effect
- Estimated wait time display
- Status indicators (waiting, serving, done)
- Visual feedback for different states
- Auto-updates using Supabase streams

### USSD Simulator (`/ussd`)
- Retro mobile phone dialer interface
- Green monochrome display
- Interactive keypad
- Menu navigation (Join Queue, Check Status, About)
- Demo feature for presentations

## Dependencies

- `supabase_flutter: ^2.0.0` - Supabase client for real-time data
- `mobile_scanner: ^3.5.5` - QR code scanning
- `go_router: ^12.1.3` - Navigation and routing
- `google_fonts: ^6.1.0` - Typography
- `intl: ^0.18.1` - Date/time formatting
- `shared_preferences: ^2.2.2` - Local storage

## Features in Detail

### QR Code Scanning
- Tap the large violet QR button
- Camera opens with custom overlay
- Scan business QR code
- Auto-prompts for name and phone
- Instantly joins queue

### Real-Time Updates
The queue screen uses Supabase's real-time capabilities:
```dart
_supabaseService.streamQueueStatus(widget.queueId)
```
Updates automatically when:
- Position changes
- Status updates (waiting → serving → done)
- Wait time recalculates

### Wait Time Calculation
```
Wait Time = (Position - 1) × Average Service Time
```

Example:
- Position 1: 0 minutes (being served)
- Position 3: 30 minutes (if avg service time = 15 min)

## Theme

Custom violet/white color scheme:
- Primary: `#7C3AED` (Violet)
- Light: `#9F7AEA` 
- Dark: `#5B21B6`
- Pale: `#EDE9FE`

## Camera Permissions

### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required to scan QR codes</string>
```

## Hidden Features

- **USSD Simulator**: Long-press on "SmartQueue v1.0" text at bottom of home screen
- **Direct URL Navigation**: Can navigate to `/ussd` directly if you know the route

## Next Steps

1. Implement push notifications for turn alerts
2. Add SMS integration
3. Add queue history
4. Implement user accounts
5. Add business selection screen
6. Multi-language support

## Troubleshooting

**Issue**: QR scanner not opening
- Ensure camera permissions are granted
- Check device camera is working
- Verify `mobile_scanner` package installation

**Issue**: Real-time updates not working
- Check Supabase URL and anon key
- Verify Supabase Realtime is enabled
- Check internet connection

**Issue**: Cannot join queue
- Verify business ID exists in database
- Check Supabase connection
- Ensure backend API is running

## License

College MVP Project - SmartQueue
