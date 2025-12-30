# Admin Dashboard - Quick Setup

## Prerequisites
- Flutter SDK installed
- Supabase project with SmartQueue database

## Setup Steps

1. **Navigate to admin directory**
   ```bash
   cd flutter_admin
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   
   Edit `lib/main.dart` (lines 10-12):
   ```dart
   await AdminService.initialize(
     url: 'https://your-project.supabase.co',
     anonKey: 'your-anon-key-here',
   );
   ```

4. **Run the app**
   
   **For Web:**
   ```bash
   flutter run -d chrome
   ```
   
   **For Windows Desktop:**
   ```bash
   flutter run -d windows
   ```

## Testing the Dashboard

1. **View Queue**: Dashboard shows all waiting customers in real-time

2. **Call Next**: Click the violet "Call Next Customer" button
   - Moves top customer to "serving"
   - Updates positions automatically
   - Shows notification with customer details

3. **AI Predictor**: Click "Run AI Predictor"
   - Analyzes last 5 completed tickets
   - Calculates actual average service time
   - Updates database automatically
   - Shows improvement metrics

## Testing AI Predictor

To test the AI Predictor, you need completed tickets:

1. Add some customers via the customer app
2. Call them using "Call Next"
3. Complete their service:
   ```sql
   -- Run in Supabase SQL Editor
   UPDATE queues 
   SET status = 'done', updated_at = NOW() 
   WHERE status = 'serving';
   ```
4. Repeat 5 times
5. Run AI Predictor in admin dashboard

## Common Issues

- **Empty dashboard**: Add businesses and customers using customer app
- **AI Predictor returns default**: Need at least 1 completed ticket
- **Not updating**: Check Supabase credentials in main.dart

## Keyboard Shortcuts

- `Ctrl+R` / `Cmd+R`: Refresh statistics
- `F5`: Reload app (web only)
