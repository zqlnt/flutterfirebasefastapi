import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_rest_auth_service.dart';
import '../widgets/welcome_card.dart';
import '../widgets/auth_status_card.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/mock_data_section.dart';
import '../widgets/database_data_section.dart';

/// The main home screen displayed after successful authentication.
/// 
/// This screen provides a dashboard with user information, authentication
/// status, and quick actions for testing API connectivity and data fetching.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  /// Builds the app bar with user menu
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Infinity Link'),
      backgroundColor: const Color(0xFF1976D2),
      foregroundColor: Colors.white,
      actions: [
        _buildUserMenu(context),
      ],
    );
  }

  /// Builds the user menu dropdown
  Widget _buildUserMenu(BuildContext context) {
    return Consumer<FirebaseRestAuthService>(
      builder: (context, authService, child) {
        return PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'logout') {
              await _handleSignOut(context, authService);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Sign Out'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds the main body content
  Widget _buildBody(BuildContext context) {
    return Consumer<FirebaseRestAuthService>(
      builder: (context, authService, child) {
        return Container(
          decoration: _buildBackgroundDecoration(),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(authService),
                  const SizedBox(height: 24),
                  _buildAuthStatusSection(authService),
                  const SizedBox(height: 24),
                  const QuickActionsSection(),
                  const SizedBox(height: 32),
                  const MockDataSection(),
                  const SizedBox(height: 32),
                  const DatabaseDataSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the background gradient decoration
  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE3F2FD),
          Colors.white,
        ],
      ),
    );
  }

  /// Builds the welcome section with user info
  Widget _buildWelcomeSection(FirebaseRestAuthService authService) {
    return WelcomeCard(
      userEmail: authService.userEmail,
      displayName: authService.displayName,
    );
  }

  /// Builds the authentication status section
  Widget _buildAuthStatusSection(FirebaseRestAuthService authService) {
    return AuthStatusCard(
      userId: authService.userId,
      userEmail: authService.userEmail,
    );
  }

  /// Handles user sign out
  Future<void> _handleSignOut(BuildContext context, FirebaseRestAuthService authService) async {
    try {
      await authService.signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
