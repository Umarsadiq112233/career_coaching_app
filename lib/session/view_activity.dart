// this is the dashboard content page

import 'package:career_coaching/home/coach_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewActivitiesPage extends StatelessWidget {
  const ViewActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Activities')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('activities')
                .orderBy('time')
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          return ListView(
            children:
                snapshot.data!.docs
                    .map((doc) => SessionListItem(doc: doc))
                    .toList(),
          );
        },
      ),
    );
  }
}
