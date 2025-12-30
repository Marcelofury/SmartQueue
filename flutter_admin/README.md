# SmartQueue Admin Dashboard

Flutter web/desktop application for managing the SmartQueue virtual queue system.

## Features

- 📊 Real-time dashboard with live queue updates
- 📞 Call Next button to move customers to serving status
- 🤖 AI Predictor to calculate actual service times
- 📈 Statistics cards (waiting, serving, completed)
- 🔄 Automatic position recalculation
- 🎨 Professional admin theme with violet accents

## AI Predictor

The AI Predictor analyzes the last 5 completed service tickets to calculate the actual average service time. It:

1. Fetches the 5 most recently completed tickets
2. Calculates the time between `created_at` and `updated_at` for each ticket
3. Filters out invalid times (< 1 min or > 120 min)
4. Computes the average service time
5. Updates the business's `avg_service_time` automatically
6. Shows before/after comparison with improvement percentage

This helps the system provide more accurate wait time estimates based on real-world data.

## Setup Instructions

### 1. Install Dependencies

```bash
cd flutter_admin
flutter pub get
```

### 2. Configure Supabase

Edit `lib/main.dart` and replace the placeholders with your Supabase credentials:

```dart
await AdminService.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

### 3. Run on Web

```bash
flutter run -d chrome
```

### 4. Run on Desktop

**Windows:**
```bash
flutter run -d windows
```

**macOS:**
```bash
flutter run -d macos
```

**Linux:**
```bash
flutter run -d linux
```

## Project Structure

```
flutter_admin/
├── lib/
│   ├── config/
│   │   └── theme.dart               # Admin dashboard theme
│   ├── screens/
│   │   └── dashboard_screen.dart    # Main dashboard
│   ├── services/
│   │   └── admin_service.dart       # Supabase API & AI Predictor
│   ├── widgets/
│   │   ├── stat_card.dart           # Statistics display card
│   │   └── queue_list_card.dart     # Real-time queue list
│   └── main.dart                     # App entry point
├── web/
│   └── index.html                    # Web entry point
├── pubspec.yaml                      # Dependencies
└── README.md
```

## Dashboard Features

### Statistics Cards
- **Waiting**: Number of customers in queue
- **Serving**: Number of customers being served
- **Completed**: Total completed services
- **Avg Service Time**: Current average service time

### Call Next Button
- Moves the top customer from "waiting" to "serving"
- Automatically recalculates positions for remaining customers
- Shows notification with customer name and phone
- Updates all statistics in real-time

### AI Predictor Button
- Analyzes last 5 completed tickets
- Calculates actual average service time
- Updates the database automatically
- Shows detailed analysis results:
  - Previous average time
  - New average time
  - Time difference
  - Improvement percentage

### Queue List
- Real-time updates using Supabase streams
- Shows all waiting customers
- Displays position, name, phone, and time joined
- Highlights next customer to be called
- Auto-updates when customers are added or called

## AI Predictor Algorithm

```dart
// Pseudo-code
1. Query last 5 completed tickets from database
2. For each ticket:
   a. Calculate service_time = updated_at - created_at
   b. Validate: 1 min <= service_time <= 120 min
   c. Add to running total if valid
3. Calculate average = total_time / valid_tickets
4. Update business.avg_service_time in database
5. Return analysis results
```

### Example Output

```
AI Analysis Complete!

Previous Avg: 15 min
New Avg: 12 min
Difference: -3 min
Improvement: 20.0%
```

## Real-Time Features

The dashboard uses Supabase Realtime to provide live updates:

- Queue list updates automatically when customers join
- Statistics refresh when status changes
- No manual refresh needed
- Sub-second update latency

## Theme

Professional dashboard theme with:
- Primary: Violet (#7C3AED)
- Background: Light gray (#F7FAFC)
- Cards: White with subtle borders
- Status colors: Amber (waiting), Green (serving), Gray (done)

## API Methods

### AdminService

```dart
// Get waiting queue
getWaitingQueue(businessId)

// Stream real-time updates
streamWaitingQueue(businessId)

// Call next customer
callNext(businessId)

// Run AI predictor
runAIPredictor(businessId)

// Get statistics
getQueueStatistics(businessId)
```

## Production Deployment

### Web Deployment

1. Build for web:
```bash
flutter build web --release
```

2. Deploy the `build/web` folder to:
   - Firebase Hosting
   - Netlify
   - Vercel
   - GitHub Pages

### Desktop Distribution

1. Build for your platform:
```bash
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

2. Distribute the built executables from:
   - `build/windows/runner/Release/`
   - `build/macos/Build/Products/Release/`
   - `build/linux/release/bundle/`

## Troubleshooting

**Issue**: No businesses showing
- Ensure database has at least one business
- Run the schema.sql to create sample business

**Issue**: Real-time not working
- Check Supabase Realtime is enabled in dashboard
- Verify anon key has proper permissions
- Check browser console for errors

**Issue**: AI Predictor shows no change
- Need at least 1 completed ticket in database
- Manually complete some test services first
- Check that tickets have valid timestamps

## Future Enhancements

1. Multiple business selection
2. Historical analytics and charts
3. SMS notification triggers
4. Customer wait time alerts
5. Performance metrics dashboard
6. Export data to CSV/Excel
7. Business hours management
8. Staff management and roles

## License

College MVP Project - SmartQueue
