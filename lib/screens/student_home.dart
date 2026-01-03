import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class StudentHomeScreen extends StatefulWidget {
  @override
  _StudentHomeScreenState createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  Map<String, dynamic>? _user;
  List<dynamic> _attendance = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAttendance();
  }
  
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) {
      setState(() {
        _user = json.decode(userString);
      });
    }
  }
  
  Future<void> _loadAttendance() async {
    final studentId = _user?['id'] ?? 3; // Default to student ID 3
    
    final attendance = await ApiService.getStudentAttendance(studentId);
    
    setState(() {
      _attendance = attendance;
      _isLoading = false;
    });
  }
  
  Future<void> _logout() async {
    await ApiService.logout();
    Navigator.pushReplacementNamed(context, '/');
  }
  
  Widget _buildStatusChip(String status) {
    final isPresent = status == 'present';
    return Chip(
      label: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: isPresent ? Colors.green : Colors.red,
      avatar: Icon(
        isPresent ? Icons.check : Icons.close,
        color: Colors.white,
        size: 16,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Attendance'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadAttendance,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_user?['name'] ?? 'Student'),
              accountEmail: Text(_user?['email'] ?? 'student@uni.edu'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.green),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Attendance Records'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.class_),
              title: Text('My Classes'),
              onTap: () {
                // TODO: Add classes screen
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _attendance.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'No attendance records',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 10),
                      Text('Your attendance hasn\'t been marked yet.'),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Stats Card
                    Card(
                      margin: EdgeInsets.all(16),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Total', _attendance.length.toString(), Icons.list),
                            _buildStatItem(
                              'Present',
                              _attendance.where((a) => a['status'] == 'present').length.toString(),
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            _buildStatItem(
                              'Absent',
                              _attendance.where((a) => a['status'] == 'absent').length.toString(),
                              Icons.cancel,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Attendance List
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _attendance.length,
                        itemBuilder: (context, index) {
                          final record = _attendance[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: record['status'] == 'present' 
                                    ? Colors.green.shade100 
                                    : Colors.red.shade100,
                                child: Icon(
                                  record['status'] == 'present' 
                                      ? Icons.check 
                                      : Icons.close,
                                  color: record['status'] == 'present' 
                                      ? Colors.green 
                                      : Colors.red,
                                ),
                              ),
                              title: Text(
                                record['class_name'] ?? 'Unknown Class',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text('Teacher: ${record['teacher_name'] ?? 'N/A'}'),
                                  Text('Date: ${record['attendance_date']}'),
                                ],
                              ),
                              trailing: _buildStatusChip(record['status']),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.blue, size: 30),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.blue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}