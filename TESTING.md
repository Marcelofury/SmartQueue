# SmartQueue - Testing & Verification Guide

Complete guide to verify that all components of SmartQueue are working correctly.

## 📋 Pre-Flight Checklist

Before starting, ensure you have:
- [ ] Supabase account created
- [ ] Supabase project initialized with schema
- [ ] Environment variables configured
- [ ] Docker installed (for Docker setup) OR Node.js 18+ (for local setup)
- [ ] Flutter SDK installed (for mobile/admin apps)

## 🚀 Quick Verification (5 Minutes)

### Step 1: Start the Backend

**Option A: Using Docker (Recommended)**
```bash
# Navigate to project root
cd SmartQueue

# Start services
docker-compose up -d

# Check if services are running
docker-compose ps

# Expected output:
# NAME                  STATUS
# smartqueue_backend    Up (healthy)
# smartqueue_db         Up (healthy)
```

**Option B: Local Setup**
```bash
cd backend
npm install
npm run dev

# Expected output:
# SmartQueue server running on port 3000
# ✓ Twilio SMS service initialized (or warning if not configured)
```

### Step 2: Verify Backend is Running

Open your browser or use curl:

```bash
# Test 1: Health Check
curl http://localhost:3000/

# Expected: {"message":"SmartQueue API is running"}

# Test 2: Check if Supabase is connected (should return empty array initially)
curl http://localhost:3000/api/queue/list/YOUR_BUSINESS_ID
```

If you see errors, jump to [Troubleshooting](#troubleshooting-common-issues) section.

### Step 3: Get Your Business ID

You need the business ID for testing. Run this in Supabase SQL Editor:

```sql
SELECT id, name, avg_service_time FROM businesses;
```

Copy the `id` value. You'll use this throughout testing.

## 🧪 Complete System Test

### Test 1: Backend API ✅

#### 1.1 Join Queue (Create Customer)

```bash
# Replace YOUR_BUSINESS_ID with actual ID from Supabase
curl -X POST http://localhost:3000/api/queue/join \
  -H "Content-Type: application/json" \
  -d '{
    "business_id": "YOUR_BUSINESS_ID",
    "customer_name": "Test Customer",
    "phone_number": "+1234567890"
  }'
```

**Expected Response:**
```json
{
  "message": "Successfully joined the queue",
  "queue_entry": {
    "id": "some-uuid",
    "customer_name": "Test Customer",
    "phone_number": "+1234567890",
    "position": 1,
    "status": "waiting"
  },
  "estimated_wait_time": 0,
  "wait_time_unit": "minutes"
}
```

✅ **Success**: You got a JSON response with queue_entry  
❌ **Failed**: See [Backend Troubleshooting](#backend-issues)

#### 1.2 Check Queue Status

```bash
# Use the queue_id from previous response
curl http://localhost:3000/api/queue/status/QUEUE_ID_HERE
```

**Expected**: Customer details with position and status "waiting"

#### 1.3 View Queue List

```bash
curl http://localhost:3000/api/queue/list/YOUR_BUSINESS_ID
```

**Expected**: Array with your test customer

#### 1.4 Call Next Customer (Tests SMS)

```bash
curl -X POST http://localhost:3000/api/queue/next/YOUR_BUSINESS_ID
```

**Expected Response:**
```json
{
  "message": "Next customer called",
  "customer": { ... },
  "sms_sent": true  // or false if Twilio not configured
}
```

**Check Console**: You should see either:
- `✓ SMS sent to +1234567890: SMxxxxxxxx` (if Twilio configured)
- `[SMS DISABLED] Would send to +1234567890: ...` (if Twilio not configured)

✅ **Success**: Customer status changed to "serving"  
⚠️ **Warning**: If sms_sent is false, SMS won't be sent (this is OK for testing)

### Test 2: Flutter Customer App 📱

#### 2.1 Configure App

```bash
cd flutter_customer
flutter pub get
```

Edit `lib/main.dart` (lines 12-14):
```dart
await SupabaseService.initialize(
  url: 'YOUR_SUPABASE_URL',  // Paste your actual URL
  anonKey: 'YOUR_SUPABASE_ANON_KEY',  // Paste your actual key
);
```

Also update `lib/screens/home_screen.dart` (line 20):
```dart
final String _defaultBusinessId = 'YOUR_BUSINESS_ID';  // Paste actual ID
```

#### 2.2 Run App

```bash
flutter run
```

**Expected**: App launches without errors

#### 2.3 Test Features

1. **Manual Join**:
   - Enter name: "Test User"
   - Enter phone: "+1234567890"
   - Click "Join Queue"
   - ✅ Should navigate to queue screen

2. **Queue Screen**:
   - ✅ Shows your position
   - ✅ Shows estimated wait time
   - ✅ Updates in real-time

3. **QR Scanner** (Optional):
   - Tap "Scan QR Code"
   - ✅ Camera opens with overlay
   - Grant camera permission if asked

4. **USSD Simulator**:
   - Long-press "SmartQueue v1.0" text at bottom
   - ✅ Opens retro menu interface

### Test 3: Flutter Admin Dashboard 💻

#### 3.1 Configure Dashboard

```bash
cd flutter_admin
flutter pub get
```

Edit `lib/main.dart` (lines 10-12):
```dart
await AdminService.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

#### 3.2 Run Dashboard

**For Web:**
```bash
flutter run -d chrome
```

**For Desktop:**
```bash
flutter run -d windows  # or macos/linux
```

**Expected**: Dashboard opens in browser/window

#### 3.3 Test Features

1. **View Statistics**:
   - ✅ See "Waiting", "Serving", "Completed" counts
   - ✅ See "Avg Service Time"

2. **View Queue List**:
   - ✅ See customers in waiting list
   - ✅ "Live Updates" badge shows
   - ✅ Next customer highlighted

3. **Call Next Button**:
   - Click "Call Next Customer"
   - ✅ Shows notification: "Called: [Name] ([Phone])"
   - ✅ Queue list updates automatically
   - ✅ Statistics update

4. **AI Predictor**:
   - Click "Run AI Predictor"
   - ⚠️ Need at least 1 completed ticket for accurate results
   - ✅ Shows analysis result

### Test 4: Real-Time Updates 🔄

This tests Supabase real-time streaming.

#### 4.1 Setup
- Open Customer App on phone/emulator
- Open Admin Dashboard on computer
- Join queue from Customer App

#### 4.2 Test Real-Time Sync
1. Customer joins queue → ✅ Admin dashboard updates immediately
2. Admin calls next → ✅ Customer app status changes to "serving"
3. Both apps should update within 1-2 seconds

✅ **Success**: Changes appear instantly on both apps  
❌ **Failed**: Check Supabase Realtime is enabled

### Test 5: SMS Notifications 📲 (Optional)

Only if you have Twilio configured.

#### 5.1 Configure Twilio

Add to `backend/.env`:
```env
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_PHONE_NUMBER=+1234567890
```

Restart backend:
```bash
# Docker
docker-compose restart backend

# Local
# Press Ctrl+C and run: npm run dev
```

#### 5.2 Test SMS

1. Join queue with YOUR REAL PHONE NUMBER (with country code):
```bash
curl -X POST http://localhost:3000/api/queue/join \
  -H "Content-Type: application/json" \
  -d '{
    "business_id": "YOUR_BUSINESS_ID",
    "customer_name": "Your Name",
    "phone_number": "+YOUR_REAL_PHONE"
  }'
```

2. Call next from Admin Dashboard or API:
```bash
curl -X POST http://localhost:3000/api/queue/next/YOUR_BUSINESS_ID
```

3. Check your phone:
   - ✅ Should receive SMS within 5-30 seconds
   - Message: "Hi [Name]! 🎉 Your turn is coming up..."

#### 5.3 Verify in Twilio Console

1. Go to [Twilio Console](https://console.twilio.com/)
2. Click "Monitor" → "Logs" → "Messaging"
3. ✅ See your message with status "delivered"

## 🐳 Docker-Specific Tests

If using Docker, verify containerization:

### Check Container Health

```bash
# View all containers
docker-compose ps

# Check backend logs
docker-compose logs backend --tail 50

# Check postgres logs
docker-compose logs postgres --tail 50

# Test backend from inside container
docker exec smartqueue_backend node -e "console.log('Container test OK')"
```

### Test Database Connection

```bash
# Connect to PostgreSQL (optional - needs pgAdmin or psql)
docker exec -it smartqueue_db psql -U smartqueue -d smartqueue

# Inside psql, run:
\dt  # List tables
SELECT * FROM businesses;
SELECT * FROM queues;
\q  # Exit
```

### Test with pgAdmin (Optional)

```bash
# Start pgAdmin
docker-compose --profile tools up -d

# Open browser: http://localhost:5050
# Login: admin@smartqueue.local / admin123
# Add server:
#   Host: postgres
#   Port: 5432
#   Database: smartqueue
#   Username: smartqueue
#   Password: smartqueue123
```

## ✅ Final Verification Checklist

Run through this checklist to confirm everything works:

### Backend
- [ ] Server starts without errors
- [ ] Health check returns 200 OK
- [ ] Can join queue via API
- [ ] Can get queue status
- [ ] Can call next customer
- [ ] SMS logs appear in console (or sends if Twilio configured)

### Customer App
- [ ] App launches successfully
- [ ] Can join queue manually
- [ ] Queue screen shows position
- [ ] Real-time updates work
- [ ] QR scanner opens (camera permission granted)
- [ ] USSD simulator accessible

### Admin Dashboard
- [ ] Dashboard loads
- [ ] Statistics display correctly
- [ ] Queue list shows waiting customers
- [ ] "Call Next" button works
- [ ] Real-time updates work
- [ ] AI Predictor runs (after completing tickets)

### Integration
- [ ] Customer joins → appears in admin dashboard
- [ ] Admin calls next → customer app updates
- [ ] SMS sent to customer (if Twilio configured)
- [ ] Queue positions update automatically

## 🔧 Troubleshooting Common Issues

### Backend Issues

**"Cannot connect to Supabase"**
```bash
# Check your .env file
cat backend/.env

# Verify credentials in Supabase dashboard
# Settings > API > Project URL and anon key
```

**"Port 3000 already in use"**
```bash
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Mac/Linux
lsof -ti:3000 | xargs kill -9
```

**"No businesses found"**
```sql
-- Run in Supabase SQL Editor
INSERT INTO businesses (name, avg_service_time) 
VALUES ('Test Business', 15);
```

### Docker Issues

**"Container exits immediately"**
```bash
# Check logs for errors
docker-compose logs backend

# Common fix: Rebuild
docker-compose down
docker-compose up -d --build
```

**"Cannot connect to postgres"**
```bash
# Check postgres is healthy
docker-compose ps

# Restart postgres
docker-compose restart postgres

# Wait 10 seconds, then restart backend
docker-compose restart backend
```

### Flutter Issues

**"Supabase not initialized"**
- Check credentials in `lib/main.dart`
- Ensure internet connection
- Run `flutter clean` then `flutter pub get`

**"Business ID not found"**
- Update `_defaultBusinessId` in `lib/screens/home_screen.dart`
- Get ID from Supabase: `SELECT id FROM businesses;`

**"QR scanner black screen"**
- Grant camera permissions in device settings
- Android: Check AndroidManifest.xml has camera permission
- iOS: Check Info.plist has NSCameraUsageDescription

### SMS Issues

**"SMS not sending"**
```bash
# Check Twilio credentials
echo $TWILIO_ACCOUNT_SID
echo $TWILIO_PHONE_NUMBER

# Check backend logs
docker-compose logs backend | grep -i twilio

# Verify phone number format includes country code
# Correct: +1234567890
# Wrong: 1234567890
```

**"Message shows as 'disabled'"**
- This is normal if Twilio not configured
- System works fine without SMS
- Add Twilio credentials to enable SMS

## 📊 Performance Testing

Test with multiple customers:

```bash
# Add 10 customers quickly
for i in {1..10}; do
  curl -X POST http://localhost:3000/api/queue/join \
    -H "Content-Type: application/json" \
    -d "{
      \"business_id\": \"YOUR_BUSINESS_ID\",
      \"customer_name\": \"Customer $i\",
      \"phone_number\": \"+123456789$i\"
    }"
done

# Check queue
curl http://localhost:3000/api/queue/list/YOUR_BUSINESS_ID
```

Verify:
- ✅ All customers added successfully
- ✅ Positions are sequential (1, 2, 3, ...)
- ✅ Admin dashboard shows all customers
- ✅ Real-time updates still fast

## 🎯 Next Steps

Once everything is verified:

1. **Customize**: Update business name, service times
2. **Brand**: Change colors in theme files
3. **Deploy**: See [README.md](README.md) for deployment options
4. **Monitor**: Check logs regularly for errors
5. **Scale**: Add more businesses, configure load balancing

## 📞 Getting Help

If you're still having issues:

1. Check logs: `docker-compose logs -f backend`
2. Review [README.md](README.md) troubleshooting section
3. Verify all environment variables are set correctly
4. Ensure Supabase schema is initialized
5. Check Supabase project is not paused (free tier)

---

**All tests passed?** 🎉 Congratulations! Your SmartQueue system is fully operational!
