import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1/attendance-system/api";
  
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
  // GET CLASS ATTENDANCE
static Future<Map<String, dynamic>> getClassAttendance(int classId, {String? date}) async {
  try {
    final dateParam = date ?? DateTime.now().toIso8601String().split('T')[0];
    final url = Uri.parse('$baseUrl/attendance/class_view.php?class_id=$classId&date=$dateParam');
    
    print('🌐 [API] Fetching class attendance for class $classId on $dateParam');
    
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {"success": false, "message": "Server error"};
  } catch (e) {
    return {"success": false, "message": "Network error: $e"};
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
  print('🌐 [API] Fetching attendance for student $studentId');
  
  try {
    // IMPORTANT: For Flutter web, use 127.0.0.1 instead of localhost
    final url = Uri.parse('http://127.0.0.1/attendance-system/api/attendance/view.php?student_id=$studentId');
    print('📡 URL: $url');
    
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    print('📊 Response Status: ${response.statusCode}');
    print('📄 Response Body (first 500 chars): ${response.body.length > 500 ? response.body.substring(0, 500) + "..." : response.body}');
    
    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        print('✅ JSON Parsed - success: ${data['success']}');
        
        if (data['success'] == true) {
          final attendance = data['attendance'] ?? [];
          print('📈 Found ${attendance.length} attendance records');
          return attendance;
        } else {
          print('❌ API error: ${data['message']}');
          return [];
        }
      } catch (e) {
        print('❌ JSON Parse Error: $e');
        return [];
      }
    } else {
      print('❌ HTTP Error ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('❌ Network Exception: $e');
    return [];
  }
} 
  
  // MARK ATTENDANCE
static Future<Map<String, dynamic>> markAttendance({
  required int studentId,
  required int classId,
  required String status,
}) async {
  print('🎯 MARK ATTENDANCE API CALL:');
  print('   Student ID: $studentId');
  print('   Class ID: $classId');
  print('   Status: $status');
  
  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1/attendance-system/api/attendance/mark.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'student_id': studentId,
        'class_id': classId,
        'status': status,
      }),
    );
    
    print('📊 Mark Attendance Response:');
    print('   Status Code: ${response.statusCode}');
    print('   Body: ${response.body}');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {'success': false, 'message': 'Server error ${response.statusCode}'};
  } catch (e) {
    print('❌ Mark Attendance Error: $e');
    return {'success': false, 'message': 'Network error: $e'};
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