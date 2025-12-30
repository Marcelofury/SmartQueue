# SmartQueue - Virtual Queue Management System

A comprehensive virtual queue management system for college MVP built with:
- **Backend**: Node.js + Express + Supabase (PostgreSQL)
- **Frontend**: Flutter (Mobile Customer App + Web/Desktop Admin Dashboard)
- **SMS Notifications**: Twilio integration
- **Deployment**: Docker & Docker Compose

## 📋 Table of Contents

- [Features](#features)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation Methods](#installation-methods)
  - [Docker Setup (Recommended)](#docker-setup-recommended)
  - [Local Server Setup](#local-server-setup)
- [Configuration](#configuration)
- [Running the Applications](#running-the-applications)
- [API Documentation](#api-documentation)
- [SMS Notifications](#sms-notifications)
- [Troubleshooting](#troubleshooting)

## ✨ Features

### Backend API
- RESTful API for queue management
- Real-time position updates
- Automated wait time calculations
- SMS notifications via Twilio
- CORS enabled for cross-origin requests

### Customer Mobile App
- 📱 QR code scanning for quick check-in
- ✍️ Manual queue joining
- ⏱️ Real-time position and wait time updates
- 📊 Live status tracking via Supabase streams
- 📞 USSD simulator for demos

### Admin Dashboard
- 📊 Real-time queue monitoring
- 📞 Call Next functionality with SMS notifications
- 🤖 AI Predictor for service time optimization
- 📈 Statistics and analytics
- 🔄 Live updates via Supabase streams

## 📁 Project Structure

```
SmartQueue/
├── backend/                    # Node.js Express API
│   ├── server.js              # Main server file with API routes
│   ├── services/
│   │   └── twilioService.js   # Twilio SMS integration
│   ├── package.json           # Dependencies
│   ├── Dockerfile             # Docker configuration
│   └── .env.example           # Environment variables template
├── database/
│   └── schema.sql             # PostgreSQL database schema
├── flutter_customer/          # Flutter mobile app
│   ├── lib/
│   │   ├── screens/          # UI screens
│   │   ├── services/         # Supabase integration
│   │   └── config/           # Theme & configuration
│   └── pubspec.yaml          # Flutter dependencies
├── flutter_admin/            # Flutter admin dashboard (web/desktop)
│   ├── lib/
│   │   ├── screens/         # Dashboard UI
│   │   ├── services/        # Admin API & AI Predictor
│   │   └── widgets/         # Reusable components
│   └── pubspec.yaml         # Flutter dependencies
├── docker-compose.yml        # Docker orchestration
├── .env.example             # Environment variables
└── README.md                # This file
```

## 🔧 Prerequisites

- **Docker & Docker Compose** (for containerized setup) OR
- **Node.js** 18+ (for local setup)
- **Flutter SDK** 3.0+ (for mobile/desktop apps)
- **Supabase Account** (free tier available)
- **Twilio Account** (optional, for SMS notifications)

## 🚀 Installation Methods

### Docker Setup (Recommended)

The easiest way to run SmartQueue is using Docker Compose.

#### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/SmartQueue.git
cd SmartQueue
```

#### 2. Configure Environment Variables

```bash
cp .env.example .env
nano .env  # or use any text editor
```

Fill in your credentials:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

TWILIO_ACCOUNT_SID=your-account-sid
TWILIO_AUTH_TOKEN=your-auth-token
TWILIO_PHONE_NUMBER=+1234567890
```

#### 3. Start the Services

```bash
# Start backend and database
docker-compose up -d

# View logs
docker-compose logs -f backend

# Stop services
docker-compose down
```

#### 4. Verify Services

- Backend API: http://localhost:3000
- Database: localhost:5432
- pgAdmin (optional): http://localhost:5050

#### 5. Optional: Start pgAdmin

```bash
docker-compose --profile tools up -d
```

### Local Server Setup

For development without Docker.

#### 1. Set Up Supabase Database

1. Create a free account at [supabase.com](https://supabase.com)
2. Create a new project
3. Go to SQL Editor and run `database/schema.sql`
4. Get your Project URL and anon key from Settings > API

#### 2. Install Backend Dependencies

```bash
cd backend
npm install
```

#### 3. Configure Backend Environment

```bash
cp .env.example .env
```

Edit `.env`:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
PORT=3000

# Optional: Twilio for SMS
TWILIO_ACCOUNT_SID=your-account-sid
TWILIO_AUTH_TOKEN=your-auth-token
TWILIO_PHONE_NUMBER=+1234567890
```

#### 4. Start Backend Server

```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

Server will run at: http://localhost:3000

#### 5. Set Up Flutter Customer App

```bash
cd flutter_customer
flutter pub get
```

Edit `lib/main.dart` with your Supabase credentials:
```dart
await SupabaseService.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

Run the app:
```bash
flutter run
```

#### 6. Set Up Flutter Admin Dashboard

```bash
cd flutter_admin
flutter pub get
```

Edit `lib/main.dart` with your Supabase credentials.

Run on web:
```bash
flutter run -d chrome
```

Run on desktop:
```bash
flutter run -d windows  # or macos/linux
```

## ⚙️ Configuration

### Supabase Setup

1. **Create Project**: Sign up at [supabase.com](https://supabase.com)
2. **Run Schema**: Execute `database/schema.sql` in SQL Editor
3. **Get Credentials**: Project Settings > API
   - Copy Project URL
   - Copy anon/public key

### Twilio SMS Setup (Optional)

1. **Sign Up**: Create account at [twilio.com](https://www.twilio.com/try-twilio)
2. **Get Phone Number**: Console > Phone Numbers > Buy a number
3. **Get Credentials**: Console > Account Info
   - Account SID
   - Auth Token
   - Phone Number (with country code, e.g., +1234567890)

**Note**: SMS is optional. If not configured, the system will log messages to console instead.

### Phone Number Format

For SMS to work, phone numbers must include country code:
- ✅ Correct: `+1234567890`, `+919876543210`
- ❌ Incorrect: `1234567890`, `9876543210`

## 🎮 Running the Applications

### With Docker (All-in-One)

```bash
# Start everything
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Stop everything
docker-compose down
```

### Without Docker (Individual Components)

**Backend:**
```bash
cd backend
npm install
npm run dev  # Development
npm start    # Production
```

**Customer App:**
```bash
cd flutter_customer
flutter pub get
flutter run
```

**Admin Dashboard:**
```bash
cd flutter_admin
flutter pub get
flutter run -d chrome     # Web
flutter run -d windows    # Desktop
```

## 📡 API Documentation

### Base URL
- Local: `http://localhost:3000`
- Docker: `http://localhost:3000`

### Endpoints

#### `businesses`
- `id` (UUID, Primary Key)
- `name` (VARCHAR)
- `avg_service_time` (INTEGER) - Average service time in minutes
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### `queues`
- `id` (UUID, Primary Key)
- `business_id` (UUID, Foreign Key)
- `customer_name` (VARCHAR)
- `phone_number` (VARCHAR)
- `position` (INTEGER)
- `status` (VARCHAR) - Values: 'waiting', 'serving', 'done'
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

## 🚀 Setup Instructions

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Supabase

1. Create a new project on [Supabase](https://supabase.com)
2. Go to SQL Editor and run the schema from `database/schema.sql`
3. Get your project URL and anon key from Project Settings > API

### 3. Configure Environment Variables

```bash
cd backend
cp .env.example .env
```

Edit `.env` and add your Supabase credentials:
```
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
PORT=3000
```

### 4. Run the Server

```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

Server will run on `http://localhost:3000`

## 📡 API Endpoints

### 1. Join Queue
**POST** `/api/queue/join`

Add a customer to the queue.

**Request Body:**
```json
{
  "business_id": "uuid",
  "customer_name": "John Doe",
  "phone_number": "1234567890"
}
```

**Response:**
```json
{
  "message": "Successfully joined the queue",
  "queue_entry": {
    "id": "uuid",
    "customer_name": "John Doe",
    "phone_number": "1234567890",
    "position": 3,
    "status": "waiting"
  },
  "estimated_wait_time": 30,
  "wait_time_unit": "minutes"
}
```

### 2. Get Queue Status
**GET** `/api/queue/status/:queue_id`

Get the current status of a queue entry.

**Response:**
```json
{
  "queue_id": "uuid",
  "customer_name": "John Doe",
  "phone_number": "1234567890",
  "position": 2,
  "status": "waiting",
  "business_name": "Sample College Clinic",
  "estimated_wait_time": 15,
  "wait_time_unit": "minutes",
  "created_at": "2025-12-30T10:30:00Z"
}
```

### 3. Call Next Customer
**POST** `/api/queue/next/:business_id`

Call the next customer in line (moves them to 'serving' status). **Sends SMS notification if Twilio is configured.**

**Response:**
```json
{
  "message": "Next customer called",
  "customer": {
    "id": "uuid",
    "customer_name": "John Doe",
    "phone_number": "+1234567890",
    "status": "serving",
    "position": 1
  },
  "sms_sent": true
}
```

### 4. Complete Service
**POST** `/api/queue/complete/:queue_id`

Mark a customer's service as completed.

**Response:**
```json
{
  "message": "Service completed",
  "customer": {
    "id": "uuid",
    "status": "done"
  }
}
```

### 5. Get Current Queue
**GET** `/api/queue/list/:business_id`

Get all waiting customers for a business.

**Response:**
```json
{
  "queue": [
    {
      "id": "uuid",
      "customer_name": "John Doe",
      "position": 1,
      "status": "waiting",
      "estimated_wait_time": 0
    },
    {
      "id": "uuid",
      "customer_name": "Jane Smith",
      "position": 2,
      "status": "waiting",
      "estimated_wait_time": 15
    }
  ],
  "total_waiting": 2
}
```

## 🧮 Wait Time Logic

The wait time is calculated using the formula:
```
Wait Time = (Position - 1) × Average Service Time
```

For example:
- Position 1: 0 minutes wait (currently being served)
- Position 2: 15 minutes wait (if avg_service_time = 15)
- Position 3: 30 minutes wait

## 🔧 Technologies Used

### Backend
- **Runtime**: Node.js 18
- **Framework**: Express.js
- **Database**: Supabase (PostgreSQL)
- **SMS**: Twilio
- **Container**: Docker & Docker Compose

### Frontend
- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **Charts**: FL Chart
- **QR Scanner**: mobile_scanner
- **Fonts**: Google Fonts

### Key Dependencies
- `@supabase/supabase-js` - Supabase client
- `express` - Web framework
- `twilio` - SMS notifications
- `dotenv` - Environment variables
- `cors` - Cross-origin resource sharing

## 📲 SMS Notifications

### Setup Twilio

1. **Create Account**: [twilio.com/try-twilio](https://www.twilio.com/try-twilio)
2. **Get Phone Number**: Console > Phone Numbers
3. **Copy Credentials**: Console > Account Info
   - Account SID
   - Auth Token
   - Phone Number

4. **Add to Environment**:
```env
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_PHONE_NUMBER=+1234567890
```

### SMS Messages

**When Admin Calls Next:**
```
Hi [Name]! 🎉 Your turn is coming up at [Business]. 
Please head to the counter. Thank you for using SmartQueue!
```

**Note**: SMS is optional. If Twilio is not configured, the system will log messages to console instead of sending actual SMS.

## 🐳 Docker Commands

```bash
# Build and start
docker-compose up -d --build

# View logs
docker-compose logs -f backend
docker-compose logs -f postgres

# Restart services
docker-compose restart backend

# Stop services
docker-compose stop

# Remove everything (including volumes)
docker-compose down -v

# Start with pgAdmin
docker-compose --profile tools up -d
```

## 🗄️ Database Schema

### Tables

#### `businesses`
- `id` (UUID, Primary Key)
- `name` (VARCHAR)
- `avg_service_time` (INTEGER) - Average service time in minutes
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### `queues`
- `id` (UUID, Primary Key)
- `business_id` (UUID, Foreign Key)
- `customer_name` (VARCHAR)
- `phone_number` (VARCHAR)
- `position` (INTEGER)
- `status` (VARCHAR) - Values: 'waiting', 'serving', 'done'
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

### Indexes
- `idx_queues_business_id` - On business_id
- `idx_queues_status` - On status
- `idx_queues_position` - On position

## 🧪 Testing

### Test the Backend API

```bash
# Health check
curl http://localhost:3000/

# Join queue
curl -X POST http://localhost:3000/api/queue/join \
  -H "Content-Type: application/json" \
  -d '{
    "business_id": "YOUR_BUSINESS_ID",
    "customer_name": "John Doe",
    "phone_number": "+1234567890"
  }'

# Call next customer (triggers SMS)
curl -X POST http://localhost:3000/api/queue/next/YOUR_BUSINESS_ID
```

### Test SMS Without Twilio

The system gracefully handles missing Twilio credentials:
- SMS messages are logged to console
- API continues to work normally
- No errors are thrown

## 🔧 Troubleshooting

## � Troubleshooting

### Backend Issues

**Port 3000 already in use:**
```bash
# Find and kill the process
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:3000 | xargs kill -9
```

**Supabase connection error:**
- Verify URL and anon key in `.env`
- Check Supabase project is active
- Ensure schema is properly initialized

**SMS not sending:**
- Verify Twilio credentials are correct
- Check phone numbers include country code (+)
- Review Twilio console for error messages
- Ensure Twilio account has sufficient credits

### Docker Issues

**Container won't start:**
```bash
# Check logs
docker-compose logs backend

# Rebuild
docker-compose up -d --build --force-recreate
```

**Database connection failed:**
```bash
# Check if postgres is healthy
docker-compose ps

# Restart postgres
docker-compose restart postgres
```

**Port conflicts:**
Edit `docker-compose.yml` to use different ports:
```yaml
ports:
  - "3001:3000"  # Host:Container
```

### Flutter Issues

**Supabase connection error:**
- Update credentials in `lib/main.dart`
- Rebuild app after changes
- Check internet connection

**QR scanner not working:**
- Grant camera permissions
- Check device camera works
- iOS: Update Info.plist with camera usage description

## 📱 Mobile App Permissions

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS (ios/Runner/Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access required to scan QR codes</string>
```

## 🚀 Production Deployment

### Backend

**Option 1: Docker**
```bash
docker build -t smartqueue-backend ./backend
docker run -p 3000:3000 --env-file .env smartqueue-backend
```

**Option 2: Cloud Platforms**
- **Heroku**: Deploy with `heroku.yml`
- **Railway**: Connect GitHub repo
- **Render**: Auto-deploy from GitHub
- **AWS ECS**: Use provided Dockerfile

### Admin Dashboard

**Build for Web:**
```bash
cd flutter_admin
flutter build web --release
```

Deploy `build/web` to:
- Netlify
- Vercel  
- Firebase Hosting
- GitHub Pages

**Build for Desktop:**
```bash
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

## 📝 Environment Variables Reference

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `SUPABASE_URL` | Yes | Supabase project URL | `https://xxx.supabase.co` |
| `SUPABASE_ANON_KEY` | Yes | Supabase anon/public key | `eyJhbGc...` |
| `TWILIO_ACCOUNT_SID` | No | Twilio Account SID | `ACxxxxxxx` |
| `TWILIO_AUTH_TOKEN` | No | Twilio Auth Token | `your_token` |
| `TWILIO_PHONE_NUMBER` | No | Twilio phone with country code | `+1234567890` |
| `PORT` | No | Backend server port | `3000` |
| `NODE_ENV` | No | Environment | `production` |

## 🎯 Next Steps & Enhancements

1. ✅ ~~SMS notifications~~ (Implemented with Twilio)
2. ✅ ~~Real-time updates~~ (Supabase streams)
3. ✅ ~~AI service time predictor~~ (Admin dashboard)
4. 🔲 Push notifications for mobile apps
5. 🔲 Multi-business support
6. 🔲 Customer authentication
7. 🔲 Analytics dashboard with charts
8. 🔲 Queue history and reports
9. 🔲 Business hours management
10. 🔲 Staff roles and permissions

## 📄 License

College MVP Project - SmartQueue

## 🤝 Contributing

This is a college MVP project. Feel free to fork and extend!
- UUIDs are used for all primary keys for better scalability

## 🤝 Contributing

This is a college MVP project. Feel free to extend and modify as needed.
