import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:career_coaching/assessment/indiviual%20work/attempt_quiz.dart';

class LearnerQuizListScreen extends StatelessWidget {
  const LearnerQuizListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Quizzes"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: supabase
            .from('quizzes')
            .select()
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final quizzes = snapshot.data ?? [];

          if (quizzes.isEmpty) {
            return const Center(child: Text('No quizzes available.'));
          }

          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return ListTile(
                title: Text(quiz['title'] ?? 'No Title'),
                subtitle: Text(quiz['description'] ?? 'No Description'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizAttemptScreen(
                        quizId: quiz['id'].toString(),
                        title: quiz['title'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
