import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://localhost/attendance-system/api";
  
  // LOGIN
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection failed: $e'
      };
    }
  }
  
  // GET TEACHER CLASSES
  static Future<List<dynamic>> getTeacherClasses(int teacherId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/classes/list.php?teacher_id=$teacherId'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['classes'] ?? [];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  // GET STUDENT ATTENDANCE
  static Future<List<dynamic>> getStudentAttendance(int studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/attendance/view.php?student_id=$studentId'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['attendance'] ?? [];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  // MARK ATTENDANCE
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
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Server error'};
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }
  
  // ADD USER (ADMIN)
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
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Server error'};
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }
  
  // CREATE CLASS (TEACHER)
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
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Server error'};
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }
  
  // LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  
  // GET CURRENT USER ID
  static Future<int> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId') ?? 0;
  }
  
  // GET STORED USER
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