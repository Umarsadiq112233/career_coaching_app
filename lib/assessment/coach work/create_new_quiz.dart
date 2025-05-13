import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final List<Map<String, dynamic>> questions = [];
  final questionController = TextEditingController();
  final List<TextEditingController> optionControllers = List.generate(4, (_) => TextEditingController());
  int correctAnswerIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Quiz"),
        backgroundColor: const Color.fromARGB(255, 255, 193, 7),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Quiz Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Quiz Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            const Text(
              'Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Question ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => removeQuestion(index),
                          ),
                        ],
                      ),
                      Text(question['questionText']),
                      const SizedBox(height: 8),
                      ...question['options'].asMap().entries.map((option) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.circle,
                                color: question['correctAnswer'] == option.key ? Colors.green : Colors.grey,
                                size: 12,
                              ),
                              const SizedBox(width: 8),
                              Text(option.value),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add New Question', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: questionController,
                      decoration: const InputDecoration(
                        labelText: 'Question Text',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Options:'),
                    ...List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: index,
                              groupValue: correctAnswerIndex,
                              onChanged: (value) => setState(() => correctAnswerIndex = value!),
                            ),
                            Expanded(
                              child: TextField(
                                controller: optionControllers[index],
                                decoration: InputDecoration(
                                  hintText: 'Option ${String.fromCharCode(65 + index)}',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: addQuestion,
                      child: const Text('Add Question'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: questions.isNotEmpty ? createQuiz : null,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("Create Quiz"),
            ),
          ],
        ),
      ),
    );
  }

  void addQuestion() {
    if (questionController.text.isEmpty || optionControllers.any((c) => c.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() {
      questions.add({
        'questionText': questionController.text,
        'options': optionControllers.map((c) => c.text).toList(),
        'correctAnswer': correctAnswerIndex,
      });
      questionController.clear();
      for (var controller in optionControllers) {
        controller.clear();
      }
      correctAnswerIndex = 0;
    });
  }

  void removeQuestion(int index) {
    setState(() => questions.removeAt(index));
  }

  Future<void> createQuiz() async {
    final title = titleController.text.trim();
    final desc = descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and description')),
      );
      return;
    }

    try {
      final response = await _supabase.from('quizzes').insert({
        'title': title,
        'description': desc,
        'questionCount': questions.length,
        'status': 'New',
        'progress': 0.0,
      }).select().single();

      final quizId = response['id'];

      for (final question in questions) {
        await _supabase.from('quiz_questions').insert({
          'quiz_id': quizId,
          'question_text': question['questionText'],
          'options': question['options'],
          'correct_answer': question['correctAnswer'],
        });
      }

      final newAssessment = {
        'title': title,
        'desc': '$desc (${questions.length} Questions)',
        'status': 'New',
        'progress': 0.0,
      };

      if (!mounted) return;
      Navigator.pop(context, newAssessment);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating quiz: $e')));
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    questionController.dispose();
    for (var controller in optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
