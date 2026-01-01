import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 100, color: Colors.red),
            SizedBox(height: 20),
            Text(
              'Admin Home Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('This screen will manage users'),
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