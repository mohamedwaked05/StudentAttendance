import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _emailController.text = 'teacher@uni.edu';
    _passwordController.text = '123456';
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please enter email and password');
      return;
    }
    
    setState(() => _isLoading = true);
    
    final response = await ApiService.login(
      _emailController.text,
      _passwordController.text,
    );
    
    setState(() => _isLoading = false);
    
    if (response['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(response['user']));
      await prefs.setBool('isLoggedIn', true);
      await prefs.setInt('userId', response['user']['id']);
      
      _showSuccess('Welcome ${response['user']['name']}!');
      _navigateBasedOnRole(response['user']['role']);
    } else {
      _showError(response['message'] ?? 'Login failed');
    }
  }
  
  void _navigateBasedOnRole(String role) {
    switch (role) {
      case 'teacher':
        Navigator.pushReplacementNamed(context, '/teacher');
        break;
      case 'student':
        Navigator.pushReplacementNamed(context, '/student');
        break;
      case 'admin':
        Navigator.pushReplacementNamed(context, '/admin');
        break;
      default:
        _showError('Unknown user role');
    }
  }
  
  void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
  
  void _showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }
  
  void _copyCredentials(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
    _showSuccess('Credentials copied!');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.school,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Title
                  Text(
                    'Student Attendance',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  Text(
                    'University Management System',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Login Card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Email Field
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          
                          SizedBox(height: 16),
                          
                          // Password Field
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 24),
                          
                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: _isLoading
                                ? Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade700,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 3,
                                    ),
                                    child: Text(
                                      'LOGIN',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Demo Accounts
                  Card(
                    color: Colors.grey.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.account_circle, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'Demo Accounts',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 12),
                          
                          // Teacher
                          ListTile(
                            leading: Icon(Icons.person, color: Colors.blue),
                            title: Text('Teacher'),
                            subtitle: Text('teacher@uni.edu / 123456'),
                            trailing: IconButton(
                              icon: Icon(Icons.content_copy, size: 18),
                              onPressed: () => _copyCredentials('teacher@uni.edu', '123456'),
                            ),
                            dense: true,
                          ),
                          
                          // Student
                          ListTile(
                            leading: Icon(Icons.school, color: Colors.green),
                            title: Text('Student'),
                            subtitle: Text('student1@uni.edu / 123456'),
                            trailing: IconButton(
                              icon: Icon(Icons.content_copy, size: 18),
                              onPressed: () => _copyCredentials('student1@uni.edu', '123456'),
                            ),
                            dense: true,
                          ),
                          
                          // Admin
                          ListTile(
                            leading: Icon(Icons.admin_panel_settings, color: Colors.red),
                            title: Text('Admin'),
                            subtitle: Text('admin@uni.edu / 123456'),
                            trailing: IconButton(
                              icon: Icon(Icons.content_copy, size: 18),
                              onPressed: () => _copyCredentials('admin@uni.edu', '123456'),
                            ),
                            dense: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}