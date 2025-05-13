// Updated CoachProfileScreen using Supabase
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart';

class CoachProfileScreen extends StatefulWidget {
  const CoachProfileScreen({super.key});

  @override
  _CoachProfileScreenState createState() => _CoachProfileScreenState();
}

class _CoachProfileScreenState extends State<CoachProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;

  File? _profileImage;
  List<String> _selectedSkills = [];
  Map<String, bool> _availability = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  final List<String> _allSkills = [
    'Flutter',
    'Dart',
    'Firebase',
    'UI/UX Design',
    'API Integration',
    'State Management',
    'Testing',
    'Git',
  ];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await _supabase.from('coaches').select().eq('id', user.id).single();
      setState(() {
        _nameController.text = data['name'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _experienceController.text = data['experience'] ?? '';
        _selectedSkills = List<String>.from(data['skills'] ?? []);
        _availability = Map<String, bool>.from(data['availability'] ?? _availability);
      });
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  void _toggleSkill(String skill) {
    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        _selectedSkills.add(skill);
      }
    });
  }

  void _toggleAvailability(String day) {
    setState(() => _availability[day] = !_availability[day]!);
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final user = _supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(content: Text('User not logged in')));
        return;
      }

      String? imageUrl;

      if (_profileImage != null) {
        final fileExt = extension(_profileImage!.path);
        final filePath = 'coach_profiles/${user.id}$fileExt';
        await _supabase.storage.from('coach_profiles').upload(filePath, _profileImage!, fileOptions: const FileOptions(upsert: true));
        imageUrl = _supabase.storage.from('coach_profiles').getPublicUrl(filePath);
      }

      await _supabase.from('coaches').upsert({
        'id': user.id,
        'email': user.email,
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'experience': _experienceController.text.trim(),
        'skills': _selectedSkills,
        'availability': _availability,
        if (imageUrl != null) 'image_url': imageUrl,
      });

      if (mounted) {
        Navigator.pop(context as BuildContext);
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
      }

      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 193, 7),
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                          backgroundColor: const Color.fromARGB(255, 255, 193, 7),
                          child: _profileImage == null ? const Icon(Icons.camera_alt, size: 40) : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'Tap to upload profile image',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person, color: Color.fromARGB(255, 255, 193, 7)),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 255, 193, 7)),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        prefixIcon: Icon(Icons.info, color: Color.fromARGB(255, 255, 193, 7)),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 255, 193, 7)),
                        ),
                      ),
                      maxLines: 3,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a short bio' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _experienceController,
                      decoration: const InputDecoration(
                        labelText: 'Experience (in years)',
                        prefixIcon: Icon(Icons.work, color: Color.fromARGB(255, 255, 193, 7)),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 255, 193, 7)),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter your experience';
                        if (double.tryParse(value) == null) return 'Please enter a valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Select Your Skills:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _allSkills.map((skill) {
                        return FilterChip(
                          labelStyle: const TextStyle(color: Colors.black),
                          side: const BorderSide(color: Color.fromARGB(255, 255, 193, 7)),
                          label: Text(skill),
                          selected: _selectedSkills.contains(skill),
                          onSelected: (selected) => _toggleSkill(skill),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Availability:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _availability.keys.map((day) {
                        return FilterChip(
                          labelStyle: const TextStyle(color: Colors.black),
                          side: const BorderSide(color: Color.fromARGB(255, 255, 193, 7)),
                          label: Text(day),
                          selected: _availability[day]!,
                          onSelected: (_) => _toggleAvailability(day),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 193, 7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              'Update Profile',
                              style: TextStyle(fontSize: 18, color: Colors.black),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}