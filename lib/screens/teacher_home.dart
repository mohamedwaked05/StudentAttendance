import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class TeacherHomeScreen extends StatefulWidget {
  @override
  _TeacherHomeScreenState createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  Map<String, dynamic>? _user;
  List<dynamic> _classes = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadClasses();
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
  
  Future<void> _loadClasses() async {
    final teacherId = _user?['id'] ?? 2; // Default to teacher ID 2
    
    final classes = await ApiService.getTeacherClasses(teacherId);
    
    setState(() {
      _classes = classes;
      _isLoading = false;
    });
  }
  
  Future<void> _logout() async {
    await ApiService.logout();
    Navigator.pushReplacementNamed(context, '/');
  }
  
  void _markAttendance(int classId, String className) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark Attendance'),
        content: Text('Mark attendance for $className?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _markAllPresent(classId, className);
            },
            child: Text('Mark All Present'),
          ),
        ],
      ),
    );
  }
  
Future<void> _markAllPresent(int classId, String className) async {
  try {
    // In real app, get enrolled students first
    // For now, mark dummy students
    final result = await ApiService.markAttendance(
      studentId: 3, // Real student ID from database
      classId: classId,
      status: 'present',
    );
    
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance marked successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${result['message']}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadClasses,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_user?['name'] ?? 'Teacher'),
              accountEmail: Text(_user?['email'] ?? 'teacher@uni.edu'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Create New Class'),
              onTap: () {
                Navigator.pop(context);
                _createNewClass();
              },
            ),
            ListTile(
              leading: Icon(Icons.analytics),
              title: Text('Reports'),
              onTap: () {
                // TODO: Add reports screen
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
          : _classes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.class_, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'No classes yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _createNewClass,
                        child: Text('Create Your First Class'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _classes.length,
                  itemBuilder: (context, index) {
                    final cls = _classes[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(Icons.class_, color: Colors.blue),
                        ),
                        title: Text(
                          cls['class_name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text('Day: ${cls['schedule_day']}'),
                            Text('Time: ${cls['schedule_time']?.toString().substring(0, 5) ?? 'N/A'}'),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _markAttendance(cls['id'], cls['class_name']),
                          child: Text('Mark Attendance'),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewClass,
        child: Icon(Icons.add),
        tooltip: 'Create New Class',
      ),
    );
  }
  
  void _createNewClass() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New Class'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Class creation would be implemented here.'),
            SizedBox(height: 20),
            Text('For now, classes are simulated in Development Mode.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}