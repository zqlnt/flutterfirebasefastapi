import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/environment.dart';

/// Service for interacting with the mock API server.
/// 
/// This service provides methods to test connectivity, discover endpoints,
/// and fetch data from various mock API endpoints. It's designed to work
/// with the mock server at https://mock-server-6yyu.onrender.com.
class MockApiService {
  /// Base URL for the mock API server (from Environment)
  static String get baseUrl => Environment.mockApiBaseUrl;
  
  /// HTTP client configured with timeout settings
  final http.Client _client = http.Client();
  
  /// Tests the connection to the mock API server.
  /// 
  /// Makes a simple GET request to the base URL to verify the server is reachable.
  /// Returns true if the server responds (even with 404), false if connection fails.
  /// 
  /// Returns [true] if connection is successful, [false] otherwise.
  Future<bool> testConnection() async {
    try {
      debugPrint('Testing connection to mock API...');
      debugPrint('URL: $baseUrl');
      
      // Make a simple GET request to test connectivity
      final response = await _client
          .get(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('Connection timeout after 10 seconds');
              throw TimeoutException('Connection timeout', const Duration(seconds: 10));
            },
          );
      
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Headers: ${response.headers}');
      debugPrint('Response Body: ${response.body}');
      
      // For mock APIs, even 404 means the server is reachable
      // We just need to confirm the server responded
      if (response.statusCode >= 200 && response.statusCode < 500) {
        debugPrint('Mock API server is reachable!');
        debugPrint('Note: 404 is normal for root endpoint - server is working');
        return true;
      } else {
        debugPrint('Mock API server error: ${response.statusCode}');
        return false;
      }
      
    } on TimeoutException catch (e) {
      debugPrint('Connection timeout: $e');
      return false;
    } on SocketException catch (e) {
      debugPrint('Network error: $e');
      return false;
    } on HttpException catch (e) {
      debugPrint('HTTP error: $e');
      return false;
    } on FormatException catch (e) {
      debugPrint('Format error: $e');
      return false;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return false;
    }
  }
  
  /// Test a specific endpoint on the mock API
  Future<bool> testEndpoint(String endpoint) async {
    try {
      final url = '$baseUrl$endpoint';
      debugPrint('Testing endpoint: $url');
      
      final response = await _client
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));
      
      debugPrint('Endpoint Response: ${response.statusCode}');
      debugPrint('Endpoint Body: ${response.body}');
      
      return response.statusCode >= 200 && response.statusCode < 300;
      
    } catch (e) {
      debugPrint('Endpoint test failed: $e');
      return false;
    }
  }
  
  /// Test common API endpoints that might exist
  Future<Map<String, bool>> testCommonEndpoints() async {
    final endpoints = ['/api', '/api/users', '/api/health', '/api/status', '/docs', '/swagger'];
    final results = <String, bool>{};
    
    for (final endpoint in endpoints) {
      results[endpoint] = await testEndpoint(endpoint);
    }
    
    return results;
  }
  
  /// Discover available endpoints on the mock API
  /// Returns a map of endpoint paths and their response details
  Future<Map<String, Map<String, dynamic>>> discoverEndpoints() async {
    debugPrint('Starting endpoint discovery...');
    
    // Common REST API endpoints to test
    final endpointsToTest = [
      // Basic data endpoints
      '/users', '/posts', '/products', '/todos', '/items', '/data',
      '/customers', '/orders', '/categories', '/comments', '/reviews',
      
      // API versioned endpoints
      '/api', '/api/v1', '/api/v2', '/api/users', '/api/posts', '/api/products',
      '/api/todos', '/api/items', '/api/data', '/api/customers', '/api/orders',
      
      // Health and status endpoints
      '/health', '/status', '/ping', '/heartbeat', '/ready', '/live',
      
      // Documentation endpoints
      '/docs', '/swagger', '/redoc', '/openapi.json', '/api-docs',
      
      // Common variations
      '/user', '/post', '/product', '/todo', '/item', '/datum',
      '/customer', '/order', '/category', '/comment', '/review',
    ];
    
    final results = <String, Map<String, dynamic>>{};
    
    for (final endpoint in endpointsToTest) {
      try {
        final url = '$baseUrl$endpoint';
        debugPrint('Testing: $url');
        
        final response = await _client
            .get(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 5));
        
        final result = {
          'statusCode': response.statusCode,
          'contentType': response.headers['content-type'] ?? 'unknown',
          'contentLength': response.headers['content-length'] ?? 'unknown',
          'success': response.statusCode >= 200 && response.statusCode < 300,
          'body': _parseResponseBody(response.body, response.headers['content-type']),
        };
        
        results[endpoint] = result;
        
        debugPrint('$endpoint: ${response.statusCode} (${response.headers['content-type']})');
        
        // Only log body for successful responses to avoid spam
        if (response.statusCode >= 200 && response.statusCode < 300) {
          debugPrint('$endpoint body: ${response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body}');
        }
        
      } catch (e) {
        results[endpoint] = {
          'statusCode': 0,
          'contentType': 'error',
          'contentLength': '0',
          'success': false,
          'body': 'Error: $e',
        };
        debugPrint('$endpoint: Error - $e');
      }
    }
    
    // Summary
    final successfulEndpoints = results.entries
        .where((e) => e.value['success'] == true)
        .map((e) => e.key)
        .toList();
    
    debugPrint('Discovery complete!');
    debugPrint('Total endpoints tested: ${results.length}');
    debugPrint('Successful endpoints: ${successfulEndpoints.length}');
    debugPrint('Available endpoints: $successfulEndpoints');
    
    return results;
  }
  
  /// Parse response body based on content type
  String _parseResponseBody(String body, String? contentType) {
    if (body.isEmpty) return 'Empty response';
    
    // Truncate very long responses
    if (body.length > 500) {
      body = '${body.substring(0, 500)}...';
    }
    
    if (contentType?.contains('json') == true) {
      try {
        // Try to format JSON nicely
        final json = jsonDecode(body);
        return jsonEncode(json);
      } catch (e) {
        return body;
      }
    }
    
    return body;
  }
  
  /// Get Gmail accounts
  Future<Map<String, dynamic>> getAccounts() async {
    try {
      debugPrint('Fetching Gmail accounts...');
      final response = await _client
          .get(
            Uri.parse('$baseUrl/accounts'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));
      
      debugPrint('Accounts Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Accounts fetched successfully: ${data.length} accounts');
        
        // Debug: Print the structure of the first account
        if (data is List && data.isNotEmpty) {
          debugPrint('First account structure: ${data[0]}');
          debugPrint('Account keys: ${data[0].keys.toList()}');
        }
        
        return {
          'success': true,
          'data': data,
          'count': data is List ? data.length : 1,
        };
      } else {
        throw Exception('Failed to fetch accounts: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching accounts: $e');
      return {
        'success': false,
        'error': e.toString(),
        'data': null,
        'count': 0,
      };
    }
  }
  
  /// Get inbox messages
  Future<Map<String, dynamic>> getInboxMessages() async {
    try {
      debugPrint('Fetching inbox messages...');
      final response = await _client
          .get(
            Uri.parse('$baseUrl/emails/inbox'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));
      
      debugPrint('Inbox Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Inbox messages fetched successfully: ${data.length} messages');
        return {
          'success': true,
          'data': data,
          'count': data is List ? data.length : 1,
        };
      } else {
        throw Exception('Failed to fetch inbox messages: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching inbox messages: $e');
      return {
        'success': false,
        'error': e.toString(),
        'data': null,
        'count': 0,
      };
    }
  }
  
  /// Get email messages from database
  Future<Map<String, dynamic>> getEmailMessages() async {
    try {
      debugPrint('Fetching email messages from DB...');
      final response = await _client
          .get(
            Uri.parse('$baseUrl/db/email/messages'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));
      
      debugPrint('Email Messages Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Raw email response: ${response.body}');
        
        // Handle different response formats
        int itemCount = 0;
        dynamic itemsData = data;
        
        if (data is List) {
          itemCount = data.length;
          itemsData = data;
        } else if (data is Map && data.containsKey('data') && data['data'] is List) {
          itemCount = data['data'].length;
          itemsData = data['data'];
        } else if (data is Map && data.containsKey('items') && data['items'] is List) {
          itemCount = data['items'].length;
          itemsData = data['items'];
        } else if (data is Map && data.containsKey('results') && data['results'] is List) {
          itemCount = data['results'].length;
          itemsData = data['results'];
        } else {
          itemCount = 1;
          itemsData = data;
        }
        
        debugPrint('Email messages fetched successfully: $itemCount messages');
        debugPrint('Response structure: ${data.runtimeType}');
        if (data is Map) {
          debugPrint('Map keys: ${data.keys.toList()}');
        }
        
        return {
          'success': true,
          'data': itemsData,
          'count': itemCount,
          'rawResponse': data,
        };
      } else {
        throw Exception('Failed to fetch email messages: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching email messages: $e');
      return {
        'success': false,
        'error': e.toString(),
        'data': null,
        'count': 0,
      };
    }
  }
  
  /// Get calendar events from database
  Future<Map<String, dynamic>> getCalendarEvents() async {
    try {
      debugPrint('Fetching calendar events from DB...');
      final response = await _client
          .get(
            Uri.parse('$baseUrl/db/calendar/events'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));
      
      debugPrint('Calendar Events Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Raw calendar response: ${response.body}');
        
        // Handle different response formats
        int itemCount = 0;
        dynamic itemsData = data;
        
        if (data is List) {
          itemCount = data.length;
          itemsData = data;
        } else if (data is Map && data.containsKey('data') && data['data'] is List) {
          itemCount = data['data'].length;
          itemsData = data['data'];
        } else if (data is Map && data.containsKey('items') && data['items'] is List) {
          itemCount = data['items'].length;
          itemsData = data['items'];
        } else if (data is Map && data.containsKey('results') && data['results'] is List) {
          itemCount = data['results'].length;
          itemsData = data['results'];
        } else {
          itemCount = 1;
          itemsData = data;
        }
        
        debugPrint('Calendar events fetched successfully: $itemCount events');
        debugPrint('Response structure: ${data.runtimeType}');
        if (data is Map) {
          debugPrint('Map keys: ${data.keys.toList()}');
        }
        
        return {
          'success': true,
          'data': itemsData,
          'count': itemCount,
          'rawResponse': data,
        };
      } else {
        throw Exception('Failed to fetch calendar events: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching calendar events: $e');
      return {
        'success': false,
        'error': e.toString(),
        'data': null,
        'count': 0,
      };
    }
  }
  
  /// Get individual email by string ID (inbox format)
  /// Fetches from /emails/{id} endpoint which returns HTML body with clean text and attachments
  Future<Map<String, dynamic>> getEmailByStringId(String id) async {
    try {
      debugPrint('Fetching email by string ID: $id');
      final response = await _client
          .get(
            Uri.parse('$baseUrl/emails/$id'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));
      
      debugPrint('Email String ID Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Email fetched successfully by string ID');
        debugPrint('Email structure: ${data.keys.toList()}');
        
        return {
          'success': true,
          'data': data,
          'format': 'inbox',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Email not found with ID: $id',
          'data': null,
        };
      } else {
        throw Exception('Failed to fetch email by string ID: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching email by string ID: $e');
      return {
        'success': false,
        'error': e.toString(),
        'data': null,
      };
    }
  }
  
  /// Get individual email by integer ID (database format)
  /// Fetches from /db/email/messages/{id} endpoint which returns full database schema
  Future<Map<String, dynamic>> getEmailByIntId(int id) async {
    try {
      debugPrint('Fetching email by integer ID: $id');
      final response = await _client
          .get(
            Uri.parse('$baseUrl/db/email/messages/$id'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));
      
      debugPrint('Email Int ID Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Email fetched successfully by integer ID');
        debugPrint('Email structure: ${data.keys.toList()}');
        
        return {
          'success': true,
          'data': data,
          'format': 'database',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Email not found with ID: $id',
          'data': null,
        };
      } else {
        throw Exception('Failed to fetch email by integer ID: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching email by integer ID: $e');
      return {
        'success': false,
        'error': e.toString(),
        'data': null,
      };
    }
  }
  
  /// Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}
