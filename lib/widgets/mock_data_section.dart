import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mock_api_service.dart';
import '../services/fastapi_auth_service.dart';

/// A section widget that displays mock data fetching functionality.
/// 
/// Provides buttons for fetching various types of mock data from
/// different API endpoints, with proper loading states and error handling.
class MockDataSection extends StatelessWidget {
  const MockDataSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context),
        const SizedBox(height: 16),
        _buildMockDataGrid(context),
      ],
    );
  }

  /// Builds the section title
  Widget _buildSectionTitle(BuildContext context) {
    return Text(
      'Fetch Mock Data',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1976D2),
      ),
    );
  }

  /// Builds the grid of mock data cards
  Widget _buildMockDataGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDataCard(
                context,
                'Gmail Accounts',
                Icons.account_circle,
                Colors.blue,
                () => _fetchAccountsData(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(), // Empty space to maintain layout
            ),
          ],
        ),
      ],
    );
  }

  /// Builds an individual data card
  Widget _buildDataCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fetches accounts data with specialized display
  Future<void> _fetchAccountsData(BuildContext context) async {
    final mockApi = MockApiService();
    
    // Set Bearer token if FastAPI auth is active
    final fastApiAuth = Provider.of<FastApiAuthService>(context, listen: false);
    if (fastApiAuth.isAuthenticated && fastApiAuth.bearerToken != null) {
      mockApi.setBearerToken(fastApiAuth.bearerToken);
    }
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text('Loading Gmail accounts...'),
          ],
        ),
      ),
    );
    
    try {
      final result = await mockApi.getAccounts();
      mockApi.dispose();
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showAccountsResults(context, result);
      }
    } catch (e) {
      mockApi.dispose();
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to load accounts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Shows accounts results with structured display
  void _showAccountsResults(BuildContext context, Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('GMAIL ACCOUNTS'),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (result['success'] == true) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            '✅ ${result['count']} accounts loaded successfully',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      if (result['count'] > 10) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Showing first 10 accounts. Click "Show All" to see all ${result['count']} accounts.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildAccountsDataPreview(result['data'], context),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '❌ Failed to load accounts: ${result['error']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (result['success'] == true && result['count'] > 10)
            TextButton(
              onPressed: () => _showAllAccounts(context, result['data']),
              child: const Text('Show All'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show all accounts in a full-screen dialog
  void _showAllAccounts(BuildContext context, dynamic data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Gmail Accounts'),
        content: SizedBox(
          width: double.maxFinite,
          height: 600,
          child: _buildAccountsDataPreview(data, context, showAll: true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Build accounts data preview
  Widget _buildAccountsDataPreview(dynamic data, BuildContext context, {bool showAll = false}) {
    if (data == null || (data is List && data.isEmpty)) {
      return const Center(
        child: Text('No accounts available'),
      );
    }
    
    if (data is List) {
      final itemCount = showAll ? data.length : (data.length > 10 ? 10 : data.length);
      return ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final account = data[index];
          return _buildAccountCard(account, index, context);
        },
      );
    } else {
      return _buildAccountCard(data, 0, context);
    }
  }

  /// Build individual account card
  Widget _buildAccountCard(dynamic account, int index, BuildContext context) {
    // Extract account information based on the actual API structure
    final email = account['gmail_address'] ?? 
                  account['email'] ?? 
                  account['name'] ?? 
                  account['account'] ?? 
                  account['emailAddress'] ?? 
                  account['address'] ?? 
                  account['user'] ??
                  'Unknown Account';
    
    final displayName = account['displayName'] ?? 
                        account['fullName'] ?? 
                        account['name'] ?? 
                        account['username'];
    
    final accountId = account['id'] ?? 
                      account['accountId'] ?? 
                      account['userId'] ?? 
                      account['user_id'] ??
                      account['localId'];
    
    final status = account['status'] ?? 
                   account['state'] ?? 
                   account['active'] ?? 
                   account['verified'];
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            _getAccountInitial(email),
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          email,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (accountId != null)
              Text(
                'ID: $accountId',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            if (account['scopes'] != null && account['scopes'] is List)
              Text(
                'Scopes: ${(account['scopes'] as List).length} permissions',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            if (account['created_at'] != null)
              Text(
                'Created: ${account['created_at']}',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            // Show account type if available
            if (email.contains('@gmail.com'))
              Text(
                'Gmail Account',
                style: TextStyle(
                  color: Colors.red[600], 
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        onTap: () => _showItemDetails(context, account),
      ),
    );
  }

  /// Get the first letter of the account email for the avatar
  String _getAccountInitial(String email) {
    if (email.isNotEmpty) {
      return email.substring(0, 1).toUpperCase();
    }
    return 'A';
  }

  /// Fetches mock data and shows results
  Future<void> _fetchMockData(
    BuildContext context,
    String dataType,
    Future<Map<String, dynamic>> Function() fetchFunction,
  ) async {
    final mockApi = MockApiService();
    
    // Set Bearer token if FastAPI auth is active
    final fastApiAuth = Provider.of<FastApiAuthService>(context, listen: false);
    if (fastApiAuth.isAuthenticated && fastApiAuth.bearerToken != null) {
      mockApi.setBearerToken(fastApiAuth.bearerToken);
    }
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text('Fetching $dataType data...'),
          ],
        ),
      ),
    );
    
    try {
      final result = await fetchFunction();
      mockApi.dispose();
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showDataResults(context, dataType, result);
      }
    } catch (e) {
      mockApi.dispose();
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to fetch $dataType: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Shows data results in a dialog
  void _showDataResults(BuildContext context, String dataType, Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$dataType Data'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (result['success'] == true) ...[
                Text(
                  '✅ Successfully fetched ${result['count']} items',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildDataPreview(result['data']),
                ),
              ] else ...[
                Text(
                  '❌ Failed to fetch data',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Error: ${result['error']}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Build data preview widget
  Widget _buildDataPreview(dynamic data) {
    if (data == null) {
      return const Text('No data available');
    }
    
    if (data is List) {
      if (data.isEmpty) {
        return const Text('No items found');
      }
      
      return ListView.builder(
        itemCount: data.length > 5 ? 5 : data.length, // Show max 5 items
        itemBuilder: (context, index) {
          final item = data[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 2),
            child: ListTile(
              title: Text('Item ${index + 1}'),
              subtitle: Text(
                _formatDataPreview(item),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _showItemDetails(context, item),
            ),
          );
        },
      );
    } else {
      return SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            _formatDataPreview(data),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ),
      );
    }
  }

  /// Format data for preview
  String _formatDataPreview(dynamic data) {
    if (data == null) return 'null';
    if (data is String) return data;
    if (data is num) return data.toString();
    if (data is bool) return data.toString();
    
    try {
      return jsonEncode(data);
    } catch (e) {
      return data.toString();
    }
  }

  /// Show detailed item information
  void _showItemDetails(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Item Details'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _formatDataPreview(item),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
