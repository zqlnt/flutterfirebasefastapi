# Configuration Guide

## Environment Variables

The application uses environment variables for configuration. All sensitive data is stored in a `.env` file and loaded at runtime.

### Required Variables

#### Firebase Configuration
```env
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_API_KEY=your-firebase-api-key
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_STORAGE_BUCKET=your-project.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=your-messaging-sender-id
FIREBASE_APP_ID=your-app-id
FIREBASE_MEASUREMENT_ID=your-measurement-id
```

#### Mock API Configuration
```env
MOCK_API_BASE_URL=https://mock-server-6yyu.onrender.com
```

#### Development Settings
```env
DEBUG_MODE=true
ENABLE_LOGGING=true
```

### Environment File Structure

Create a `.env` file in the project root:
```env
# Firebase Configuration
FIREBASE_PROJECT_ID=infinity-link-878fe
FIREBASE_API_KEY=your-actual-api-key
FIREBASE_AUTH_DOMAIN=infinity-link-878fe.firebaseapp.com
FIREBASE_STORAGE_BUCKET=infinity-link-878fe.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=your-messaging-sender-id
FIREBASE_APP_ID=your-app-id
FIREBASE_MEASUREMENT_ID=your-measurement-id

# Mock API Configuration
MOCK_API_BASE_URL=https://mock-server-6yyu.onrender.com

# Development Settings
DEBUG_MODE=true
ENABLE_LOGGING=true
```

## Configuration Loading

The `Environment` class in `lib/config/environment.dart` loads these values:

```dart
class Environment {
  /// Firebase project configuration
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseAuthDomain => dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';
  static String get firebaseStorageBucket => dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  static String get firebaseMessagingSenderId => dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';
  static String get firebaseMeasurementId => dotenv.env['FIREBASE_MEASUREMENT_ID'] ?? '';
  
  /// Mock API configuration
  static String get mockApiBaseUrl => dotenv.env['MOCK_API_BASE_URL'] ?? 'https://mock-server-6yyu.onrender.com';
  
  /// Development settings
  static bool get debugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true' || true;
  static bool get enableLogging => dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true' || true;
}
```

## Firebase Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project"
3. Enter project name
4. Enable Google Analytics (optional)

### 2. Enable Authentication
1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" provider
5. Click "Save"

### 3. Get Project Configuration
1. Go to Project Settings (gear icon)
2. Scroll down to "Your apps" section
3. Click "Add app" → Web app
4. Register app with a nickname
5. Copy the configuration values

### 4. Add to Environment File
Copy the configuration values to your `.env` file:
```env
FIREBASE_PROJECT_ID=your-actual-project-id
FIREBASE_API_KEY=your-actual-api-key
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_STORAGE_BUCKET=your-project.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=your-messaging-sender-id
FIREBASE_APP_ID=your-app-id
FIREBASE_MEASUREMENT_ID=your-measurement-id
```

## Mock API Configuration

The app connects to a mock server at `https://mock-server-6yyu.onrender.com`. No additional configuration required.

### Available Endpoints
- **Email Messages**: `GET /db/email/messages`
- **Calendar Events**: `GET /db/calendar/events`
- **Gmail Accounts**: `GET /accounts`
- **Health Check**: `GET /health`

## Security

### Environment File Security
- **Never commit `.env` file** to version control
- **Use `.gitignore`** to exclude sensitive files
- **Use different values** for development and production

### Production Deployment
For production deployment (Vercel, Netlify, etc.):
1. Add environment variables in the platform's dashboard
2. Use production Firebase project configuration
3. Ensure all variables are properly set

## Troubleshooting

### Environment Variables Not Loading
- **Check file location**: Ensure `.env` file is in project root
- **Check file format**: Ensure no spaces around `=`
- **Check file encoding**: Use UTF-8 encoding
- **Restart app**: After changing environment variables

### Firebase Configuration Issues
- **Verify project ID**: Ensure it matches your Firebase project
- **Check API key**: Ensure it's the correct web API key
- **Verify domain**: Ensure auth domain is correct
- **Test authentication**: Try signing in with test credentials

### Mock API Issues
- **Check internet connection**: Ensure you can reach the mock server
- **Verify base URL**: Ensure the URL is correct
- **Test endpoints**: Use browser to test endpoints directly

## Version History
- Latest update: Configuration documentation and security improvements