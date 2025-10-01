import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// FastAPI authentication service using Bearer tokens.
/// 
/// This service handles user authentication through a FastAPI server,
/// providing email/password sign-in and sign-up functionality with Bearer token support.
/// It's designed to work alongside the existing Firebase authentication.
class FastApiAuthService extends ChangeNotifier {
  // Private state variables
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _userId;
  String? _displayName;
  String? _bearerToken;
  String? _authMethod;

  // FastAPI server configuration
  static const String baseUrl = 'https://mock-server-6yyu.onrender.com';
  
  // Common authentication endpoints to try
  static const List<String> loginEndpoints = [
    '/auth/login',
    '/auth/signin', 
    '/login',
    '/token',
    '/api/auth/login',
    '/api/login'
  ];
  
  static const List<String> signupEndpoints = [
    '/auth/signup',
    '/auth/register',
    '/signup',
    '/register',
    '/api/auth/signup',
    '/api/register'
  ];

  // HTTP client
  final http.Client _client = http.Client();

  // Public getters for accessing authentication state
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get userId => _userId;
  String? get displayName => _displayName;
  String? get bearerToken => _bearerToken;
  String? get authMethod => _authMethod;

  /// Signs in a user with email and password using FastAPI server.
  /// 
  /// [email] - The user's email address
  /// [password] - The user's password
  /// 
  /// Throws an exception if authentication fails or network error occurs.
  Future<void> signInWithFastAPI(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('FastAPI Email Sign-In via REST API');
      debugPrint('Email: $email');
      debugPrint('Base URL: $baseUrl');
      
      // Try different login endpoints
      for (final endpoint in loginEndpoints) {
        try {
          final response = await _client.post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'email': email,
              'password': password,
            }),
          ).timeout(const Duration(seconds: 10));

          debugPrint('FastAPI Response: ${response.statusCode}');
          debugPrint('Response body: ${response.body}');

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            
            // Extract token from various possible response formats
            String? token = data['access_token'] ?? 
                           data['token'] ?? 
                           data['bearer_token'] ?? 
                           data['auth_token'] ??
                           data['jwt'] ??
                           data['token'];

            if (token != null) {
              _isAuthenticated = true;
              _userEmail = email;
              _userId = data['user_id'] ?? data['id'] ?? data['user']['id']?.toString();
              _displayName = data['display_name'] ?? data['name'] ?? data['user']['name'] ?? email.split('@')[0];
              _bearerToken = token;
              _authMethod = 'FastAPI';

              debugPrint('FastAPI email sign-in successful!');
              debugPrint('User ID: $_userId');
              debugPrint('Email: $_userEmail');
              debugPrint('Bearer Token: ${_bearerToken?.substring(0, 20)}...');
              debugPrint('Auth Method: $_authMethod');
              
              _isLoading = false;
              notifyListeners();
              return;
            }
          }
        } catch (e) {
          debugPrint('Failed to authenticate with $endpoint: $e');
          continue;
        }
      }
      
      throw Exception('No working authentication endpoint found');
      
    } catch (e) {
      debugPrint('FastAPI sign-in error: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Creates a new user with email and password using FastAPI server.
  /// 
  /// [email] - The user's email address
  /// [password] - The user's password
  /// 
  /// Throws an exception if registration fails or network error occurs.
  Future<void> signUpWithFastAPI(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('FastAPI Email Sign-Up via REST API');
      debugPrint('Email: $email');
      debugPrint('Base URL: $baseUrl');
      
      // Try different signup endpoints
      for (final endpoint in signupEndpoints) {
        try {
          final response = await _client.post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'email': email,
              'password': password,
            }),
          ).timeout(const Duration(seconds: 10));

          debugPrint('FastAPI Response: ${response.statusCode}');
          debugPrint('Response body: ${response.body}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            final data = json.decode(response.body);
            
            // Extract token from various possible response formats
            String? token = data['access_token'] ?? 
                           data['token'] ?? 
                           data['bearer_token'] ?? 
                           data['auth_token'] ??
                           data['jwt'] ??
                           data['token'];

            if (token != null) {
              _isAuthenticated = true;
              _userEmail = email;
              _userId = data['user_id'] ?? data['id'] ?? data['user']['id']?.toString();
              _displayName = data['display_name'] ?? data['name'] ?? data['user']['name'] ?? email.split('@')[0];
              _bearerToken = token;
              _authMethod = 'FastAPI';

              debugPrint('FastAPI email sign-up successful!');
              debugPrint('User ID: $_userId');
              debugPrint('Email: $_userEmail');
              debugPrint('Bearer Token: ${_bearerToken?.substring(0, 20)}...');
              debugPrint('Auth Method: $_authMethod');
              
              _isLoading = false;
              notifyListeners();
              return;
            }
          }
        } catch (e) {
          debugPrint('Failed to register with $endpoint: $e');
          continue;
        }
      }
      
      throw Exception('No working registration endpoint found');
      
    } catch (e) {
      debugPrint('FastAPI sign-up error: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Signs out the current user and clears authentication state.
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('FastAPI Sign Out');
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      _isAuthenticated = false;
      _userEmail = null;
      _userId = null;
      _displayName = null;
      _bearerToken = null;
      _authMethod = null;

      debugPrint('FastAPI sign-out successful!');
    } catch (e) {
      debugPrint('FastAPI sign-out error: $e');
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Gets the authorization header for API requests.
  /// Returns null if not authenticated.
  Map<String, String>? getAuthorizationHeaders() {
    if (_isAuthenticated && _bearerToken != null) {
      return {
        'Authorization': 'Bearer $_bearerToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    }
    return null;
  }

  /// Disposes the HTTP client
  void dispose() {
    _client.close();
    super.dispose();
  }
}
