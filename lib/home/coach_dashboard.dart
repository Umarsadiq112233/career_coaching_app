import 'package:career_coaching/assessment/assessment_screen.dart';
import 'package:career_coaching/message/coach_chat_message.dart';
import 'package:career_coaching/profile/coach_profile_look.dart';
import 'package:career_coaching/session/calender_screen.dart';
import 'package:career_coaching/session/view_all_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CoachDashboardScreen extends StatelessWidget {
  const CoachDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: const Text('Coach Dashboard'),
      centerTitle: true,
      backgroundColor: const Color.fromARGB(255, 255, 193, 7),
      actions: [
        Stack(
          children: [
            IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
            const Positioned(
              right: 8,
              top: 8,
              child: CircleAvatar(
                radius: 8,
                backgroundColor: Colors.red,
                child: Text(
                  '3',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 24),
          _buildUpcomingSessions(context),
          const SizedBox(height: 24),
          _buildSkillRequests(),
          const SizedBox(height: 24),
          _buildMessagesSection(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final upcomingSessionsStream =
        FirebaseFirestore.instance
            .collection('activities')
            .where('time', isGreaterThan: Timestamp.now())
            .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: upcomingSessionsStream,
      builder: (context, snapshot) {
        int upcomingCount = 0;
        String nextSessionText = 'No upcoming';
        DateTime? nextSessionDate;

        if (snapshot.hasData) {
          upcomingCount = snapshot.data!.docs.length;

          if (upcomingCount > 0) {
            final sessionDates =
                snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final timestamp = data['time'] as Timestamp;
                  return timestamp.toDate();
                }).toList();

            sessionDates.sort((a, b) => a.compareTo(b)); // sort dates
            nextSessionDate = sessionDates.first;
            final now = DateTime.now();
            final difference = nextSessionDate.difference(now);

            if (difference.inDays > 0) {
              nextSessionText = 'Next in ${difference.inDays} days';
            } else if (difference.inHours > 0) {
              nextSessionText = 'Next in ${difference.inHours} hours';
            } else {
              nextSessionText = 'Starting soon';
            }
          }
        }

        final cards = [
          {
            'title': 'Total Learners',
            'value': '120',
            'icon': Icons.people,
            'color': Colors.blue,
            'trend': '↑ 12%',
          },
          {
            'title': 'Upcoming Sessions',
            'value': '$upcomingCount',
            'icon': Icons.calendar_today,
            'color': Colors.green,
            'trend': nextSessionText,
          },
          {
            'title': 'Skill Requests',
            'value': '5',
            'icon': Icons.lightbulb_outline,
            'color': Colors.orange,
            'trend': '3 new',
          },
          {
            'title': 'Pending Assessments',
            'value': '12',
            'icon': Icons.assignment,
            'color': Colors.purple,
            'trend': '3 overdue',
          },
        ];

        return GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: cards.map((c) => _buildSummaryCard(c)).toList(),
        );
      },
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> card) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: card['color'],
              child: Icon(card['icon'], color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              card['title'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              card['value'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              card['trend'],
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSessions(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('activities')
              .orderBy('time', descending: false) // Oldest first
              .limit(4)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upcoming Sessions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('No sessions found'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => SheduleSetForUpcommingSession(),
                            ),
                          );
                        },
                        child: const Text('Add New Session'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Sessions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ...snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final time = (data['time'] as Timestamp).toDate();

                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getActivityColor(
                                data['activityType'],
                              ),
                              child: Icon(
                                _getActivityIcon(data['activityType']),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(data['title'] ?? 'No Title'),
                            subtitle: Text(
                              '${DateFormat('MMM dd, yyyy - hh:mm a').format(time)}\n'
                              '${data['description'] ?? ''}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () {},
                            ),
                          ),
                          if (doc != snapshot.data!.docs.last) const Divider(),
                        ],
                      );
                    }),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        SheduleSetForUpcommingSession(),
                              ),
                            );
                          },
                          child: const Text('Add New Schedule'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ActivityListPage(),
                              ),
                            );
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper methods for activity styling
  Color _getActivityColor(String? activityType) {
    switch (activityType) {
      case 'Work':
        return Colors.blue;
      case 'Study':
        return Colors.green;
      case 'Exercise':
        return Colors.orange;
      case 'Meeting':
        return Colors.purple;
      case 'Personal':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String? activityType) {
    switch (activityType) {
      case 'Work':
        return Icons.work;
      case 'Study':
        return Icons.school;
      case 'Exercise':
        return Icons.fitness_center;
      case 'Meeting':
        return Icons.people;
      case 'Personal':
        return Icons.person;
      default:
        return Icons.event;
    }
  }

  Widget _buildSkillRequests() {
    final requests = [
      {
        'learner': 'Emma Johnson',
        'skill': 'Public Speaking',
        'date': '2 days ago',
      },
      {
        'learner': 'Michael Chen',
        'skill': 'Time Management',
        'date': '1 day ago',
      },
      {
        'learner': 'Team A',
        'skill': 'Conflict Resolution',
        'date': '5 hours ago',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Skill Improvement Requests',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Chip(
              label: Text('${requests.length} New'),
              backgroundColor: Colors.orange[100],
              labelStyle: TextStyle(color: Colors.orange[800]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...requests.map(
                  (req) => ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.lightbulb_outline, color: Colors.white),
                    ),
                    title: Text(req['skill'] ?? 'Unknown Skill'),
                    subtitle: Text(
                      'Requested by ${req['learner']} • ${req['date']}',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Messages',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: const [
                ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.message, color: Colors.blue),
                  ),
                  title: Text('John Doe'),
                  subtitle: Text('Hey, can we reschedule?'),
                  trailing: Text('2h ago'),
                ),
                Divider(),
                ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.message, color: Colors.green),
                  ),
                  title: Text('Team A'),
                  subtitle: Text('Looking forward to session!'),
                  trailing: Text('1d ago'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BottomNavigationBar _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color.fromARGB(255, 255, 193, 7),
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      onTap: (index) {
        switch (index) {
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AssessmentScreen()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SheduleSetForUpcommingSession(),
              ),
            );
            break;

          case 4:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CoachProfileScreenLook()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => CoachChatScreen(
                      chatId: 'sampleChatId',
                      learnerId: 'sampleLearnerId',
                      learnerName: 'Sample Learner',
                    ),
              ),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Assessments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

class SessionListItem extends StatelessWidget {
  final DocumentSnapshot doc;

  const SessionListItem({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final time = (data['time'] as Timestamp).toDate();

    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            data['activityType'] == '1-on-1'
                ? Colors.blue[100]
                : Colors.green[100],
        child: Icon(
          data['activityType'] == '1-on-1' ? Icons.person : Icons.people,
          color: Colors.black,
        ),
      ),
      title: Text(data['title'] ?? 'No Title'),
      subtitle: Text(DateFormat('MMM dd, yyyy - hh:mm a').format(time)),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () => _showOptions(context),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              ListTile(leading: Icon(Icons.edit), title: Text('Edit Session')),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Cancel Session'),
              ),
            ],
          ),
    );
  }
}
