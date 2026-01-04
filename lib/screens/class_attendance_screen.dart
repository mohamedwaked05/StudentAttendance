import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ClassAttendanceScreen extends StatefulWidget {
  final int classId;
  final String className;
  
  const ClassAttendanceScreen({super.key, required this.classId, required this.className});
  
  @override
  _ClassAttendanceScreenState createState() => _ClassAttendanceScreenState();
}

class _ClassAttendanceScreenState extends State<ClassAttendanceScreen> {
  Map<String, dynamic>? _classData;
  List<dynamic> _students = [];
  bool _isLoading = true;
  String _selectedDate = DateTime.now().toIso8601String().split('T')[0];
  
  @override
  void initState() {
    super.initState();
    _loadClassAttendance();
  }
  
  Future<void> _loadClassAttendance() async {
    setState(() => _isLoading = true);
    
    final response = await ApiService.getClassAttendance(widget.classId, date: _selectedDate);
    
    if (response['success'] == true) {
      setState(() {
        _classData = response;
        _students = response['students'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load attendance: ${response['message']}')),
      );
    }
  }
  
  Future<void> _updateAttendance(int studentId, String status) async {
    final result = await ApiService.markAttendance(
      studentId: studentId,
      classId: widget.classId,
      status: status,
    );
    
    if (result['success'] == true) {
      _loadClassAttendance(); // Refresh data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance updated to $status')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${result['message']}')),
      );
    }
  }
  
  Widget _buildStatusChip(String status) {
    final isPresent = status == 'present';
    return Chip(
      label: Text(status.toUpperCase()),
      backgroundColor: isPresent ? Colors.green : Colors.red,
      labelStyle: TextStyle(color: Colors.white),
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
        title: Text(widget.className),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadClassAttendance,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
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
                        _buildStatItem('Total', '${_students.length}', Icons.people),
                        _buildStatItem('Present', '${_classData?['stats']['present'] ?? 0}', 
                            Icons.check_circle, color: Colors.green),
                        _buildStatItem('Absent', '${_classData?['stats']['absent'] ?? 0}', 
                            Icons.cancel, color: Colors.red),
                      ],
                    ),
                  ),
                ),
                
                // Date Selector
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.blue),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Attendance Date',
                            hintText: 'YYYY-MM-DD',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _selectedDate,
                          onChanged: (value) {
                            setState(() => _selectedDate = value);
                          },
                          onFieldSubmitted: (_) => _loadClassAttendance(),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _loadClassAttendance,
                        child: Text('Load'),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Student List Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text('Students (${_students.length})', style: TextStyle(fontWeight: FontWeight.bold)),
                      Spacer(),
                      Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 50),
                    ],
                  ),
                ),
                
                SizedBox(height: 8),
                
                // Student List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              student['student_name'][0].toUpperCase(),
                              style: TextStyle(color: Colors.blue.shade800),
                            ),
                          ),
                          title: Text(
                            student['student_name'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('ID: ${student['student_number'] ?? 'N/A'}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildStatusChip(student['attendance_status']),
                              SizedBox(width: 10),
                              PopupMenuButton<String>(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'present',
                                    child: Row(
                                      children: [
                                        Icon(Icons.check, color: Colors.green),
                                        SizedBox(width: 8),
                                        Text('Mark Present'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'absent',
                                    child: Row(
                                      children: [
                                        Icon(Icons.close, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Mark Absent'),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) => _updateAttendance(student['student_id'], value),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Mark All Students'),
              content: Text('Mark all students as present?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    for (var student in _students) {
                      await _updateAttendance(student['student_id'], 'present');
                    }
                  },
                  child: Text('Mark All Present'),
                ),
              ],
            ),
          );
        },
        icon: Icon(Icons.checklist),
        label: Text('Mark All Present'),
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}