import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await _firestore.collection('coaches').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _experienceController.text = data['experience'] ?? '';
          _selectedSkills = List<String>.from(data['skills'] ?? []);
          _availability = Map<String, bool>.from(
            data['availability'] ?? _availability,
          );
        });

        // Load existing profile image
        try {
          final ref = _storage.ref('coach_profiles/${user.uid}.jpg');
          final url = await ref.getDownloadURL();
          final file = await _getImageFileFromUrl(url);
          setState(() {
            _profileImage = file;
          });
        } catch (e) {
          print('No existing profile image: $e');
        }
      }
    } catch (e) {
      print('Error loading existing data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<File> _getImageFileFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File('${documentDirectory.path}/profile_image.jpg');
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
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
    setState(() {
      _availability[day] = !_availability[day]!;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('User not logged in')));
          return;
        }

        String? imageUrl;

        // Upload new image if selected
        if (_profileImage != null) {
          final storageRef = _storage.ref('coach_profiles/${user.uid}.jpg');
          await storageRef.putFile(_profileImage!);
          imageUrl = await storageRef.getDownloadURL();
        }

        // Save data to Firestore
        await _firestore.collection('coaches').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'bio': _bioController.text.trim(),
          'experience': _experienceController.text.trim(),
          'skills': _selectedSkills,
          'availability': _availability,
          'email': user.email,
          'uid': user.uid,
          if (imageUrl != null) 'profileImageUrl': imageUrl,
        }, SetOptions(merge: true));

        Navigator.pop(context); // Return to previous screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        print('Error saving profile: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile Image Upload
                      GestureDetector(
                        onTap: _pickImage,
                        child: Center(
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage:
                                _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : null,
                            backgroundColor: const Color.fromARGB(
                              255,
                              255,
                              193,
                              7,
                            ),
                            child:
                                _profileImage == null
                                    ? const Icon(Icons.camera_alt, size: 40)
                                    : null,
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

                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Color.fromARGB(255, 255, 193, 7),
                          ),
                          border: const OutlineInputBorder(),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 255, 193, 7),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Bio Field
                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(
                          labelText: 'Bio',
                          prefixIcon: Icon(
                            Icons.info,
                            color: Color.fromARGB(255, 255, 193, 7),
                          ),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 255, 193, 7),
                            ),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a short bio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Experience Field
                      TextFormField(
                        controller: _experienceController,
                        decoration: const InputDecoration(
                          labelText: 'Experience (in years)',
                          prefixIcon: Icon(
                            Icons.work,
                            color: Color.fromARGB(255, 255, 193, 7),
                          ),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 255, 193, 7),
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your experience';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Skills Section
                      const Text(
                        'Select Your Skills:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children:
                            _allSkills.map((skill) {
                              return FilterChip(
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                side: const BorderSide(
                                  color: Color.fromARGB(255, 255, 193, 7),
                                ),
                                label: Text(skill),
                                selected: _selectedSkills.contains(skill),
                                onSelected: (bool selected) {
                                  _toggleSkill(skill);
                                },
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 30),

                      // Availability Section
                      const Text(
                        'Availability:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children:
                            _availability.keys.map((day) {
                              return FilterChip(
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                side: const BorderSide(
                                  color: Color.fromARGB(255, 255, 193, 7),
                                ),
                                label: Text(day),
                                selected: _availability[day]!,
                                onSelected: (bool selected) {
                                  _toggleAvailability(day);
                                },
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 30),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            255,
                            193,
                            7,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.black,
                                )
                                : const Text(
                                  'Update Profile',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
