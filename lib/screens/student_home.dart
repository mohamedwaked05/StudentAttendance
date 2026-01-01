import 'package:flutter/material.dart';

class StudentHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'Student Home Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('This screen will show student attendance'),
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