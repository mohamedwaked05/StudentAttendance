import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; // For TimeoutException
class ApiService {
  // IMPORTANT: Update this IP address!
  // Run `ipconfig` in CMD to find your IPv4 address
  // For emulator: use "10.0.2.2" for Android, "localhost" for iOS

  static const String baseUrl = "http://192.168.16.101/attendance-system/api";
  
  // Test if backend is reachable
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/../test.php'),
      ).timeout(Duration(seconds: 5));  // Fixed timeout syntax
      
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
  
  // Get current user ID from shared preferences
  static Future<int> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId') ?? 0;
  }
  
  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🔐 Attempting login for: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email.trim(),
          'password': password.trim(),
        }),
      ).timeout(Duration(seconds: 10));  // Added timeout
      
      print('📥 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Check:\n1. XAMPP is running\n2. Correct IP in api_service.dart'
      };
    } on http.ClientException {
      return {
        'success': false,
        'message': 'Cannot connect to server. Check backend is running.'
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Connection timeout. Server is not responding.'
      };
    } catch (e) {
      print('❌ Login error: $e');
      return {
        'success': false,
        'message': 'Error: $e'
      };
    }
  }
  
  // Get teacher's classes
  static Future<List<dynamic>> getTeacherClasses(int teacherId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/classes/list.php?teacher_id=$teacherId'),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['classes'] ?? [];
        }
      }
      return [];
    } on TimeoutException {
      print('Timeout getting classes');
      return [];
    } catch (e) {
      print('Error getting classes: $e');
      return [];
    }
  }
  
  // Get student attendance
  static Future<List<dynamic>> getStudentAttendance(int studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/attendance/view.php?student_id=$studentId'),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['attendance'] ?? [];
        }
      }
      return [];
    } on TimeoutException {
      print('Timeout getting attendance');
      return [];
    } catch (e) {
      print('Error getting attendance: $e');
      return [];
    }
  }
  
  // Mark attendance
  static Future<Map<String, dynamic>> markAttendance({
    required int studentId,
    required int classId,
    required String status,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/attendance/mark.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'student_id': studentId,
          'class_id': classId,
          'status': status,
          'attendance_date': DateTime.now().toIso8601String().split('T')[0],
        }),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Server error'};
    } on TimeoutException {
      return {'success': false, 'message': 'Request timeout'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // Add user (admin)
  static Future<Map<String, dynamic>> addUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? studentId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/add.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'student_id': studentId,
          'admin_key': 'admin123',
        }),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Server error'};
    } on TimeoutException {
      return {'success': false, 'message': 'Request timeout'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // Create class (teacher)
  static Future<Map<String, dynamic>> createClass({
    required String className,
    required int teacherId,
    String day = 'Monday',
    String time = '10:00',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/classes/create.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'class_name': className,
          'teacher_id': teacherId,
          'schedule_day': day,
          'schedule_time': '$time:00',
        }),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Server error'};
    } on TimeoutException {
      return {'success': false, 'message': 'Request timeout'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // Helper method to clear stored data (logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  
  // Helper method to get stored user
  static Future<Map<String, dynamic>?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) {
      try {
        return json.decode(userString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}