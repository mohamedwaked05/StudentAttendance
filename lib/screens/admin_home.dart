import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _studentIdController = TextEditingController();
  String _selectedRole = 'student';
  bool _isSubmitting = false;
  String _message = '';
  bool _isSuccess = false;
  
  @override
  void initState() {
    super.initState();
    _studentIdController.text = 'S00${DateTime.now().millisecondsSinceEpoch % 100}';
  }
  
 Future<void> _addUser() async {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() {
    _isSubmitting = true;
    _message = '';
  });
  
  print('🆕 Creating new user...');
  print('   Name: ${_nameController.text}');
  print('   Email: ${_emailController.text}');
  print('   Role: $_selectedRole');
  print('   Student ID: ${_studentIdController.text}');
  
  final response = await ApiService.addUser(
    name: _nameController.text,
    email: _emailController.text,
    password: _passwordController.text,
    role: _selectedRole,
    studentId: _selectedRole == 'student' ? _studentIdController.text : null,
  );
  
  print('📊 Add User API Response:');
  print('   Success: ${response['success']}');
  print('   Message: ${response['message']}');
  print('   User ID: ${response['user_id']}');
  
  setState(() {
    _isSubmitting = false;
    _isSuccess = response['success'] == true;
    _message = response['message'];
  });
  
  if (response['success'] == true) {
    // IMPORTANT: Tell user to add this ID to the teacher's list
    if (_selectedRole == 'student') {
      _message += '\n\nIMPORTANT: Add student ID ${response['user_id']} to teacher\'s student list in teacher_home.dart';
      _isSuccess = true;
    }
    _clearForm();
  }
}
  
  void _clearForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _studentIdController.text = 'S00${DateTime.now().millisecondsSinceEpoch % 100}';
    _selectedRole = 'student';
  }
  
  Future<void> _logout() async {
    await ApiService.logout();
    Navigator.pushReplacementNamed(context, '/');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _clearForm,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('Admin User'),
              accountEmail: Text('admin@uni.edu'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings, color: Colors.red),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Add Users'),
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Manage Users'),
              onTap: () {
                // TODO: Add user management
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Add New User',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Add students, teachers, or other admins',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 30),
            
            // Success/Error Message
            if (_message.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: _isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isSuccess ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSuccess ? Icons.check_circle : Icons.error,
                      color: _isSuccess ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 10),
                    Expanded(child: Text(_message)),
                  ],
                ),
              ),
            
            // Add User Form
            Card(
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 6) {
                            return 'Minimum 6 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      
                      // Role Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.people),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'student',
                            child: Row(
                              children: [
                                Icon(Icons.school, color: Colors.green),
                                SizedBox(width: 8),
                                Text('Student'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'teacher',
                            child: Row(
                              children: [
                                Icon(Icons.person, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Teacher'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Row(
                              children: [
                                Icon(Icons.admin_panel_settings, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Admin'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedRole = value!);
                        },
                      ),
                      SizedBox(height: 15),
                      
                      // Student ID Field (only for students)
                      if (_selectedRole == 'student')
                        TextFormField(
                          controller: _studentIdController,
                          decoration: InputDecoration(
                            labelText: 'Student ID',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.badge),
                          ),
                          validator: (value) {
                            if (_selectedRole == 'student' && 
                                (value == null || value.isEmpty)) {
                              return 'Student ID is required';
                            }
                            return null;
                          },
                        ),
                      
                      if (_selectedRole == 'student') SizedBox(height: 15),
                      
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: _isSubmitting
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _addUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                ),
                                child: Text(
                                  'Add User',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 30),
            
            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Development Mode Info',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'In Development Mode, user data is simulated. '
                      'When backend connection is established, data will be saved to the database.',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}