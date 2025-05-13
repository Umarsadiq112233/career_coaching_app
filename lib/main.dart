// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/login_screen.dart';
import 'auth/user_role.dart';
import 'home/coach_dashboard.dart';
import 'home/indiviual_dashboard.dart';
import 'profile/coach_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fevfaxnkgfrlcoyyktts.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZldmZheG5rZ2ZybGNveXlrdHRzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcxNTY3NTcsImV4cCI6MjA2MjczMjc1N30.UOVTjohX_2j9FPSvtyPoyEKb9jzgAvzyySLHSxzcaHE',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashWrapper(),
    );
  }
}

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _isLoading = true;
  late Widget _nextScreen;

  final SupabaseClient _client = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _checkUserFlow();
  }

  Future<void> _checkUserFlow() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      _nextScreen = const LoginScreen();
    } else {
      try {
        final response =
            await _client
                .from('users')
                .select('role')
                .eq('id', user.id)
                .single();

        final role = response['role'];

        if (role == null || role.toString().isEmpty) {
          _nextScreen = const UserRoleScreen();
        } else if (role == 'coach') {
          final coach =
              await _client
                  .from('coaches')
                  .select('name')
                  .eq('id', user.id)
                  .maybeSingle();

          if (coach == null || coach['name'] == null) {
            _nextScreen = const CoachProfileScreen();
          } else {
            _nextScreen = const CoachDashboardScreen();
          }
        } else if (role == 'individual') {
          _nextScreen = const IndiviualDashboard();
        } else {
          _nextScreen = const LoginScreen(); // fallback
        }
      } catch (e) {
        print("Error checking user flow: $e");
        _nextScreen = const LoginScreen();
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _nextScreen,
    );
  }
}
