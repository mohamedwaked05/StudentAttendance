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
  bool _isTestingConnection = false;
  String _connectionStatus = '';
  
  @override
  void initState() {
    super.initState();
    // Pre-fill for testing
    _emailController.text = 'teacher@uni.edu';
    _passwordController.text = '123456';
    _testBackendConnection();
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _testBackendConnection() async {
    setState(() => _isTestingConnection = true);
    
    final isConnected = await ApiService.testConnection();
    
    setState(() {
      _isTestingConnection = false;
      _connectionStatus = isConnected 
          ? '✅ Backend connected!' 
          : '❌ Cannot connect to backend. Check:\n• XAMPP is running\n• Correct IP in api_service.dart';
    });
  }
  
  Future<void> _login() async {
    // Basic validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please enter email and password');
      return;
    }
    
    if (!_emailController.text.contains('@')) {
      _showError('Please enter a valid email');
      return;
    }
    
    setState(() => _isLoading = true);
    
    final response = await ApiService.login(
      _emailController.text,
      _passwordController.text,
    );
    
    setState(() => _isLoading = false);
    
    if (response['success'] == true) {
      // Save user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(response['user']));
      await prefs.setBool('isLoggedIn', true);
      await prefs.setInt('userId', response['user']['id']);
      
      // Show success
      _showSuccess('Welcome ${response['user']['name']}!');
      
      // Navigate based on role
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
  
  void _showConnectionHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connection Help'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To fix connection issues:'),
            SizedBox(height: 10),
            Text('1. Open CMD and run: ipconfig'),
            Text('2. Find your "IPv4 Address"'),
            Text('3. Update lib/services/api_service.dart'),
            Text('4. Change baseUrl to:'),
            Text('   "http://YOUR_IP/attendance-system/api"'),
            SizedBox(height: 10),
            Text('For Android Emulator use:'),
            Text('   "http://10.0.2.2/attendance-system/api"'),
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
                  
                  // Connection Status
                  if (_connectionStatus.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _connectionStatus.contains('✅') 
                            ? Colors.green.shade50 
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _connectionStatus.contains('✅')
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _connectionStatus.contains('✅') 
                                ? Icons.check_circle 
                                : Icons.warning,
                            color: _connectionStatus.contains('✅')
                                ? Colors.green
                                : Colors.orange,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _connectionStatus,
                              style: TextStyle(
                                color: _connectionStatus.contains('✅')
                                    ? Colors.green.shade800
                                    : Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
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
                          
                          SizedBox(height: 16),
                          
                          // Test Connection Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _testBackendConnection,
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.blue),
                              ),
                              child: _isTestingConnection
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                        SizedBox(width: 10),
                                        Text('Testing Connection...'),
                                      ],
                                    )
                                  : Text('Test Backend Connection'),
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
                          
                          _buildDemoAccountRow('👨‍🏫 Teacher', 'teacher@uni.edu', '123456'),
                          _buildDemoAccountRow('👨‍🎓 Student', 'student1@uni.edu', '123456'),
                          _buildDemoAccountRow('👨‍💼 Admin', 'admin@uni.edu', '123456'),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Help Button
                  TextButton(
                    onPressed: _showConnectionHelp,
                    child: Text(
                      'Need help with connection?',
                      style: TextStyle(color: Colors.blue.shade700),
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
  
  Widget _buildDemoAccountRow(String role, String email, String password) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.blue.shade400,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text('Email: $email'),
                Text('Password: $password'),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.content_copy, size: 18),
            onPressed: () {
              _emailController.text = email;
              _passwordController.text = password;
              _showSuccess('Credentials copied!');
            },
            tooltip: 'Copy to form',
          ),
        ],
      ),
    );
  }
}