# Infinity Link - Flutter Web Application

A Flutter web application demonstrating Firebase authentication and mock API integration. Built for testing and development purposes with a clean, modern interface.

## 🚀 Features

- **Firebase Authentication** - Secure user login/registration
- **Mock API Integration** - Real-time data fetching from external server
- **Responsive Design** - Material Design interface optimized for web
- **State Management** - Provider pattern for efficient state handling
- **Environment Configuration** - Secure configuration management

## 📋 Project Overview

This application showcases modern Flutter web development practices:

- **Authentication Flow**: Firebase REST API for user management
- **Data Processing**: Intelligent parsing of different API response formats
- **UI Components**: Modular widget architecture with reusable components
- **Error Handling**: Comprehensive error handling and user feedback
- **Security**: Environment-based configuration with proper secret management

## 🏗️ Architecture

### Core Components
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

### Data Flow
1. **User Authentication** → Firebase REST API validates credentials
2. **Data Fetching** → MockApiService requests data from Render server
3. **Data Processing** → JSON responses parsed and transformed
4. **UI Rendering** → Data displayed in Material Design components
5. **State Updates** → Provider notifies UI of state changes

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK (latest stable version)
- Chrome browser for web development
- Git for version control

### Installation
1. **Clone the repository**:
   ```bash
   git clone https://github.com/zqlnt/flutterfirebasefastapi.git
   cd flutterfirebasefastapi
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

## 🔐 Configuration

### Firebase Setup
1. Create a Firebase project in the Firebase Console
2. Enable Authentication with Email/Password
3. Get your project configuration from Project Settings
4. Add the configuration to your `.env` file

### Mock API Server
The app connects to a mock server at `https://mock-server-6yyu.onrender.com` for data fetching.

## 📊 API Integration

### Firebase Authentication
- **Sign In**: `POST https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword`
- **Sign Up**: `POST https://identitytoolkit.googleapis.com/v1/accounts:signUp`
- **Password Reset**: `POST https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode`

### Mock API Server
- **Email Messages**: `GET /db/email/messages`
- **Calendar Events**: `GET /db/calendar/events`
- **Gmail Accounts**: `GET /accounts`
- **Health Check**: `GET /health`

## 🛠️ Development

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

### Environment Variables
All sensitive configuration is stored in the `.env` file and loaded at runtime. The `.env` file is excluded from version control.

## 🚀 Deployment

### Vercel Deployment
1. Connect your GitHub repository to Vercel
2. Vercel will automatically detect it's a Flutter project
3. Add environment variables in Vercel dashboard
4. Deploy automatically on every push

### Build Configuration
The `vercel.json` file configures the build process:
```json
{
  "buildCommand": "flutter build web --release",
  "outputDirectory": "build/web",
  "framework": "flutter",
  "installCommand": "flutter pub get"
}
```

## 🧪 Testing

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

## 🔒 Security

- **Environment Variables**: All sensitive data stored in `.env` file
- **Git Ignore**: `.env` file excluded from version control
- **Input Validation**: All user inputs validated before processing
- **Error Handling**: Secure error messages without sensitive data exposure
- **HTTPS Only**: All API calls use HTTPS endpoints

## 📚 Documentation

- **README.md**: Project overview and setup instructions
- **TECHNICAL_DOCUMENTATION.md**: Detailed technical implementation
- **SETUP_INSTRUCTIONS.md**: Step-by-step setup guide
- **CONFIGURATION.md**: Configuration management guide

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is for educational and development purposes.

## 🆘 Troubleshooting

### Common Issues
- **Environment variables not loading**: Ensure `.env` file exists in project root
- **API connection failures**: Check internet connection and mock server status
- **Authentication errors**: Verify Firebase configuration in `.env` file
- **Build errors**: Run `flutter clean` and `flutter pub get`

### Debug Mode
Enable debug logging by setting `DEBUG_MODE=true` in your `.env` file.

## Version History
- Latest update: Project cleanup and documentation improvements