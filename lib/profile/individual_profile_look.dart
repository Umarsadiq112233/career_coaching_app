// ignore_for_file: use_build_context_synchronously

import 'package:career_coaching/profile/individual_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:career_coaching/auth/login_screen.dart';

class IndividualProfileScreenLook extends StatefulWidget {
  const IndividualProfileScreenLook({super.key});

  @override
  State<IndividualProfileScreenLook> createState() =>
      _IndividualProfileScreenLookState();
}

class _IndividualProfileScreenLookState
    extends State<IndividualProfileScreenLook> {
  String? imageUrl;
  String name = '';
  String email = '';
  String bio = '';
  List<String> skills = [];
  String careerLevel = '';
  List<String> goals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchIndividualData();
  }

  Future<void> fetchIndividualData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          name = data['name'] ?? 'No Name';
          email = data['email'] ?? 'No Email';
          bio = data['bio'] ?? 'No Bio';
          skills = List<String>.from(data['skills'] ?? []);
          careerLevel = data['careerLevel'] ?? 'Not Specified';
          goals = List<String>.from(data['goals'] ?? []);
        });

        try {
          final ref = FirebaseStorage.instance.ref('user_profiles/$userId.jpg');
          imageUrl = await ref.getDownloadURL();
        } catch (e) {
          print('No profile image found: $e');
        }
      }
    } catch (e) {
      print('Error fetching individual data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color.fromARGB(255, 255, 193, 7),
        actions: [
          PopupMenuButton<String>(
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit Profile'),
                  ),
                  const PopupMenuItem(value: 'logout', child: Text('Logout')),
                ],
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              } else if (value == 'edit') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IndividualProfileScreen(),
                  ),
                );
                fetchIndividualData(); // Refresh data after returning
              }
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: fetchIndividualData,
                child: SingleChildScrollView(
                  child: Center(
                    child: IndividualProfileCard(
                      name: name,
                      email: email,
                      bio: bio,
                      skills: skills,
                      careerLevel: careerLevel,
                      goals: goals,
                      imageUrl: imageUrl ?? '',
                    ),
                  ),
                ),
              ),
    );
  }
}

class IndividualProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String bio;
  final List<String> skills;
  final String careerLevel;
  final List<String> goals;
  final String imageUrl;

  const IndividualProfileCard({
    super.key,
    required this.name,
    required this.email,
    required this.bio,
    required this.skills,
    required this.careerLevel,
    required this.goals,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 173, 140, 39),
      elevation: 8,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage:
                  imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              backgroundColor: const Color.fromARGB(255, 255, 193, 7),
              child:
                  imageUrl.isEmpty
                      ? const Icon(Icons.person, size: 60, color: Colors.black)
                      : null,
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.email, size: 16, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  email,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              bio,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.work_history, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Career Level: $careerLevel',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Skills:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  skills
                      .map(
                        (skill) => Chip(
                          label: Text(skill),
                          backgroundColor: const Color.fromARGB(
                            255,
                            255,
                            193,
                            7,
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Goals:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start, // Align children to the start (left)
              children:
                  goals
                      .map(
                        (goal) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center, // Align items to the left
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .center, // Align items to the top
                            children: [
                              const Icon(Icons.flag, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                goal,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 193, 7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Back to Dashboard',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
