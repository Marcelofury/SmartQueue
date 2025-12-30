# SmartQueue - Virtual Queue Management System

A virtual queue management system for college MVP built with Node.js Express backend and Supabase (PostgreSQL) database.

## 📁 Project Structure

```
SmartQueue/
├── backend/
│   ├── server.js          # Express server with API routes
│   ├── package.json       # Node.js dependencies
│   ├── .env.example       # Environment variables template
│   └── .gitignore
└── database/
    └── schema.sql         # Database schema and tables
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

Call the next customer in line (moves them to 'serving' status).

**Response:**
```json
{
  "message": "Next customer called",
  "customer": {
    "id": "uuid",
    "customer_name": "John Doe",
    "status": "serving",
    "position": 1
  }
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

- **Backend**: Node.js, Express.js
- **Database**: Supabase (PostgreSQL)
- **Dependencies**:
  - `@supabase/supabase-js` - Supabase client
  - `express` - Web framework
  - `dotenv` - Environment variables
  - `cors` - Cross-origin resource sharing
  - `nodemon` - Development auto-reload

## 📱 Next Steps

1. Build the Flutter frontend to consume these APIs
2. Implement real-time updates using Supabase realtime subscriptions
3. Add authentication for businesses and customers
4. Implement SMS notifications when customer's turn is near
5. Add analytics and reporting features

## 📝 Notes

- A sample business "Sample College Clinic" is automatically created when you run the schema
- Queue positions are automatically updated when customers are called
- All timestamps use UTC timezone
- UUIDs are used for all primary keys for better scalability

## 🤝 Contributing

This is a college MVP project. Feel free to extend and modify as needed.
