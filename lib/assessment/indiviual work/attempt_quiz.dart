import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuizAttemptScreen extends StatefulWidget {
  final String quizId;
  final String title;

  const QuizAttemptScreen({
    super.key,
    required this.quizId,
    required this.title,
  });

  @override
  State<QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen> {
  List<QueryDocumentSnapshot> questions = [];
  Map<int, int> selectedAnswers = {}; // questionIndex -> selectedOptionIndex
  bool submitted = false;
  int score = 0;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('quizzes')
            .doc(widget.quizId)
            .collection('questions')
            .get();

    setState(() {
      questions = snapshot.docs;
    });
  }

  void submitAnswers() {
    int totalScore = 0;

    for (int i = 0; i < questions.length; i++) {
      final correct = questions[i]['correctAnswer'];
      final selected = selectedAnswers[i];
      if (selected != null && selected == correct) {
        totalScore++;
      }
    }

    setState(() {
      score = totalScore;
      submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: ${widget.title}'),
        backgroundColor: Colors.teal,
      ),
      body:
          questions.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: questions.length + 1,
                itemBuilder: (context, index) {
                  if (index == questions.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: ElevatedButton(
                        onPressed: submitted ? null : submitAnswers,
                        child: const Text("Submit Answers"),
                      ),
                    );
                  }

                  final q = questions[index];
                  final options = q['options'] as List;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q${index + 1}: ${q['questionText']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(options.length, (i) {
                            final isCorrect =
                                submitted && q['correctAnswer'] == i;
                            final isSelected = selectedAnswers[index] == i;
                            Color? color;

                            if (submitted) {
                              if (isCorrect) {
                                color = Colors.green;
                              } else if (isSelected) {
                                color = Colors.red;
                              }
                            }

                            return ListTile(
                              title: Text(options[i]),
                              leading: Radio<int>(
                                value: i,
                                groupValue: selectedAnswers[index],
                                onChanged:
                                    submitted
                                        ? null
                                        : (value) {
                                          setState(() {
                                            selectedAnswers[index] = value!;
                                          });
                                        },
                              ),
                              tileColor: color?.withOpacity(0.1),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
      bottomNavigationBar:
          submitted
              ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Your Score: $score / ${questions.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
              : null,
    );
  }
}
