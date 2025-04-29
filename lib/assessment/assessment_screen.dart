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

  final assessments = [
    {
      'title': 'Leadership Assessment',
      'desc': 'Evaluate your leadership skills.',
      'status': 'Completed',
      'progress': 1.0,
    },
    {
      'title': 'Communication Skills',
      'desc': 'Improve verbal and written skills.',
      'status': 'In Progress',
      'progress': 0.6,
    },
    {
      'title': 'Problem Solving',
      'desc': 'Test your problem-solving ability.',
      'status': 'New',
      'progress': 0.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 193, 7),
        title:
            showSearch
                ? TextField(
                  controller: searchController,
                  autofocus: true,
                  decoration: InputDecoration(
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
            child: ListView(
              padding: const EdgeInsets.all(16),
              children:
                  getFilteredAssessments().map((a) => buildCard(a)).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 255, 193, 7),
        onPressed: () {
          // Add assessment action
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
                      selected ? Colors.blue : Color.fromARGB(255, 255, 193, 7),
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
