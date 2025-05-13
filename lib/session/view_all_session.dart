import 'package:career_coaching/session/session_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ActivityListPage extends StatefulWidget {
  const ActivityListPage({super.key});

  @override
  State<ActivityListPage> createState() => _ActivityListPageState();
}

class _ActivityListPageState extends State<ActivityListPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    setState(() => _isLoading = true);
    final response = await _supabase
        .from('activities')
        .select()
        .order('time', ascending: false);

    setState(() {
      _activities = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
    });
  }

  Future<void> _deleteActivity(int id) async {
    try {
      await _supabase.from('activities').delete().eq('id', id);
      _fetchActivities();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting activity: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Activities'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 193, 7),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activities.isEmpty
              ? const Center(child: Text('No activities found'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: _activities.length,
                  itemBuilder: (context, index) {
                    final activity = _activities[index];
                    return ActivityListItem(
                      activity: activity,
                      onDelete: () => _deleteActivity(activity['id']),
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
        backgroundColor: const Color.fromARGB(255, 255, 193, 7),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ActivityListItem extends StatelessWidget {
  final Map<String, dynamic> activity;
  final VoidCallback onDelete;

  const ActivityListItem({
    super.key,
    required this.activity,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String title = activity['title'] ?? 'No Title';
    final String description = activity['description'] ?? 'No Description';
    final String activityType = activity['activityType'] ?? 'Other';
    final DateTime activityTime = DateTime.parse(activity['time']);
    final String? fileName = activity['fileName'];
    final String? fileType = activity['fileType'];
    final timeString = DateFormat('MMM dd, yyyy - hh:mm a').format(activityTime);

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
        onTap: () => _showActivityDetails(context, activity, activityTime),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    Icon(_getFileIcon(fileType), size: 20, color: Colors.amber[700]),
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
                  Text(timeString, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    color: Colors.red[400],
                    onPressed: onDelete,
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
      builder: (context) => AlertDialog(
        title: Text(activity['title'] ?? 'Activity Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(activity['description'] ?? 'No description'),
              const SizedBox(height: 16),
              if (activity['fileName'] != null) ...[
                const Text('Attached File:', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Icon(_getFileIcon(activity['fileType'])),
                    const SizedBox(width: 8),
                    Text(activity['fileName']),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Text('Time: ${DateFormat('MMM dd, yyyy - hh:mm a').format(activityTime)}'),
              Text('Type: ${activity['activityType'] ?? 'Not specified'}'),
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
}
