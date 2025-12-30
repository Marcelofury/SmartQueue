# SmartQueue - Quick Start Guide

Get SmartQueue running in under 5 minutes!

## 🚀 Fastest Way: Docker

### 1. Prerequisites
- Docker Desktop installed
- Supabase account (free)

### 2. Setup

```bash
# Clone and navigate
git clone <repo-url>
cd SmartQueue

# Configure environment
cp .env.example .env
# Edit .env with your Supabase and Twilio credentials

# Start everything
docker-compose up -d

# Verify
docker-compose ps
```

### 3. Access

- **Backend API**: http://localhost:3000
- **Database**: localhost:5432
- **pgAdmin** (optional): http://localhost:5050

### 4. Setup Supabase

1. Go to [supabase.com](https://supabase.com) and create project
2. Run `database/schema.sql` in SQL Editor
3. Get credentials from Settings > API
4. Update `.env` file

### 5. Setup Twilio (Optional)

1. Sign up at [twilio.com](https://www.twilio.com/try-twilio)
2. Get phone number
3. Copy Account SID, Auth Token, Phone Number
4. Update `.env` file

### 6. Run Flutter Apps

**Customer App:**
```bash
cd flutter_customer
flutter pub get
# Edit lib/main.dart with Supabase credentials
flutter run
```

**Admin Dashboard:**
```bash
cd flutter_admin
flutter pub get
# Edit lib/main.dart with Supabase credentials
flutter run -d chrome
```

## 🎯 What Each Component Does

- **Backend**: REST API for queue management
- **Customer App**: Mobile app to join queue and track position
- **Admin Dashboard**: Web/desktop app to manage queue and call customers
- **SMS**: Automatic notifications when it's customer's turn

## 📱 Testing the System

1. Open Customer App → Join Queue
2. Open Admin Dashboard → See customer in queue
3. Click "Call Next" → Customer gets SMS
4. Customer app updates to "serving" status

## 🆘 Common Issues

**Backend won't start:**
```bash
docker-compose logs backend
```

**Can't connect to Supabase:**
- Check credentials in `.env`
- Ensure schema is initialized

**SMS not working:**
- Check Twilio credentials
- Verify phone numbers include country code (+1234567890)
- SMS is optional - system works without it

## 📚 Full Documentation

See [README.md](README.md) for complete documentation including:
- Local server setup (no Docker)
- API documentation
- Troubleshooting guide
- Production deployment

## 🔑 Get Your Credentials

**Supabase:**
1. Project Settings > API
2. Copy Project URL and anon key

**Twilio:**
1. Console > Account Info
2. Copy Account SID and Auth Token
3. Console > Phone Numbers > Get a number

---

Need help? Check the full [README.md](README.md) or open an issue!
