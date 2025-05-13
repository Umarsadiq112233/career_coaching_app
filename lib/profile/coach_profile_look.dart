// Updated CoachProfileScreenLook using Supabase
import 'package:career_coaching/auth/login_screen.dart';
import 'package:career_coaching/profile/coach_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CoachProfileScreenLook extends StatefulWidget {
  const CoachProfileScreenLook({super.key});

  @override
  State<CoachProfileScreenLook> createState() => _CoachProfileScreenLookState();
}

class _CoachProfileScreenLookState extends State<CoachProfileScreenLook> {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? imageUrl;
  String name = '';
  String email = '';
  String bio = '';
  List<String> skills = [];
  String experience = '';
  Map<String, bool> availability = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCoachData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchCoachData();
  }

  Future<void> fetchCoachData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('coaches')
          .select()
          .eq('id', user.id)
          .single();

      setState(() {
        name = response['name'] ?? 'No Name';
        email = response['email'] ?? 'No Email';
        bio = response['bio'] ?? 'No Bio';
        skills = List<String>.from(response['skills'] ?? []);
        experience = response['experience'] ?? '0';
        availability = Map<String, bool>.from(response['availability'] ?? {
          'Monday': false,
          'Tuesday': false,
          'Wednesday': false,
          'Thursday': false,
          'Friday': false,
          'Saturday': false,
          'Sunday': false,
        });
        imageUrl = response['image_url'] ?? '';
      });
    } catch (e) {
      print('Error fetching coach data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _formatAvailability() {
    final availableDays = availability.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    return availableDays.isEmpty ? 'Not Available' : availableDays.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach Profile'),
        backgroundColor: const Color.fromARGB(255, 255, 193, 7),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit Profile')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                await _supabase.auth.signOut();
                // ignore: use_build_context_synchronously
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              } else if (value == 'edit') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CoachProfileScreen()),
                );
                fetchCoachData();
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchCoachData,
              child: SingleChildScrollView(
                child: Center(
                  child: CoachProfileCard(
                    name: name,
                    email: email,
                    bio: bio,
                    skills: skills,
                    experience: experience,
                    availability: _formatAvailability(),
                    imageUrl: imageUrl ?? '',
                    onEditPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CoachProfileScreen(),
                        ),
                      );
                      fetchCoachData();
                    },
                  ),
                ),
              ),
            ),
    );
  }
}

class CoachProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String bio;
  final List<String> skills;
  final String experience;
  final String availability;
  final String imageUrl;
  final VoidCallback? onEditPressed;

  const CoachProfileCard({
    super.key,
    required this.name,
    required this.email,
    required this.bio,
    required this.skills,
    required this.experience,
    required this.availability,
    required this.imageUrl,
    this.onEditPressed,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage:
                  imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              backgroundColor: const Color.fromARGB(255, 255, 193, 7),
              child: imageUrl.isEmpty
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                bio,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.work, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  '$experience years of experience',
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
              children: skills
                  .map(
                    (skill) => Chip(
                      label: Text(skill),
                      backgroundColor: const Color.fromARGB(255, 255, 193, 7),
                      side: const BorderSide(color: Colors.white, width: 1),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Availability:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              availability,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onEditPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 193, 7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
