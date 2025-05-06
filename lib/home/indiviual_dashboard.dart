// ignore_for_file: deprecated_member_use

import 'package:career_coaching/assessment/indiviual%20work/learner_quiz_screen.dart';
import 'package:career_coaching/message/individual_chat_screen.dart';
import 'package:career_coaching/profile/individual_profile_look.dart';
import 'package:flutter/material.dart';

class IndiviualDashboard extends StatefulWidget {
  const IndiviualDashboard({super.key});

  @override
  State<IndiviualDashboard> createState() => _IndiviualDashboardState();
}

class _IndiviualDashboardState extends State<IndiviualDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Indivual Dashboard"),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 255, 193, 7),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
          IconButton(onPressed: () {}, icon: Icon(Icons.logout)),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        backgroundColor: Color.fromARGB(255, 255, 193, 7),
        unselectedItemColor: Colors.black,
        currentIndex: 0, // Set the default selected index
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Assessment',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Navigate to Home
              break;
            case 1:
              // Navigate to Progress
              break;
            case 2:
              // Navigate to Assessment
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LearnerQuizListScreen(),
                ),
              );
              break;
            case 3:
              // Navigate to chat

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => IndividualChatScreen(
                        chatId: 'exampleChatId',
                        otherUserId: 'exampleUserId',
                        otherUserName: 'exampleUserName',
                        isCoach: false,
                      ),
                ),
              );

              break;
            case 4:
              // Navigate to Profile
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IndividualProfileScreenLook(),
                ),
              );
              break;
          }
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),

              Card(
                child: Container(
                  width:
                      MediaQuery.of(context).size.width -
                      30, // Adjusted to match the border
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Progress Overview",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "70%",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 193, 7),
                            ),
                          ),
                          Text(
                            "Overall progress toward your goal",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: 0.45,
                        backgroundColor: Colors.grey[300],
                        color: Color.fromARGB(255, 255, 193, 7),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10),
              Card(
                child: Container(
                  width:
                      MediaQuery.of(context).size.width -
                      30, // Adjusted to match the border
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Upcoming Sessions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Session with Coach John on 20th Oct at 3 PM",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(
                            255,
                            255,
                            193,
                            7,
                          ), // Button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              5,
                            ), // Rounded corners
                          ),
                        ),
                        child: Text(
                          "Join Session",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Card(
                child: Container(
                  width:
                      MediaQuery.of(context).size.width -
                      30, // Adjusted to match the border
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Completed Sessions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "You have completed 5 sessions this month.",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(
                            255,
                            255,
                            193,
                            7,
                          ), // Button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              5,
                            ), // Rounded corners
                          ),
                        ),
                        child: Text(
                          "View Details",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Card(
                child: Container(
                  width:
                      MediaQuery.of(context).size.width -
                      30, // Adjusted to match the border
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pending Assessments",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "You have 2 pending assessments to complete.",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(
                                255,
                                255,
                                193,
                                7,
                              ), // Button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  5,
                                ), // Rounded corners
                              ),
                            ),
                            child: Text(
                              "Start Assessment",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(
                                255,
                                255,
                                193,
                                7,
                              ), // Button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  5,
                                ), // Rounded corners
                              ),
                            ),
                            child: Text(
                              "View Details",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // Add your action here
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50), // Full width button
                  backgroundColor: Color.fromARGB(
                    255,
                    255,
                    193,
                    7,
                  ), // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                icon: Icon(Icons.add, color: Colors.black),
                label: Text(
                  "Add New Goal",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
