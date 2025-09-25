# Infinity Link - Flutter Web Application

Flutter web app with Firebase authentication and mock API integration.

## Architecture

- **Authentication**: Firebase REST API calls
- **Data Source**: Mock server at `https://mock-server-6yyu.onrender.com`
- **State Management**: Provider pattern
- **Configuration**: Environment variables

## Data Processing

### Mock API Service
Handles communication with Render server for data fetching:

```dart
class MockApiService {
  static String get baseUrl => Environment.mockApiBaseUrl;
  
  Future<Map<String, dynamic>> getEmailMessages() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/db/email/messages'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));
    
    final data = jsonDecode(response.body);
    final itemCount = _determineItemCount(data);
    
    return {
      'success': true,
      'data': data,
      'count': itemCount,
    };
  }
}
```

### Data Count Logic
Handles different API response formats:

```dart
int _determineItemCount(dynamic data) {
  if (data is List) return data.length;
  if (data is Map) {
    if (data.containsKey('data') && data['data'] is List) {
      return data['data'].length;
    }
    if (data.containsKey('items') && data['items'] is List) {
      return data['items'].length;
    }
  }
  return 1;
}
```

### Data Transformation
Converts raw API data to UI format:

```dart
Map<String, dynamic> _formatEmailData(Map<String, dynamic> email) {
  return {
    'sender': email['sender'] ?? 'Unknown Sender',
    'subject': _truncateText(email['subject'] ?? 'No Subject', 50),
    'date': _formatDate(email['date']),
    'snippet': _truncateText(email['snippet'] ?? '', 100),
  };
}
```

## API Endpoints

### Firebase Authentication
- Sign In: `POST https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword`
- Sign Up: `POST https://identitytoolkit.googleapis.com/v1/accounts:signUp`
- Password Reset: `POST https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode`

### Mock Server
- Email Messages: `GET /db/email/messages`
- Calendar Events: `GET /db/calendar/events`
- Gmail Accounts: `GET /accounts`

## Data Flow

1. **HTTP Request** → MockApiService calls Render server
2. **JSON Parsing** → Response parsed and validated
3. **Data Counting** → Intelligent count determination
4. **UI Formatting** → Data transformed for display
5. **State Update** → Provider notifies UI

## Configuration

Environment variables in `.env`:

```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
MOCK_API_BASE_URL=https://mock-server-6yyu.onrender.com
```

## Dependencies

```yaml
dependencies:
  http: ^1.1.0                    # HTTP client
  provider: ^6.1.1               # State management
  flutter_dotenv: ^5.1.0         # Environment variables
```

## File Structure

```
lib/
├── main.dart
├── config/environment.dart
├── services/
│   ├── firebase_rest_auth_service.dart
│   └── mock_api_service.dart
└── screens/
    ├── auth_screen.dart
    └── home_screen.dart
```