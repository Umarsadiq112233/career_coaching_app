import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
                .orderBy(
                  'time',
                ) // You can change the order based on your requirements
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading activities'));
          }
          final activities = snapshot.data!.docs;
          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index].data() as Map<String, dynamic>;
              final String title = activity['title'] ?? 'No Title';
              final String description =
                  activity['description'] ?? 'No Description';
              final Timestamp timestamp = activity['time'];
              final DateTime activityTime = timestamp.toDate();
              return Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Color.fromARGB(255, 255, 193, 7),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.event,
                    color: Color.fromARGB(255, 255, 193, 7),
                  ),
                  title: Text(title),
                  subtitle: Text(description),
                  trailing: Text('${activityTime.toLocal()}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
