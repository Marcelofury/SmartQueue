# Authentication Implementation

## Overview
Authentication has been added to both the Admin and Customer applications.

## Database Changes

### New Table: `admin_users`
```sql
CREATE TABLE admin_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Updated `businesses` Table
- Added `admin_user_id` column to link businesses to their admin users
- Each business is now owned by an admin user

## Admin App

### Login Screen
- **Location**: `flutter_admin/lib/screens/login_screen.dart`
- **Demo Credentials**: 
  - Email: `admin@smartqueue.com`
  - Password: `admin123` (any password for demo)

### Features
- Email/password authentication
- Session persistence using SharedPreferences
- Automatic redirect to dashboard when logged in
- Logout functionality in dashboard
- Businesses filtered by logged-in admin

### Authentication Flow
1. App checks login status on startup
2. If not logged in → Show login screen
3. If logged in → Show dashboard
4. Login stores user ID in SharedPreferences
5. Logout clears session and returns to login

## Customer App

### Login Screen
- **Location**: `flutter_customer/lib/screens/login_screen.dart`
- **Required Info**:
  - Full Name (minimum 3 characters)
  - Phone Number (10 digits starting with 7)

### Features
- Simple name and phone-based authentication
- Session persistence using SharedPreferences
- Auto-fill on subsequent visits
- Logout functionality in home screen
- No password required (customer-friendly)

### Authentication Flow
1. App checks if customer info is stored
2. If not stored → Show login screen
3. If stored → Auto-fill and show home screen
4. Info persists between sessions
5. Logout clears stored info

## Implementation Details

### Admin Service Updates
```dart
// New methods added:
- login(email, password) - Authenticates admin
- logout() - Clears session
- isLoggedIn() - Checks login status
- getAllBusinesses() - Now filters by admin user
```

### Supabase Service Updates
```dart
// New methods added:
- saveCustomerInfo(name, phone) - Stores customer data locally
- getCustomerInfo() - Retrieves stored customer data
- isLoggedIn() - Checks if customer info exists
- logout() - Clears customer data
```

## Security Notes

### Current Implementation (Demo)
- Admin passwords are not verified (demo mode)
- Customer authentication is local only
- No actual password hashing yet

### Production Requirements
1. **Admin Auth**:
   - Implement proper password hashing (bcrypt)
   - Use Supabase Auth for secure authentication
   - Add email verification
   - Implement password reset

2. **Customer Auth**:
   - Add SMS verification for phone numbers
   - Consider OAuth integration
   - Implement proper session tokens

3. **General**:
   - Enable RLS (Row Level Security) in Supabase
   - Add JWT token validation
   - Implement refresh tokens
   - Add rate limiting

## Next Steps

To enable full authentication in production:

1. **Update Database**:
   ```sql
   -- Run the updated schema.sql file
   -- Update admin_users with proper password hashes
   ```

2. **Enable Supabase Auth**:
   - Configure authentication in Supabase dashboard
   - Enable email provider
   - Set up password policies

3. **Update Code**:
   - Replace demo login with Supabase Auth
   - Add proper password verification
   - Implement token-based authentication

4. **Test**:
   - Test login/logout flows
   - Verify session persistence
   - Test password security

## Files Modified

### Admin App
- `flutter_admin/lib/main.dart` - Added auth wrapper
- `flutter_admin/lib/screens/login_screen.dart` - New login screen
- `flutter_admin/lib/screens/dashboard_screen.dart` - Added logout button
- `flutter_admin/lib/services/admin_service.dart` - Added auth methods

### Customer App
- `flutter_customer/lib/main.dart` - Added auth wrapper and routing
- `flutter_customer/lib/screens/login_screen.dart` - New login screen
- `flutter_customer/lib/screens/home_screen.dart` - Added logout, auto-fill
- `flutter_customer/lib/services/supabase_service.dart` - Added auth methods

### Database
- `database/schema.sql` - Added admin_users table, updated businesses table

## Usage

### Admin
1. Run admin app
2. Login with demo credentials
3. Manage queues
4. Logout from dashboard

### Customer
1. Run customer app
2. Enter name and phone
3. Join queues
4. Info persists for next time
5. Logout to change user
