import 'package:flutter/material.dart';

class TeacherHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Teacher Home Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('This screen will show teacher\'s classes'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement logout
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}