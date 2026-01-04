import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/teacher_home.dart';
import 'screens/student_home.dart';
import 'screens/admin_home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Attendance',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
      routes: {
        '/teacher': (context) => TeacherHomeScreen(),
        '/student': (context) => StudentHomeScreen(),
        '/admin': (context) => AdminHomeScreen(),
        // No need to add class-attendance route since we're using MaterialPageRoute
      },
      debugShowCheckedModeBanner: false,
    );
  }
}