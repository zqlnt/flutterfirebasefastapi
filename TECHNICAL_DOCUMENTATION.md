# Technical Documentation

## Architecture Overview

### High-Level Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   AuthScreen    │  │   HomeScreen    │  │   Widgets   │ │
│  │                 │  │                 │  │             │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                    Business Logic Layer                    │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │ FirebaseRest    │  │   MockApi       │  │  Provider  │ │
│  │ AuthService     │  │   Service       │  │   State    │ │
│  │                 │  │                 │  │ Management │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   Firebase      │  │   Mock API       │  │   Local     │ │
│  │   REST API      │  │   Server         │  │   Storage   │ │
│  │                 │  │                 │  │             │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Core Services Implementation

### FirebaseRestAuthService
Handles Firebase authentication using REST API calls.

#### Key Methods
```dart
Future<bool> signIn(String email, String password)
Future<bool> signUp(String email, String password)
Future<bool> resetPassword(String email)
void signOut()
```

#### Authentication Flow
1. **User Input** → Email/password validation
2. **API Request** → HTTP POST to Firebase Identity Toolkit
3. **Response Processing** → JSON parsing and token extraction
4. **State Update** → Provider notifies UI components
5. **UI Navigation** → Route to appropriate screen

### MockApiService
Handles communication with external mock API server.

#### Key Methods
```dart
Future<bool> testConnection()
Future<Map<String, dynamic>> discoverEndpoints()
Future<Map<String, dynamic>> getEmailMessages()
Future<Map<String, dynamic>> getCalendarEvents()
Future<Map<String, dynamic>> getAccounts()
```

## Data Processing Pipeline

### HTTP Request Phase
```dart
final response = await _client.get(
  Uri.parse('$baseUrl/db/email/messages'),
  headers: {'Content-Type': 'application/json'},
).timeout(const Duration(seconds: 10));
```

### Response Processing
```dart
final data = jsonDecode(response.body);
final itemCount = _determineItemCount(data);

return {
  'success': true,
  'data': data,
  'count': itemCount,
  'rawResponse': data,
};
```

### Data Format Detection
Handles different API response structures:

**Direct Array Response**:
```json
[
  {"id": 1, "sender": "user@example.com", "subject": "Test Email"},
  {"id": 2, "sender": "admin@example.com", "subject": "Another Email"}
]
```

**Wrapped Object Response**:
```json
{
  "data": [{"id": 1, "sender": "user@example.com", "subject": "Test Email"}],
  "count": 1,
  "status": "success"
}
```

**Items Array Response**:
```json
{
  "items": [{"id": 1, "title": "Event 1"}, {"id": 2, "title": "Event 2"}],
  "total": 2
}
```

### Data Transformation

#### Email Message Processing
**Raw Data**:
```json
{
  "id": 1,
  "sender": "john.doe@example.com",
  "subject": "Important Meeting Tomorrow",
  "date": "2024-01-15T10:30:00Z",
  "snippet": "Hi team, we have an important meeting tomorrow at 2 PM..."
}
```

**UI Format**:
```dart
{
  "sender": "john.doe@example.com",
  "subject": "Important Meeting Tomorrow",
  "date": "Jan 15, 2024 10:30 AM",
  "snippet": "Hi team, we have an important meeting tomorrow at 2 PM...",
  "avatar": "JD"
}
```

#### Calendar Event Processing
**Raw Data**:
```json
{
  "id": 1,
  "title": "Team Standup",
  "start_time": "2024-01-15T09:00:00Z",
  "end_time": "2024-01-15T09:30:00Z",
  "description": "Daily team standup meeting"
}
```

**UI Format**:
```dart
{
  "title": "Team Standup",
  "time": "9:00 AM - 9:30 AM",
  "date": "January 15, 2024",
  "description": "Daily team standup meeting",
  "duration": "30 minutes"
}
```

## State Management

### Provider Pattern
```dart
class FirebaseRestAuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _idToken;
  
  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  
  Future<bool> signIn(String email, String password) async {
    // Authentication logic
    _isAuthenticated = true;
    notifyListeners(); // Notify UI of state change
    return true;
  }
}
```

### UI State Updates
```dart
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseRestAuthService>(
      builder: (context, authService, child) {
        if (authService.isLoading) return const LoadingScreen();
        if (authService.isAuthenticated) return const HomeScreen();
        return const AuthScreen();
      },
    );
  }
}
```

## Error Handling

### Network Error Handling
```dart
try {
  final response = await _client.get(uri).timeout(
    const Duration(seconds: 10),
  );
  
  if (response.statusCode == 200) {
    return _processSuccessResponse(response);
  } else {
    return _handleHttpError(response);
  }
} on TimeoutException {
  return _handleTimeoutError();
} on SocketException {
  return _handleNetworkError();
} catch (e) {
  return _handleGenericError(e);
}
```

### Data Validation
```dart
bool _validateEmailData(Map<String, dynamic> email) {
  return email.containsKey('sender') && 
         email.containsKey('subject') &&
         email['sender'] is String &&
         email['subject'] is String;
}
```

## Performance Optimizations

### Memory Management
- **Data Caching**: Store fetched data in widget state
- **Lazy Loading**: Only fetch data when requested
- **Efficient Parsing**: Use `jsonDecode` with proper error handling

### UI Rendering
- **ListView.builder**: Efficient rendering for large datasets
- **Text Truncation**: Prevent UI overflow with proper text handling
- **Card Reuse**: Reusable components for different data types
- **Loading States**: Provide visual feedback during operations

## Configuration Management

### Environment Variables
```dart
class Environment {
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get mockApiBaseUrl => dotenv.env['MOCK_API_BASE_URL'] ?? 'https://mock-server-6yyu.onrender.com';
}
```

### Security Implementation
- **Environment Variables**: All sensitive data stored in `.env` file
- **Git Ignore**: `.env` file excluded from version control
- **Input Validation**: All user inputs validated before processing
- **Error Handling**: Secure error messages without sensitive data exposure
- **HTTPS Only**: All API calls use HTTPS endpoints

## API Integration

### Firebase REST API
```dart
static String get signInUrl => 'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${Environment.firebaseApiKey}';
static String get signUpUrl => 'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${Environment.firebaseApiKey}';
```

### Mock Server Integration
```dart
static String get baseUrl => 'https://mock-server-6yyu.onrender.com';

// Endpoints
GET /db/email/messages
GET /db/calendar/events
GET /accounts
GET /health
```

## Data Flow Summary

1. **User Action** → Button click triggers API call
2. **HTTP Request** → MockApiService makes request to Render server
3. **Response Processing** → JSON parsed and validated
4. **Data Counting** → Intelligent count determination based on response format
5. **Data Transformation** → Raw data formatted for UI display
6. **State Update** → Provider notifies UI components
7. **UI Rendering** → Material Design components display formatted data