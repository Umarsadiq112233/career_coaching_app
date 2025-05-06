import 'package:career_coaching/assessment/coach%20work/create_new_quiz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int selectedFilter = 0;
  final filters = ['All', 'Completed', 'In Progress', 'New'];
  final searchController = TextEditingController();
  bool showSearch = false;

  List<Map<String, dynamic>> assessments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAssessments();
  }

  Future<void> loadAssessments() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('quizzes').get();

    setState(() {
      assessments =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'title': data['title'] ?? '',
              'desc': data['description'] ?? '',
              'status': data['status'] ?? 'New', // Default if not set
              'progress': data['progress'] ?? 0.0,
            };
          }).toList();
      isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 193, 7),
        title:
            showSearch
                ? TextField(
                  controller: searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) => setState(() {}),
                )
                : const Text('Assessments'),
        actions: [
          IconButton(
            icon: Icon(showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                showSearch = !showSearch;
                if (!showSearch) searchController.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          buildFilters(),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                      padding: const EdgeInsets.all(16),
                      children:
                          getFilteredAssessments()
                              .map((a) => buildCard(a))
                              .toList(),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 255, 193, 7),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateQuizScreen()),
          );
          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              assessments.add(result);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildFilters() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, i) {
          final selected = selectedFilter == i;
          return GestureDetector(
            onTap: () => setState(() => selectedFilter = i),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      selected
                          ? Colors.blue
                          : const Color.fromARGB(255, 255, 193, 7),
                ),
              ),
              child: Center(
                child: Text(
                  filters[i],
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> getFilteredAssessments() {
    final query = searchController.text.toLowerCase();
    return assessments.where((a) {
      final matchesFilter =
          filters[selectedFilter] == 'All' ||
          a['status'] == filters[selectedFilter];
      final matchesSearch =
          (a['title'] as String?)?.toLowerCase().contains(query) ??
          false ||
              (a['desc'] != null &&
                  (a['desc'] as String).toLowerCase().contains(query));
      return matchesFilter && matchesSearch;
    }).toList();
  }

  Widget buildCard(Map<String, dynamic> a) {
    return Card(
      child: ListTile(
        title: Text(a['title']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(a['desc']),
            const SizedBox(height: 8),
            if (a['status'] == 'In Progress' || a['status'] == 'New')
              LinearProgressIndicator(
                value: a['progress'],
                backgroundColor: Colors.grey[300],
                color: Colors.blue,
              ),
          ],
        ),
        trailing:
            a['status'] == 'Completed'
                ? const Icon(Icons.check_circle, color: Colors.green)
                : a['status'] == 'In Progress'
                ? Text('${(a['progress'] * 100).round()}%')
                : const Text('New'),
      ),
    );
  }
}
