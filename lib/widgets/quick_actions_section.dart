import 'package:flutter/material.dart';
import '../services/mock_api_service.dart';

/// A section widget that displays quick action cards for the home screen.
/// 
/// Provides buttons for common actions like testing API connections,
/// discovering endpoints, and accessing user features.
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context),
        const SizedBox(height: 16),
        _buildActionGrid(context),
      ],
    );
  }

  /// Builds the section title
  Widget _buildSectionTitle(BuildContext context) {
    return Text(
      'Quick Actions',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1976D2),
      ),
    );
  }

  /// Builds the grid of action cards
  Widget _buildActionGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'Profile',
                Icons.person,
                Colors.blue,
                () => _showComingSoon(context, 'Profile'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                context,
                'Test API',
                Icons.api,
                Colors.orange,
                () => _handleTestApi(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'Discover Endpoints',
                Icons.search,
                Colors.purple,
                () => _handleDiscoverEndpoints(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                context,
                'Settings',
                Icons.settings,
                Colors.green,
                () => _showComingSoon(context, 'Settings'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds an individual action card
  Widget _buildActionCard(
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handles the Test API action
  Future<void> _handleTestApi(BuildContext context) async {
    final mockApi = MockApiService();
    
    // Test basic connection
    final isConnected = await mockApi.testConnection();
    
    if (isConnected) {
      // Test common endpoints
      final endpoints = await mockApi.testCommonEndpoints();
      final workingEndpoints = endpoints.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();
      
      mockApi.dispose();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              workingEndpoints.isNotEmpty
                ? '✅ API connected! Found endpoints: ${workingEndpoints.join(', ')}'
                : '✅ API server reachable (404 is normal for root)',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else {
      mockApi.dispose();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ API connection failed!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Handles the Discover Endpoints action
  Future<void> _handleDiscoverEndpoints(BuildContext context) async {
    final mockApi = MockApiService();
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Discovering endpoints...'),
          ],
        ),
      ),
    );
    
    try {
      final results = await mockApi.discoverEndpoints();
      mockApi.dispose();
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        // Note: This would need to be implemented in the parent widget
        // or passed as a callback to show the results
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found ${results.length} endpoints'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      mockApi.dispose();
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Discovery failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Shows a "coming soon" message for unimplemented features
  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
      ),
    );
  }
}
