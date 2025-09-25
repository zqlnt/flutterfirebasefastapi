# Configuration Guide

This document explains how to configure the Infinity Link application with proper environment variables and security settings.

## 🔧 Environment Configuration

### Firebase Configuration

The app uses the official Firebase SDK for authentication. Configuration is managed through environment variables loaded from a `.env` file.

**Environment Variables (.env file)**:
```env
# Firebase Configuration
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_API_KEY=your-firebase-api-key
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_STORAGE_BUCKET=your-project.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=your-messaging-sender-id
FIREBASE_APP_ID=your-app-id
FIREBASE_MEASUREMENT_ID=your-measurement-id
```

**Configuration Loading**:
The `Environment` class in `lib/config/environment.dart` loads these values from the `.env` file with fallback values for development.

### Mock API Configuration

The app connects to a mock server for testing purposes:
```dart
static const String mockApiBaseUrl = 'https://mock-server-6yyu.onrender.com';
```

## 🔒 Security Best Practices

### Development vs Production

**Development (Current Setup)**:
- API keys are stored in the codebase for easy development
- Configuration is hardcoded in the `Environment` class
- Debug logging is enabled

**Production (Recommended)**:
- Move API keys to environment variables
- Use secure configuration management
- Disable debug logging
- Implement proper secrets handling

### Environment Variables (Recommended for Production)

Create a `.env` file in the project root:
```env
# Firebase Configuration
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_API_KEY=your-firebase-api-key
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com

# Mock API Configuration
MOCK_API_BASE_URL=https://mock-server-6yyu.onrender.com

# Development Settings
DEBUG_MODE=false
ENABLE_LOGGING=false
```

### Using Environment Variables

To use environment variables in production, you would need to:

1. Add the `flutter_dotenv` package to `pubspec.yaml`:
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

2. Load environment variables in `main.dart`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase and the app
  final authService = FirebaseAuthService();
  await authService.initialize();
  
  runApp(MyApp(authService: authService));
}
```

3. Update the `Environment` class to use environment variables:
```dart
class Environment {
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseAuthDomain => dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';
  static String get mockApiBaseUrl => dotenv.env['MOCK_API_BASE_URL'] ?? '';
}
```

## 🚀 Firebase Setup

### Creating a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: "Infinity Link"
4. Enable Google Analytics (optional)
5. Create the project

### Getting Firebase Configuration

1. In the Firebase Console, go to Project Settings
2. Scroll down to "Your apps" section
3. Click "Add app" and select "Web" (</>) icon
4. Register your app with a nickname
5. Copy the configuration values:
   - `apiKey`
   - `authDomain`
   - `projectId`

### Enabling Authentication

1. In the Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" provider
5. Save the configuration

## 🔐 Security Considerations

### API Key Protection

**Never commit API keys to version control**:
- Add `.env` to `.gitignore`
- Use environment variables in production
- Implement proper secrets management
- Regular security audits

### Firebase Security Rules

Configure Firebase Security Rules for your project:
```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access to authenticated users only
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### HTTPS Only

Ensure all API calls use HTTPS:
- Firebase SDK automatically uses HTTPS
- Mock API server uses HTTPS
- No HTTP requests in production

## 📝 Configuration Files

### Current Files

- `lib/config/environment.dart` - Main configuration
- `lib/config/app_config.dart` - Legacy configuration (can be removed)
- `.gitignore` - Excludes sensitive files from version control

### Recommended Structure

```
lib/
├── config/
│   ├── environment.dart      # Environment configuration
│   └── firebase_options.dart # Firebase configuration (auto-generated)
├── services/
│   ├── firebase_auth_service.dart    # Firebase SDK authentication
│   └── mock_api_service.dart         # Mock API integration
└── ...
```

## 🚨 Important Notes

1. **Development**: Current setup is fine for development and testing
2. **Production**: Must implement proper environment variable handling
3. **Security**: Never commit API keys to version control
4. **Updates**: Keep Firebase SDK and dependencies updated
5. **Monitoring**: Monitor authentication and API usage in production

---

**Infinity Link** - Proper configuration and security setup for production deployment.
