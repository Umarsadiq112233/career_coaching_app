import 'package:career_coaching/auth/update_password.dart';
import 'package:flutter/material.dart';

class VerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verification'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 255, 193, 7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter the verification code sent to your email:',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.password_rounded,
                  color: Color.fromARGB(255, 255, 193, 7),
                ),
                border: OutlineInputBorder(),
                labelText: 'Verification Code',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 255, 193, 7),
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add verification logic here

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdatePasswordScreen(),
                  ),
                );
              },
              child: Text('Verify', style: TextStyle(color: Colors.black)),

              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color.fromARGB(255, 255, 193, 7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                // Add resend code logic here
              },
              child: Text('Resend Code'),
            ),
          ],
        ),
      ),
    );
  }
}
