# Setup Instructions

## Prerequisites

- **Flutter SDK** (latest stable version)
- **Chrome browser** for web development
- **Git** for version control
- **Firebase project** for authentication

## Installation Steps

### 1. Clone Repository
```bash
git clone https://github.com/zqlnt/flutterfirebasefastapi.git
cd flutterfirebasefastapi
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Environment Variables
Create `.env` file in the project root:
```env
# Firebase Configuration
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_API_KEY=your-firebase-api-key
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_STORAGE_BUCKET=your-project.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=your-messaging-sender-id
FIREBASE_APP_ID=your-app-id
FIREBASE_MEASUREMENT_ID=your-measurement-id

# Mock API Configuration
MOCK_API_BASE_URL=https://mock-server-6yyu.onrender.com

# Development Settings
DEBUG_MODE=true
ENABLE_LOGGING=true
```

### 4. Run Application
```bash
flutter run -d chrome
```

## Firebase Configuration

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project"
3. Enter project name (e.g., "infinity-link")
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
6. Add them to your `.env` file

## Mock API Server

The app connects to a mock server at `https://mock-server-6yyu.onrender.com` for data fetching. No additional configuration required.

## Development

### Project Structure
```
lib/
├── main.dart                          # App entry point
├── config/
│   └── environment.dart               # Environment configuration
├── services/
│   ├── firebase_rest_auth_service.dart # Authentication service
│   └── mock_api_service.dart          # Mock API service
├── screens/
│   ├── auth_screen.dart               # Login/register screen
│   └── home_screen.dart               # Main dashboard
└── widgets/
    ├── auth_status_card.dart         # Authentication status widget
    ├── database_data_section.dart   # Database data display
    ├── mock_data_section.dart        # Mock API data display
    ├── quick_actions_section.dart    # Quick actions panel
    └── welcome_card.dart             # Welcome message widget
```

### Key Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0                    # HTTP client for API calls
  provider: ^6.1.1               # State management
  flutter_dotenv: ^5.1.0         # Environment variables
  cupertino_icons: ^1.0.2        # Material icons
```

## Testing

### Authentication Testing
1. Start the app: `flutter run -d chrome`
2. Navigate to the authentication screen
3. Test sign-in with valid credentials
4. Test sign-up with new account
5. Test password reset functionality

### API Testing
1. Sign in to the app
2. Navigate to the home screen
3. Test "Test API Connection" button
4. Test "Discover Endpoints" button
5. Test data fetching buttons (emails, calendar, accounts)

## Deployment

### Vercel Deployment
1. Go to [vercel.com](https://vercel.com)
2. Sign in with GitHub
3. Click "New Project"
4. Import your repository: `zqlnt/flutterfirebasefastapi`
5. Add environment variables in Vercel dashboard
6. Deploy automatically

### Environment Variables for Production
Add these in Vercel dashboard:
```
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_API_KEY=your-firebase-api-key
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_STORAGE_BUCKET=your-project.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=your-messaging-sender-id
FIREBASE_APP_ID=your-app-id
FIREBASE_MEASUREMENT_ID=your-measurement-id
MOCK_API_BASE_URL=https://mock-server-6yyu.onrender.com
```

## Troubleshooting

### Common Issues

#### Environment Variables Not Loading
- **Problem**: App can't find environment variables
- **Solution**: Ensure `.env` file exists in project root with correct format

#### API Connection Failures
- **Problem**: Mock API calls failing
- **Solution**: Check internet connection and mock server status

#### Authentication Errors
- **Problem**: Firebase authentication not working
- **Solution**: Verify Firebase configuration in `.env` file

#### Build Errors
- **Problem**: Flutter build failing
- **Solution**: Run `flutter clean` and `flutter pub get`

### Debug Mode
Enable debug logging by setting `DEBUG_MODE=true` in your `.env` file.

### Development Tips
- Use `flutter run -d chrome` for web development
- Check browser console for debug messages
- Use Flutter Inspector for widget debugging
- Test on different screen sizes for responsiveness