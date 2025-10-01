import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mock_api_service.dart';
import '../services/fastapi_auth_service.dart';

/// A section widget that displays database data fetching functionality.
/// 
/// Provides buttons for fetching email messages and calendar events from
/// the mock database endpoints, with proper loading states and error handling.
class DatabaseDataSection extends StatelessWidget {
  const DatabaseDataSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context),
        const SizedBox(height: 16),
        _buildDatabaseCards(context),
      ],
    );
  }

  /// Builds the section title
  Widget _buildSectionTitle(BuildContext context) {
    return Text(
      'Mock Database Data',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: const Color(0xFF4CAF50),
      ),
    );
  }

  /// Builds the database cards
  Widget _buildDatabaseCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildDatabaseCard(
            context,
            'Email Messages',
            Icons.email,
            Colors.blue,
            () => _fetchDatabaseData(context, 'email_messages', () => _getMockApiWithToken(context).getEmailMessages()),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDatabaseCard(
            context,
            'Calendar Events',
            Icons.event,
            Colors.orange,
            () => _fetchDatabaseData(context, 'calendar_events', () => _getMockApiWithToken(context).getCalendarEvents()),
          ),
        ),
      ],
    );
  }

  /// Builds an individual database card
  Widget _buildDatabaseCard(
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
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Database Schema',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Gets MockApiService with Bearer token if available
  MockApiService _getMockApiWithToken(BuildContext context) {
    final mockApi = MockApiService();
    
    // Set Bearer token if FastAPI auth is active
    final fastApiAuth = Provider.of<FastApiAuthService>(context, listen: false);
    if (fastApiAuth.isAuthenticated && fastApiAuth.bearerToken != null) {
      mockApi.setBearerToken(fastApiAuth.bearerToken);
    }
    
    return mockApi;
  }

  /// Fetches database data and shows results
  Future<void> _fetchDatabaseData(
    BuildContext context,
    String dataType,
    Future<Map<String, dynamic>> Function() fetchFunction,
  ) async {
    final mockApi = _getMockApiWithToken(context);
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text('Loading $dataType from database...'),
          ],
        ),
      ),
    );
    
    try {
      final result = await fetchFunction();
      mockApi.dispose();
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showDatabaseResults(context, dataType, result);
      }
    } catch (e) {
      mockApi.dispose();
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to load $dataType: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Shows database results with structured display
  void _showDatabaseResults(BuildContext context, String dataType, Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${dataType.replaceAll('_', ' ').toUpperCase()} Database'),
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
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            '✅ ${result['count']} items loaded successfully',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      if (result['count'] > 10) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Showing first 10 items. Click "Show All" to see all ${result['count']} items.',
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
                  child: _buildDatabaseDataPreview(dataType, result['data'], context),
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
                          '❌ Failed to load data: ${result['error']}',
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
              onPressed: () => _showAllItems(context, dataType, result['data']),
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

  /// Show all items in a full-screen dialog
  void _showAllItems(BuildContext context, String dataType, dynamic data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('All ${dataType.replaceAll('_', ' ').toUpperCase()} Items'),
        content: SizedBox(
          width: double.maxFinite,
          height: 600,
          child: _buildDatabaseDataPreview(dataType, data, context, showAll: true),
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

  /// Build structured database data preview
  Widget _buildDatabaseDataPreview(String dataType, dynamic data, BuildContext context, {bool showAll = false}) {
    if (data == null || (data is List && data.isEmpty)) {
      return const Center(
        child: Text('No data available'),
      );
    }
    
    if (data is List) {
      final itemCount = showAll ? data.length : (data.length > 10 ? 10 : data.length);
      return ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final item = data[index];
          return _buildDatabaseItemCard(dataType, item, index, context);
        },
      );
    } else {
      return _buildDatabaseItemCard(dataType, data, 0, context);
    }
  }

  /// Build individual database item card
  Widget _buildDatabaseItemCard(String dataType, dynamic item, int index, BuildContext context) {
    if (dataType == 'email_messages') {
      return _buildEmailCard(item, index, context);
    } else if (dataType == 'calendar_events') {
      return _buildCalendarCard(item, index, context);
    } else {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          title: Text('Item ${index + 1}'),
          subtitle: Text(_formatDataPreview(item)),
          onTap: () => _showItemDetails(context, item),
        ),
      );
    }
  }

  /// Build email message card
  Widget _buildEmailCard(dynamic email, int index, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(Icons.email, color: Colors.blue[700]),
        ),
        title: Text(
          email['subject'] ?? email['title'] ?? 'No Subject',
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'From: ${email['sender'] ?? email['from'] ?? 'Unknown'}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            if (email['date'] != null || email['timestamp'] != null)
              Text(
                'Date: ${email['date'] ?? email['timestamp']}',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            if (email['snippet'] != null || email['body'] != null)
              Text(
                email['snippet'] ?? email['body'] ?? '',
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        onTap: () => _showItemDetails(context, email),
      ),
    );
  }

  /// Build calendar event card
  Widget _buildCalendarCard(dynamic event, int index, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange[100],
          child: Icon(Icons.event, color: Colors.orange[700]),
        ),
        title: Text(
          event['title'] ?? event['name'] ?? 'No Title',
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (event['date'] != null || event['start_date'] != null)
              Text(
                'Date: ${event['date'] ?? event['start_date']}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            if (event['time'] != null || event['start_time'] != null)
              Text(
                'Time: ${event['time'] ?? event['start_time']}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            if (event['description'] != null || event['details'] != null)
              Text(
                event['description'] ?? event['details'] ?? '',
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        onTap: () => _showItemDetails(context, event),
      ),
    );
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

