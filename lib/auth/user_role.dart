import 'package:career_coaching/profile/coach_profile_screen.dart';
import 'package:career_coaching/profile/individual_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRoleScreen extends StatefulWidget {
  const UserRoleScreen({super.key});

  @override
  State<UserRoleScreen> createState() => _UserRoleScreenState();
}

class _UserRoleScreenState extends State<UserRoleScreen> {
  final _client = Supabase.instance.client;
  bool _isProcessing = false;

  Future<void> _handleRoleSelection(String role) async {
    final user = _client.auth.currentUser;
    if (user == null || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      await _updateUserRole(user.id, role);
      if (!mounted) return;
      _navigateToRoleScreen(role);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to select role. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _updateUserRole(String userId, String role) async {
    final now = DateTime.now().toIso8601String();

    // Update role in users table
    await _client
        .from('users')
        .update({'role': role, 'updated_at': now})
        .eq('id', userId);

    // If role is coach, upsert into coaches table
    if (role == 'coach') {
      await _client.from('coaches').upsert({
        'id': userId,
        'role': role,
        'created_at': now,
      });
    }
  }

  void _navigateToRoleScreen(String role) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                role == 'individual'
                    ? const IndividualProfileScreen()
                    : const CoachProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          _buildRoleSelectionUI(),
          if (_isProcessing) _buildProcessingOverlay(),
        ],
      ),
    );
  }

  Widget _buildRoleSelectionUI() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Your Role',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Choose how you want to use the app',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 40),
          _buildRoleCard(
            icon: Icons.person,
            title: 'Individual',
            description: 'Get personalized career guidance',
            onTap: () => _handleRoleSelection('individual'),
          ),
          const SizedBox(height: 20),
          _buildRoleCard(
            icon: Icons.school,
            title: 'Coach',
            description: 'Provide career coaching services',
            onTap: () => _handleRoleSelection('coach'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.amber),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
