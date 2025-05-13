import 'package:career_coaching/session/session_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityListPage extends StatelessWidget {
  const ActivityListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Activities'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 255, 193, 7),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('activities')
                .orderBy('time', descending: true) // Newest first
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No activities found'));
          }

          final activities = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final doc = activities[index];
              final activity = doc.data() as Map<String, dynamic>;

              return ActivityListItem(
                doc: doc,
                activity: activity,
                showFullDate: true,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SessionScreen()),
          );
        },
        backgroundColor: Color.fromARGB(255, 255, 193, 7),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ActivityListItem extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final Map<String, dynamic> activity;
  final bool showFullDate;

  const ActivityListItem({
    super.key,
    required this.doc,
    required this.activity,
    this.showFullDate = false,
  });

  @override
  Widget build(BuildContext context) {
    final String title = activity['title'] ?? 'No Title';
    final String description = activity['description'] ?? 'No Description';
    final String activityType = activity['activityType'] ?? 'Other';
    final Timestamp timestamp = activity['time'];
    final DateTime activityTime = timestamp.toDate();
    final String? fileName = activity['fileName'];
    final String? fileType = activity['fileType'];

    // Format the date/time display
    final dateFormat =
        showFullDate
            ? DateFormat('MMM dd, yyyy - hh:mm a')
            : DateFormat('hh:mm a');
    final timeString = dateFormat.format(activityTime);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          color: Color.fromARGB(255, 255, 193, 7),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          // Show details dialog or navigate to detail page
          _showActivityDetails(context, activity, activityTime);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getActivityTypeColor(activityType),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      activityType,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (description.isNotEmpty) ...[
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
              ],
              if (fileName != null) ...[
                Row(
                  children: [
                    Icon(
                      _getFileIcon(fileType),
                      size: 20,
                      color: Colors.amber[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      fileName,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    timeString,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    color: Colors.red[400],
                    onPressed: () => _confirmDeleteActivity(context, doc.id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getActivityTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'work':
        return Colors.blue;
      case 'study':
        return Colors.green;
      case 'exercise':
        return Colors.orange;
      case 'meeting':
        return Colors.purple;
      case 'personal':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getFileIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'txt':
        return Icons.text_snippet;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _showActivityDetails(
    BuildContext context,
    Map<String, dynamic> activity,
    DateTime activityTime,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(activity['title'] ?? 'Activity Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activity['description'] ?? 'No description',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  if (activity['fileName'] != null) ...[
                    const Text(
                      'Attached File:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Icon(_getFileIcon(activity['fileType'])),
                        const SizedBox(width: 8),
                        Text(activity['fileName']),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    'Time: ${DateFormat('MMM dd, yyyy - hh:mm a').format(activityTime)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Type: ${activity['activityType'] ?? 'Not specified'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Future<void> _confirmDeleteActivity(
    BuildContext context,
    String docId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Activity'),
            content: const Text(
              'Are you sure you want to delete this activity?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('activities')
            .doc(docId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting activity: $e')));
      }
    }
  }
}
