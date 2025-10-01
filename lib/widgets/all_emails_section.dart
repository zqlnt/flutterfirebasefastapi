import 'package:flutter/material.dart';
import '../services/mock_api_service.dart';

/// Widget for fetching and displaying all emails with their IDs.
/// 
/// This widget provides a button to fetch all emails from the database
/// and displays them in scrollable cards showing key email information.
class AllEmailsSection extends StatefulWidget {
  const AllEmailsSection({super.key});

  @override
  State<AllEmailsSection> createState() => _AllEmailsSectionState();
}

class _AllEmailsSectionState extends State<AllEmailsSection> {
  final MockApiService _apiService = MockApiService();
  
  List<dynamic> _emails = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _totalCount = 0;

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  /// Fetch all emails from the database
  Future<void> _fetchAllEmails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _emails = [];
      _totalCount = 0;
    });

    try {
      final result = await _apiService.getEmailMessages();
      
      if (result['success'] == true) {
        setState(() {
          _emails = result['data'] is List ? result['data'] : [result['data']];
          _totalCount = result['count'] ?? _emails.length;
          _errorMessage = null;
        });
        _showSuccessMessage('${_totalCount} emails loaded successfully');
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to fetch emails';
          _emails = [];
          _totalCount = 0;
        });
        _showErrorMessage(_errorMessage!);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _emails = [];
        _totalCount = 0;
      });
      _showErrorMessage(_errorMessage!);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Show success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Format timestamp for display
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    
    try {
      if (timestamp is String) {
        final date = DateTime.parse(timestamp);
        return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      }
      return timestamp.toString();
    } catch (e) {
      return timestamp.toString();
    }
  }

  /// Build individual email card
  Widget _buildEmailCard(dynamic email, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with ID and index
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ID: ${email['id'] ?? 'N/A'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '#${index + 1}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Subject
            if (email['subject'] != null)
              _buildFieldRow('Subject', email['subject'], isBold: true),
            
            // Sender and Recipient
            Row(
              children: [
                if (email['sender'] != null)
                  Expanded(
                    child: _buildFieldRow('From', email['sender'], isCompact: true),
                  ),
                if (email['recipient'] != null)
                  Expanded(
                    child: _buildFieldRow('To', email['recipient'], isCompact: true),
                  ),
              ],
            ),
            
            // Received timestamp
            if (email['received_at'] != null)
              _buildFieldRow('Received', _formatTimestamp(email['received_at']), isCompact: true),
            
            // Snippet
            if (email['snippet'] != null)
              _buildFieldRow('Snippet', email['snippet'], isLongText: true),
            
            // Additional info if available
            if (email['user_id'] != null)
              _buildFieldRow('User ID', email['user_id'], isCompact: true),
          ],
        ),
      ),
    );
  }

  /// Build field row
  Widget _buildFieldRow(String label, dynamic value, {bool isBold = false, bool isCompact = false, bool isLongText = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isCompact ? 4 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: Colors.grey[700],
              fontSize: isCompact ? 12 : 14,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isCompact ? 6 : 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              value?.toString() ?? 'N/A',
              style: TextStyle(
                fontSize: isCompact ? 12 : 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontFamily: isLongText ? 'monospace' : null,
              ),
              maxLines: isLongText ? 3 : (isCompact ? 1 : 2),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Build the emails list
  Widget _buildEmailsList() {
    if (_emails.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Count header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              const Icon(Icons.email, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                '$_totalCount emails found',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Scrollable emails list
        Container(
          height: 400, // Fixed height for scrollable area
          child: ListView.builder(
            itemCount: _emails.length,
            itemBuilder: (context, index) {
              return _buildEmailCard(_emails[index], index);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.list_alt, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Fetch All Emails with IDs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Load all emails from the database with their IDs and details:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            // Load button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _fetchAllEmails,
                icon: _isLoading 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
                label: Text(_isLoading ? 'Loading Emails...' : 'Load All Emails with IDs'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            
            // Loading indicator
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            
            // Error message
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
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
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Emails list
            if (_emails.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _buildEmailsList(),
              ),
          ],
        ),
      ),
    );
  }
}
