import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for the Infinity Link app.
/// 
/// This file loads configuration from environment variables (.env file)
/// and provides fallback values for development.
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
  
  /// Firebase configuration for SDK initialization
  static Map<String, String> get firebaseConfig => {
    'apiKey': firebaseApiKey,
    'authDomain': firebaseAuthDomain,
    'projectId': firebaseProjectId,
    'storageBucket': firebaseStorageBucket,
    'messagingSenderId': firebaseMessagingSenderId,
    'appId': firebaseAppId,
    'measurementId': firebaseMeasurementId,
  };
}
