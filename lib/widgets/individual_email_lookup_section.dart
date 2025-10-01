import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/mock_api_service.dart';

/// Widget for individual email lookup functionality.
/// 
/// This widget provides a text input field and two buttons to fetch individual
/// email details by ID using either the inbox format (/emails/{id}) or 
/// database format (/db/email/messages/{id}) endpoints.
class IndividualEmailLookupSection extends StatefulWidget {
  const IndividualEmailLookupSection({super.key});

  @override
  State<IndividualEmailLookupSection> createState() => _IndividualEmailLookupSectionState();
}

class _IndividualEmailLookupSectionState extends State<IndividualEmailLookupSection> {
  final TextEditingController _idController = TextEditingController();
  final MockApiService _apiService = MockApiService();
  
  Map<String, dynamic>? _emailData;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentFormat;

  @override
  void dispose() {
    _idController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  /// Fetch email using string ID (inbox format)
  Future<void> _fetchInboxFormat() async {
    final id = _idController.text.trim();
    if (id.isEmpty) {
      _showErrorMessage('Please enter an email ID');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _emailData = null;
      _currentFormat = 'inbox';
    });

    try {
      final result = await _apiService.getEmailByStringId(id);
      
      if (result['success'] == true) {
        setState(() {
          _emailData = result['data'];
          _errorMessage = null;
        });
        _showSuccessMessage('Email fetched successfully (Inbox Format)');
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to fetch email';
          _emailData = null;
        });
        _showErrorMessage(_errorMessage!);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _emailData = null;
      });
      _showErrorMessage(_errorMessage!);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Fetch email using integer ID (database format)
  Future<void> _fetchDbFormat() async {
    final idText = _idController.text.trim();
    if (idText.isEmpty) {
      _showErrorMessage('Please enter an email ID');
      return;
    }

    int? id;
    try {
      id = int.parse(idText);
    } catch (e) {
      _showErrorMessage('Please enter a valid integer ID for database format');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _emailData = null;
      _currentFormat = 'database';
    });

    try {
      final result = await _apiService.getEmailByIntId(id);
      
      if (result['success'] == true) {
        setState(() {
          _emailData = result['data'];
          _errorMessage = null;
        });
        _showSuccessMessage('Email fetched successfully (Database Format)');
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to fetch email';
          _emailData = null;
        });
        _showErrorMessage(_errorMessage!);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _emailData = null;
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

  /// Build the email data display
  Widget _buildEmailData() {
    if (_emailData == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _currentFormat == 'inbox' ? Icons.inbox : Icons.storage,
                  color: _currentFormat == 'inbox' ? Colors.blue : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Email Details (${_currentFormat?.toUpperCase()} Format)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEmailFields(),
            if (_emailData!['attachments'] != null && 
                (_emailData!['attachments'] as List).isNotEmpty)
              _buildAttachmentsSection(),
          ],
        ),
      ),
    );
  }

  /// Build email fields display
  Widget _buildEmailFields() {
    final data = _emailData!;
    final fields = <Widget>[];

    // Common fields for both formats
    if (data['subject'] != null) {
      fields.add(_buildFieldRow('Subject', data['subject']));
    }
    if (data['sender'] != null) {
      fields.add(_buildFieldRow('Sender', data['sender']));
    }
    if (data['recipient'] != null) {
      fields.add(_buildFieldRow('Recipient', data['recipient']));
    }
    if (data['threadId'] != null) {
      fields.add(_buildFieldRow('Thread ID', data['threadId']));
    }

    // Inbox format specific fields
    if (_currentFormat == 'inbox') {
      if (data['htmlBody'] != null) {
        fields.add(_buildFieldRow('HTML Body', data['htmlBody'], isLongText: true));
      }
      if (data['cleanBody'] != null) {
        fields.add(_buildFieldRow('Clean Body', data['cleanBody'], isLongText: true));
      }
    }

    // Database format specific fields
    if (_currentFormat == 'database') {
      if (data['user_id'] != null) {
        fields.add(_buildFieldRow('User ID', data['user_id']));
      }
      if (data['gmail_id'] != null) {
        fields.add(_buildFieldRow('Gmail ID', data['gmail_id']));
      }
      if (data['created_at'] != null) {
        fields.add(_buildFieldRow('Created At', data['created_at']));
      }
      if (data['updated_at'] != null) {
        fields.add(_buildFieldRow('Updated At', data['updated_at']));
      }
      if (data['raw_headers'] != null) {
        fields.add(_buildFieldRow('Raw Headers', data['raw_headers'], isLongText: true));
      }
      if (data['html_body'] != null) {
        fields.add(_buildFieldRow('HTML Body', data['html_body'], isLongText: true));
      }
      if (data['text_body'] != null) {
        fields.add(_buildFieldRow('Text Body', data['text_body'], isLongText: true));
      }
    }

    return Column(children: fields);
  }

  /// Build individual field row
  Widget _buildFieldRow(String label, dynamic value, {bool isLongText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              value?.toString() ?? 'N/A',
              style: TextStyle(
                fontSize: isLongText ? 12 : 14,
                fontFamily: isLongText ? 'monospace' : null,
              ),
              maxLines: isLongText ? 10 : 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Build attachments section
  Widget _buildAttachmentsSection() {
    final attachments = _emailData!['attachments'] as List;
    
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.attach_file, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Attachments (${attachments.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...attachments.map((attachment) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (attachment['filename'] != null)
                  Text(
                    'File: ${attachment['filename']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                if (attachment['contentType'] != null)
                  Text('Type: ${attachment['contentType']}'),
                if (attachment['size'] != null)
                  Text('Size: ${attachment['size']} bytes'),
                if (attachment['id'] != null)
                  Text('ID: ${attachment['id']}'),
              ],
            ),
          )).toList(),
        ],
      ),
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
                const Icon(Icons.search, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Individual Email Lookup',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter an email ID to fetch individual email details:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Email ID',
                hintText: 'Enter string ID for inbox format or integer ID for database format',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _fetchInboxFormat,
                    icon: const Icon(Icons.inbox),
                    label: const Text('Fetch Inbox Format'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _fetchDbFormat,
                    icon: const Icon(Icons.storage),
                    label: const Text('Fetch DB Format'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
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
            _buildEmailData(),
          ],
        ),
      ),
    );
  }
}
