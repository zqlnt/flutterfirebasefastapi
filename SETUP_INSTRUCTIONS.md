# Setup Instructions

## Prerequisites

- Flutter SDK (latest stable version)
- Chrome browser for web development
- Git for version control

## Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd flutter_frontend
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Create environment file**:
   Create `.env` file in the project root:
   ```env
   FIREBASE_PROJECT_ID=your-project-id
   FIREBASE_API_KEY=your-api-key
   FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
   FIREBASE_STORAGE_BUCKET=your-project.firebasestorage.app
   FIREBASE_MESSAGING_SENDER_ID=your-messaging-sender-id
   FIREBASE_APP_ID=your-app-id
   FIREBASE_MEASUREMENT_ID=your-measurement-id
   MOCK_API_BASE_URL=https://mock-server-6yyu.onrender.com
   ```

4. **Run the application**:
   ```bash
   flutter run -d chrome
   ```

## Configuration

### Firebase Setup
1. Create a Firebase project in the Firebase Console
2. Enable Authentication with Email/Password
3. Get your project configuration from Project Settings
4. Add the configuration to your `.env` file

### Mock API Server
The app connects to a mock server at `https://mock-server-6yyu.onrender.com` for data fetching.

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
    └── (various UI components)
```

### Key Dependencies
- `http: ^1.1.0` - HTTP client for API calls
- `provider: ^6.1.1` - State management
- `flutter_dotenv: ^5.1.0` - Environment variables

### Environment Variables
All sensitive configuration is stored in the `.env` file and loaded at runtime. The `.env` file is excluded from version control.

## Testing

### Authentication Testing
1. Start the app
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

## Troubleshooting

### Common Issues
- **Environment variables not loading**: Ensure `.env` file exists in project root
- **API connection failures**: Check internet connection and mock server status
- **Authentication errors**: Verify Firebase configuration in `.env` file
- **Build errors**: Run `flutter clean` and `flutter pub get`

### Debug Mode
Enable debug logging by setting `DEBUG_MODE=true` in your `.env` file.