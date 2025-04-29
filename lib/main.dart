// ignore_for_file: avoid_print

import 'package:career_coaching/auth/login_screen.dart';
import 'package:career_coaching/auth/user_role.dart';
import 'package:career_coaching/home/coach_dashboard.dart';
import 'package:career_coaching/home/indiviual_dashboard.dart';
import 'package:career_coaching/profile/coach_profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashWrapper(),
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

  @override
  void initState() {
    super.initState();
    _checkUserFlow();
  }

  Future<void> _checkUserFlow() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Not logged in → go to Login
      _nextScreen = const LoginScreen();
    } else {
      try {
        // First check in 'users' collection for role selection
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (!userDoc.exists || userDoc.data()?['role'] == null) {
          // No role selected → go to Select Role screen
          _nextScreen = UserRoleScreen();
        } else {
          // Role selected - check which role
          final role = userDoc.data()?['role'];

          if (role == 'coach') {
            // Check coach profile completion
            final coachDoc =
                await FirebaseFirestore.instance
                    .collection('coaches')
                    .doc(user.uid)
                    .get();

            if (!coachDoc.exists || coachDoc.data()?['name'] == null) {
              // Coach profile not complete
              _nextScreen = const CoachProfileScreen();
            } else {
              // Coach profile complete → Dashboard
              _nextScreen = CoachDashboardScreen();
            }
          } else if (role == 'individual') {
            // Individual user → go to Individual Dashboard
            _nextScreen = IndiviualDashboard();
          }
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      return _nextScreen;
    }
  }
}
