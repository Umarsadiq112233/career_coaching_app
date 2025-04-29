import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SheduleSetForUpcommingSession extends StatefulWidget {
  const SheduleSetForUpcommingSession({super.key});

  @override
  State<SheduleSetForUpcommingSession> createState() =>
      _SheduleSetForUpcommingSessionState();
}

class _SheduleSetForUpcommingSessionState
    extends State<SheduleSetForUpcommingSession> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedTime;
  String? _selectedActivityType;

  final List<String> _activityTypes = [
    'Work',
    'Study',
    'Exercise',
    'Meeting',
    'Personal',
  ];

  Future<void> _saveActivity() async {
    if (_formKey.currentState!.validate() && _selectedTime != null) {
      try {
        await FirebaseFirestore.instance.collection('activities').add({
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'time': _selectedTime,
          'activityType': _selectedActivityType,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity saved successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color.fromARGB(255, 255, 193, 7)),
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Add New Activity'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 255, 193, 7),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Time Picker
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    tileColor: Colors.grey[200],
                    title: Text(
                      _selectedTime == null
                          ? 'Select Time'
                          : 'Time: ${DateFormat.jm().format(_selectedTime!)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.access_time,
                      color: Color.fromARGB(255, 255, 193, 7),
                    ),
                    onTap: _selectTime,
                  ),
                  const SizedBox(height: 20),

                  // Activity Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedActivityType,
                    hint: const Text('Select Activity Type'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      enabledBorder: borderStyle,
                      focusedBorder: borderStyle,
                      errorBorder: borderStyle,
                      focusedErrorBorder: borderStyle,
                    ),
                    items:
                        _activityTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                    onChanged:
                        (value) =>
                            setState(() => _selectedActivityType = value),
                    validator:
                        (value) =>
                            value == null
                                ? 'Please select an activity type'
                                : null,
                  ),
                  const SizedBox(height: 20),

                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      filled: true,
                      fillColor: Colors.grey[200],
                      enabledBorder: borderStyle,
                      focusedBorder: borderStyle,
                      errorBorder: borderStyle,
                      focusedErrorBorder: borderStyle,
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 20),

                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      filled: true,
                      fillColor: Colors.grey[200],
                      enabledBorder: borderStyle,
                      focusedBorder: borderStyle,
                      errorBorder: borderStyle,
                      focusedErrorBorder: borderStyle,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 30),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _saveActivity,
                      icon: const Icon(Icons.save),
                      label: const Text(
                        'Save Activity',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 193, 7),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
