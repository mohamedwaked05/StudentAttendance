class User {
  int id;
  String name;
  String email;
  String role;
  String? studentId;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.studentId,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'student',
      studentId: json['student_id']?.toString(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'student_id': studentId,
    };
  }
  
  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role)';
  }
}