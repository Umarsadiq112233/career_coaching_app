// Updated IndividualProfileScreen using Supabase
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IndividualProfileScreen extends StatefulWidget {
  const IndividualProfileScreen({super.key});

  @override
  State<IndividualProfileScreen> createState() => _IndividualProfileScreenState();
}

class _IndividualProfileScreenState extends State<IndividualProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _skillsController;
  late TextEditingController _goalsController;
  bool _isLoading = false;

  String? _selectedCareerLevel;
  final List<String> _careerLevels = [
    'Student',
    'Entry Level',
    'Mid Career',
    'Senior Level',
    'Executive',
  ];

  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    final user = _supabase.auth.currentUser;
    _nameController = TextEditingController();
    _emailController = TextEditingController(text: user?.email);
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
    _skillsController = TextEditingController();
    _goalsController = TextEditingController();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final response = await _supabase.from('users').select().eq('id', user.id).single();
    setState(() {
      _nameController.text = response['name'] ?? '';
      _phoneController.text = response['phone'] ?? '';
      _bioController.text = response['bio'] ?? '';
      _skillsController.text = (response['skills'] as List?)?.join(', ') ?? '';
      _goalsController.text = (response['goals'] as List?)?.join(', ') ?? '';
      _selectedCareerLevel = response['careerLevel'];
    });
  }

  Future<void> _saveProfile() async {
    final user = _supabase.auth.currentUser;
    if (!_formKey.currentState!.validate() || user == null) return;

    setState(() => _isLoading = true);

    final skillsList = _skillsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final goalsList = _goalsController.text.split(',').map((g) => g.trim()).where((g) => g.isNotEmpty).toList();

    await _supabase.from('users').upsert({
      'id': user.id,
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'bio': _bioController.text.trim(),
      'skills': skillsList,
      'goals': goalsList,
      'careerLevel': _selectedCareerLevel,
      'userType': 'individual',
      'lastUpdated': DateTime.now().toIso8601String(),
    });

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    _goalsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color.fromARGB(255, 255, 193, 7),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildPersonalInfoSection(),
              const SizedBox(height: 24),
              _buildCareerInfoSection(),
              const SizedBox(height: 24),
              _buildSkillsSection(),
              const SizedBox(height: 24),
              _buildGoalsSection(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 193, 7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            'Upload Profile',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.amber[100],
                child: const Icon(Icons.person, size: 60, color: Colors.amber),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _nameController.text.isEmpty ? 'Your Name' : _nameController.text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            _selectedCareerLevel ?? 'Select career level',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
              validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(labelText: 'Bio/Introduction', prefixIcon: Icon(Icons.info)),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareerInfoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Career Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCareerLevel,
              decoration: const InputDecoration(labelText: 'Career Level', prefixIcon: Icon(Icons.work)),
              items: _careerLevels.map((level) => DropdownMenuItem(value: level, child: Text(level))).toList(),
              onChanged: (value) => setState(() => _selectedCareerLevel = value),
              validator: (value) => value == null || value.isEmpty ? 'Please select your career level' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Skills & Expertise', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('List your skills separated by commas', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _skillsController,
              decoration: const InputDecoration(labelText: 'Your Skills', prefixIcon: Icon(Icons.star)),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Career Goals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('List your career goals separated by commas', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _goalsController,
              decoration: const InputDecoration(labelText: 'Your Goals', prefixIcon: Icon(Icons.flag)),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
