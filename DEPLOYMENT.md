# Deployment Guide

## Render Deployment

### Prerequisites
- GitHub repository with your Flutter app
- Render account
- Firebase project configured for web

### Environment Variables Required

Set these in your Render service dashboard:

```
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_API_KEY=your-firebase-api-key
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_STORAGE_BUCKET=your-project.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=your-messaging-sender-id
FIREBASE_APP_ID=your-app-id
FIREBASE_MEASUREMENT_ID=your-measurement-id
MOCK_API_BASE_URL=https://mock-server-6yyu.onrender.com
DEBUG_MODE=false
ENABLE_LOGGING=true
```

### Deployment Steps

1. **Create Web Service** on Render
2. **Connect GitHub repository**: https://github.com/zqlnt/flutterfirebasefastapi
3. **Configure build settings**:
   - Build Command: `flutter build web --release`
   - Publish Directory: `build/web`
   - Environment: `Dart`
4. **Add environment variables** from the list above
5. **Deploy**

### Alternative: Docker Deployment

If you prefer Docker deployment:

1. **Use the provided Dockerfile**
2. **Set environment variables** in Render
3. **Build Command**: `docker build -t infinity-link .`
4. **Start Command**: `docker run -p 80:80 infinity-link`

### Firebase Configuration

Ensure your Firebase project is configured for web:

1. **Enable Authentication** with Email/Password
2. **Add your Render domain** to authorized domains
3. **Configure CORS** if needed
4. **Set up security rules** for your Firebase services

### Troubleshooting

- **Build failures**: Check Flutter version compatibility
- **Environment variables**: Ensure all required variables are set
- **Firebase errors**: Verify project configuration and API keys
- **CORS issues**: Add your Render domain to Firebase authorized domains
